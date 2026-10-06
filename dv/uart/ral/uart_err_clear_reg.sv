class uart_err_clear_reg extends uvm_reg;
  `uvm_object_utils(uart_err_clear_reg)
  uvm_reg_field parity_error,framing_error,overrun;
  function new(string n="uart_err_clear_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    parity_error=uvm_reg_field::type_id::create("parity_error");
    parity_error.configure(this,1,2,"W1C",1,0,1,0,0);
    parity_error.set_compare(UVM_NO_CHECK);
    framing_error=uvm_reg_field::type_id::create("framing_error");
    framing_error.configure(this,1,3,"W1C",1,0,1,0,0);
    framing_error.set_compare(UVM_NO_CHECK);
    overrun=uvm_reg_field::type_id::create("overrun");
    overrun.configure(this,1,4,"W1C",1,0,1,0,0);
    overrun.set_compare(UVM_NO_CHECK);
  endfunction
endclass
