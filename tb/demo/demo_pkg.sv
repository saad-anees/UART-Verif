package demo_pkg;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*; import common_pkg::*;
  `include "uvm_macros.svh"
  class scratch_reg extends uvm_reg;
    `uvm_object_utils(scratch_reg)
    uvm_reg_field data;
    function new(string n="scratch_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
    function void build();
      data=uvm_reg_field::type_id::create("data");
      data.configure(this,32,0,"RW",0,0,1,1,0);
    endfunction
  endclass
  class demo_block extends uvm_reg_block;
    `uvm_object_utils(demo_block)
    scratch_reg scratch;
    function new(string n="demo_block"); super.new(n,UVM_NO_COVERAGE); endfunction
    function void build();
      default_map=create_map("apb",0,4,UVM_LITTLE_ENDIAN,1);
      scratch=scratch_reg::type_id::create("scratch");
      scratch.configure(this); scratch.build(); default_map.add_reg(scratch,0,"RW");
      lock_model(); reset();
    endfunction
  endclass
  class demo_env extends base_env;
    `uvm_component_utils(demo_env)
    function new(string n,uvm_component p); super.new(n,p); endfunction
    function uvm_reg_block create_register_model();
      demo_block b=demo_block::type_id::create("rm"); b.build(); return b;
    endfunction
  endclass
  class generic_smoke_test extends base_test;
    `uvm_component_utils(generic_smoke_test)
    demo_env env;
    function new(string n,uvm_component p); super.new(n,p); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); env=demo_env::type_id::create("env",this);
    endfunction
    task run_phase(uvm_phase phase);
      demo_block b; uvm_status_e status; uvm_reg_data_t v;
      phase.raise_objection(this);
      wait(env.bus_cfg.vif.presetn); @(negedge env.bus_cfg.vif.pclk);
      if(!$cast(b,env.rm)) `uvm_fatal("CAST","Expected demo_block")
      b.scratch.mirror(status,UVM_CHECK);
      if(status!=UVM_IS_OK) `uvm_error("RAL","Reset read failed")
      repeat(32) begin
        v={$urandom}; b.scratch.write(status,v);
        if(status!=UVM_IS_OK) `uvm_error("RAL","Write failed")
        b.scratch.mirror(status,UVM_CHECK);
        if(status!=UVM_IS_OK) `uvm_error("RAL","Read failed")
      end
      phase.drop_objection(this);
    endtask
  endclass
endpackage
