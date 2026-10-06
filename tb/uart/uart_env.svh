class uart_env extends base_env;
  `uvm_component_utils(uart_env)
  uart_agent serial;
  uart_cfg serial_cfg;
  uart_scoreboard sb;
  uart_coverage cov;
  uart_reg_coverage reg_cov;
  uart_config_tracker tracker;
  uart_virtual_sequencer uart_vsqr;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function uvm_reg_block create_register_model();
    uart_reg_block b=uart_reg_block::type_id::create("rm"); b.build(); return b;
  endfunction
  function base_virtual_sequencer create_virtual_sequencer();
    return uart_virtual_sequencer::type_id::create("vsqr",this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
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
    if(!$cast(uart_vsqr,vsqr)) `uvm_fatal("CAST","Expected UART virtual sequencer")
    if(!$cast(uart_vsqr.regs,rm)) `uvm_fatal("CAST","Expected UART register model")
    uart_vsqr.serial_sqr=serial.sqr; uart_vsqr.serial_cfg=serial_cfg; uart_vsqr.sb=sb;
    bus.mon.ap.connect(tracker.analysis_export);
    bus.mon.ap.connect(sb.bus_in);
    bus.mon.ap.connect(reg_cov.analysis_export);
    serial.mon.ap.connect(sb.serial_in);
    serial.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
