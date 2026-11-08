# Resolved Interface and Verification Decisions

The PDF-underspecified details below were resolved by root under the user's autonomous-workflow authorization and frozen in `docs/interface_contract.md`:

- Reset while active/stalled: asynchronous active-low reset flushes pending work and invalidates the key schedule.
- Plaintext before key setup: held off until K0–K10 expansion completes.
- Key update: idle/barrier-only; never overwrite a bank used by an in-flight block or pending output.
- Simultaneous key/data presentation: key priority; only the key handshakes.
- Output stall: valid and ciphertext remain stable until transfer.
- II: maximum spacing between consecutive accepted plaintexts after key setup with continuous input valid and output ready.
- Coverage: report Questa statement, branch, condition, expression, toggle, FSM, assertion, and functional metrics separately. The >=98% headline target is named RTL statement coverage by design unit. Aggregate all-source code metrics are disclosed separately; there are no exclusions.

## Current decisions

- Selected architecture: two-round iterative AES core; predicted and measured steady no-stall II=5.
- Verification scope: QuestaSim 10.2c/UVM 1.1d simulation only.
- PDF-requested synthesis, PDK, STA, critical path, cell area, and 200 MHz hardware timing are **NOT VERIFIED** because those tasks are excluded from the active project scope.
