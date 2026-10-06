// Package assembly only. Each class is defined in its own matching .sv file.
package uart_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  import common_pkg::*;
  `include "uvm_macros.svh"
  localparam bit [15:0] A_CTRL='h00,A_BAUD='h04,A_TX='h08,A_RX='h0c,
    A_STATUS='h10,A_IRQ_EN='h14,A_IRQ_STATUS='h18,A_ERR_CLEAR='h1c;

  // Register model (dependency order).
  `include "ral/uart_ctrl_reg.sv"
  `include "ral/uart_baud_reg.sv"
  `include "ral/uart_tx_reg.sv"
  `include "ral/uart_rx_reg.sv"
  `include "ral/uart_status_reg.sv"
  `include "ral/uart_irq_en_reg.sv"
  `include "ral/uart_irq_status_reg.sv"
  `include "ral/uart_err_clear_reg.sv"
  `include "ral/uart_reg_block.sv"

  // Serial agent (dependency order).
  `include "uart_item.sv"
  `include "uart_cfg.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_config_tracker.sv"
  `include "uart_monitor.sv"
  `include "uart_agent.sv"

  // Checking and coverage (dependency order).
  `include "uart_scoreboard.sv"
  `include "uart_coverage.sv"
  `include "uart_reg_coverage.sv"

  // Environment (dependency order).
  `include "uart_virtual_sequencer.sv"
  `include "uart_env.sv"

  // Sequences (dependency order).
  `include "seq_lib/uart_send_seq.sv"
  `include "seq_lib/uart_base_vseq.sv"
  `include "seq_lib/uart_smoke_vseq.sv"
  `include "seq_lib/uart_ral_vseq.sv"
  `include "seq_lib/uart_formats_vseq.sv"
  `include "seq_lib/uart_random_vseq.sv"
  `include "seq_lib/uart_errors_vseq.sv"
  `include "seq_lib/uart_fifo_vseq.sv"
  `include "seq_lib/uart_reset_vseq.sv"

  // Tests (dependency order).
  `include "tests/uart_base_test.sv"
  `include "tests/uart_smoke_test.sv"
  `include "tests/uart_ral_test.sv"
  `include "tests/uart_formats_test.sv"
  `include "tests/uart_random_test.sv"
  `include "tests/uart_errors_test.sv"
  `include "tests/uart_fifo_test.sv"
  `include "tests/uart_reset_test.sv"
endpackage
