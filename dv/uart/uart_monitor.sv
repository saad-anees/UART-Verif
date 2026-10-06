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
