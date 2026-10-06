class uart_item extends uvm_sequence_item;
  rand bit [7:0] data;
  rand bit parity_en,odd,stop2;
  rand int unsigned divisor;
  rand bit inject_parity_error,inject_frame_error;
  rand int unsigned gap_bits;
  bit is_tx, parity_error, frame_error, aborted;
  constraint legal { divisor inside {[8:64]}; gap_bits inside {[1:3]}; }
  `uvm_object_utils_begin(uart_item)
    `uvm_field_int(data,UVM_DEFAULT)
    `uvm_field_int(parity_en,UVM_DEFAULT)
    `uvm_field_int(odd,UVM_DEFAULT)
    `uvm_field_int(stop2,UVM_DEFAULT)
    `uvm_field_int(divisor,UVM_DEFAULT)
    `uvm_field_int(inject_parity_error,UVM_DEFAULT)
    `uvm_field_int(inject_frame_error,UVM_DEFAULT)
    `uvm_field_int(gap_bits,UVM_DEFAULT)
    `uvm_field_int(is_tx,UVM_DEFAULT)
    `uvm_field_int(parity_error,UVM_DEFAULT)
    `uvm_field_int(frame_error,UVM_DEFAULT)
    `uvm_field_int(aborted,UVM_DEFAULT)
  `uvm_object_utils_end
  function new(string n="uart_item"); super.new(n); endfunction
endclass
