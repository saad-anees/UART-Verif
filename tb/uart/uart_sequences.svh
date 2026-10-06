// Leaf serial sequence. Virtual sequences coordinate this with RAL/APB.
class uart_send_seq extends uvm_sequence #(uart_item);
  `uvm_object_utils(uart_send_seq)
  uart_item frame;
  function new(string n="uart_send_seq"); super.new(n); endfunction
  task body();
    if(frame==null) `uvm_fatal("FRAME","No serial frame supplied")
    start_item(frame); finish_item(frame);
  endtask
endclass

class uart_base_vseq extends uvm_sequence;
  `uvm_object_utils(uart_base_vseq)
  `uvm_declare_p_sequencer(uart_virtual_sequencer)
  function new(string n="uart_base_vseq"); super.new(n); endfunction
  task cycles(int n); repeat(n) @(negedge p_sequencer.bus_vif.pclk); endtask
  task wr(uvm_reg reg_h,uvm_reg_data_t data);
    uvm_status_e status;
    reg_h.write(status,data,UVM_FRONTDOOR,p_sequencer.regs.default_map,this);
    if(status!=UVM_IS_OK) `uvm_fatal("RAL_WRITE",reg_h.get_full_name())
  endtask
  task rd(uvm_reg reg_h,output uvm_reg_data_t data);
    uvm_status_e status;
    reg_h.read(status,data,UVM_FRONTDOOR,p_sequencer.regs.default_map,this);
    if(status!=UVM_IS_OK) `uvm_fatal("RAL_READ",reg_h.get_full_name())
  endtask
  task expect_reg(uvm_reg reg_h,uvm_reg_data_t expected,uvm_reg_data_t mask='1);
    uvm_reg_data_t got;
    rd(reg_h,got);
    if((got&mask)!==(expected&mask))
      `uvm_error("READBACK",$sformatf("%s got=%h expected=%h mask=%h",reg_h.get_name(),got,expected,mask))
  endtask
  task wait_tx_idle();
    uvm_reg_data_t value;
    for(int i=0;i<20000;i++) begin
      rd(p_sequencer.regs.status,value);
      if(!value[0]) return;
    end
    `uvm_fatal("TX_TIMEOUT","TX busy never cleared")
  endtask
  task configure_uart(int div=16,bit parity_en=0,bit odd=0,bit stop2=0);
    wait_tx_idle();
    cycles(4); // serial sequences have already completed before configuration
    wr(p_sequencer.regs.ctrl,0);
    wr(p_sequencer.regs.baud,div);
    wr(p_sequencer.regs.ctrl,{28'b0,stop2,odd,parity_en,1'b1});
    expect_reg(p_sequencer.regs.baud,div);
  endtask
  task send_rx(bit[7:0] data,bit pe=0,bit fe=0);
    uart_send_seq seq=uart_send_seq::type_id::create("send_rx");
    seq.frame=uart_item::type_id::create("rx_frame");
    seq.frame.data=data; seq.frame.divisor=p_sequencer.serial_cfg.divisor;
    seq.frame.parity_en=p_sequencer.serial_cfg.parity_en;
    seq.frame.odd=p_sequencer.serial_cfg.odd; seq.frame.stop2=p_sequencer.serial_cfg.stop2;
    seq.frame.inject_parity_error=pe; seq.frame.inject_frame_error=fe; seq.frame.gap_bits=1;
    seq.start(p_sequencer.serial_sqr,this);
    if(seq.frame.aborted) `uvm_error("RX_ABORT","Unexpected reset during RX stimulus")
    cycles(4);
  endtask
  task transmit(bit[7:0] data);
    wait_tx_idle(); wr(p_sequencer.regs.txdata,data); wait_tx_idle(); cycles(2);
  endtask
  task receive_and_read(bit[7:0] data);
    send_rx(data); expect_reg(p_sequencer.regs.rxdata,data);
  endtask
  task raw(bit wr_en,bit[15:0] addr,bit[31:0] data,bit expect_error);
    apb_access_seq s=apb_access_seq::type_id::create("raw_apb");
    s.wr=wr_en; s.address=addr; s.value=data; s.start(p_sequencer.bus_sqr,this);
    if(s.error!=expect_error) `uvm_error("BUS_RESPONSE",$sformatf("addr=%h error=%b expected=%b",addr,s.error,expect_error))
  endtask
  task expect_irq(bit expected);
    cycles(4);
    if(p_sequencer.serial_cfg.vif.irq!==expected)
      `uvm_error("IRQ",$sformatf("IRQ expected=%b actual=%b",expected,p_sequencer.serial_cfg.vif.irq))
  endtask
  task apply_reset();
    // Sole runtime reset owner. APB must be idle; UART may be transmitting.
    if(p_sequencer.bus_vif.psel) `uvm_fatal("RESET","Reset requires idle APB")
    @(negedge p_sequencer.bus_vif.pclk); p_sequencer.bus_vif.presetn=0;
    cycles(5); p_sequencer.regs.reset();
    p_sequencer.bus_vif.presetn=1; cycles(4);
  endtask
endclass

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

class uart_formats_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_formats_vseq)
  function new(string n="uart_formats_vseq"); super.new(n); endfunction
  task body();
    int divisors[3]='{8,16,31};
    bit[7:0] patterns[12]='{'h00,'hff,'h55,'haa,1,2,4,8,16,32,64,128};
    foreach(divisors[d]) for(int parity=0;parity<3;parity++)
      for(int stops=0;stops<2;stops++) begin
        configure_uart(divisors[d],parity!=0,parity==2,stops!=0);
        foreach(patterns[i]) begin transmit(patterns[i]); receive_and_read(patterns[i]); end
      end
  endtask
endclass

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
