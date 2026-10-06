class uart_irq_en_reg extends uvm_reg;
  `uvm_object_utils(uart_irq_en_reg)
  uvm_reg_field rx,error_irq;
  function new(string n="uart_irq_en_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    rx=uvm_reg_field::type_id::create("rx");
    rx.configure(this,1,0,"RW",0,0,1,0,0);
    error_irq=uvm_reg_field::type_id::create("error_irq");
    error_irq.configure(this,1,1,"RW",0,0,1,0,0);
  endfunction
endclass
