# Verification Status

Status: **PASS for the final QuestaSim/UVM regression and measured RTL coverage.**

## Current verification evidence

- QuestaSim 10.2c/UVM 1.1d clean compile passed.
- All 21 combinations passed: seven UVM tests at seeds 1, 17, and 20261109.
- Focused `aes_key_toggle_test` seed 4242 passed; it accepts keys `0 -> all ones -> 0` and checks a plaintext under each epoch.
- Clean smoke passed 3/3, max sustained no-stall II=5. Directed backpressure seed 314159 passed 3/3, max II=23 while output stalls.
- Zero UVM_ERROR, UVM_FATAL, scoreboard mismatch, or assertion failure in the final test matrix and focused runs.

## Final measured code coverage

| Questa metric | Final result |
|---|---:|
| RTL statements | 100% (92/92) |
| RTL branches | 100% (32/32) |
| RTL FEC condition terms | 100% (2/2) |
| RTL FEC expression terms | 100% (14/14) |
| Attainable RTL toggle bins | 100% (2872/2872 after the documented exclusion) |
| Full-UCDB statements | 67.5% (425/629) |
| Full-UCDB branches | 30.0% (87/290) |
| Full-UCDB FEC condition terms | 71.4% (10/14) |
| Full-UCDB FEC expression terms | 100% (20/20) |
| Full-UCDB toggle bins | 100% (3930/3930) |
| Functional coverage | 100%; all operation/data crosses and five stall bins hit |
| Assertions | 100% (4/4) |

The >=98% acceptance criterion is satisfied by the explicitly named RTL
statement metric. The full-UCDB metric includes testbench and reference code,
and is reported separately; its code-only filtered total is 73.7%.

## Exclusion and limits

Exactly two toggle bins are excluded: both transition directions for
`aes128_block_engine.round_num[0]`. The bit is structurally constant one from
`{pass_count,1'b0} + 1`, so these transitions are unreachable. RTL and DV
reviewed this exact node. No feasible RTL or `i_key` input bins are excluded.
The directed key-toggle test covers previously missed key bus transitions.
Details are in [`coverage_gaps.md`](coverage_gaps.md).

Hardware synthesis, cell area, STA, and silicon timing are **NOT VERIFIED**.
Questa HTML testplan metadata was unavailable under the installed license;
UCDB merge and text reports succeeded.
