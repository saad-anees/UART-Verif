// Package assembly only. Each class is defined in its own matching .sv file.
package common_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Reusable APB components (dependency order).
  `include "apb_item.sv"
  `include "apb_cfg.sv"
  `include "apb_sequencer.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_coverage.sv"
  `include "apb_agent.sv"
  `include "apb_reg_adapter.sv"
  `include "seq_lib/apb_access_seq.sv"

  // Reusable environment and test components (dependency order).
  `include "ordered_scoreboard.sv"
  `include "base_virtual_sequencer.sv"
  `include "base_env.sv"
  `include "base_test.sv"
endpackage
