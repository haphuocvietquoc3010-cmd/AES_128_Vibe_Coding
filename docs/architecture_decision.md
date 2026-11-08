# AES-128 Architecture Decision Record

Decision status: **APPROVED BY AUTOMATIC QUALITY GATE (2026-11-09)**  
Phase: 1 authorized  
PDF reconciliation: **COMPLETE** (`docs/spec_traceability.md`; exact ports and byte ordering follow the PDF)

## Decision

Use one two-round iterative AES-128 encryption core. It contains 32 data S-boxes and two 128-bit MixColumns transforms, executes two rounds per pass for five passes, and targets steady-state II=5 with output always ready. Nominal payload rate is 5.12 Gb/s at an assumed 200 MHz. This is not a timing-closure claim.

It is the smallest direct candidate studied that meets II <= 6. The one-round core was eliminated at II=10; five-round folded and fully unrolled choices use 80 and 160 data S-boxes respectively.

## Frozen assumptions

- Top-level ports and semantics are exactly those frozen in `docs/interface_contract.md`.
- External byte 0 is `[127:120]`; AES state maps external byte `4*c+r` to row `r`, column `c`.
- Eleven 128-bit round keys are precomputed into one 1408-bit bank by a four-S-box, 10-cycle iterative expander.
- Key updates are idle/barrier-only. The key bank is never overwritten while a block or stalled output remains.
- Key presentation has priority over plaintext presentation; the two channels never handshake on the same edge.
- Plaintext cannot be accepted until key expansion completes.
- A dedicated output register holds valid and ciphertext stable under backpressure.
- Active-low asynchronous reset flushes computation/output and invalidates the active key.
- Expected no-stall acceptance-to-output-valid latency is five cycles; predicted steady-state II is five.

## Quality gate

The selected architecture meets the cycle-II requirement in simulation. Its 200 MHz timing feasibility remains unverified because synthesis and STA are outside the active project scope.
