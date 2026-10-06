# Verification plan and coverage interpretation

## Test-to-requirement map

| Requirement | UVM test | Checker |
| --- | --- | --- |
| One valid TX and RX, 8N1 | `uart_smoke_test` | Scoreboard and nonzero comparison counts |
| Reset values, stable RW fields, mirror, update | `uart_ral_test` | Explicit reads, RAL UVM_CHECK |
| Unmapped, misaligned, RO/WO violations | `uart_ral_test` | Expected APB error |
| Disabled TX, TX busy, configuration while TX busy | `uart_ral_test` | Expected APB error, original TX still checked |
| Invalid divisors, reserved bits | `uart_ral_test` | Errors and readback |
| All 3 parity modes × 2 stop modes × 3 divisors × 2 directions | `uart_formats_test` | TX/RX scoreboard, format cross |
| Zero, ones, alternating and walking-one data | `uart_formats_test` | Data scoreboard and payload bins |
| Random full-duplex traffic | `uart_random_test` | Independent TX and RX comparisons |
| Bad parity, stop, and both | `uart_errors_test` | Error flags, retained byte, coverage |
| Sticky errors, W1C zero, selective clear | `uart_errors_test` | STATUS/IRQ readback and pin checks |
| IRQ masked/pending/unmasked and RX drain | `uart_errors_test` | IRQ pin plus IRQ_STATUS |
| FIFO fill, overflow, discard-new, pointer wrap | `uart_fifo_test` | Queue model, W1C, overflow counters |
| Reset with queued RX, error and in-flight TX | `uart_reset_test` | Flushed expectations, reset reads, recovery |
| Reset during incoming frame | `uart_reset_test` | Driver abort flag and post-reset traffic |
| APB setup/access/wait stability | Every UVM test | Interface SVA |
| False start shorter than half bit | Supplemental `rtl_smoke` | Empty STATUS followed by valid RX |

## Functional coverage

`apb_coverage` records direction, response and latency. The example UART is
zero-wait, so wait-state bins are reusable agent goals, **unreachable for this
DUT**. They are not an unclosed UART requirement.

`uart_coverage` samples observed frames, not generated transactions. The format
cross has 36 combinations: two directions, three parity modes, two stop choices
and three divisors. The directed format test targets all of them. TX parity/stop
error combinations are excluded from the injected-error cross, because the DUT
is expected to generate correct frames. RX error combinations are intentionally
exercised.

`uart_reg_coverage` records address, direction, response and status values. Its
broad diagnostic access cross includes combinations which are illegal or
unreachable for individual registers, and its broad status bins include unused
flag combinations. Do not use its aggregate percentage as a closure target.
Before production signoff, refine it into requirement-specific bins and approved
exclusions, then review actual coverage reports.

The testbench prints frame coverage, but this package contains **no measured
functional coverage closure claim**. Static elaboration and the supplemental
RTL test do not collect commercial-simulator covergroups. Code, assertion and
functional coverage must be collected and reviewed with the requested simulator.

## Pass/fail

A run must finish, print TEST PASSED, have no UVM_ERROR/UVM_FATAL and no detected
assertion/simulator errors. `scripts/check_log.py` turns log failures into a
nonzero Make result. A watchdog, bounded APB waits and bounded TX polling prevent
an indefinitely hung regression. `check_phase` rejects unread expected RX data or
unmatched TX frames. Reset-induced discards are counted separately from checks.

A passing RAL-only test can have zero RX frames by design; a passing smoke test
must check one transfer in each direction. The format test generates 216 TX and
216 RX frames. The random test defaults to 100 TX/RX pairs per seed. FIFO testing
sends 18 frames, checks 12 retained bytes and expects six overflows.

## Deliberate remaining extensions

Not implemented as UVM closure tests: precise baud tolerance/jitter, exact
back-to-back frames with zero extra idle time, break detection, noise/glitches
beyond the supplemental false-start check, arbitrary asynchronous RX phase,
simultaneous FIFO pop/receive at the commit edge, hardware clear/error collisions,
configuration while RX is active, divisors 4 and 65535, and reset during APB.
RTS/CTS, 5/6/7/9-bit formats, DMA and TX FIFO are not supported DUT features.
See `06_scope.md` for why these distinctions matter.
