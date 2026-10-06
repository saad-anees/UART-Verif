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
