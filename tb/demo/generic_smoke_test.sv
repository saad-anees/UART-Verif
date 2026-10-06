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
