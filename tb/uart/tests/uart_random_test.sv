// uart_random_test: run uart_random_vseq through the UART virtual sequencer.
class uart_random_test extends uart_base_test;
  `uvm_component_utils(uart_random_test)
  function new(string n, uvm_component p);
    super.new(n,p);
  endfunction
  function uart_base_vseq create_sequence();
    return uart_random_vseq::type_id::create("vseq");
  endfunction
endclass
