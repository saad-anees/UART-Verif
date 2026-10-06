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
