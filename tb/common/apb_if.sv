// APB3 subset: 16-bit byte address, 32-bit data, no strobes.
interface apb_if(input logic pclk);
  timeunit 1ns; timeprecision 1ps;
  logic presetn = 0;
  logic psel = 0, penable = 0, pwrite = 0;
  logic [15:0] paddr = 0;
  logic [31:0] pwdata = 0;
  logic [31:0] prdata;
  logic pready, pslverr;
  // Drive on falling edges. Sample completion on rising edges, before NBA.
  // This deliberately avoids DUT/testbench races without clocking blocks.
  a_access_has_select: assert property (@(posedge pclk) disable iff(!presetn)
      penable |-> psel) else $error("APB enable without select");
  a_setup_to_access: assert property (@(posedge pclk) disable iff(!presetn)
      psel && !penable |=> psel && penable && $stable({paddr,pwrite,pwdata}))
      else $error("APB setup not followed by stable access");
  a_wait_stable: assert property (@(posedge pclk) disable iff(!presetn)
      psel && penable && !pready |=> psel && penable && $stable({paddr,pwrite,pwdata}))
      else $error("APB changed during wait state");
  a_known_response: assert property (@(posedge pclk) disable iff(!presetn)
      psel && penable && pready |-> !$isunknown({pslverr,prdata}))
      else $error("Unknown APB response");
endinterface
