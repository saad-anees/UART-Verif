# UART UVM learning repository

Two real Git versions, an original UART peripheral, and an end-to-end UVM 1.2
environment. VCS is the default simulator; Questa is selectable.

## Start here

```sh
make                                      # UART smoke, VCS, seed 1
make TEST=uart_formats_test
make TEST=uart_random_test SEED=23 PLUSARGS="+N_FRAMES=200"
make regression                           # seven tests × three seeds
make coverage                             # VCS URG report
make SIM=questa UVM_HOME=/tools/uvm-1.2
make regression SIM=questa UVM_HOME=/tools/uvm-1.2
make coverage SIM=questa
make SUITE=generic                        # original register-only example
```

Linux, GNU Make, Python 3 and licensed VCS or Questa executables on PATH are
required for these commands. `UVM_HOME` means the directory containing `src/`.
VCS uses bundled UVM 1.2. Questa compiles your UVM 1.2 source with `UVM_NO_DPI`;
this example needs no backdoor, DPI regex or DPI command-line services.
UVM's fallback still supports `+UVM_TESTNAME` and `+UVM_VERBOSITY`, and the
custom `+N_FRAMES` uses `$value$plusargs`. Do not assume all UVM command-line
factory/configuration switches work in this no-DPI mode.

The repository does not include a third-party UVM library. Obtain it from
https://www.accellera.org/downloads/standards/uvm .

## Source organization

Each of the 55 project classes lives in its own class-named `.sv` file.
For example: `apb_driver.sv`, `uart_scoreboard.sv`, `uart_ctrl_reg.sv`,
`uart_smoke_vseq.sv` and `uart_smoke_test.sv`. Package `.sv` files contain
only imports, constants and includes in dependency order. See the
[class file map](docs/07_class_file_map.md) for every class and the descriptive
testbench module filenames. Compile the packages using the supplied file lists;
Class `.sv` files are included by their package, not compiled twice as standalone units.
Sequences live under `seq_lib/`. Register models and the APB RAL adapter live
under `ral/`, and all test classes live under `tests/` within their owning
`tb/common`, `tb/demo` or `tb/uart` directory.

## What's included

- Reusable APB3 item, sequencer, driver, monitor, active/passive agent, coverage,
  timeout handling, adapter and observed-transaction RAL predictor.
- Generic base environment, virtual sequencer, test and ordered comparator.
- Runnable generic scratch-register example.
- Synthesizable teaching UART: APB register interface, 8-bit full-duplex data,
  programmable clocks per bit, no/even/odd parity, one/two stop bits, four-byte
  RX FIFO, sticky parity/framing/overrun flags, write-one-to-clear and IRQ masks.
- Named-field RAL model for eight registers; frontdoor write/read/mirror/update
  examples, with volatility and FIFO side effects treated explicitly.
- Active serial RX driver, independent RX/TX monitor, reset abort handling,
  observed-bus configuration tracking and virtual sequences.
- Architectural scoreboard, frame/register functional coverage, APB assertions,
  seven directed/random UVM tests and reproducible regression seeds.
- Supplemental plain-SystemVerilog RTL test and Python static-compile helper.

This is a substantial learning/reference implementation, not a claim of
production verification closure or a drop-in verifier for every UART. Read
[scope and limitations](docs/06_scope.md), especially the receive-commit timing
window and the fixed four-entry scoreboard model.

## Learn in order

1. [Architecture and UVM concepts](docs/01_learning_guide.md)
2. [UART register and timing specification](docs/02_uart_spec.md)
3. [RAL walkthrough](docs/03_ral_walkthrough.md)
4. [Verification plan and coverage](docs/04_verification_plan.md)
5. [Simulator commands and debugging](docs/05_running.md)
6. [Reuse boundaries and extension exercises](docs/06_scope.md)
7. [Actual validation evidence](docs/VALIDATION.md)

## Two Git versions

| Tag | Content |
| --- | --- |
| `v1.0-generic` | Reusable foundation plus runnable scratch-register demo |
| `v2.0-uart` | UART RTL, complete specialization, tests and learning guide |

The downloadable ZIP contains the current source tree and a Git bundle in
`history/uart-uvm.bundle`. To restore a normal repository with both tags:

```sh
git clone history/uart-uvm.bundle ../uart-uvm-git
cd ../uart-uvm-git
git log --oneline --decorate
git diff v1.0-generic..v2.0-uart --stat
git switch --detach v1.0-generic
make                                  # generic demo in version 1
git switch main                       # return to UART version
```

Published at https://github.com/saad-anees/UART-Verif. If you clone this GitHub
repository, both version tags are available directly. Browser publication creates
several upload commits; `history/uart-uvm.bundle` preserves the original two-commit
history and original tag objects. All project-owned source is original and MIT
licensed; the UART is intentionally small enough to read in one sitting.
