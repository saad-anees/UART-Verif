class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  apb_cfg cfg;
  apb_sequencer sqr;
  apb_driver drv;
  apb_monitor mon;
  apb_coverage cov;
  function new(string n, uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(apb_cfg)::get(this,"","cfg",cfg) || cfg.vif==null)
      `uvm_fatal("CFG","Missing APB cfg or virtual interface")
    uvm_config_db#(apb_cfg)::set(this,"*","cfg",cfg);
    mon=apb_monitor::type_id::create("mon",this);
    cov=apb_coverage::type_id::create("cov",this);
    if(cfg.is_active==UVM_ACTIVE) begin
      sqr=apb_sequencer::type_id::create("sqr",this);
      drv=apb_driver::type_id::create("drv",this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mon.ap.connect(cov.analysis_export);
    if(cfg.is_active==UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
