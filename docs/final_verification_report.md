# Final Verification Report

Date: 2026-11-09  
Status: **PASS for Questa RTL simulation/UVM acceptance; hardware implementation requirements NOT VERIFIED**

## Scope and design

The refactored project implements AES-128 encryption using a two-round iterative core with ten-cycle iterative key setup, idle-barrier key updates, output backpressure, and an independent UVM scoreboard. Each RTL module and major UVM component has its own file; every UVM test and major sequence class is separated into an individual file. The PDFs' exact top-level signal names and byte ordering are preserved.

The target no-stall II is <=6. QuestaSim measured maximum sustained II=5 cycles/block. At an assumed 200 MHz, the nominal calculation is `128*200e6/5 = 5.12 Gb/s`. This simulation does not verify a 200 MHz silicon clock, 5 ns critical path, PDK timing, or cell area.

## Run evidence

- QuestaSim 10.2c and UVM 1.1d compiled all RTL, model, interface, UVM package, assertions, and top-level sources from a fresh work library. The generated previous `sim/work/` directory was removed after confirming no Questa process was active; the fresh compile produced no locked-library cleanup warnings.
- Independent FIPS-197/NIST AES-128 KAT passed: key `000102030405060708090a0b0c0d0e0f`, plaintext `00112233445566778899aabbccddeeff`, ciphertext `69c4e0d86a7b0430d8cdb78070b4c55a`.
- Smoke passed: 3 accepted/3 transferred, max II=5.
- Updated seeded regression passed all 21 individual test/seed combinations:

| UVM test | Seed 1 | Seed 17 | Seed 20261109 |
|---|---|---|---|
| `aes_smoke_test` | PASS | PASS | PASS |
| `aes_pattern_test` | PASS | PASS | PASS |
| `aes_random_test` | PASS | PASS | PASS |
| `aes_reset_test` | PASS | PASS | PASS |
| `aes_throughput_test` | PASS | PASS | PASS |
| `aes_coverage_test` | PASS | PASS | PASS |
| `aes_key_toggle_test` | PASS | PASS | PASS |

- `aes_key_toggle_test`, seed 4242, also passed as a focused run (3 accepted/3 transferred, no UVM errors/fatals). The full matrix includes it at all three regression seeds.
- `aes_coverage_test`, seed 314159, passed after the RTL fix and again after the refactor (3 accepted/3 transferred, max II=23 under directed stalls, zero UVM errors/fatals).
- A clean smoke rerun passed (3/3, max II=5). Across the final 21-run matrix: no compiler errors, UVM_FATAL, UVM_ERROR, scoreboard mismatch, missing output, or failed assertion.
- Merged UCDB: `sim/reports/merged.ucdb`; run logs and HTML/text reports reside in `sim/reports/`.

## Coverage

| Questa metric | Final result |
|---|---:|
| RTL statements | 100% (92/92) |
| RTL branches | 100% (32/32) |
| RTL FEC condition terms | 100% (2/2) |
| RTL FEC expression terms | 100% (14/14) |
| RTL attainable toggle bins | 100% (2872/2872, after the two-bin structural exclusion) |
| All-source statements | 67.5% (425/629) |
| All-source branches | 30.0% (87/290) |
| All-source FEC conditions | 71.4% (10/14) |
| All-source FEC expressions | 100.0% (20/20) |
| All-source toggle bins | 100.0% (3930/3930, includes testbench/reference code) |
| Code-only filtered total | 73.7% |
| Functional covergroups | 100.0%; all six input operation/data crosses and all five stall bins hit |
| Assertions | 100.0% (4/4) |

The >=98% code-coverage claim is met by the named RTL statement metric at 100%; all separately reported enabled RTL branch/FEC/toggle metrics also reach 100%. Exactly two toggle bins are excluded: 0-to-1 and 1-to-0 for `aes128_block_engine.round_num[0]`, structurally constant one from `{pass_count,1'b0} + 1`. Questa's merged user-exclusion report records the exact scoped node, and RTL/DV peer review confirmed it is unreachable. All environment-driven key input transitions were covered by the new accepted-key-toggle test; no `i_key` bins were excluded. Whole-database percentages include verification/reference code and are not claimed to reach 98%. Questa reports zero active FSM states/transitions, so the displayed FSM percentage is not evidence of exercised FSM bins. Full rationale and per-DU counts are in `docs/verification/coverage_gaps.md`.

## Reproduction

From the project root in PowerShell with Questa commands on `PATH`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\regression.ps1
```

Fixed regression seeds: 1, 17, and 20261109. The seven tests are `aes_smoke_test`, `aes_pattern_test`, `aes_random_test`, `aes_reset_test`, `aes_throughput_test`, `aes_coverage_test`, and `aes_key_toggle_test`. To rerun the directed output-stall case from `sim/`, set `$env:TEST = 'aes_coverage_test'`, `$env:SEED = '314159'`, and `$env:AES_PROJECT_ROOT = (Resolve-Path '..').Path`, then run `vsim -c -do run.do`.

## Limitations

- Hardware timing, synthesis, PDK, STA, maximum frequency, and cell area are **NOT VERIFIED**; these are outside the authorized Questa-only implementation scope despite being requested in the course PDF.
- Exact acceptance-to-output latency was not separately captured by the scoreboard; only measured steady-state II is reported.
- Questa's full HTML report warned that no license was available for HTML testplan data. UCDB merging and text code/functional/per-RTL reports succeeded.
- Questa notes that optional UVM-aware debug support is disabled because `questa_uvm_pkg` is not separately compiled; this did not affect simulation. The final fresh-work-library compile had no cleanup warnings.
- Git status/diff is unavailable because this workspace is not initialized as a Git repository.
