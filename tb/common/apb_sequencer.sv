class apb_sequencer extends uvm_sequencer #(apb_item);
  `uvm_component_utils(apb_sequencer)
  function new(string n, uvm_component p); super.new(n,p); endfunction
endclass
