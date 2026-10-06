class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  uart_cfg cfg;
  uart_sequencer sqr;
  uart_driver drv;
  uart_monitor mon;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(uart_cfg)::get(this,"","cfg",cfg) || cfg.vif==null)
      `uvm_fatal("CFG","UART configuration/interface missing")
    uvm_config_db#(uart_cfg)::set(this,"*","cfg",cfg);
    mon=uart_monitor::type_id::create("mon",this);
    if(cfg.is_active==UVM_ACTIVE) begin
      sqr=uart_sequencer::type_id::create("sqr",this);
      drv=uart_driver::type_id::create("drv",this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    if(cfg.is_active==UVM_ACTIVE) drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
