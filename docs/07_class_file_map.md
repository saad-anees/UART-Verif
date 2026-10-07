# UART/APB class files and compile order

Each class is in one matching `.sv` file. `dv/uart/uart_pkg.sv` includes all
classes once in dependency order. Compile `sim/uart.f` through `sim/Makefile`.

| Directory | Contents |
| --- | --- |
| `dv/uart/apb/` | UART-owned APB agent and interface |
| `dv/uart/ral/` | UART registers, block and APB adapter |
| `dv/uart/seq_lib/` | UART and APB stimulus sequences |
| `dv/uart/tests/` | UART base test and scenario tests |
| `dv/uart/` | Serial agent, environment, virtual sequencer, scoreboard and coverage |
| `tb/` | UART integration and standalone RTL testbench tops |

The environment, virtual sequencer and base test derive directly from standard
UVM classes. No project-specific common package or shared base classes are used.

## Class file map

| Class file | Base class |
| --- | --- |
| [`apb/apb_agent.sv`](../dv/uart/apb/apb_agent.sv) | `uvm_agent` |
| [`apb/apb_cfg.sv`](../dv/uart/apb/apb_cfg.sv) | `uvm_object` |
| [`apb/apb_coverage.sv`](../dv/uart/apb/apb_coverage.sv) | `uvm_subscriber` |
| [`apb/apb_driver.sv`](../dv/uart/apb/apb_driver.sv) | `uvm_driver` |
| [`apb/apb_item.sv`](../dv/uart/apb/apb_item.sv) | `uvm_sequence_item` |
| [`apb/apb_monitor.sv`](../dv/uart/apb/apb_monitor.sv) | `uvm_monitor` |
| [`apb/apb_sequencer.sv`](../dv/uart/apb/apb_sequencer.sv) | `uvm_sequencer` |
| [`ral/apb_reg_adapter.sv`](../dv/uart/ral/apb_reg_adapter.sv) | `uvm_reg_adapter` |
| [`ral/uart_baud_reg.sv`](../dv/uart/ral/uart_baud_reg.sv) | `uvm_reg` |
| [`ral/uart_ctrl_reg.sv`](../dv/uart/ral/uart_ctrl_reg.sv) | `uvm_reg` |
| [`ral/uart_err_clear_reg.sv`](../dv/uart/ral/uart_err_clear_reg.sv) | `uvm_reg` |
| [`ral/uart_irq_en_reg.sv`](../dv/uart/ral/uart_irq_en_reg.sv) | `uvm_reg` |
| [`ral/uart_irq_status_reg.sv`](../dv/uart/ral/uart_irq_status_reg.sv) | `uvm_reg` |
| [`ral/uart_reg_block.sv`](../dv/uart/ral/uart_reg_block.sv) | `uvm_reg_block` |
| [`ral/uart_rx_reg.sv`](../dv/uart/ral/uart_rx_reg.sv) | `uvm_reg` |
| [`ral/uart_status_reg.sv`](../dv/uart/ral/uart_status_reg.sv) | `uvm_reg` |
| [`ral/uart_tx_reg.sv`](../dv/uart/ral/uart_tx_reg.sv) | `uvm_reg` |
| [`seq_lib/apb_access_seq.sv`](../dv/uart/seq_lib/apb_access_seq.sv) | `uvm_sequence` |
| [`seq_lib/uart_base_vseq.sv`](../dv/uart/seq_lib/uart_base_vseq.sv) | `uvm_sequence` |
| [`seq_lib/uart_errors_vseq.sv`](../dv/uart/seq_lib/uart_errors_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_fifo_vseq.sv`](../dv/uart/seq_lib/uart_fifo_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_formats_vseq.sv`](../dv/uart/seq_lib/uart_formats_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_ral_vseq.sv`](../dv/uart/seq_lib/uart_ral_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_random_vseq.sv`](../dv/uart/seq_lib/uart_random_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_reset_vseq.sv`](../dv/uart/seq_lib/uart_reset_vseq.sv) | `uart_base_vseq` |
| [`seq_lib/uart_send_seq.sv`](../dv/uart/seq_lib/uart_send_seq.sv) | `uvm_sequence` |
| [`seq_lib/uart_smoke_vseq.sv`](../dv/uart/seq_lib/uart_smoke_vseq.sv) | `uart_base_vseq` |
| [`tests/uart_base_test.sv`](../dv/uart/tests/uart_base_test.sv) | `uvm_test` |
| [`tests/uart_errors_test.sv`](../dv/uart/tests/uart_errors_test.sv) | `uart_base_test` |
| [`tests/uart_fifo_test.sv`](../dv/uart/tests/uart_fifo_test.sv) | `uart_base_test` |
| [`tests/uart_formats_test.sv`](../dv/uart/tests/uart_formats_test.sv) | `uart_base_test` |
| [`tests/uart_ral_test.sv`](../dv/uart/tests/uart_ral_test.sv) | `uart_base_test` |
| [`tests/uart_random_test.sv`](../dv/uart/tests/uart_random_test.sv) | `uart_base_test` |
| [`tests/uart_reset_test.sv`](../dv/uart/tests/uart_reset_test.sv) | `uart_base_test` |
| [`tests/uart_smoke_test.sv`](../dv/uart/tests/uart_smoke_test.sv) | `uart_base_test` |
| [`uart_agent.sv`](../dv/uart/uart_agent.sv) | `uvm_agent` |
| [`uart_cfg.sv`](../dv/uart/uart_cfg.sv) | `uvm_object` |
| [`uart_config_tracker.sv`](../dv/uart/uart_config_tracker.sv) | `uvm_subscriber` |
| [`uart_coverage.sv`](../dv/uart/uart_coverage.sv) | `uvm_subscriber` |
| [`uart_driver.sv`](../dv/uart/uart_driver.sv) | `uvm_driver` |
| [`uart_env.sv`](../dv/uart/uart_env.sv) | `uvm_env` |
| [`uart_item.sv`](../dv/uart/uart_item.sv) | `uvm_sequence_item` |
| [`uart_monitor.sv`](../dv/uart/uart_monitor.sv) | `uvm_monitor` |
| [`uart_reg_coverage.sv`](../dv/uart/uart_reg_coverage.sv) | `uvm_subscriber` |
| [`uart_scoreboard.sv`](../dv/uart/uart_scoreboard.sv) | `uvm_scoreboard` |
| [`uart_sequencer.sv`](../dv/uart/uart_sequencer.sv) | `uvm_sequencer` |
| [`uart_virtual_sequencer.sv`](../dv/uart/uart_virtual_sequencer.sv) | `uvm_sequencer` |
