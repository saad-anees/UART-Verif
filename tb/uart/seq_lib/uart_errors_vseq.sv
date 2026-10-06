class uart_errors_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_errors_vseq)
  function new(string n="uart_errors_vseq"); super.new(n); endfunction
  task body();
    configure_uart(16,1,0,0);
    wr(p_sequencer.regs.irq_en,0);
    send_rx('h39,1,0); expect_irq(0); // pending state with masked interrupt
    wr(p_sequencer.regs.irq_en,2); expect_irq(1);
    expect_reg(p_sequencer.regs.status,'h06);
    expect_reg(p_sequencer.regs.irq_status,3);
    expect_reg(p_sequencer.regs.rxdata,'h39);
    wr(p_sequencer.regs.err_clear,0); expect_irq(1); // write zero keeps sticky flag
    wr(p_sequencer.regs.err_clear,4); expect_irq(0);
    for(int s=0;s<2;s++) begin
      configure_uart(16,1,1,s!=0);
      send_rx('ha6,0,1); expect_reg(p_sequencer.regs.status,'h0a);
      expect_reg(p_sequencer.regs.rxdata,'ha6);
      expect_irq(1); wr(p_sequencer.regs.err_clear,8); expect_irq(0);
      send_rx('h69,1,1); expect_reg(p_sequencer.regs.status,'h0e);
      expect_reg(p_sequencer.regs.rxdata,'h69);
      wr(p_sequencer.regs.err_clear,4); expect_irq(1); // selective clear leaves FE
      expect_reg(p_sequencer.regs.status,8);
      wr(p_sequencer.regs.err_clear,8); expect_irq(0);
    end
    configure_uart();
    wr(p_sequencer.regs.irq_en,1);
    send_rx('h11); expect_irq(1); expect_reg(p_sequencer.regs.rxdata,'h11); expect_irq(0);
  endtask
endclass
