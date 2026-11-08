# DV Final Status

Date: 2026-11-09  
Simulator: QuestaSim 10.2c 64-bit  
UVM: 1.1d with `uvm_dpi.dll`  
Status: **PASS for the verified RTL/UVM simulation scope**

## Final regression

- All 18 test/seed combinations completed successfully, including smoke, patterns, randomized backpressure, reset, sustained throughput, and targeted coverage closure.
- No compiler errors, `UVM_FATAL`, unexpected `UVM_ERROR`, scoreboard mismatches, missing/extra outputs, or assertion failures remain.
- The previously failing deterministic-backpressure test `aes_coverage_test`, seed 314159, passes after the RTL fix.
- Measured sustained initiation interval is 5 cycles. Nominal throughput at the assumed 200 MHz is `128*200e6/5 = 5.12 Gb/s`; this is arithmetic, not silicon timing closure.
- The independent AES oracle KAT passes and remains independent of RTL functions and DUT internals.

## Final genuine coverage

| Metric | Result | Interpretation |
|---|---:|---|
| Named RTL statement coverage | **100%** | Each of `aes128_pkg`, `aes128_key_expand`, `aes128_block_engine`, and `aes128_core` reports 100%. This is the named metric exceeding 98%. |
| All-source statement | 67.9% | 410/603 active statements; includes DV/reference sources. |
| All-source branch | 31.0% | 87/280 active branches. |
| All-source condition | 85.7% | Questa total; FEC condition terms are 10/14 = 71.4%. |
| All-source expression | 100.0% | FEC expression terms are 20/20. |
| All-source toggle | 94.2% | 3704/3932 toggle bins. |
| FSM | 100.0% reported | Zero active states/transitions, so this is not evidence of exercised FSM bins. |
| Functional covergroups | **100.0%** | Both types, all coverpoints, all six crosses, and all five stall bins are covered. |
| Assertions | **100.0%** | 4/4 covered with no failures. |
| Code-only filtered total | 72.9% | Not claimed as >=98%. |
| Overall filtered total | 80.6% | Not claimed as >=98%. |

No coverage exclusions were applied. There are no remaining mandatory feasible functional bins or open DV bugs. Silicon timing, physical area, synthesis, and STA remain outside this verified scope.

Evidence is under `sim/reports/`, including `coverage_code.txt`, `coverage_functional.txt`, merged UCDB, per-run logs, and HTML coverage.
