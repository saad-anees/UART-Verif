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
