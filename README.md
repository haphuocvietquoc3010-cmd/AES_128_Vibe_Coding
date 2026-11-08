# AES-128 RTL and UVM Project

This project contains a synthesizable AES-128 encryption accelerator, an independent SystemVerilog AES reference model, a UVM verification environment, and QuestaSim scripts. The project specification is [docs/Big_Project_01_2026.pdf](docs/Big_Project_01_2026.pdf).

The RTL implements AES-128 encryption with runtime 128-bit keys and preserves the specified 128-bit top-level interface and byte ordering. The datapath uses two iterative round lanes. Key updates follow the idle-barrier policy in [docs/interface_contract.md](docs/interface_contract.md).

## Project layout

| Directory | Contents |
|---|---|
| `rtl/` | AES package, key expansion, block engine, and top-level core |
| `tb/models/` | Independent AES reference model and known-answer checks |
| `tb/testbench/` | Interface, assertions, and simulation top |
| `tb/packages/` | UVM transaction types and package include order |
| `tb/env/` | Separate sequencer, driver, coverage, monitors, scoreboard, environment, and one AES agent |
| `tb/sequences/` | One source file per major sequence |
| `tb/tests/` | One source file per UVM test |
| `sim/` | Questa compile, run, smoke, and regression scripts |
| `docs/` | Specification traceability, architecture, contracts, verification evidence, and resume state |

See [docs/project_structure.md](docs/project_structure.md) for the detailed compile order and source organization.

## Requirements

- QuestaSim 10.2c and UVM 1.1d, with `vlog`, `vsim`, and `vcover` available on `PATH`.
- Set `UVM_HOME` if the installed UVM source directory differs from the local Questa default.
- A valid Questa simulation license.

## Run the verification

From the project root in PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\regression.ps1
```

The regression compiles the project, runs each registered test with fixed seeds `1`, `17`, and `20261109`, merges passing UCDBs, and writes text and HTML reports under `sim/reports/`. The seven tests are `aes_smoke_test`, `aes_pattern_test`, `aes_random_test`, `aes_reset_test`, `aes_throughput_test`, `aes_coverage_test`, and `aes_key_toggle_test`.

The deterministic backpressure reproducer can be run from `sim/` by setting `TEST=aes_coverage_test`, `SEED=314159`, and `AES_PROJECT_ROOT` to the project root, then invoking `vsim -c -do run.do`.

## Latest verification results

The final fresh-work-library QuestaSim 10.2c/UVM 1.1d regression passed all 21 test/seed cases. A focused key-toggle run (seed 4242), a clean smoke rerun, and directed backpressure seed 314159 also passed. No UVM errors/fatals, scoreboard mismatches, or assertion failures were reported.

- Maximum measured sustained no-stall initiation interval: **5 cycles/block**.
- RTL statement coverage: **100% (92/92)**; branches: **100% (32/32)**; FEC conditions: **100% (2/2)**; FEC expressions: **100% (14/14)**; attainable RTL toggle bins: **100% (2872/2872)**.
- UVM functional coverage: **100%**; assertions: **4/4**.
- Aggregate RTL/testbench/reference coverage is reported separately: 67.5% statements, 30.0% branches, 71.4% FEC conditions, 100% FEC expressions, and 100% toggle bins. Its code-only filtered total is 73.7%; it is not represented as RTL-only coverage.
- Exactly two structurally unreachable toggle bins are excluded: both directions for `aes128_block_engine.round_num[0]`, which is constant 1 by construction. No feasible RTL or key-input bins are excluded. See [docs/verification/coverage_gaps.md](docs/verification/coverage_gaps.md) for the justification and per-DU evidence.

See [docs/final_verification_report.md](docs/final_verification_report.md) for per-test results, coverage details, and reproduction information. Questa HTML output does not include testplan metadata when the corresponding license feature is unavailable.

## Scope limits

The flow verifies RTL behavior and measured cycle-level throughput. It does not perform synthesis, STA, PDK analysis, physical timing closure, or cell-area measurement. A nominal calculation using an assumed 200 MHz clock is not a hardware timing claim. Exact acceptance-to-output latency is not separately captured by the scoreboard. Hardware timing and area remain **NOT VERIFIED**.
