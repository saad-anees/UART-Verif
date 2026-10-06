// Reset values, access policy, volatility and field positions are explicit.
class uart_ctrl_reg extends uvm_reg;
  `uvm_object_utils(uart_ctrl_reg)
  uvm_reg_field enable,parity_en,odd,stop2;
  function new(string n="uart_ctrl_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    enable=uvm_reg_field::type_id::create("enable");
    enable.configure(this,1,0,"RW",0,0,1,0,0);
    parity_en=uvm_reg_field::type_id::create("parity_en");
    parity_en.configure(this,1,1,"RW",0,0,1,0,0);
    odd=uvm_reg_field::type_id::create("odd");
    odd.configure(this,1,2,"RW",0,0,1,0,0);
    stop2=uvm_reg_field::type_id::create("stop2");
    stop2.configure(this,1,3,"RW",0,0,1,0,0);
  endfunction
endclass
