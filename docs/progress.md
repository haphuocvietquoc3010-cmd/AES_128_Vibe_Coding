# Project Progress

Updated: 2026-11-09

## Active coverage and publish follow-up

The RTL/UVM refactor, formatting, per-class file split, coverage closure, README refresh, and clean-library rerun are complete. Publication is waiting on GitHub authentication.

Final changes are committed in `.publish_stage`. The requested push is **BLOCKED - GitHub authentication required**: noninteractive HTTPS push reports `Cannot prompt because user interactivity has been disabled` and `unable to get password from user`. The remote has no `main` ref, and the local staging commit is preserved. Added a directed accepted key transition test (`0 -> all ones -> 0`) and integrated it into the regression.

Checkpoint details are in [`resume_state.md`](resume_state.md).

Final coverage closure: all four RTL DUs have 100% statements (92/92), branches (32/32), FEC condition terms (2/2), FEC expression terms (14/14), and attainable toggle bins (2872/2872). Two structurally unreachable toggles for `aes128_block_engine.round_num[0]` are excluded; see `docs/verification/coverage_gaps.md`. Added key-toggle stimulus covers all feasible key-port transitions. The merged all-source report is explicitly separate: statement 67.5%, branch 30.0%, FEC conditions 71.4%, FEC expressions 100%, toggles 100%, code-only total 73.7%.

| Phase | Status | Evidence / limitation |
|---|---|---|
| P0 specification/architecture/contract | COMPLETE | PDF requirements cited in `spec_traceability.md`; interface follows PDF ports; local unspecified protocol choices documented |
| P1 implementation | COMPLETE | Modular two-round iterative RTL and independent UVM/reference model implemented |
| P2 compile/smoke | PASS | Clean Questa 10.2c compile and smoke; NIST KAT passes |
| P3 regression/debug | PASS | Updated 21 test/seed cases, plus focused key-toggle seed 4242 and directed stall seed 314159; zero UVM errors/fatals, mismatches, or assertion failures |
| P4 coverage closure | PASS | All reported attainable RTL metrics 100%; 2 structurally unreachable toggle bins excluded with peer-reviewed rationale; functional 100% |
| P5 refactor/final package | COMPLETE WITH SCOPE LIMITATION | RTL/UVM refactor, formatting, per-class split, scripts, reports, README, AGENTS.md, and final report complete; synthesis/STA/area/timing excluded and NOT VERIFIED |

Measured sustained no-stall II is 5 cycles/block. The formula at assumed 200 MHz gives 5.12 Gb/s nominal; this is not a verified hardware clock/timing result. Exact measured latency was not separately recorded by the scoreboard.

## Refactor baseline

- Git status unavailable because the workspace has no `.git` repository metadata.
- Pre-refactor regression: 15/15 passed, max II 5; functional coverage 77.2%.
- Final regression: 21/21 passed, max no-stall II 5; functional coverage 100%. Focused seed 4242, clean smoke, and backpressure seed 314159 passed.
- Final named RTL statement coverage is 100% for `aes128_pkg`, `aes128_key_expand`, `aes128_block_engine`, and `aes128_core`.
- Final all-source metrics: statements 67.5%, branches 30.0%, FEC conditions 71.4%, FEC expressions 100.0%, toggles 100.0%, code-only filtered total 73.7%; these include verification/reference source and are not RTL-only metrics.
- Only the two unreachable toggle bins for `round_num[0]` are excluded. Detailed metrics and rationale are in `docs/verification/coverage_gaps.md`; Questa UCDB/text evidence is under `sim/reports/` locally.
