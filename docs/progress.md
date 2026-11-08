# Project Progress

Updated: 2026-11-09

## Latest follow-up task

The RTL/UVM refactor, formatting, per-class file split, script cleanup, and clean-library rerun are complete. Final smoke, full regression, and the directed backpressure reproducer passed.

The README is refreshed and the project has a local root commit in `.publish_stage`. Push is pending GitHub authentication: HTTPS rejected the available credential; no usable GitHub CLI or SSH identity is configured.

Checkpoint details are in [`resume_state.md`](resume_state.md).

Follow-up updates: RTL/TB and Questa/PowerShell formatting and per-class file split are complete. Fresh-library compile and smoke seed 1 pass (3 accepted/transferred, max II 5, no UVM errors/fatals). The 18-case matrix and directed seed 314159 pass. Current coverage reports 100% RTL statement coverage per RTL DU, 100% functional coverage, and 4/4 assertions. No simulation tests remain pending; only authenticated GitHub push remains.

| Phase | Status | Evidence / limitation |
|---|---|---|
| P0 specification/architecture/contract | COMPLETE | PDF requirements cited in `spec_traceability.md`; interface follows PDF ports; local unspecified protocol choices documented |
| P1 implementation | COMPLETE | Modular two-round iterative RTL and independent UVM/reference model implemented |
| P2 compile/smoke | PASS | Clean Questa 10.2c compile and smoke; NIST KAT passes |
| P3 regression/debug | PASS | 18 test/seed cases, zero UVM errors/fatals, mismatches, or assertion failures; reset and output-stall defects fixed with preserved reproducers |
| P4 coverage closure | PASS for named metrics | RTL statement 100% in all four RTL design units; functional 100%; aggregate metrics reported separately |
| P5 refactor/final package | COMPLETE WITH SCOPE LIMITATION | RTL/UVM refactor, formatting, per-class split, scripts, reports, README, AGENTS.md, and final report complete; synthesis/STA/area/timing excluded and NOT VERIFIED |

Measured sustained no-stall II is 5 cycles/block. The formula at assumed 200 MHz gives 5.12 Gb/s nominal; this is not a verified hardware clock/timing result. Exact measured latency was not separately recorded by the scoreboard.

## Refactor baseline

- Git status unavailable because the workspace has no `.git` repository metadata.
- Pre-refactor regression: 15/15 passed, max II 5; functional coverage 77.2%.
- Final regression: 18/18 passed, max no-stall II 5; functional coverage 100%.
- Final named RTL statement coverage is 100% for `aes128_pkg`, `aes128_key_expand`, `aes128_block_engine`, and `aes128_core`.
- Final all-source metrics: statements 67.9%, branches 31.0%, conditions 85.7%, expressions 100.0%, toggles 94.2%; these include verification/reference source and are not represented as RTL-only values.
- No coverage exclusions were applied. Reports and UCDB evidence are under `sim/reports/`.
