// A transaction describes one completed APB transfer, never pin timing.
class apb_item extends uvm_sequence_item;
  rand bit write;
  rand bit [15:0] addr;
  rand bit [31:0] data;
  bit error;
  int unsigned wait_cycles;
  `uvm_object_utils_begin(apb_item)
    `uvm_field_int(write, UVM_DEFAULT)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_int(error, UVM_DEFAULT)
    `uvm_field_int(wait_cycles, UVM_DEFAULT)
  `uvm_object_utils_end
  function new(string name="apb_item"); super.new(name); endfunction
endclass

class apb_cfg extends uvm_object;
  `uvm_object_utils(apb_cfg)
  virtual apb_if vif;
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  int unsigned timeout_cycles = 100;
  function new(string name="apb_cfg"); super.new(name); endfunction
endclass

class apb_sequencer extends uvm_sequencer #(apb_item);
  `uvm_component_utils(apb_sequencer)
  function new(string n, uvm_component p); super.new(n,p); endfunction
endclass

class apb_driver extends uvm_driver #(apb_item);
  `uvm_component_utils(apb_driver)
  apb_cfg cfg;
  function new(string n, uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(apb_cfg)::get(this,"","cfg",cfg))
      `uvm_fatal("CFG","Missing APB configuration")
  endfunction
  task idle();
    cfg.vif.psel = 0; cfg.vif.penable = 0;
    cfg.vif.pwrite = 0; cfg.vif.paddr = 0; cfg.vif.pwdata = 0;
  endtask
  task run_phase(uvm_phase phase);
    idle();
    forever begin
      seq_item_port.get_next_item(req);
      req.error=0; req.wait_cycles=0;
      // The reset contract is quiescent APB reset: do not reset mid transfer.
      do @(negedge cfg.vif.pclk); while (!cfg.vif.presetn);
      cfg.vif.psel=1; cfg.vif.penable=0; cfg.vif.pwrite=req.write;
      cfg.vif.paddr=req.addr; cfg.vif.pwdata=req.data;
      @(negedge cfg.vif.pclk); cfg.vif.penable=1;
      forever begin
        @(posedge cfg.vif.pclk);
        if (!cfg.vif.presetn) `uvm_fatal("RESET","APB reset during transfer is unsupported")
        if (cfg.vif.pready === 1'b1) begin
          req.error = (cfg.vif.pslverr !== 1'b0);
          if (!req.write) req.data = cfg.vif.prdata;
          break;
        end
        req.wait_cycles++;
        if (req.wait_cycles >= cfg.timeout_cycles)
          `uvm_fatal("APB_TIMEOUT",$sformatf("No response at %h",req.addr))
      end
      @(negedge cfg.vif.pclk); idle();
      // Adapter uses the updated request, not a separate response item.
      seq_item_port.item_done();
    end
  endtask
endclass

class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)
  apb_cfg cfg;
  uvm_analysis_port #(apb_item) ap;
  function new(string n, uvm_component p); super.new(n,p); ap=new("ap",this); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(apb_cfg)::get(this,"","cfg",cfg))
      `uvm_fatal("CFG","Missing APB configuration")
  endfunction
  task run_phase(uvm_phase phase);
    int unsigned waits=0;
    apb_item t;
    forever begin
      @(posedge cfg.vif.pclk);
      if (!cfg.vif.presetn) waits=0;
      else if (cfg.vif.psel && cfg.vif.penable) begin
        if (cfg.vif.pready) begin
          t=apb_item::type_id::create("observed");
          t.addr=cfg.vif.paddr; t.write=cfg.vif.pwrite;
          t.data=t.write ? cfg.vif.pwdata : cfg.vif.prdata;
          t.error=cfg.vif.pslverr; t.wait_cycles=waits; waits=0;
          ap.write(t); // fresh object: subscribers must not modify it
        end else waits++;
      end
    end
  endtask
endclass

class apb_coverage extends uvm_subscriber #(apb_item);
  `uvm_component_utils(apb_coverage)
  covergroup transfers with function sample(bit wr, bit err, int unsigned waits);
    option.per_instance=1;
    direction: coverpoint wr;
    response: coverpoint err;
    latency: coverpoint waits { bins zero={0}; bins short_wait={[1:4]}; bins long_wait={[5:99]}; }
    direction_response: cross direction,response;
  endgroup
  function new(string n, uvm_component p); super.new(n,p); transfers=new; endfunction
  function void write(apb_item t); transfers.sample(t.write,t.error,t.wait_cycles); endfunction
endclass

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

class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)
  function new(string n="apb_reg_adapter");
    super.new(n); supports_byte_enable=0; provides_responses=0;
  endfunction
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_item t=apb_item::type_id::create("ral_apb");
    if (rw.addr > 'hffff) `uvm_fatal("ADDR","APB address exceeds 16 bits")
    t.addr=rw.addr[15:0]; t.write=(rw.kind==UVM_WRITE); t.data=rw.data[31:0];
    return t;
  endfunction
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_item t;
    if (!$cast(t,bus_item)) `uvm_fatal("CAST","Adapter expected apb_item")
    rw.kind=t.write ? UVM_WRITE : UVM_READ;
    rw.addr=t.addr; rw.data=t.data; rw.n_bits=32;
    rw.status=t.error ? UVM_NOT_OK : UVM_IS_OK;
  endfunction
endclass

// Useful for invalid-address/access tests which intentionally bypass RAL policy.
class apb_access_seq extends uvm_sequence #(apb_item);
  `uvm_object_utils(apb_access_seq)
  bit wr; bit [15:0] address; bit [31:0] value; bit error;
  function new(string n="apb_access_seq"); super.new(n); endfunction
  task body();
    apb_item t=apb_item::type_id::create("t");
    start_item(t); t.write=wr; t.addr=address; t.data=value; finish_item(t);
    value=t.data; error=t.error;
  endtask
endclass
