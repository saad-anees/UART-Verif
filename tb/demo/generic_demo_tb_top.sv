module demo_top;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*; import demo_pkg::*;
  bit clk=0;
  always #5ns clk=~clk;
  apb_if bus(clk);
  demo_regs dut(clk,bus.presetn,bus.psel,bus.penable,bus.pwrite,
    bus.paddr,bus.pwdata,bus.prdata,bus.pready,bus.pslverr);
  initial begin repeat(5) @(negedge clk); bus.presetn=1; end
  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top.env","bus_vif",bus);
    run_test();
  end
endmodule
