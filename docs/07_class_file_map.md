# Class files and compile order

Every project class has its own `.sv` file named exactly after the class. For
example, `uart_driver` is in `dv/uart/uart_driver.sv`, and `uart_ctrl_reg` is in
`dv/uart/ral/uart_ctrl_reg.sv`. The seven UART scenario tests are explicit classes;
there is no test-generation macro to expand while debugging.

The `.sv` package files contain imports, constants and ordered includes only.
Compile packages through `sim/uart.f`; do not compile the included class `.sv`
files separately: the package includes them exactly once. They inherit the package scope and its UVM imports.
Package include order is dependency order: items/configuration before agents,
registers before the register block, environment before sequences, and sequences
before tests. Editing a class does not require editing the file list.

## Sequence libraries

- `dv/common/seq_lib/`: reusable APB access sequence.
- `dv/uart/seq_lib/`: UART sender, base virtual sequence, and seven scenario sequences.

Package includes use `seq_lib/<class_name>.sv`. Sequencers remain with the
agents/environment because they are components rather than stimulus sequences.

## Register models and tests

| Directory | Contents |
| --- | --- |
| `dv/common/ral/` | Reusable APB register adapter |
| `dv/uart/ral/` | Eight UART register classes and UART register block |
| `dv/common/tests/` | Reusable base test |
| `dv/uart/tests/` | UART base test and seven scenario tests |

RAL programming sequences stay in `seq_lib/`; they use the models in `ral/`.
Package includes preserve dependency order across these directories.

## Testbench module filenames

| File | Module | Role |
| --- | --- | --- |
| [`tb/uart_tb_top.sv`](../tb/uart_tb_top.sv) | `tb_top` | UART UVM top |
| [`tb/uart_rtl_smoke_tb.sv`](../tb/uart_rtl_smoke_tb.sv) | `rtl_smoke` | Standalone UART RTL checks |

Module and class names remain compatible with the existing simulator commands.

## Reusable foundation

Package: [`common_pkg.sv`](../dv/common/common_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`apb_item.sv`](../dv/common/apb_item.sv) | `uvm_sequence_item` |
| [`apb_cfg.sv`](../dv/common/apb_cfg.sv) | `uvm_object` |
| [`apb_sequencer.sv`](../dv/common/apb_sequencer.sv) | `uvm_sequencer` |
| [`apb_driver.sv`](../dv/common/apb_driver.sv) | `uvm_driver` |
| [`apb_monitor.sv`](../dv/common/apb_monitor.sv) | `uvm_monitor` |
| [`apb_coverage.sv`](../dv/common/apb_coverage.sv) | `uvm_subscriber` |
| [`apb_agent.sv`](../dv/common/apb_agent.sv) | `uvm_agent` |
| [`apb_reg_adapter.sv`](../dv/common/ral/apb_reg_adapter.sv) | `uvm_reg_adapter` |
| [`apb_access_seq.sv`](../dv/common/seq_lib/apb_access_seq.sv) | `uvm_sequence` |
| [`ordered_scoreboard.sv`](../dv/common/ordered_scoreboard.sv) | `uvm_scoreboard` |
| [`base_virtual_sequencer.sv`](../dv/common/base_virtual_sequencer.sv) | `uvm_sequencer` |
| [`base_env.sv`](../dv/common/base_env.sv) | `uvm_env` |
| [`base_test.sv`](../dv/common/tests/base_test.sv) | `uvm_test` |

## UART specialization

Package: [`uart_pkg.sv`](../dv/uart/uart_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`uart_ctrl_reg.sv`](../dv/uart/ral/uart_ctrl_reg.sv) | `uvm_reg` |
| [`uart_baud_reg.sv`](../dv/uart/ral/uart_baud_reg.sv) | `uvm_reg` |
| [`uart_tx_reg.sv`](../dv/uart/ral/uart_tx_reg.sv) | `uvm_reg` |
| [`uart_rx_reg.sv`](../dv/uart/ral/uart_rx_reg.sv) | `uvm_reg` |
| [`uart_status_reg.sv`](../dv/uart/ral/uart_status_reg.sv) | `uvm_reg` |
| [`uart_irq_en_reg.sv`](../dv/uart/ral/uart_irq_en_reg.sv) | `uvm_reg` |
| [`uart_irq_status_reg.sv`](../dv/uart/ral/uart_irq_status_reg.sv) | `uvm_reg` |
| [`uart_err_clear_reg.sv`](../dv/uart/ral/uart_err_clear_reg.sv) | `uvm_reg` |
| [`uart_reg_block.sv`](../dv/uart/ral/uart_reg_block.sv) | `uvm_reg_block` |
| [`uart_item.sv`](../dv/uart/uart_item.sv) | `uvm_sequence_item` |
| [`uart_cfg.sv`](../dv/uart/uart_cfg.sv) | `uvm_object` |
| [`uart_sequencer.sv`](../dv/uart/uart_sequencer.sv) | `uvm_sequencer` |
| [`uart_driver.sv`](../dv/uart/uart_driver.sv) | `uvm_driver` |
| [`uart_config_tracker.sv`](../dv/uart/uart_config_tracker.sv) | `uvm_subscriber` |
| [`uart_monitor.sv`](../dv/uart/uart_monitor.sv) | `uvm_monitor` |
| [`uart_agent.sv`](../dv/uart/uart_agent.sv) | `uvm_agent` |
| [`uart_scoreboard.sv`](../dv/uart/uart_scoreboard.sv) | `uvm_scoreboard` |
| [`uart_coverage.sv`](../dv/uart/uart_coverage.sv) | `uvm_subscriber` |
| [`uart_reg_coverage.sv`](../dv/uart/uart_reg_coverage.sv) | `uvm_subscriber` |
| [`uart_virtual_sequencer.sv`](../dv/uart/uart_virtual_sequencer.sv) | `base_virtual_sequencer` |
| [`uart_env.sv`](../dv/uart/uart_env.sv) | `base_env` |
| [`uart_send_seq.sv`](../dv/uart/seq_lib/uart_send_seq.sv) | `uvm_sequence` |
| [`uart_base_vseq.sv`](../dv/uart/seq_lib/uart_base_vseq.sv) | `uvm_sequence` |
| [`uart_smoke_vseq.sv`](../dv/uart/seq_lib/uart_smoke_vseq.sv) | `uart_base_vseq` |
| [`uart_ral_vseq.sv`](../dv/uart/seq_lib/uart_ral_vseq.sv) | `uart_base_vseq` |
| [`uart_formats_vseq.sv`](../dv/uart/seq_lib/uart_formats_vseq.sv) | `uart_base_vseq` |
| [`uart_random_vseq.sv`](../dv/uart/seq_lib/uart_random_vseq.sv) | `uart_base_vseq` |
| [`uart_errors_vseq.sv`](../dv/uart/seq_lib/uart_errors_vseq.sv) | `uart_base_vseq` |
| [`uart_fifo_vseq.sv`](../dv/uart/seq_lib/uart_fifo_vseq.sv) | `uart_base_vseq` |
| [`uart_reset_vseq.sv`](../dv/uart/seq_lib/uart_reset_vseq.sv) | `uart_base_vseq` |
| [`uart_base_test.sv`](../dv/uart/tests/uart_base_test.sv) | `base_test` |
| [`uart_smoke_test.sv`](../dv/uart/tests/uart_smoke_test.sv) | `uart_base_test` |
| [`uart_ral_test.sv`](../dv/uart/tests/uart_ral_test.sv) | `uart_base_test` |
| [`uart_formats_test.sv`](../dv/uart/tests/uart_formats_test.sv) | `uart_base_test` |
| [`uart_random_test.sv`](../dv/uart/tests/uart_random_test.sv) | `uart_base_test` |
| [`uart_errors_test.sv`](../dv/uart/tests/uart_errors_test.sv) | `uart_base_test` |
| [`uart_fifo_test.sv`](../dv/uart/tests/uart_fifo_test.sv) | `uart_base_test` |
| [`uart_reset_test.sv`](../dv/uart/tests/uart_reset_test.sv) | `uart_base_test` |

## Source roots

`dv/` owns UVM classes, package assembly and interfaces. `tb/` contains only
the two testbench modules listed above. `rtl/` contains only the UART IP.
Compile `sim/uart.f`; all class `.sv` units are included once by their package.
