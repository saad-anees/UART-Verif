class uart_item extends uvm_sequence_item;
  rand bit [7:0] data;
  rand bit parity_en,odd,stop2;
  rand int unsigned divisor;
  rand bit inject_parity_error,inject_frame_error;
  rand int unsigned gap_bits;
  bit is_tx, parity_error, frame_error, aborted;
  constraint legal { divisor inside {[8:64]}; gap_bits inside {[1:3]}; }
  `uvm_object_utils_begin(uart_item)
    `uvm_field_int(data,UVM_DEFAULT)
    `uvm_field_int(parity_en,UVM_DEFAULT)
    `uvm_field_int(odd,UVM_DEFAULT)
    `uvm_field_int(stop2,UVM_DEFAULT)
    `uvm_field_int(divisor,UVM_DEFAULT)
    `uvm_field_int(inject_parity_error,UVM_DEFAULT)
    `uvm_field_int(inject_frame_error,UVM_DEFAULT)
    `uvm_field_int(gap_bits,UVM_DEFAULT)
    `uvm_field_int(is_tx,UVM_DEFAULT)
    `uvm_field_int(parity_error,UVM_DEFAULT)
    `uvm_field_int(frame_error,UVM_DEFAULT)
    `uvm_field_int(aborted,UVM_DEFAULT)
  `uvm_object_utils_end
  function new(string n="uart_item"); super.new(n); endfunction
endclass

class uart_cfg extends uvm_object;
  `uvm_object_utils(uart_cfg)
  virtual uart_if vif;
  uvm_active_passive_enum is_active=UVM_ACTIVE;
  bit enabled,parity_en,odd,stop2;
  int unsigned divisor=16;
  function new(string n="uart_cfg"); super.new(n); endfunction
endclass

class uart_sequencer extends uvm_sequencer #(uart_item);
  `uvm_component_utils(uart_sequencer)
  function new(string n,uvm_component p); super.new(n,p); endfunction
endclass

class uart_driver extends uvm_driver #(uart_item);
  `uvm_component_utils(uart_driver)
  uart_cfg cfg;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(uart_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("CFG","UART cfg missing")
  endfunction
  task bit_time(bit value,int unsigned n);
    cfg.vif.rx<=value;
    repeat(n) @(negedge cfg.vif.clk);
  endtask
  task send_frame(uart_item t);
    do @(negedge cfg.vif.clk); while(!cfg.vif.rst_n);
    bit_time(0,t.divisor);
    for(int i=0;i<8;i++) bit_time(t.data[i],t.divisor);
    if(t.parity_en) bit_time((^t.data)^t.odd^t.inject_parity_error,t.divisor);
    bit_time(!t.inject_frame_error,t.divisor);
    if(t.stop2) bit_time(!t.inject_frame_error,t.divisor);
    bit_time(1,(t.gap_bits+1)*t.divisor);
  endtask
  task run_phase(uvm_phase phase);
    cfg.vif.rx<=1;
    forever begin
      seq_item_port.get_next_item(req); req.aborted=0;
      fork : reset_aware_drive
        send_frame(req);
        begin wait(!cfg.vif.rst_n); req.aborted=1; end
      join_any
      disable reset_aware_drive;
      cfg.vif.rx<=1;
      seq_item_port.item_done();
    end
  endtask
endclass

// Configuration follows successful observed APB writes, not sequence intent.
class uart_config_tracker extends uvm_subscriber #(apb_item);
  `uvm_component_utils(uart_config_tracker)
  uart_cfg cfg;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void write(apb_item t);
    if(t.error || !t.write) return;
    if(t.addr==A_CTRL) begin
      cfg.enabled=t.data[0]; cfg.parity_en=t.data[1];
      cfg.odd=t.data[2]; cfg.stop2=t.data[3];
    end
    if(t.addr==A_BAUD) cfg.divisor=t.data[15:0];
  endfunction
  task run_phase(uvm_phase phase);
    forever begin
      wait(!cfg.vif.rst_n);
      cfg.enabled=0; cfg.parity_en=0; cfg.odd=0; cfg.stop2=0; cfg.divisor=16;
      @(posedge cfg.vif.rst_n);
    end
  endtask
endclass

class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)
  uart_cfg cfg;
  uvm_analysis_port #(uart_item) ap;
  function new(string n,uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(uart_cfg)::get(this,"","cfg",cfg)) `uvm_fatal("CFG","UART cfg missing")
  endfunction
  function logic line_value(bit is_tx); return is_tx ? cfg.vif.tx : cfg.vif.rx; endfunction
  task ticks(int unsigned n); repeat(n) @(negedge cfg.vif.clk); endtask
  task decode(bit is_tx,output uart_item t);
    t=uart_item::type_id::create("observed_frame");
    t.is_tx=is_tx; t.divisor=cfg.divisor; t.parity_en=cfg.parity_en;
    t.odd=cfg.odd; t.stop2=cfg.stop2;
    ticks(t.divisor/2);
    if(line_value(is_tx)!==0) begin t.aborted=1; return; end // false start
    for(int i=0;i<8;i++) begin
      ticks(t.divisor);
      if($isunknown(line_value(is_tx))) `uvm_error("SERIAL_X","Unknown data bit")
      t.data[i]=line_value(is_tx);
    end
    if(t.parity_en) begin
      ticks(t.divisor);
      t.parity_error=(line_value(is_tx)!==((^t.data)^t.odd));
    end
    ticks(t.divisor); t.frame_error=(line_value(is_tx)!==1);
    if(t.stop2) begin ticks(t.divisor); t.frame_error|=(line_value(is_tx)!==1); end
    // Publish at final stop center. Tests allow settling before register reads.
    ap.write(t);
    // Re-arm only after idle; a held-low line is not repeatedly decoded.
    do @(negedge cfg.vif.clk); while(line_value(is_tx)!==1);
  endtask
  task watch(bit is_tx);
    uart_item t;
    forever begin
      @(negedge cfg.vif.clk);
      if(cfg.vif.rst_n && cfg.enabled && line_value(is_tx)===0) begin
        fork : reset_aware_monitor
          decode(is_tx,t);
          begin wait(!cfg.vif.rst_n); end
        join_any
        disable reset_aware_monitor;
      end
    end
  endtask
  task run_phase(uvm_phase phase);
    fork watch(0); watch(1); join
  endtask
endclass

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
