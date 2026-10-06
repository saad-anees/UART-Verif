// Original teaching UART, MIT licensed. APB3 / 8 data bits / RX FIFO depth 4.
// Configure only while idle. BAUD counts peripheral clocks per serial bit.
module uart_apb # (parameter int RX_DEPTH=4) (
  input logic clk, rst_n,
  input logic psel, penable, pwrite,
  input logic [15:0] paddr,
  input logic [31:0] pwdata,
  output logic [31:0] prdata,
  output logic pready, pslverr,
  input logic rx,
  output logic tx, irq
);
  timeunit 1ns; timeprecision 1ps;
  localparam logic [15:0] CTRL='h00, BAUD='h04, TXDATA='h08,
    RXDATA='h0c, STATUS='h10, IRQ_EN='h14, IRQ_STATUS='h18, ERR_CLEAR='h1c;
  logic [3:0] ctrl;
  logic [15:0] divisor;
  logic [1:0] irq_en;
  logic parity_error, framing_error, overrun_error;
  logic tx_busy;
  logic [11:0] tx_shift;
  int unsigned tx_count, tx_left;
  logic rx_meta, rx_sync;
  typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP1, STOP2} rx_state_t;
  rx_state_t rx_state;
  int unsigned rx_count, rx_bit;
  logic [7:0] rx_shift;
  logic rx_parity_bad, rx_frame_bad;
  logic [7:0] fifo[RX_DEPTH];
  int unsigned rd_ptr,wr_ptr,used;
  logic access_ok, push, pop;
  logic [11:0] next_frame;
  int unsigned frame_bits;
  logic [1:0] irq_status;
  assign pready=1'b1;
  assign tx=tx_busy ? tx_shift[0] : 1'b1;
  assign irq_status={parity_error|framing_error|overrun_error,(used!=0)};
  assign irq=|(irq_en & irq_status);
  // Push at the center of the final stop bit. Error frames are retained.
  assign push=ctrl[0] && rx_count==0 &&
    ((rx_state==STOP1 && !ctrl[3]) || rx_state==STOP2);
  assign pop=access_ok && !pwrite && paddr==RXDATA;
  always_comb begin
    prdata=0; pslverr=0;
    case(paddr)
      CTRL: prdata={28'b0,ctrl};
      BAUD: prdata={16'b0,divisor};
      RXDATA: if(used!=0) prdata={24'b0,fifo[rd_ptr]};
      STATUS: prdata={27'b0,overrun_error,framing_error,parity_error,(used!=0),tx_busy};
      IRQ_EN: prdata={30'b0,irq_en};
      IRQ_STATUS: prdata={30'b0,irq_status};
      default: prdata=0;
    endcase
    if(psel && penable) begin
      case(paddr)
        CTRL,BAUD: pslverr=pwrite &&
          (tx_busy || rx_state!=IDLE || (paddr==BAUD && (pwdata<4 || pwdata>65535)));
        TXDATA: pslverr=!pwrite || !ctrl[0] || tx_busy;
        RXDATA: pslverr=pwrite || used==0;
        STATUS,IRQ_STATUS: pslverr=pwrite;
        IRQ_EN: pslverr=0;
        ERR_CLEAR: pslverr=!pwrite;
        default: pslverr=1;
      endcase
    end
  end
  assign access_ok=psel && penable && pready && !pslverr;
  always_comb begin
    next_frame='1; next_frame[0]=0; next_frame[8:1]=pwdata[7:0];
    frame_bits=10;
    if(ctrl[1]) begin
      next_frame[9]=(^pwdata[7:0]) ^ ctrl[2]; frame_bits++;
    end
    if(ctrl[3]) frame_bits++;
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin rx_meta<=1; rx_sync<=1; end
    else begin rx_meta<=rx; rx_sync<=rx_meta; end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      ctrl<=0; divisor<=16; irq_en<=0;
      tx_busy<=0; tx_shift<='1; tx_count<=0; tx_left<=0;
      rx_state<=IDLE; rx_count<=0; rx_bit<=0; rx_shift<=0;
      rx_parity_bad<=0; rx_frame_bad<=0;
      parity_error<=0; framing_error<=0; overrun_error<=0;
      rd_ptr<=0; wr_ptr<=0; used<=0;
    end else begin
      if(access_ok && pwrite) begin
        case(paddr)
          CTRL: ctrl<=pwdata[3:0];
          BAUD: divisor<=pwdata[15:0];
          IRQ_EN: irq_en<=pwdata[1:0];
          ERR_CLEAR: begin
            if(pwdata[2]) parity_error<=0;
            if(pwdata[3]) framing_error<=0;
            if(pwdata[4]) overrun_error<=0;
          end
          default: ;
        endcase
      end
      if(access_ok && pwrite && paddr==TXDATA) begin
        tx_shift<=next_frame; tx_count<=int'(divisor)-1;
        tx_left<=frame_bits; tx_busy<=1;
      end else if(tx_busy) begin
        if(tx_count==0) begin
          tx_shift<={1'b1,tx_shift[11:1]}; tx_count<=int'(divisor)-1;
          if(tx_left==1) begin tx_busy<=0; tx_left<=0; end
          else tx_left<=tx_left-1;
        end else tx_count<=tx_count-1;
      end
      if(!ctrl[0]) begin rx_state<=IDLE; rx_count<=0; end
      else case(rx_state)
        IDLE: if(!rx_sync) begin
          rx_state<=START; rx_count<=(int'(divisor)/2)-1;
          rx_parity_bad<=0; rx_frame_bad<=0;
        end
        START: if(rx_count!=0) rx_count<=rx_count-1;
          else if(rx_sync) rx_state<=IDLE; // Reject false start.
          else begin rx_state<=DATA; rx_count<=int'(divisor)-1; rx_bit<=0; end
        DATA: if(rx_count!=0) rx_count<=rx_count-1;
          else begin
            rx_shift[rx_bit]<=rx_sync; rx_count<=int'(divisor)-1;
            if(rx_bit==7) rx_state<=ctrl[1] ? PARITY : STOP1;
            else rx_bit<=rx_bit+1;
          end
        PARITY: if(rx_count!=0) rx_count<=rx_count-1;
          else begin
            rx_parity_bad<=(rx_sync != ((^rx_shift)^ctrl[2]));
            rx_state<=STOP1; rx_count<=int'(divisor)-1;
          end
        STOP1: if(rx_count!=0) rx_count<=rx_count-1;
          else begin
            rx_frame_bad<=!rx_sync;
            if(ctrl[3]) begin rx_state<=STOP2; rx_count<=int'(divisor)-1; end
            else rx_state<=IDLE;
          end
        STOP2: if(rx_count!=0) rx_count<=rx_count-1;
          else rx_state<=IDLE;
        default: rx_state<=IDLE;
      endcase
      if(pop) rd_ptr<=(rd_ptr+1)%RX_DEPTH;
      if(push) begin
        // A coincident pop frees space even when the FIFO was full.
        if(used<RX_DEPTH || pop) begin
          fifo[wr_ptr]<=rx_shift; wr_ptr<=(wr_ptr+1)%RX_DEPTH;
        end else overrun_error<=1;
        if(rx_parity_bad) parity_error<=1;
        if(!rx_sync || (rx_state==STOP2 && rx_frame_bad)) framing_error<=1;
      end
      case({push && (used<RX_DEPTH || pop),pop})
        2'b10: used<=used+1;
        2'b01: used<=used-1;
        default: ;
      endcase
    end
  end
endmodule
