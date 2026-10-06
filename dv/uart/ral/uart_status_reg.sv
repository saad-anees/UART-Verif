class uart_status_reg extends uvm_reg;
  `uvm_object_utils(uart_status_reg)
  uvm_reg_field tx_busy,rx_valid,parity_error,framing_error,overrun;
  function new(string n="uart_status_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    tx_busy=uvm_reg_field::type_id::create("tx_busy");
    tx_busy.configure(this,1,0,"RO",1,0,1,0,0);
    tx_busy.set_compare(UVM_NO_CHECK);
    rx_valid=uvm_reg_field::type_id::create("rx_valid");
    rx_valid.configure(this,1,1,"RO",1,0,1,0,0);
    rx_valid.set_compare(UVM_NO_CHECK);
    parity_error=uvm_reg_field::type_id::create("parity_error");
    parity_error.configure(this,1,2,"RO",1,0,1,0,0);
    parity_error.set_compare(UVM_NO_CHECK);
    framing_error=uvm_reg_field::type_id::create("framing_error");
    framing_error.configure(this,1,3,"RO",1,0,1,0,0);
    framing_error.set_compare(UVM_NO_CHECK);
    overrun=uvm_reg_field::type_id::create("overrun");
    overrun.configure(this,1,4,"RO",1,0,1,0,0);
    overrun.set_compare(UVM_NO_CHECK);
  endfunction
endclass
