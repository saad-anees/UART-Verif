class uart_smoke_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_smoke_vseq)
  function new(string n="uart_smoke_vseq"); super.new(n); endfunction
  task body();
    configure_uart();
    transmit('h55); receive_and_read('haa);
    expect_reg(p_sequencer.regs.status,0);
    if(p_sequencer.sb.tx_compared!=1 || p_sequencer.sb.rx_compared!=1)
      `uvm_error("VACUOUS","Smoke test did not check both directions")
  endtask
endclass
