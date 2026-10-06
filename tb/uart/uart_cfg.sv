class uart_cfg extends uvm_object;
  `uvm_object_utils(uart_cfg)
  virtual uart_if vif;
  uvm_active_passive_enum is_active=UVM_ACTIVE;
  bit enabled,parity_en,odd,stop2;
  int unsigned divisor=16;
  function new(string n="uart_cfg"); super.new(n); endfunction
endclass
