# Reuse boundaries and known limitations

## UART/APB ownership

This `uart-apb` branch contains a self-contained UART environment. APB components
are under `dv/uart/apb`, the adapter and registers under `ral`, stimulus under
`seq_lib`, and tests under `tests`. There are no project-specific common base
classes or common package imports. The standard Accellera UVM library is required.

The `main` branch retains the shared-component architecture for reuse examples.

## Fixed assumptions in this version

- The UVM scoreboard models a four-entry RX FIFO. RTL RX_DEPTH is parameterized,
  but changing it alone is not a supported testbench configuration.
- The top clock is 100 MHz; scoreboard TX timing uses a 10 ns clock period.
  Change both together or extend configuration to measure the clock.
- RX/TX are 8-bit frames. Parity and one/two stop bits are programmable.
- Serial stimulus is synchronous to testbench clock edges, not a jitter source.
- APB is always active in the supplied environments, though the reusable bus
  agent supports passive construction. A passive system needs another master.
- The environment's configuration tracker follows accepted writes. A serial
  monitor snapshots that observed configuration at each frame start.
- The serial monitor checks decoded contents and sampled parity/stop levels; it
  does not comprehensively measure edge-to-edge baud accuracy or pulse widths.

## RX commit timing window

The receiver uses two synchronizer stages. The pin monitor completes decoding
near the final stop center before the RTL exposes that byte. The scoreboard
queues the expected byte at monitor completion but masks dynamic RX/status
comparisons for four peripheral clocks. It still checks TX busy and reserved
STATUS bits. Directed reads occur after the serial driver completes the frame
and an idle gap, so they compare full stable state.

This is an **architectural**, not cycle-exact, RX model. A bus pop on the exact
receive-completion edge is not supported by its ordering assumptions, even
though the RTL defines coincident pop/push behavior. Production extensions should
carry timestamps/commit events into an ordered model and test those collisions
explicitly. Do not hide such a limitation by merely increasing delays or turning
off scoreboard checking globally.

## Reset and concurrent activity

Runtime reset supports in-flight serial traffic with the APB bus idle. The
serial driver reports aborted frames; monitor tasks are cancelled; RAL and
scoreboard states are reset. A scoreboard reset discard is not counted as a
successful comparison. APB mid-transfer reset, multi-clock reset release and
metastability analysis are outside this example.

## UART feature scope

This IP is original educational RTL, not a copied open-source 16550 core and not
production-qualified. No modem flow control, break detection, fractional baud,
autobaud, DMA, TX FIFO, power management, low-power crossings or bus protection
signals are implemented. Add only features backed by a specification, and extend
both the register model and independent checking accordingly.

The supplied functional coverage includes diagnostic bins that require review
and exclusions before a closure target can be defined. There is no claim that
this environment covers every possible UART, every timing corner or every
commercial simulator version.

## Reference material

The implementation uses the explicit-predictor RAL integration described in the
Accellera UVM 1.2 User's Guide:
https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf

APB signal timing and error-response semantics are based on Arm's APB protocol:
https://documentation-service.arm.com/static/60d5b617677cf7536a55c273

These sources describe the standards. The register layout, UART RTL, tests and
learning guide in this repository are original project material.
