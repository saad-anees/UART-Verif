class uart_reg_coverage extends uvm_subscriber #(apb_item);
  `uvm_component_utils(uart_reg_coverage)
  covergroup registers with function sample(bit wr,bit[15:0] addr,bit err,bit[31:0] data);
    option.per_instance=1;
    address: coverpoint addr { bins regs[]={0,4,8,12,16,20,24,28}; bins invalid=default; }
    direction: coverpoint wr;
    response: coverpoint err;
    accesses: cross address,direction,response;
    flags: coverpoint data[4:0] iff(!wr && addr==A_STATUS && !err) {
      bins idle={0}; bins tx_busy={1}; bins rx_ready={2};
      bins parity_flag[]={[4:7]}; bins framing_flag[]={[8:15]}; bins overrun_flag[]={[16:31]};
    }
  endgroup
  function new(string n,uvm_component p); super.new(n,p); registers=new; endfunction
  function void write(apb_item t); registers.sample(t.write,t.addr,t.error,t.data); endfunction
endclass
