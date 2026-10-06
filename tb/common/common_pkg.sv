// Package assembly only. Each class is defined in its own matching .svh file.
package common_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Reusable APB components (dependency order).
  `include "apb_item.svh"
  `include "apb_cfg.svh"
  `include "apb_sequencer.svh"
  `include "apb_driver.svh"
  `include "apb_monitor.svh"
  `include "apb_coverage.svh"
  `include "apb_agent.svh"
  `include "apb_reg_adapter.svh"
  `include "apb_access_seq.svh"

  // Reusable environment and test components (dependency order).
  `include "ordered_scoreboard.svh"
  `include "base_virtual_sequencer.svh"
  `include "base_env.svh"
  `include "base_test.svh"
endpackage
