// Simulator-independent RTL test. This supplements, never replaces, UVM runs.
module rtl_smoke;
  timeunit 1ns; timeprecision 1ps;
  bit clk=0; always #5ns clk=~clk;
  logic rst_n=0,psel=0,penable=0,pwrite=0,rx=1;
  logic [15:0] paddr=0;
  logic [31:0] pwdata=0,prdata;
  logic pready,pslverr,tx,irq;
  int checks=0;
  uart_apb dut(.*);
  task ticks(int n); repeat(n) @(negedge clk); endtask
  task access(bit wr,bit[15:0] addr,bit[31:0] data,output logic[31:0] got,input bit err=0);
    @(negedge clk); psel=1; penable=0; pwrite=wr; paddr=addr; pwdata=data;
    @(negedge clk); penable=1;
    @(posedge clk);
    if(pready!==1 || pslverr!==err) $fatal(1,"APB response addr=%h err=%b expected=%b",addr,pslverr,err);
    got=prdata; checks++;
    @(negedge clk); psel=0;penable=0;
  endtask
  task wr(bit[15:0] addr,bit[31:0] data,bit err=0);
    logic[31:0] got; access(1,addr,data,got,err);
  endtask
  task expect_reg(bit[15:0] addr,bit[31:0] exp);
    logic[31:0] got; access(0,addr,0,got);
    if(got!==exp) $fatal(1,"Read %h got=%h expected=%h",addr,got,exp);
  endtask
  task config_uart(int div,bit pe,bit odd,bit stop2);
    wr(0,0); wr(4,div); wr(0,{28'b0,stop2,odd,pe,1'b1});
  endtask
  task send_rx(bit[7:0] data,int div,bit pe,bit odd,bit stop2,bit badp=0,bit badf=0);
    @(negedge clk); rx=0;ticks(div);
    for(int i=0;i<8;i++) begin rx=data[i];ticks(div);end
    if(pe) begin rx=(^data)^odd^badp;ticks(div);end
    rx=!badf;ticks(div);if(stop2) ticks(div);
    rx=1;ticks(2*div);
  endtask
  task check_tx(bit[7:0] data,int div,bit pe,bit odd,bit stop2);
    @(negedge tx);ticks(div/2);
    if(tx!==0) $fatal(1,"TX start");
    for(int i=0;i<8;i++) begin
      ticks(div); if(tx!==data[i]) $fatal(1,"TX data bit %0d got %b expected %b",i,tx,data[i]);
    end
    if(pe) begin ticks(div);if(tx!==((^data)^odd)) $fatal(1,"TX parity");end
    ticks(div);if(tx!==1) $fatal(1,"TX stop1");
    if(stop2) begin ticks(div);if(tx!==1) $fatal(1,"TX stop2");end
    ticks(div);checks++;
  endtask
  initial begin
    logic[31:0] got;
    int divisors[3]='{8,16,31};
    bit[7:0] patterns[4]='{'h00,'hff,'h55,'haa};
    ticks(5);rst_n=1;ticks(2);
    expect_reg(0,0);expect_reg(4,16);expect_reg('h10,0);
    wr(4,3,1);wr(4,65536,1);wr('h100,0,1);wr('h10,0,1);wr('h08,1,1);
    access(0,'h0c,0,got,1);access(0,'h08,0,got,1);
    foreach(divisors[d]) for(int p=0;p<3;p++) for(int s=0;s<2;s++) begin
      config_uart(divisors[d],p!=0,p==2,s!=0);
      foreach(patterns[i]) begin
        fork
          check_tx(patterns[i],divisors[d],p!=0,p==2,s!=0);
          wr(8,patterns[i]);
          send_rx(~patterns[i],divisors[d],p!=0,p==2,s!=0);
        join
        expect_reg('hc,8'(~patterns[i]));expect_reg('h10,0);
      end
    end
    // Overflow preserves oldest four bytes and raises a sticky IRQ cause.
    config_uart(16,0,0,0);wr('h14,3);
    repeat(3) begin
      for(int i=0;i<6;i++) send_rx(8'(i+32),16,0,0,0);
      expect_reg('h10,'h12);expect_reg('h18,3);
      if(!irq) $fatal(1,"Missing overflow IRQ");
      for(int i=0;i<4;i++) expect_reg('hc,i+32);
      expect_reg('h10,'h10);wr('h1c,'h10);
      if(irq) $fatal(1,"IRQ did not clear");
    end
    // Bad parity and stop(s), all error combinations and selective W1C.
    for(int s=0;s<2;s++) for(int mode=1;mode<4;mode++) begin
      config_uart(16,1,1,s!=0);
      send_rx('ha6,16,1,1,s!=0,mode[0],mode[1]);
      expect_reg('h10,2 | (mode[0]?4:0) | (mode[1]?8:0));
      expect_reg('hc,'ha6);wr('h1c,'h1c);expect_reg('h10,0);
    end
    // Busy writes are rejected, then reset aborts TX and clears RX/IRQ.
    config_uart(31,1,1,1);send_rx('h65,31,1,1,1,1,0);
    wr(8,'h55);wr(8,'haa,1);wr(0,0,1);wr(4,16,1);
    ticks(20);rst_n=0;ticks(5);rst_n=1;ticks(5);
    expect_reg(0,0);expect_reg(4,16);expect_reg('h10,0);expect_reg('h14,0);
    if(tx!==1 || irq!==0) $fatal(1,"Reset outputs");
    config_uart(16,0,0,0);
    // False start shorter than half bit must not enqueue a byte.
    @(negedge clk);rx=0;ticks(2);rx=1;ticks(30);expect_reg('h10,0);
    send_rx('h42,16,0,0,0);expect_reg('hc,'h42);
    $display("RTL_TEST_PASSED checks=%0d",checks);$finish;
  end
  initial begin #10ms; $fatal(1,"RTL watchdog expired"); end
endmodule
