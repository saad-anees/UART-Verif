class uart_base_test extends base_test;
  `uvm_component_utils(uart_base_test)
  uart_env env;
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); env=uart_env::type_id::create("env",this);
  endfunction
  virtual function uart_base_vseq create_sequence();
    return uart_smoke_vseq::type_id::create("vseq");
  endfunction
  task run_phase(uvm_phase phase);
    uart_base_vseq seq;
    phase.raise_objection(this);
    wait(env.bus_cfg.vif.presetn); repeat(4) @(negedge env.bus_cfg.vif.pclk);
    seq=create_sequence(); seq.start(env.uart_vsqr);
    // Deterministic drain and bounds: no outstanding serial TX may remain.
    seq.wait_tx_idle(); repeat(8) @(negedge env.bus_cfg.vif.pclk);
    phase.drop_objection(this);
  endtask
endclass

// Factory-created sequences keep tests small. Override either test or sequence
// in an SoC integration without copying the environment.
`define UART_TEST(TEST,SEQ) \
class TEST extends uart_base_test; \
  `uvm_component_utils(TEST) \
  function new(string n,uvm_component p); super.new(n,p); endfunction \
  function uart_base_vseq create_sequence(); \
    return SEQ::type_id::create("vseq"); \
  endfunction \
endclass
`UART_TEST(uart_smoke_test,uart_smoke_vseq)
`UART_TEST(uart_ral_test,uart_ral_vseq)
`UART_TEST(uart_formats_test,uart_formats_vseq)
`UART_TEST(uart_random_test,uart_random_vseq)
`UART_TEST(uart_errors_test,uart_errors_vseq)
`UART_TEST(uart_fifo_test,uart_fifo_vseq)
`UART_TEST(uart_reset_test,uart_reset_vseq)
`undef UART_TEST
