class base_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(base_virtual_sequencer)
  apb_sequencer bus_sqr;
  uvm_reg_block rm;
  virtual apb_if bus_vif;
  function new(string n, uvm_component p); super.new(n,p); endfunction
endclass
