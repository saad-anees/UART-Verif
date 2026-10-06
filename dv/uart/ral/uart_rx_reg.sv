class uart_rx_reg extends uvm_reg;
  `uvm_object_utils(uart_rx_reg)
  uvm_reg_field data;
  function new(string n="uart_rx_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    data=uvm_reg_field::type_id::create("data");
    data.configure(this,8,0,"RO",1,0,1,0,0);
    data.set_compare(UVM_NO_CHECK);
  endfunction
endclass
