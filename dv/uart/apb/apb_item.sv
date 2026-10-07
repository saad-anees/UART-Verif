// A transaction describes one completed APB transfer, never pin timing.
class apb_item extends uvm_sequence_item;
  rand bit write;
  rand bit [15:0] addr;
  rand bit [31:0] data;
  bit error;
  int unsigned wait_cycles;
  `uvm_object_utils_begin(apb_item)
    `uvm_field_int(write, UVM_DEFAULT)
    `uvm_field_int(addr, UVM_DEFAULT)
    `uvm_field_int(data, UVM_DEFAULT)
    `uvm_field_int(error, UVM_DEFAULT)
    `uvm_field_int(wait_cycles, UVM_DEFAULT)
  `uvm_object_utils_end
  function new(string name="apb_item"); super.new(name); endfunction
endclass
