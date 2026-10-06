// Reusable ordered comparator. Specialize T and override compare_items for
// protocols with tolerance/masking. Out-of-order protocols need an ID matcher.
class ordered_scoreboard #(type T=apb_item) extends uvm_scoreboard;
  `uvm_component_param_utils(ordered_scoreboard #(T))
  uvm_tlm_analysis_fifo #(T) expected, actual;
  int unsigned compared;
  bit pending_expected;
  function new(string n, uvm_component p);
    super.new(n,p); expected=new("expected",this); actual=new("actual",this);
  endfunction
  virtual function bit compare_items(T e,T a); return e.compare(a); endfunction
  task run_phase(uvm_phase phase);
    T e,a;
    forever begin
      expected.get(e); pending_expected=1; actual.get(a);
      if(!compare_items(e,a)) `uvm_error("MISMATCH","Ordered transaction mismatch")
      compared++; pending_expected=0;
    end
  endtask
  function void check_phase(uvm_phase phase);
    if(pending_expected || expected.used()!=0 || actual.used()!=0)
      `uvm_error("UNDRAINED","Scoreboard has unmatched transactions")
  endfunction
endclass

class base_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(base_virtual_sequencer)
  apb_sequencer bus_sqr;
  uvm_reg_block rm;
  virtual apb_if bus_vif;
  function new(string n, uvm_component p); super.new(n,p); endfunction
endclass

// All bus/RAL wiring lives here. Derived IP environments build the block and
// add their functional agent, predictor/reference model, scoreboard and coverage.
class base_env extends uvm_env;
  `uvm_component_utils(base_env)
  apb_agent bus;
  apb_cfg bus_cfg;
  apb_reg_adapter adapter;
  uvm_reg_predictor #(apb_item) predictor;
  base_virtual_sequencer vsqr;
  uvm_reg_block rm;
  function new(string n, uvm_component p); super.new(n,p); endfunction
  virtual function uvm_reg_block create_register_model();
    `uvm_fatal("ABSTRACT","Override create_register_model in the IP environment")
    return null;
  endfunction
  virtual function base_virtual_sequencer create_virtual_sequencer();
    return base_virtual_sequencer::type_id::create("vsqr",this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    bus_cfg=apb_cfg::type_id::create("bus_cfg");
    if(!uvm_config_db#(virtual apb_if)::get(this,"","bus_vif",bus_cfg.vif))
      `uvm_fatal("VIF","Missing bus_vif")
    uvm_config_db#(apb_cfg)::set(this,"bus","cfg",bus_cfg);
    bus=apb_agent::type_id::create("bus",this);
    adapter=apb_reg_adapter::type_id::create("adapter");
    predictor=uvm_reg_predictor#(apb_item)::type_id::create("predictor",this);
    rm=create_register_model();
    vsqr=create_virtual_sequencer();
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm.default_map.set_sequencer(bus.sqr,adapter);
    rm.default_map.set_auto_predict(0); // exactly ONE mirror prediction path
    predictor.map=rm.default_map; predictor.adapter=adapter;
    bus.mon.ap.connect(predictor.bus_in);
    vsqr.bus_sqr=bus.sqr; vsqr.rm=rm; vsqr.bus_vif=bus_cfg.vif;
  endfunction
endclass

class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
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
endclass
