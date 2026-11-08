# RTL and UVM Structure Refactor Report

Status: **COMPLETE for RTL simulation/UVM scope**  
Simulator: QuestaSim 10.2c, UVM 1.1d

## Changes

- RTL organized into `aes128_pkg.sv`, `aes128_key_expand.sv`, `aes128_block_engine.sv`, and `aes128_core.sv`.
- UVM organized under `tb/testbench/`, `tb/env/`, `tb/sequences/`, `tb/tests/`, `tb/models/`, and `tb/packages/`.
- Exactly one `aes128_agent` handles the complete key/data/cipher interface.
- The independent AES reference model remains separate under `tb/models/`.
- Sequencer, driver, input/output monitors, coverage, scoreboard, environment, and agent are in separate files.
- Every major sequence and every UVM test has its own file. Package includes remain dependency ordered; `sim/compile.do` resolves the new structure through the existing include directories.
- All RTL and TB sources were formatted with four-space indentation, no tabs, and readable one-statement-per-line formatting.
- Questa Tcl and PowerShell scripts were reformatted into readable blocks without changing test names, fixed seeds, checking, or coverage generation.
- `sim/regression.ps1` completed successfully after the follow-up refactor with all 18 registered test/seed cases passing; directed backpressure seed 314159 also passed. Merged UCDB plus code, functional, per-RTL-unit, and HTML reports were generated.

## Baseline and final comparison

| Metric | Pre-refactor baseline | Final post-refactor | Result |
|---|---:|---:|---|
| Passing cases | 15 | 18 | Expanded to include directed long-stall coverage test |
| Maximum sustained no-stall II | 5 | 5 | Preserved |
| Named RTL statement coverage | Not separately reported | 100% in each of four RTL design units | Meets named metric |
| All-source statements | 62.0% | 67.9% | Improved |
| All-source branches | 25.4% | 31.0% | Improved |
| All-source conditions | 87.5% | 85.7% | Slightly lower |
| All-source expressions | 96.6% | 100.0% | Improved |
| All-source toggles | 89.6% | 94.2% | Improved |
| Functional covergroups | 77.2% | 100.0% | Improved; all bins hit |
| Assertions | 100.0% | 100.0% | Preserved |

Aggregate percentages include testbench/reference sources and are reported separately from RTL-only statement coverage. No exclusions were applied.

## Issues found during refactor and closure

1. Reset seed 17 initially stalled because the DV driver changed/deasserted valid with a clocking race. DV corrected the driver and reran the failing seed successfully.
2. The first RTL split accidentally truncated the S-box lookup literal. The smoke caught ciphertext mismatches; RTL restored all 256 entries, and the exact failing smoke seed passed before regression.
3. Directed long-stall coverage exposed an RTL output overwrite while stalled. RTL now holds the completed result at the final pass until output capacity returns. The deterministic backpressure reproducer passed, followed by smoke and the full regression.

No reference-model values, scoreboard checks, or assertions were weakened.

## Limits

The PDF requests synthesis, PDK, and 5 ns timing analysis, but the controlling project scope is Questa RTL simulation/UVM only. Hardware timing and cell area are **NOT VERIFIED**. The full HTML report notes that no license was found for HTML testplan data; UCDB and text coverage reports were generated successfully.
