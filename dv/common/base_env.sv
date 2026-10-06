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
