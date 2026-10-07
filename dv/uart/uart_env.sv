class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)
  apb_agent bus;
  apb_cfg bus_cfg;
  apb_reg_adapter adapter;
  uvm_reg_predictor #(apb_item) predictor;
  uart_reg_block rm;
  uart_agent serial;
  uart_cfg serial_cfg;
  uart_scoreboard sb;
  uart_coverage cov;
  uart_reg_coverage reg_cov;
  uart_config_tracker tracker;
  uart_virtual_sequencer uart_vsqr;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    bus_cfg=apb_cfg::type_id::create("bus_cfg");
    if(!uvm_config_db#(virtual apb_if)::get(this,"","bus_vif",bus_cfg.vif))
      `uvm_fatal("VIF","Missing bus_vif")
    uvm_config_db#(apb_cfg)::set(this,"bus","cfg",bus_cfg);
    bus=apb_agent::type_id::create("bus",this);
    adapter=apb_reg_adapter::type_id::create("adapter");
    predictor=uvm_reg_predictor#(apb_item)::type_id::create("predictor",this);
    rm=uart_reg_block::type_id::create("rm"); rm.build();
    uart_vsqr=uart_virtual_sequencer::type_id::create("vsqr",this);
    serial_cfg=uart_cfg::type_id::create("serial_cfg");
    if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",serial_cfg.vif))
      `uvm_fatal("VIF","Missing uart_vif")
    uvm_config_db#(uart_cfg)::set(this,"serial","cfg",serial_cfg);
    serial=uart_agent::type_id::create("serial",this);
    sb=uart_scoreboard::type_id::create("sb",this); sb.cfg=serial_cfg;
    cov=uart_coverage::type_id::create("cov",this);
    reg_cov=uart_reg_coverage::type_id::create("reg_cov",this);
    tracker=uart_config_tracker::type_id::create("tracker",this); tracker.cfg=serial_cfg;
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm.default_map.set_sequencer(bus.sqr,adapter);
    rm.default_map.set_auto_predict(0); // observed APB predictor is the sole mirror path
    predictor.map=rm.default_map; predictor.adapter=adapter;
    bus.mon.ap.connect(predictor.bus_in);
    uart_vsqr.bus_sqr=bus.sqr; uart_vsqr.bus_vif=bus_cfg.vif;
    uart_vsqr.regs=rm;
    uart_vsqr.serial_sqr=serial.sqr; uart_vsqr.serial_cfg=serial_cfg; uart_vsqr.sb=sb;
    bus.mon.ap.connect(tracker.analysis_export);
    bus.mon.ap.connect(sb.bus_in);
    bus.mon.ap.connect(reg_cov.analysis_export);
    serial.mon.ap.connect(sb.serial_in);
    serial.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
