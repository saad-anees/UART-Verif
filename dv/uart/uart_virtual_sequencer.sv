class uart_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(uart_virtual_sequencer)
  apb_sequencer bus_sqr;
  virtual apb_if bus_vif;
  uart_sequencer serial_sqr;
  uart_reg_block regs;
  uart_cfg serial_cfg;
  uart_scoreboard sb;
  function new(string n,uvm_component p); super.new(n,p); endfunction
endclass
