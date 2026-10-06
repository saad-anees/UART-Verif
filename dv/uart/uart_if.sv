interface uart_if(input logic clk);
  timeunit 1ns; timeprecision 1ps;
  logic rst_n;
  logic rx=1;
  logic tx,irq;
  a_outputs_known: assert property (@(posedge clk) disable iff(!rst_n)
    !$isunknown({tx,irq})) else $error("Unknown UART output");
  a_reset_outputs: assert property (@(posedge clk)
    !rst_n |-> tx && !irq) else $error("UART reset outputs incorrect");
endinterface
