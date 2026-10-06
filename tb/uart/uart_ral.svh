// Reset values, access policy, volatility and field positions are explicit.
class uart_ctrl_reg extends uvm_reg;
  `uvm_object_utils(uart_ctrl_reg)
  uvm_reg_field enable,parity_en,odd,stop2;
  function new(string n="uart_ctrl_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    enable=uvm_reg_field::type_id::create("enable");
    enable.configure(this,1,0,"RW",0,0,1,0,0);
    parity_en=uvm_reg_field::type_id::create("parity_en");
    parity_en.configure(this,1,1,"RW",0,0,1,0,0);
    odd=uvm_reg_field::type_id::create("odd");
    odd.configure(this,1,2,"RW",0,0,1,0,0);
    stop2=uvm_reg_field::type_id::create("stop2");
    stop2.configure(this,1,3,"RW",0,0,1,0,0);
  endfunction
endclass

class uart_baud_reg extends uvm_reg;
  `uvm_object_utils(uart_baud_reg)
  uvm_reg_field divisor;
  function new(string n="uart_baud_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    divisor=uvm_reg_field::type_id::create("divisor");
    divisor.configure(this,16,0,"RW",0,16,1,0,0);
  endfunction
endclass

class uart_tx_reg extends uvm_reg;
  `uvm_object_utils(uart_tx_reg)
  uvm_reg_field data;
  function new(string n="uart_tx_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    data=uvm_reg_field::type_id::create("data");
    data.configure(this,8,0,"WO",0,0,1,0,0);
  endfunction
endclass

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

class uart_reg_block extends uvm_reg_block;
  `uvm_object_utils(uart_reg_block)
  uart_ctrl_reg ctrl;
  uart_baud_reg baud;
  uart_tx_reg txdata;
  uart_rx_reg rxdata;
  uart_status_reg status;
  uart_irq_en_reg irq_en;
  uart_irq_status_reg irq_status;
  uart_err_clear_reg err_clear;
  function new(string n="uart_reg_block"); super.new(n,UVM_NO_COVERAGE); endfunction
  function void build();
    default_map=create_map("apb",0,4,UVM_LITTLE_ENDIAN,1);
    ctrl=uart_ctrl_reg::type_id::create("ctrl"); ctrl.configure(this); ctrl.build();
    default_map.add_reg(ctrl,'h00,"RW");
    baud=uart_baud_reg::type_id::create("baud"); baud.configure(this); baud.build();
    default_map.add_reg(baud,'h04,"RW");
    txdata=uart_tx_reg::type_id::create("txdata"); txdata.configure(this); txdata.build();
    default_map.add_reg(txdata,'h08,"WO");
    rxdata=uart_rx_reg::type_id::create("rxdata"); rxdata.configure(this); rxdata.build();
    default_map.add_reg(rxdata,'h0c,"RO");
    status=uart_status_reg::type_id::create("status"); status.configure(this); status.build();
    default_map.add_reg(status,'h10,"RO");
    irq_en=uart_irq_en_reg::type_id::create("irq_en"); irq_en.configure(this); irq_en.build();
    default_map.add_reg(irq_en,'h14,"RW");
    irq_status=uart_irq_status_reg::type_id::create("irq_status"); irq_status.configure(this); irq_status.build();
    default_map.add_reg(irq_status,'h18,"RO");
    err_clear=uart_err_clear_reg::type_id::create("err_clear"); err_clear.configure(this); err_clear.build();
    default_map.add_reg(err_clear,'h1c,"WO");
    // RXDATA is a FIFO port, not an ordinary storage register. No backdoor is
    // provided: a backdoor read would bypass its pop side effect.
    lock_model(); reset();
  endfunction
endclass
