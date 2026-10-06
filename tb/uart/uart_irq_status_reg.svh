class uart_irq_status_reg extends uvm_reg;
  `uvm_object_utils(uart_irq_status_reg)
  uvm_reg_field rx,error_irq;
  function new(string n="uart_irq_status_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    rx=uvm_reg_field::type_id::create("rx");
    rx.configure(this,1,0,"RO",1,0,1,0,0);
    rx.set_compare(UVM_NO_CHECK);
    error_irq=uvm_reg_field::type_id::create("error_irq");
    error_irq.configure(this,1,1,"RO",1,0,1,0,0);
    error_irq.set_compare(UVM_NO_CHECK);
  endfunction
endclass
