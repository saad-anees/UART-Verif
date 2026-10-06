// Package assembly only. Each class is defined in its own matching .sv file.
package demo_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  import common_pkg::*;
  `include "uvm_macros.svh"

  // Scratch register demo (dependency order).
  `include "scratch_reg.sv"
  `include "demo_block.sv"
  `include "demo_env.sv"
  `include "generic_smoke_test.sv"
endpackage
