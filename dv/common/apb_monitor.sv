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
