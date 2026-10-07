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
