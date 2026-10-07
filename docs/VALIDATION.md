# Validation record — 2026-10-06

## Results actually obtained

| Check | Result | Evidence |
| --- | --- | --- |
| UART UVM + RTL semantic compile, pyslang 12.0.0 | PASS, zero errors | `evidence/uart-static.log` |
| UART RTL behavioral simulation, Verilator 5.49 | PASS, 438 checks | `evidence/rtl-smoke.log` |
| `uart_smoke_test` | PASS, TX 1 / RX 1 checked | `evidence/uart_smoke_test.log` |
| `uart_ral_test` | PASS, TX 1, 15 expected bus errors | `evidence/uart_ral_test.log` |
| `uart_formats_test` | PASS, TX 216 / RX 216 checked | `evidence/uart_formats_test.log` |
| `uart_errors_test` | PASS, RX 6 checked | `evidence/uart_errors_test.log` |
| `uart_fifo_test` | PASS, RX 12 checked, 6 overflows | `evidence/uart_fifo_test.log` |
| `uart_reset_test` | PASS, TX 2 / RX 2 checked, partial work discarded | `evidence/uart_reset_test.log` |
| `uart_random_test` | NOT VALIDATED: Verilator internal runtime failure | `evidence/uart_random_test.log` |
| Log pass/fail gate | PASS, nine synthetic success/failure fixtures | `scripts/test_log_checker.py` |
| VCS and Questa command expansion | Checked with `make -C sim -n` | Makefile |
| Actual VCS or Questa compile/simulation | NOT RUN: tools unavailable | No claim of simulator qualification |
| Commercial functional/code coverage | NOT COLLECTED | No closure percentage claimed |

The two static-compilation warnings are empty-loop-body warnings inside the
unmodified Accellera UVM 1.2 source, not project errors.

The six passing UVM executions used Accellera UVM 1.2, `UVM_NO_DPI`, Verilator
5.49, timing and assertions enabled. They used the simulator's default seed;
these directed tests do not randomize stimulus. Verilator ignored the project's
covergroups with COVERIGN warnings. The 0.00% coverage printed in these logs is
not a functional coverage measurement.

For the randomized test, Z3 was installed and selected as the constraint solver.
The run with `+verilator+seed+1` aborted inside Verilator's own
`verilated_std.sv`, in `process::killQueue`, with a null-pointer error. The same
failure occurred with one requested frame. This is not evidence that the random
UVM scenario passes, nor does it establish whether a commercial run will reveal
other issues. Run `uart_random_test` under VCS/Questa before relying on it.

## Reproduce the portable checks

```sh
python3 scripts/static_compile.py --uvm-home /path/to/uvm-1.2
python3 scripts/test_log_checker.py
make -C sim rtl-check VERILATOR=verilator
```

## Supplementary UVM command used

The following is an optional diagnostic experiment, not a third supported
Makefile simulator flow. Current Verilator/UVM compatibility is release-dependent.

```sh
verilator --binary --timing --assert -Wno-fatal -j 4 -CFLAGS -O0 \
  +incdir+/path/to/uvm-1.2/src +define+UVM_NO_DPI \
  /path/to/uvm-1.2/src/uvm_pkg.sv -f sim/uart.f --top-module tb_top \
  --Mdir /tmp/uart-uvm-obj
/tmp/uart-uvm-obj/Vtb_top +UVM_TESTNAME=uart_smoke_test
```

The pip-distributed Verilator build in the authoring environment also required
fixing its generated Make invocation's precompiled-header include option. The
retry was:

```sh
make -C /tmp/uart-uvm-obj -f Vtb_top.mk -j 4 \
  CFG_CXXFLAGS_PCH_I=-include CXX='c++ --std=c++20 -DVL_TIME_CONTEXT'
```

No UVM or simulator source was modified. Coverage remained unsupported in that
supplementary run. VCS and Questa are the intended paths for the full regression
and coverage reports.


## Self-contained UART/APB branch — 2026-10-07

This branch has 47 explicit class files. The UART environment now owns APB agent,
RAL adapter/predictor and register-model wiring directly. `uart_env` derives from
`uvm_env`, `uart_virtual_sequencer` from `uvm_sequencer`, and `uart_base_test`
from `uvm_test`. There is no project-specific common package or base-class layer.
The sole observed-APB RAL prediction path, serial agent, scoreboard and coverage
connections are retained. The base test retains timeout, topology and pass/fail reporting.

Current semantic compilation evidence: [UART/APB compile](evidence/uart-apb-static.log).
Makefile commands for VCS/Questa and regression were dry-run checked from `sim/`.
Runtime simulation was not repeated for this branch; earlier behavioral results
above are from the shared architecture and do not qualify this refactor under
licensed VCS/Questa. The standard UVM library is still required.
