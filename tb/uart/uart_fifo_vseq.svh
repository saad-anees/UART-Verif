class uart_fifo_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_fifo_vseq)
  function new(string n="uart_fifo_vseq"); super.new(n); endfunction
  task body();
    configure_uart(); wr(p_sequencer.regs.irq_en,3);
    // Repeat fill/overflow/drain to exercise pointer wrap, preserve oldest data.
    repeat(3) begin
      for(int i=0;i<6;i++) send_rx(8'('h20+i));
      expect_reg(p_sequencer.regs.status,'h12); expect_irq(1);
      for(int i=0;i<4;i++) expect_reg(p_sequencer.regs.rxdata,'h20+i);
      expect_reg(p_sequencer.regs.status,'h10); expect_irq(1);
      wr(p_sequencer.regs.err_clear,'h10); expect_irq(0);
      raw(0,A_RX,0,1);
    end
  endtask
endclass
