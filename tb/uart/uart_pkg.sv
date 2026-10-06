package uart_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*; import common_pkg::*;
  `include "uvm_macros.svh"
  localparam bit [15:0] A_CTRL='h00,A_BAUD='h04,A_TX='h08,A_RX='h0c,
    A_STATUS='h10,A_IRQ_EN='h14,A_IRQ_STATUS='h18,A_ERR_CLEAR='h1c;
  `include "uart_ral.svh"
  `include "uart_agent.svh"
  `include "uart_scoreboard.svh"
  `include "uart_env.svh"
  `include "uart_sequences.svh"
  `include "uart_tests.svh"
endpackage
