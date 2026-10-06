class uart_ral_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_ral_vseq)
  function new(string n="uart_ral_vseq"); super.new(n); endfunction
  task body();
    uvm_status_e status;
    expect_reg(p_sequencer.regs.ctrl,0); expect_reg(p_sequencer.regs.baud,16);
    expect_reg(p_sequencer.regs.status,0); expect_reg(p_sequencer.regs.irq_en,0);
    expect_reg(p_sequencer.regs.irq_status,0);
    // Restrict mirror checks to stable RW registers, not FIFO/status ports.
    for(int bitno=0;bitno<4;bitno++) begin
      wr(p_sequencer.regs.ctrl,1<<bitno);
      p_sequencer.regs.ctrl.mirror(status,UVM_CHECK,UVM_FRONTDOOR,
        p_sequencer.regs.default_map,this);
      if(status!=UVM_IS_OK) `uvm_error("RAL","CTRL mirror failed")
    end
    wr(p_sequencer.regs.ctrl,0);
    for(int bitno=2;bitno<16;bitno++) begin
      wr(p_sequencer.regs.baud,1<<bitno);
      p_sequencer.regs.baud.mirror(status,UVM_CHECK,UVM_FRONTDOOR,
        p_sequencer.regs.default_map,this);
      if(status!=UVM_IS_OK) `uvm_error("RAL","BAUD mirror failed")
    end
    for(int i=0;i<4;i++) begin wr(p_sequencer.regs.irq_en,i); expect_reg(p_sequencer.regs.irq_en,i); end
    // set()/update() changes a desired value, then performs a real bus write.
    p_sequencer.regs.baud.divisor.set(16);
    p_sequencer.regs.baud.update(status,UVM_FRONTDOOR,p_sequencer.regs.default_map,this);
    if(status!=UVM_IS_OK) `uvm_error("RAL","BAUD update failed")
    expect_reg(p_sequencer.regs.baud,16);
    wr(p_sequencer.regs.irq_en,0);
    raw(1,A_BAUD,3,1); raw(1,A_BAUD,65536,1);
    raw(0,'h100,0,1); raw(1,'h100,0,1); raw(0,'h01,0,1);
    raw(0,A_TX,0,1); raw(1,A_RX,0,1); raw(1,A_STATUS,0,1);
    raw(1,A_IRQ_STATUS,0,1); raw(0,A_ERR_CLEAR,0,1);
    raw(0,A_RX,0,1); raw(1,A_TX,'h55,1); // empty and disabled
    expect_reg(p_sequencer.regs.baud,16);
    configure_uart();
    wr(p_sequencer.regs.txdata,'h81);
    raw(1,A_TX,'h42,1); raw(1,A_CTRL,0,1); raw(1,A_BAUD,8,1);
    wait_tx_idle();
    // Verify high reserved write bits are ignored.
    wr(p_sequencer.regs.ctrl,'hfffffff1); expect_reg(p_sequencer.regs.ctrl,1);
    wr(p_sequencer.regs.irq_en,'hffffffff); expect_reg(p_sequencer.regs.irq_en,3);
    wr(p_sequencer.regs.irq_en,0);
  endtask
endclass
