# Building, running and debugging

Run all commands from the repository root. The current tree defaults to the
UART testbench. Verification sources live in `dv/`, and testbench tops in `tb/`.

## VCS

```sh
make
make TEST=uart_errors_test SEED=7
make TEST=uart_random_test SEED=23 PLUSARGS="+N_FRAMES=300 +UVM_VERBOSITY=UVM_HIGH"
make regression SEEDS="1 7 23"
make coverage
```

`-ntb_opts uvm-1.2` selects the simulator's bundled UVM 1.2. `COV=1` adds line,
condition, toggle, branch and assertion coverage. Functional covergroups are
part of the SystemVerilog source. `make coverage` invokes URG across run databases.
Site-specific flags can be passed in `VCS_FLAGS`; tools can be overridden with
`VCS=/path/to/vcs`. License and installation configuration remain site-specific.

## Questa

```sh
make SIM=questa UVM_HOME=/tools/uvm-1.2
make SIM=questa UVM_HOME=/tools/uvm-1.2 TEST=uart_fifo_test
make regression SIM=questa UVM_HOME=/tools/uvm-1.2 SEEDS="1 7"
make coverage SIM=questa
```

The build compiles source UVM into a private work library. `UVM_NO_DPI` avoids
a platform-specific DPI shared-library build. This disables backdoor/regex and
some UVM command-line services; see README. Our frontdoor RAL operations and
explicit expected register tests need none of them. `VLOG_FLAGS` and `VSIM_FLAGS`
allow site-specific options. The build supports native Linux 64-bit tools; do
not mix a precompiled incompatible UVM library into the source-UVM work library.

`GUI=1` opens the GUI but the supplied run script still runs to completion and
quits. For interactive debugging, first run `make compile SIM=questa ...`, then
launch manually using the absolute work-library path shown by `make -n run` and
use the tool's waveform UI. `-voptargs=+acc` may be useful in `VSIM_FLAGS`.

## Outputs and regression behavior

Outputs live under `build/<sim>/uart/<test>_seed<seed>/`. Each run has a log
and its own coverage database. A repeated identical test/seed reuses that path;
copy results before re-running if you need both. Regression is sequential and
stops at the first failed command. It recompiles for each test for simplicity;
large projects should cache builds and separate build/run scheduling.

Do not run parallel Make jobs into the same UART build directory. `make clean`
removes only the repository's generated `build/` directory.

```sh
make -n run                         # inspect commands without simulator
make help
make COV=0
```

## Supplemental local checks

```sh
python3 -m pip install pyslang
python3 scripts/static_compile.py --uvm-home /tools/uvm-1.2
make rtl-check VERILATOR=verilator
```

`static_compile.py` checks parsing, class/type resolution and elaboration using
pyslang. It is not a simulator and cannot prove that a test passes.
`rtl-check` runs the independent RTL test under Verilator with timing enabled.
It cannot replace VCS/Questa UVM functional coverage. UVM itself is not added to
that RTL-only command.

The authoring environment used Accellera UVM 1.2, pyslang 12.0.0 and Verilator
5.49. See the validation document for exactly what ran.

## Typical failures

| Symptom | Check |
| --- | --- |
| Cannot locate `uvm_pkg.sv` | Set UVM_HOME to the root containing src/ |
| Unknown test | Match test class name exactly and inspect compile log |
| Null virtual interface fatal | Top configuration paths must match `uvm_test_top.env` |
| RAL read fails | Check access policy, empty FIFO, DUT response and address map |
| Scoreboard leftovers | Missing output, unread RX entries or insufficient drain |
| Coverage utility unavailable | License/PATH; simulation may still be usable with COV=0 |
| Reconfiguration rejected | Wait for TX and external RX to be idle |

A simulator binary returning exit code zero is insufficient by itself. The log
checker is part of the run target and requires the test's success marker.
