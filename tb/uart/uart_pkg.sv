// Package assembly only. Each class is defined in its own matching .svh file.
package uart_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  import common_pkg::*;
  `include "uvm_macros.svh"
  localparam bit [15:0] A_CTRL='h00,A_BAUD='h04,A_TX='h08,A_RX='h0c,
    A_STATUS='h10,A_IRQ_EN='h14,A_IRQ_STATUS='h18,A_ERR_CLEAR='h1c;

  // Register model (dependency order).
  `include "uart_ctrl_reg.svh"
  `include "uart_baud_reg.svh"
  `include "uart_tx_reg.svh"
  `include "uart_rx_reg.svh"
  `include "uart_status_reg.svh"
  `include "uart_irq_en_reg.svh"
  `include "uart_irq_status_reg.svh"
  `include "uart_err_clear_reg.svh"
  `include "uart_reg_block.svh"

  // Serial agent (dependency order).
  `include "uart_item.svh"
  `include "uart_cfg.svh"
  `include "uart_sequencer.svh"
  `include "uart_driver.svh"
  `include "uart_config_tracker.svh"
  `include "uart_monitor.svh"
  `include "uart_agent.svh"

  // Checking and coverage (dependency order).
  `include "uart_scoreboard.svh"
  `include "uart_coverage.svh"
  `include "uart_reg_coverage.svh"

  // Environment (dependency order).
  `include "uart_virtual_sequencer.svh"
  `include "uart_env.svh"

  // Sequences (dependency order).
  `include "uart_send_seq.svh"
  `include "uart_base_vseq.svh"
  `include "uart_smoke_vseq.svh"
  `include "uart_ral_vseq.svh"
  `include "uart_formats_vseq.svh"
  `include "uart_random_vseq.svh"
  `include "uart_errors_vseq.svh"
  `include "uart_fifo_vseq.svh"
  `include "uart_reset_vseq.svh"

  // Tests (dependency order).
  `include "uart_base_test.svh"
  `include "uart_smoke_test.svh"
  `include "uart_ral_test.svh"
  `include "uart_formats_test.svh"
  `include "uart_random_test.svh"
  `include "uart_errors_test.svh"
  `include "uart_fifo_test.svh"
  `include "uart_reset_test.svh"
endpackage
