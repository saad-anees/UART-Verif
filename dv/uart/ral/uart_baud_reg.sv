class uart_baud_reg extends uvm_reg;
  `uvm_object_utils(uart_baud_reg)
  uvm_reg_field divisor;
  function new(string n="uart_baud_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    divisor=uvm_reg_field::type_id::create("divisor");
    divisor.configure(this,16,0,"RW",0,16,1,0,0);
  endfunction
endclass
