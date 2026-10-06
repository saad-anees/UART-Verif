`uvm_analysis_imp_decl(_bus)
`uvm_analysis_imp_decl(_serial)

// Independent architectural model: successful bus TX writes create expected
// frames; observed RX frames create FIFO entries. No internal DUT signals used.
class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)
  uvm_analysis_imp_bus #(apb_item,uart_scoreboard) bus_in;
  uvm_analysis_imp_serial #(uart_item,uart_scoreboard) serial_in;
  uart_cfg cfg;
  uart_item tx_expected[$];
  bit [7:0] rx_expected[$];
  bit [3:0] control;
  int unsigned baud=16;
  bit [1:0] irq_mask;
  bit pe,fe,oe;
  time tx_deadline,rx_settle_deadline;
  time clock_period=10ns;
  int unsigned tx_compared,rx_compared,rx_seen,overflows,bus_errors;
  int unsigned reset_tx_discarded,reset_rx_discarded;
  function new(string n,uvm_component p);
    super.new(n,p); bus_in=new("bus_in",this); serial_in=new("serial_in",this);
  endfunction
  function void reset_model();
    reset_tx_discarded+=tx_expected.size(); reset_rx_discarded+=rx_expected.size();
    tx_expected.delete(); rx_expected.delete();
    control=0; baud=16; irq_mask=0; pe=0; fe=0; oe=0; tx_deadline=0; rx_settle_deadline=0;
  endfunction
  task run_phase(uvm_phase phase);
    forever begin wait(!cfg.vif.rst_n); reset_model(); @(posedge cfg.vif.rst_n); end
  endtask
  function void check_value(string what,bit[31:0] got,bit[31:0] exp);
    if(got!==exp) `uvm_error("SB",$sformatf("%s got=%08h expected=%08h",what,got,exp))
  endfunction
  function void write_bus(apb_item t);
    uart_item e;
    bit [7:0] rx_byte;
    bit busy;
    busy=(tx_deadline!=0 && $time<=tx_deadline);
    if(t.error) begin bus_errors++; return; end
    if(t.write) case(t.addr)
      A_CTRL: control=t.data[3:0];
      A_BAUD: baud=t.data[15:0];
      A_IRQ_EN: irq_mask=t.data[1:0];
      A_ERR_CLEAR: begin
        if(t.data[2]) pe=0; if(t.data[3]) fe=0; if(t.data[4]) oe=0;
      end
      A_TX: begin
        e=uart_item::type_id::create("expected_tx"); e.data=t.data[7:0];
        e.parity_en=control[1]; e.odd=control[2]; e.stop2=control[3]; e.divisor=baud;
        tx_expected.push_back(e);
        tx_deadline=$time+(10+int'(control[1])+int'(control[3]))*baud*clock_period;
      end
      default: `uvm_error("SB","Unexpected successful register write")
    endcase
    else case(t.addr)
      A_CTRL: check_value("CTRL",t.data,{28'b0,control});
      A_BAUD: check_value("BAUD",t.data,baud);
      A_IRQ_EN: check_value("IRQ_EN",t.data,{30'b0,irq_mask});
      A_STATUS: begin
        // RX uses a two-flop synchronizer. The pin monitor sees stop center
        // slightly earlier than RTL. Do not assert cycle-exact RX visibility
        // in this four-clock window; stable reads still compare every bit.
        if($time < rx_settle_deadline)
          check_value("STATUS (RX settling)",t.data & 32'hffffffe1,{31'b0,busy});
        else check_value("STATUS",t.data,{27'b0,oe,fe,pe,(rx_expected.size()!=0),busy});
      end
      A_IRQ_STATUS: if($time >= rx_settle_deadline)
        check_value("IRQ_STATUS",t.data,{30'b0,(pe|fe|oe),(rx_expected.size()!=0)});
      A_RX: begin
        if(rx_expected.size()==0) `uvm_error("SB_RX","Unexpected RX read success")
        else begin
          rx_byte=rx_expected.pop_front(); check_value("RXDATA",t.data,{24'b0,rx_byte});
          rx_compared++;
        end
      end
      default: `uvm_error("SB","Unexpected successful register read")
    endcase
  endfunction
  function void write_serial(uart_item t);
    uart_item e;
    if(t.is_tx) begin
      if(tx_expected.size()==0) `uvm_error("SB_TX","Serial TX without accepted bus write")
      else begin
        e=tx_expected.pop_front();
        if(t.data!==e.data || t.parity_error || t.frame_error ||
           t.parity_en!=e.parity_en || t.odd!=e.odd || t.stop2!=e.stop2)
          `uvm_error("SB_TX",$sformatf("TX expected %02h got %02h parity_error=%0b frame_error=%0b",
            e.data,t.data,t.parity_error,t.frame_error))
        tx_compared++;
      end
    end else begin
      rx_seen++; rx_settle_deadline=$time+4*clock_period;
      if(rx_expected.size()<4) rx_expected.push_back(t.data);
      else begin oe=1; overflows++; end
      pe|=t.parity_error; fe|=t.frame_error;
    end
  endfunction
  function void check_phase(uvm_phase phase);
    if(tx_expected.size()!=0 || rx_expected.size()!=0)
      `uvm_error("SB_DRAIN",$sformatf("Unmatched TX=%0d unread RX=%0d",tx_expected.size(),rx_expected.size()))
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("SB_COUNTS",$sformatf("TX checked=%0d RX checked=%0d RX observed=%0d overflow=%0d APB errors=%0d reset discarded TX/RX=%0d/%0d",
      tx_compared,rx_compared,rx_seen,overflows,bus_errors,reset_tx_discarded,reset_rx_discarded),UVM_LOW)
  endfunction
endclass

class uart_coverage extends uvm_subscriber #(uart_item);
  `uvm_component_utils(uart_coverage)
  covergroup frames with function sample(bit tx,bit [7:0] data,bit parity_en,
      bit odd,bit stop2,int unsigned divisor,bit pe,bit fe);
    option.per_instance=1;
    direction: coverpoint tx;
    payload: coverpoint data {
      bins zero={8'h00}; bins ones={8'hff}; bins alternating[]={8'h55,8'haa};
      bins walking_one[]={1,2,4,8,16,32,64,128};
      bins other=default;
    }
    parity_mode: coverpoint (parity_en ? (odd ? 2 : 1) : 0) {
      bins none={0}; bins even_p={1}; bins odd_p={2};
    }
    stops: coverpoint stop2;
    baud: coverpoint divisor { bins fast={8}; bins nominal={16}; bins odd_div={31}; bins other=default; }
    errors: coverpoint {pe,fe} { bins clean={0}; bins parity_only={2}; bins frame_only={1}; bins both={3}; }
    formats: cross direction,parity_mode,stops,baud;
    rx_errors: cross direction,errors {
      ignore_bins tx_injected=binsof(direction) intersect {1} && binsof(errors) intersect {1,2,3};
    }
  endgroup
  function new(string n,uvm_component p); super.new(n,p); frames=new; endfunction
  function void write(uart_item t);
    frames.sample(t.is_tx,t.data,t.parity_en,t.odd,t.stop2,t.divisor,t.parity_error,t.frame_error);
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("COVERAGE",$sformatf("UART frame instance coverage %.2f%%",frames.get_inst_coverage()),UVM_LOW)
  endfunction
endclass

class uart_reg_coverage extends uvm_subscriber #(apb_item);
  `uvm_component_utils(uart_reg_coverage)
  covergroup registers with function sample(bit wr,bit[15:0] addr,bit err,bit[31:0] data);
    option.per_instance=1;
    address: coverpoint addr { bins regs[]={0,4,8,12,16,20,24,28}; bins invalid=default; }
    direction: coverpoint wr;
    response: coverpoint err;
    accesses: cross address,direction,response;
    flags: coverpoint data[4:0] iff(!wr && addr==A_STATUS && !err) {
      bins idle={0}; bins tx_busy={1}; bins rx_ready={2};
      bins parity_flag[]={[4:7]}; bins framing_flag[]={[8:15]}; bins overrun_flag[]={[16:31]};
    }
  endgroup
  function new(string n,uvm_component p); super.new(n,p); registers=new; endfunction
  function void write(apb_item t); registers.sample(t.write,t.addr,t.error,t.data); endfunction
endclass
