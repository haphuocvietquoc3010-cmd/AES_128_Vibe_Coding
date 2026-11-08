# Project Structure

## RTL (`rtl/`)

- `aes128_core.sv`: stable PDF-compatible top-level ports and integration of key setup with the block engine.
- `aes128_key_expand.sv`: iterative 128-bit AES key expansion, producing K0–K10.
- `aes128_block_engine.sv`: two-round datapath, five-pass control, state storage, output register, and ready/valid backpressure.
- `aes128_pkg.sv`: shared AES S-box, AddRoundKey, ShiftRows, MixColumns/xtime, round, and key expansion functions. Transforms are kept as focused functions in one package because they are combinational and share definitions; separate wrapper modules would add hierarchy without useful state/resource boundaries.

The selected architecture uses 32 data S-box instances across two round lanes, two MixColumns lanes, a 1408-bit round-key bank, and one registered output. No ASIC timing or cell-area result is inferred from RTL simulation.

## Verification (`tb/`)

- `testbench/`: interface, black-box assertions, and simulation top.
- `models/`: independent pure-SystemVerilog AES-128 reference model and KAT oracle.
- `packages/`: transaction/types and one UVM package that includes class fragments in dependency order.
- `env/`: separate sequencer, driver, input/output monitors, coverage, scoreboard, environment, and one `aes128_agent`.
- `sequences/`: one class per file: base, smoke, random, pattern, throughput, pre-reset, and coverage sequences.
- `tests/`: one class per file: base test, smoke, random, pattern, reset, throughput, and coverage tests.

Each class fragment is included by `tb/packages/aes_uvm_pkg.sv`; `sim/compile.do` compiles the package after the independent reference model and interface, followed by assertions and `tb_top`.

The single agent owns the complete key/data/cipher interface. The scoreboard uses only accepted interface transactions and the independent reference model. RTL and TB source use four-space indentation, no tabs, and one declaration/executable statement per line.

## Simulation (`sim/`)

- `compile.do`, `run.do`, `smoke.ps1`, and `regression.ps1`: clean Questa compile, single smoke, seeded regression, UCDB merge, and coverage reports.
- `reports/`: ignored generated logs, UCDBs, and HTML/text reports. These files are evidence artifacts, not source inputs.
- `work/`: Questa library and generated simulator state; not a deliverable source directory.

Questa 10.2c compile order is: UVM package, `rtl/aes128_pkg.sv`, key expansion, block engine, core, independent reference package, interface, UVM package, assertions, and testbench top. UVM include paths are `tb/packages`, `tb/env`, `tb/sequences`, `tb/tests`, and the configured UVM source directory.
