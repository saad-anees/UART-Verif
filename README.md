# Generic UVM learning foundation — v1.0-generic

This is a runnable UVM 1.2 foundation with an APB3 agent, adapter, explicit
RAL predictor, base environment, virtual sequencer, reusable ordered comparator,
functional bus coverage, interface assertions and a scratch-register demo.

Run `make` (VCS default) or `make SIM=questa UVM_HOME=/path/to/uvm-1.2`.
Both commands run `generic_smoke_test`. Requires licensed simulator executables
on PATH; UVM itself is not vendored. Questa uses source UVM with `UVM_NO_DPI`
for this example, which uses no DPI-dependent features.

## What generic means
The UVM lifecycle, APB agent, RAL integration, logging and build flow are reused.
No testbench can verify arbitrary IP without knowing its specification. Replace
the bus agent for AXI/AHB/etc., supply a register block, add functional protocol
agents and a reference model. Derive from `base_env` and override
`create_register_model()`; override `create_virtual_sequencer()` to add handles.
`demo_env` shows the minimum working integration. The comparator is a reusable
extension point; it is not connected in the register-only demo, whose RAL mirror
checks supply the checking.

Read code in this order: interface → item → monitor → driver → agent → adapter
→ demo register block → base environment → demo test → top. Driver requests
never directly feed a functional scoreboard: monitor observations must do that.
See the next Git tag, `v2.0-uart`, for a complete peripheral specialization.

## References
- Accellera UVM 1.2 user guide: https://www.accellera.org/images/downloads/standards/uvm/uvm_users_guide_1.2.pdf
- Arm APB specification: https://documentation-service.arm.com/static/60d5b617677cf7536a55c273

Original example code is MIT licensed. Commercial simulator execution has not
been performed in the authoring environment; validate with your installed tools.
