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
