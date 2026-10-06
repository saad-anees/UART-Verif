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
