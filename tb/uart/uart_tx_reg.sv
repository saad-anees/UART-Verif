class uart_tx_reg extends uvm_reg;
  `uvm_object_utils(uart_tx_reg)
  uvm_reg_field data;
  function new(string n="uart_tx_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    data=uvm_reg_field::type_id::create("data");
    data.configure(this,8,0,"WO",0,0,1,0,0);
  endfunction
endclass
