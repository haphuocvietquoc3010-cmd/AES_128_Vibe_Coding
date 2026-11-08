# Autonomous Phase Plan

## Ownership

- `rtl_designer`: `rtl/**`, `docs/design/**`.
- `dv_verifier`: `tb/**`, `sim/**`, `docs/verification/**`.
- Root: shared contracts, integration execution/review, progress, architecture and final report.

The paths are disjoint. Agents may develop concurrently after reading the frozen interface contract.

## Gates

1. Phase 0: requirements, architecture comparison, frozen contract — complete with missing-PDF limitation.
2. Phase 1: RTL plus independent reference/UVM implementation.
3. Phase 2: compile and smoke: model self-test, NIST KAT, two keys, repeated blocks, reset and stall.
4. Phase 3: directed corners, assertions and seeded constrained random; bounded repair loop.
5. Phase 4: real Questa coverage and targeted closure; transparent exclusions only.
6. Phase 5: measured II/latency, final evidence, reproducible commands and report.
