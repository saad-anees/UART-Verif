class uart_reset_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_reset_vseq)
  function new(string n="uart_reset_vseq"); super.new(n); endfunction
  task body();
    configure_uart(31,1,1,1); wr(p_sequencer.regs.irq_en,3);
    send_rx('h3c,1,0); // reset must clear pending FIFO and sticky flags
    wr(p_sequencer.regs.txdata,'haa); cycles(20); apply_reset();
    expect_reg(p_sequencer.regs.ctrl,0); expect_reg(p_sequencer.regs.baud,16);
    expect_reg(p_sequencer.regs.status,0); expect_reg(p_sequencer.regs.irq_en,0);
    expect_irq(0);
    configure_uart(); transmit('h42); receive_and_read('h24);
    // Reset during an incoming frame. Driver and monitor must abort cleanly.
    begin
      uart_send_seq s=uart_send_seq::type_id::create("reset_rx");
      s.frame=uart_item::type_id::create("partial_frame");
      s.frame.data='h55; s.frame.divisor=16; s.frame.gap_bits=1;
      fork
        s.start(p_sequencer.serial_sqr,this);
        begin cycles(30); apply_reset(); end
      join
      if(!s.frame.aborted) `uvm_error("RESET_RX","RX driver failed to report abort")
    end
    configure_uart(); receive_and_read('h77); transmit('hee);
  endtask
endclass
