# AES-128 Architecture Notes — Phase 0

Status: **CANDIDATE C APPROVED AND IMPLEMENTED**  
Source-spec status: the PDF was supplied after the initial Phase 0 study. Root reconciled its interface requirements into `docs/spec_traceability.md` and froze `docs/interface_contract.md`; the resource comparison remains a project architecture study rather than a PDF mandate.

## Common assumptions and counting rules

- Encryption only: initial AddRoundKey, nine full rounds, and round 10 without MixColumns.
- A "data S-box" is one physical 8-bit substitution instance. Sixteen are required for one 128-bit SubBytes operation performed in one cycle.
- A "MixColumns unit" is one physical 128-bit/four-column combinational transform. ShiftRows and 128-bit XORs are wiring/XOR logic and are counted separately from S-box/MixColumns resources.
- Round keys are precomputed into eleven 128-bit registers (K0 through K10). A conventional one-round-per-cycle key expander uses four additional 8-bit key S-boxes, one 32-bit RotWord/SubWord/Rcon path, and 10 expansion cycles per newly accepted key.
- Key setup cycles are not included in per-block latency or steady-state data II once a key is ready. Key-change behavior remains an unapproved interface decision.
- Latency is measured from an accepted plaintext edge to the first edge on which its output is valid, assuming no output backpressure. II is the spacing between accepted plaintext edges after warm-up with continuous input valid and output ready.
- An output skid/register stage is assumed so a stalled ciphertext remains stable. Backpressure may propagate to the core; buffer depth is not yet fixed.
- Nominal payload throughput is `128 * 200 MHz / II`. It is arithmetic at an assumed clock, not a Questa timing, Fmax, silicon-area, or timing-closure claim.

## Candidate comparison

| Candidate | Data round hardware | Physical data S-boxes | Physical MixColumns units | Pipeline/state stages | Key hardware | Latency | Steady II | Nominal throughput at 200 MHz | Relative non-cell cost trend | Meets II <= 6? |
|---|---|---:|---:|---:|---|---:|---:|---:|---|---|
| A. Fully unrolled, round-pipelined | 10 round lanes, final lane bypasses MixColumns | 160 | 9 | 10 round registers plus output | 11x128 round-key store + 4 key S-boxes; alternatively 10 pipelined expand stages would add 40 key S-boxes | 10–11 cycles depending input/output register convention | 1 | 25.6 Gb/s | Highest datapath area, routing, register count, and verification state; easiest peak throughput | Yes |
| B. Five-round combinational fold | One cascade of 5 round lanes, reused for rounds 1–5 and 6–10 | 80 | 5 (last physical lane bypassed only for round 10) | Accumulator/pass register + output | 11x128 store + 4 key S-boxes | 2–3 cycles | 2 | 12.8 Gb/s | Roughly half unrolled nonlinear logic, but long five-round combinational path and complex pass/key selection | Yes |
| C. Two-round iterative core | One cascade of 2 round lanes, reused across five passes | 32 | 2 (second bypassed for round 10) | State/pass register + output | 11x128 store + 4 key S-boxes | 5–6 cycles | 5 | 5.12 Gb/s | Lowest straightforward resource count that meets target; two-round combinational path | **Yes; recommended** |
| D. One-round iterative core | One round lane reused ten times | 16 | 1 (bypassed for round 10) | State/pass register + output | 11x128 store + 4 key S-boxes | 10–11 cycles | 10 | 2.56 Gb/s | Lowest datapath resource trend, but misses throughput/II requirement | **No; eliminate** |

The selected registered boundaries are now frozen: AddRoundKey K0 occurs at input acceptance and a dedicated output register captures the fifth pass. The II comparisons are unaffected.

## Concrete schedules

### A. Fully unrolled, round-pipelined

At acceptance edge `t`, input mapping and AddRoundKey K0 feed pipeline stage 1. On successive cycles, stage `r` applies AES round `r` with Kr; stages 1–9 include MixColumns and stage 10 omits it. Once full, a new block can enter each cycle and outputs remain ordered. Each stage holds its own valid bit. A global stall chain or elastic registers must freeze each payload, valid bit, and associated key context under output backpressure.

Resource detail: ten 128-bit SubBytes/ShiftRows/AddRoundKey lanes, nine 128-bit MixColumns transforms, 160 data S-boxes, at least ten 128-bit state registers plus valid/control, and the round-key storage/expander stated above. Supporting arbitrary key changes while blocks overlap requires round keys to travel with each block, epoch-indexed immutable key banks, or a drain barrier; a single mutable round-key bank is unsafe.

### B. Five-round combinational fold

| Edge/interval | Operation for block B |
|---|---|
| Accept `t` | Map input and apply AddRoundKey K0 into pass register |
| `t` to `t+1` | Cascaded rounds 1–5 using K1–K5 |
| `t+1` to `t+2` | Feed pass result back through same cascade for rounds 6–10 using K6–K10; bypass MixColumns in lane 5 for round 10 |
| `t+2` | Capture/present ciphertext (or move to a separate output register) |

The shared cascade is occupied for two consecutive passes, so the next block is accepted at `t+2`: II=2. It has 80 data S-boxes and five MixColumns datapaths, although the fifth MixColumns output is bypassed during the second pass. The five-round combinational depth makes an assumed 200 MHz especially speculative; Questa functional simulation cannot validate that timing.

### C. Two-round iterative core (recommended)

| Edge/interval | Round work for block B | Round keys | MixColumns behavior |
|---|---|---|---|
| Accept `t` | Map input; AddRoundKey | K0 | None |
| `t` to `t+1` | Rounds 1 and 2 | K1, K2 | Both lanes enabled |
| `t+1` to `t+2` | Rounds 3 and 4 | K3, K4 | Both enabled |
| `t+2` to `t+3` | Rounds 5 and 6 | K5, K6 | Both enabled |
| `t+3` to `t+4` | Rounds 7 and 8 | K7, K8 | Both enabled |
| `t+4` to `t+5` | Rounds 9 and 10 | K9, K10 | Lane 1 enabled; lane 2 bypasses MixColumns |
| `t+5` | Ciphertext valid/captured | — | — |

One engine is occupied for five passes, so the next plaintext can be accepted every five cycles when output ready is continuously high: II=5 and 5.12 Gb/s nominal at 200 MHz. A separate output register can preserve the result while the datapath accepts the next block at the same edge, provided ready/backpressure capacity is correctly handled. Physical resources are 32 data S-boxes, two 128-bit MixColumns transforms, two ShiftRows networks, two 128-bit key XOR paths, a 128-bit state register, pass counter/control, output storage, and the common key-expansion resources.

The preferred Phase 1 key organization is precomputed K0–K10 in a 1408-bit bank. With a four-S-box expander, a new key requires 10 setup cycles. For minimum area/control, pair this with the proposed barrier/idle-only policy: do not overwrite the active key bank until no block/output using it remains, and do not accept plaintext until expansion completes. If the owner instead chooses atomic per-plaintext key snapshots with overlapping epochs, add at least a second immutable 1408-bit round-key bank plus epoch ownership/reference control; snapshotting only the original 128-bit key is insufficient for a core reading a mutable precomputed bank.

### D. One-round iterative core — eliminated

This core applies one AES round per cycle using 16 data S-boxes and one MixColumns unit, bypassed in round 10. It occupies the only engine for ten passes, hence II=10 and only 2.56 Gb/s nominal at 200 MHz. Replicating two such engines could reach aggregate II=5 but would return to 32 S-boxes and two MixColumns units while adding ordering, arbitration, duplicate state/control, and key-epoch complexity; the two-round core is the cleaner equal-resource baseline.

## Recommendation

Candidate C, the two-round iterative core, was selected and implemented. It is the smallest direct architecture in this study that meets II <= 6, retains in-order single-engine behavior, and avoids the five-round combinational depth and much larger S-box count of Candidates B/A. Its nominal 5.12 Gb/s figure exceeds the 4 Gb/s arithmetic target at the assumed 200 MHz, but 200 MHz feasibility remains **NOT VERIFIED** without synthesis/timing tools and is outside this Questa-only project.

## Interface, reset, and valid implications

- Inputs/outputs use the exact PDF-derived names and widths frozen in `docs/interface_contract.md`.
- Accepted plaintext is captured only on `in_valid && in_ready`; the core deasserts `in_ready` during its five occupied passes unless future buffering is approved.
- The output register must hold payload and valid stable while `out_valid && !out_ready`; if it is full at completion, the state/pass register and control must stall without recomputation or loss.
- Reset is frozen as asynchronous active-low and flushes core/output valid state and invalidates the active key.
- Key updates are frozen as an idle barrier; a waiting key has priority over replacement plaintext acceptance.

## DV handoff checks

- Measure accepted-input spacing under continuous `in_valid=1`, loaded key, and `out_ready=1`; Candidate C predicts II=5 after key setup.
- Check output-valid latency against the final registered-boundary decision (predicted 5 or 6 cycles) and verify one output per accepted input in order.
- Stall output immediately before completion and for long durations; ensure ciphertext and valid remain stable and no subsequent acceptance exceeds available storage.
- Exercise round-10 no-MixColumns behavior with independent known-answer vectors and intermediate-state checks only if the PDF exposes them.
- Test byte mapping with asymmetric byte patterns, not only all-zero/all-one inputs.
- Test key change at every pass count and output-stall state according to the approved barrier or epoch-bank policy.

## Resolved decisions and remaining verification

Candidate C, the 10-cycle precompute barrier, key priority, output register, and asynchronous active-low flush reset are frozen. RTL exists in `rtl/aes128_core.sv`. Functional correctness, latency, II, and coverage remain subject to independent DV and real Questa reports; no synthesis, STA, Fmax, or cell-area claim is made.
