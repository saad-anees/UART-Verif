# Class files and compile order

Every project class has its own `.svh` file named exactly after the class. For
example, `uart_driver` is in `tb/uart/uart_driver.svh`, and `uart_ctrl_reg` is in
`tb/uart/uart_ctrl_reg.svh`. The seven UART scenario tests are explicit classes;
there is no test-generation macro to expand while debugging.

The `.sv` package files contain imports, constants and ordered includes only.
Compile packages through `sim/generic.f` or `sim/uart.f`; do not compile `.svh`
class files separately. They inherit the package scope and its UVM imports.
Package include order is dependency order: items/configuration before agents,
registers before the register block, environment before sequences, and sequences
before tests. Editing a class does not require editing the file list.

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
| [`apb_item.svh`](../tb/common/apb_item.svh) | `uvm_sequence_item` |
| [`apb_cfg.svh`](../tb/common/apb_cfg.svh) | `uvm_object` |
| [`apb_sequencer.svh`](../tb/common/apb_sequencer.svh) | `uvm_sequencer` |
| [`apb_driver.svh`](../tb/common/apb_driver.svh) | `uvm_driver` |
| [`apb_monitor.svh`](../tb/common/apb_monitor.svh) | `uvm_monitor` |
| [`apb_coverage.svh`](../tb/common/apb_coverage.svh) | `uvm_subscriber` |
| [`apb_agent.svh`](../tb/common/apb_agent.svh) | `uvm_agent` |
| [`apb_reg_adapter.svh`](../tb/common/apb_reg_adapter.svh) | `uvm_reg_adapter` |
| [`apb_access_seq.svh`](../tb/common/apb_access_seq.svh) | `uvm_sequence` |
| [`ordered_scoreboard.svh`](../tb/common/ordered_scoreboard.svh) | `uvm_scoreboard` |
| [`base_virtual_sequencer.svh`](../tb/common/base_virtual_sequencer.svh) | `uvm_sequencer` |
| [`base_env.svh`](../tb/common/base_env.svh) | `uvm_env` |
| [`base_test.svh`](../tb/common/base_test.svh) | `uvm_test` |

## Generic demo

Package: [`demo_pkg.sv`](../tb/demo/demo_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`scratch_reg.svh`](../tb/demo/scratch_reg.svh) | `uvm_reg` |
| [`demo_block.svh`](../tb/demo/demo_block.svh) | `uvm_reg_block` |
| [`demo_env.svh`](../tb/demo/demo_env.svh) | `base_env` |
| [`generic_smoke_test.svh`](../tb/demo/generic_smoke_test.svh) | `base_test` |

## UART specialization

Package: [`uart_pkg.sv`](../tb/uart/uart_pkg.sv).

| Class file | Base class |
| --- | --- |
| [`uart_ctrl_reg.svh`](../tb/uart/uart_ctrl_reg.svh) | `uvm_reg` |
| [`uart_baud_reg.svh`](../tb/uart/uart_baud_reg.svh) | `uvm_reg` |
| [`uart_tx_reg.svh`](../tb/uart/uart_tx_reg.svh) | `uvm_reg` |
| [`uart_rx_reg.svh`](../tb/uart/uart_rx_reg.svh) | `uvm_reg` |
| [`uart_status_reg.svh`](../tb/uart/uart_status_reg.svh) | `uvm_reg` |
| [`uart_irq_en_reg.svh`](../tb/uart/uart_irq_en_reg.svh) | `uvm_reg` |
| [`uart_irq_status_reg.svh`](../tb/uart/uart_irq_status_reg.svh) | `uvm_reg` |
| [`uart_err_clear_reg.svh`](../tb/uart/uart_err_clear_reg.svh) | `uvm_reg` |
| [`uart_reg_block.svh`](../tb/uart/uart_reg_block.svh) | `uvm_reg_block` |
| [`uart_item.svh`](../tb/uart/uart_item.svh) | `uvm_sequence_item` |
| [`uart_cfg.svh`](../tb/uart/uart_cfg.svh) | `uvm_object` |
| [`uart_sequencer.svh`](../tb/uart/uart_sequencer.svh) | `uvm_sequencer` |
| [`uart_driver.svh`](../tb/uart/uart_driver.svh) | `uvm_driver` |
| [`uart_config_tracker.svh`](../tb/uart/uart_config_tracker.svh) | `uvm_subscriber` |
| [`uart_monitor.svh`](../tb/uart/uart_monitor.svh) | `uvm_monitor` |
| [`uart_agent.svh`](../tb/uart/uart_agent.svh) | `uvm_agent` |
| [`uart_scoreboard.svh`](../tb/uart/uart_scoreboard.svh) | `uvm_scoreboard` |
| [`uart_coverage.svh`](../tb/uart/uart_coverage.svh) | `uvm_subscriber` |
| [`uart_reg_coverage.svh`](../tb/uart/uart_reg_coverage.svh) | `uvm_subscriber` |
| [`uart_virtual_sequencer.svh`](../tb/uart/uart_virtual_sequencer.svh) | `base_virtual_sequencer` |
| [`uart_env.svh`](../tb/uart/uart_env.svh) | `base_env` |
| [`uart_send_seq.svh`](../tb/uart/uart_send_seq.svh) | `uvm_sequence` |
| [`uart_base_vseq.svh`](../tb/uart/uart_base_vseq.svh) | `uvm_sequence` |
| [`uart_smoke_vseq.svh`](../tb/uart/uart_smoke_vseq.svh) | `uart_base_vseq` |
| [`uart_ral_vseq.svh`](../tb/uart/uart_ral_vseq.svh) | `uart_base_vseq` |
| [`uart_formats_vseq.svh`](../tb/uart/uart_formats_vseq.svh) | `uart_base_vseq` |
| [`uart_random_vseq.svh`](../tb/uart/uart_random_vseq.svh) | `uart_base_vseq` |
| [`uart_errors_vseq.svh`](../tb/uart/uart_errors_vseq.svh) | `uart_base_vseq` |
| [`uart_fifo_vseq.svh`](../tb/uart/uart_fifo_vseq.svh) | `uart_base_vseq` |
| [`uart_reset_vseq.svh`](../tb/uart/uart_reset_vseq.svh) | `uart_base_vseq` |
| [`uart_base_test.svh`](../tb/uart/uart_base_test.svh) | `base_test` |
| [`uart_smoke_test.svh`](../tb/uart/uart_smoke_test.svh) | `uart_base_test` |
| [`uart_ral_test.svh`](../tb/uart/uart_ral_test.svh) | `uart_base_test` |
| [`uart_formats_test.svh`](../tb/uart/uart_formats_test.svh) | `uart_base_test` |
| [`uart_random_test.svh`](../tb/uart/uart_random_test.svh) | `uart_base_test` |
| [`uart_errors_test.svh`](../tb/uart/uart_errors_test.svh) | `uart_base_test` |
| [`uart_fifo_test.svh`](../tb/uart/uart_fifo_test.svh) | `uart_base_test` |
| [`uart_reset_test.svh`](../tb/uart/uart_reset_test.svh) | `uart_base_test` |

## Version history

`main` uses this class-per-file layout. The `v1.0-generic` and `v2.0-uart`
tags and `history/uart-uvm.bundle` retain the original published snapshots.
Historical logs may therefore mention the old combined filenames. The refactor
compile logs use the current filenames and are linked in [VALIDATION.md](VALIDATION.md).
