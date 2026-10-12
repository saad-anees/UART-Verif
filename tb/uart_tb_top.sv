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
`ifdef UART_FSDB
  // Compiled only for the VCS/Verdi flow; ordinary VCS and Questa need no FSDB PLI.
  initial begin
    string fsdb_file;
    if ($test$plusargs("UART_FSDB")) begin
      if (!$value$plusargs("FSDB_FILE=%s",fsdb_file)) fsdb_file="uart.fsdb";
      $fsdbDumpfile(fsdb_file);
      $fsdbDumpvars(0,tb_top,"+all"); // DUT, APB/serial interfaces and unpacked arrays
    end
  end
`endif
  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top.env","bus_vif",bus);
    uvm_config_db#(virtual uart_if)::set(null,"uvm_test_top.env","uart_vif",serial);
    run_test();
  end
endmodule
