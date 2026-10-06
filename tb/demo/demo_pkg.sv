// Package assembly only. Each class is defined in its own matching .svh file.
package demo_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  import common_pkg::*;
  `include "uvm_macros.svh"

  // Scratch register demo (dependency order).
  `include "scratch_reg.svh"
  `include "demo_block.svh"
  `include "demo_env.svh"
  `include "generic_smoke_test.svh"
endpackage
