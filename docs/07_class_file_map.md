# Class files and compile order

Every project class has its own `.sv` file named exactly after the class. For
example, `uart_driver` is in `tb/uart/uart_driver.sv`, and `uart_ctrl_reg` is in
`tb/uart/ral/uart_ctrl_reg.sv`. The seven UART scenario tests are explicit classes;
there is no test-generation macro to expand while debugging.

The `.sv` package files contain imports, constants and ordered includes only.
Compile packages through `sim/generic.f` or `sim/uart.f`; do not compile the included class `.sv`
files separately: the package includes them exactly once. They inherit the package scope and its UVM imports.
Package include order is dependency order: items/configuration before agents,
registers before the register block, environment before sequences, and sequences
before tests. Editing a class does not require editing the file list.

## Sequence libraries

- `tb/common/seq_lib/`: reusable APB access sequence.
- `tb/uart/seq_lib/`: UART sender, base virtual sequence, and seven scenario sequences.

Package includes use `seq_lib/<class_name>.sv`. Sequencers remain with the
agents/environment because they are components rather than stimulus sequences.

## Register models and tests

| Directory | Contents |
| --- | --- |
| `tb/common/ral/` | Reusable APB register adapter |
| `tb/demo/ral/` | Scratch register class and demo register block |
| `tb/uart/ral/` | Eight UART register classes and UART register block |
| `tb/common/tests/` | Reusable base test |
| `tb/demo/tests/` | Generic smoke test |
| `tb/uart/tests/` | UART base test and seven scenario tests |

RAL programming sequences stay in `seq_lib/`; they use the models in `ral/`.
Package includes preserve dependency order across these directories.

## Testbench module filenames

| File | Module | Role |
| --- | --- | --- |
| [`tb/demo/generic_demo_tb_top.sv`](../tb/demo/generic_demo_tb_top.sv) | `demo_top` | Generic APB/RAL demo top |
| [`tb/uart/uart_tb_top.sv`](../tb/uart/uart_tb_top.sv) | `tb_top` | UART UVM top |
| [`tb/uart_rtl_smoke_tb.sv`](../tb/uart_rtl_smoke_tb.sv) | `rtl_smoke` | Standalone UART RTL checks |

Module and class names remain compatible with the existing simulator commands.

## Reusable foundation

Package: [`common_pkg.sv`](../tb/common/common_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`apb_item.sv`](../tb/common/apb_item.sv) | `uvm_sequence_item` |
| [`apb_cfg.sv`](../tb/common/apb_cfg.sv) | `uvm_object` |
| [`apb_sequencer.sv`](../tb/common/apb_sequencer.sv) | `uvm_sequencer` |
| [`apb_driver.sv`](../tb/common/apb_driver.sv) | `uvm_driver` |
| [`apb_monitor.sv`](../tb/common/apb_monitor.sv) | `uvm_monitor` |
| [`apb_coverage.sv`](../tb/common/apb_coverage.sv) | `uvm_subscriber` |
| [`apb_agent.sv`](../tb/common/apb_agent.sv) | `uvm_agent` |
| [`apb_reg_adapter.sv`](../tb/common/ral/apb_reg_adapter.sv) | `uvm_reg_adapter` |
| [`apb_access_seq.sv`](../tb/common/seq_lib/apb_access_seq.sv) | `uvm_sequence` |
| [`ordered_scoreboard.sv`](../tb/common/ordered_scoreboard.sv) | `uvm_scoreboard` |
| [`base_virtual_sequencer.sv`](../tb/common/base_virtual_sequencer.sv) | `uvm_sequencer` |
| [`base_env.sv`](../tb/common/base_env.sv) | `uvm_env` |
| [`base_test.sv`](../tb/common/tests/base_test.sv) | `uvm_test` |

## Generic demo

Package: [`demo_pkg.sv`](../tb/demo/demo_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`scratch_reg.sv`](../tb/demo/ral/scratch_reg.sv) | `uvm_reg` |
| [`demo_block.sv`](../tb/demo/ral/demo_block.sv) | `uvm_reg_block` |
| [`demo_env.sv`](../tb/demo/demo_env.sv) | `base_env` |
| [`generic_smoke_test.sv`](../tb/demo/tests/generic_smoke_test.sv) | `base_test` |

## UART specialization

Package: [`uart_pkg.sv`](../tb/uart/uart_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`uart_ctrl_reg.sv`](../tb/uart/ral/uart_ctrl_reg.sv) | `uvm_reg` |
| [`uart_baud_reg.sv`](../tb/uart/ral/uart_baud_reg.sv) | `uvm_reg` |
| [`uart_tx_reg.sv`](../tb/uart/ral/uart_tx_reg.sv) | `uvm_reg` |
| [`uart_rx_reg.sv`](../tb/uart/ral/uart_rx_reg.sv) | `uvm_reg` |
| [`uart_status_reg.sv`](../tb/uart/ral/uart_status_reg.sv) | `uvm_reg` |
| [`uart_irq_en_reg.sv`](../tb/uart/ral/uart_irq_en_reg.sv) | `uvm_reg` |
| [`uart_irq_status_reg.sv`](../tb/uart/ral/uart_irq_status_reg.sv) | `uvm_reg` |
| [`uart_err_clear_reg.sv`](../tb/uart/ral/uart_err_clear_reg.sv) | `uvm_reg` |
| [`uart_reg_block.sv`](../tb/uart/ral/uart_reg_block.sv) | `uvm_reg_block` |
| [`uart_item.sv`](../tb/uart/uart_item.sv) | `uvm_sequence_item` |
| [`uart_cfg.sv`](../tb/uart/uart_cfg.sv) | `uvm_object` |
| [`uart_sequencer.sv`](../tb/uart/uart_sequencer.sv) | `uvm_sequencer` |
| [`uart_driver.sv`](../tb/uart/uart_driver.sv) | `uvm_driver` |
| [`uart_config_tracker.sv`](../tb/uart/uart_config_tracker.sv) | `uvm_subscriber` |
| [`uart_monitor.sv`](../tb/uart/uart_monitor.sv) | `uvm_monitor` |
| [`uart_agent.sv`](../tb/uart/uart_agent.sv) | `uvm_agent` |
| [`uart_scoreboard.sv`](../tb/uart/uart_scoreboard.sv) | `uvm_scoreboard` |
| [`uart_coverage.sv`](../tb/uart/uart_coverage.sv) | `uvm_subscriber` |
| [`uart_reg_coverage.sv`](../tb/uart/uart_reg_coverage.sv) | `uvm_subscriber` |
| [`uart_virtual_sequencer.sv`](../tb/uart/uart_virtual_sequencer.sv) | `base_virtual_sequencer` |
| [`uart_env.sv`](../tb/uart/uart_env.sv) | `base_env` |
| [`uart_send_seq.sv`](../tb/uart/seq_lib/uart_send_seq.sv) | `uvm_sequence` |
| [`uart_base_vseq.sv`](../tb/uart/seq_lib/uart_base_vseq.sv) | `uvm_sequence` |
| [`uart_smoke_vseq.sv`](../tb/uart/seq_lib/uart_smoke_vseq.sv) | `uart_base_vseq` |
| [`uart_ral_vseq.sv`](../tb/uart/seq_lib/uart_ral_vseq.sv) | `uart_base_vseq` |
| [`uart_formats_vseq.sv`](../tb/uart/seq_lib/uart_formats_vseq.sv) | `uart_base_vseq` |
| [`uart_random_vseq.sv`](../tb/uart/seq_lib/uart_random_vseq.sv) | `uart_base_vseq` |
| [`uart_errors_vseq.sv`](../tb/uart/seq_lib/uart_errors_vseq.sv) | `uart_base_vseq` |
| [`uart_fifo_vseq.sv`](../tb/uart/seq_lib/uart_fifo_vseq.sv) | `uart_base_vseq` |
| [`uart_reset_vseq.sv`](../tb/uart/seq_lib/uart_reset_vseq.sv) | `uart_base_vseq` |
| [`uart_base_test.sv`](../tb/uart/tests/uart_base_test.sv) | `base_test` |
| [`uart_smoke_test.sv`](../tb/uart/tests/uart_smoke_test.sv) | `uart_base_test` |
| [`uart_ral_test.sv`](../tb/uart/tests/uart_ral_test.sv) | `uart_base_test` |
| [`uart_formats_test.sv`](../tb/uart/tests/uart_formats_test.sv) | `uart_base_test` |
| [`uart_random_test.sv`](../tb/uart/tests/uart_random_test.sv) | `uart_base_test` |
| [`uart_errors_test.sv`](../tb/uart/tests/uart_errors_test.sv) | `uart_base_test` |
| [`uart_fifo_test.sv`](../tb/uart/tests/uart_fifo_test.sv) | `uart_base_test` |
| [`uart_reset_test.sv`](../tb/uart/tests/uart_reset_test.sv) | `uart_base_test` |

## Version history

`main` uses this class-per-file layout. The `v1.0-generic` and `v2.0-uart`
tags and `history/uart-uvm.bundle` retain the original published snapshots.
Historical logs may therefore mention the old combined filenames. The latest `.sv` layout
compile logs use the current filenames and are linked in [VALIDATION.md](VALIDATION.md).
