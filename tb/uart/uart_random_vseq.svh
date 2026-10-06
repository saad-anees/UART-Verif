class uart_random_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_random_vseq)
  function new(string n="uart_random_vseq"); super.new(n); endfunction
  task body();
    uart_item t;
    int count=100;
    void'($value$plusargs("N_FRAMES=%d",count));
    if(count<1 || count>2000) `uvm_fatal("COUNT","N_FRAMES must be 1..2000")
    repeat(count) begin
      t=uart_item::type_id::create("random_frame");
      if(!t.randomize() with { divisor inside {8,16,31};
          inject_parity_error==0; inject_frame_error==0; })
        `uvm_fatal("RANDOMIZE","UART constraints failed")
      configure_uart(t.divisor,t.parity_en,t.odd,t.stop2);
      // Full duplex: independent APB TX and serial RX run concurrently.
      fork transmit(t.data); send_rx(~t.data); join
      expect_reg(p_sequencer.regs.rxdata,8'(~t.data));
    end
  endtask
endclass
