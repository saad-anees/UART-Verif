class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)
  uart_env env;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); env=uart_env::type_id::create("env",this);
  endfunction
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
    uvm_top.set_timeout(20ms,0);
  endfunction
  function void report_phase(uvm_phase phase);
    uvm_report_server s=uvm_report_server::get_server();
    if(s.get_severity_count(UVM_ERROR)==0 && s.get_severity_count(UVM_FATAL)==0)
      `uvm_info("TEST_RESULT","TEST PASSED",UVM_NONE)
    else `uvm_info("TEST_RESULT","TEST FAILED",UVM_NONE)
  endfunction
  virtual function uart_base_vseq create_sequence();
    return uart_smoke_vseq::type_id::create("vseq");
  endfunction
  task run_phase(uvm_phase phase);
    uart_base_vseq seq;
    phase.raise_objection(this);
    wait(env.bus_cfg.vif.presetn); repeat(4) @(negedge env.bus_cfg.vif.pclk);
    seq=create_sequence(); seq.start(env.uart_vsqr);
    // Deterministic drain and bounds: no outstanding serial TX may remain.
    seq.wait_tx_idle(); repeat(8) @(negedge env.bus_cfg.vif.pclk);
    phase.drop_objection(this);
  endtask
endclass
