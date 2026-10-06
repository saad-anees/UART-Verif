module tb_top;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*; import uart_pkg::*;
  bit clk=0;
  always #5ns clk=~clk; // 100 MHz; scoreboard clock_period must match
  apb_if bus(clk);
  uart_if serial(clk);
  assign serial.rst_n=bus.presetn;
  uart_apb #(.RX_DEPTH(4)) dut(
    .clk(clk),.rst_n(bus.presetn),.psel(bus.psel),.penable(bus.penable),
    .pwrite(bus.pwrite),.paddr(bus.paddr),.pwdata(bus.pwdata),
    .prdata(bus.prdata),.pready(bus.pready),.pslverr(bus.pslverr),
    .rx(serial.rx),.tx(serial.tx),.irq(serial.irq));
  initial begin repeat(5) @(negedge clk); bus.presetn=1; end
  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top.env","bus_vif",bus);
    uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top.env","uart_vif",serial);
    run_test();
  end
endmodule
