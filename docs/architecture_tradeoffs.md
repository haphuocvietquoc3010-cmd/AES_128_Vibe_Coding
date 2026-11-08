# AES-128 Architecture Trade-off Study

Status: **CANDIDATE C SELECTED AND SIMULATION-VALIDATED FOR II**  
The PDF is present at `docs/Big_Project_01_2026.pdf`; PDF requirements are enumerated in `docs/spec_traceability.md`. Synthesis/timing feasibility remains outside current scope.

## Assumptions and counting method

- AES-128 encryption consists of initial AddRoundKey, nine full rounds, and a final round without MixColumns.
- One 128-bit round lane contains 16 physical byte S-boxes, one ShiftRows wiring network, one 128-bit AddRoundKey XOR, and (except when bypassed for round 10) one four-column MixColumns transform.
- All candidates assume eleven precomputed 128-bit round keys. A compact iterative key expander adds four byte S-boxes and takes 10 setup cycles per new key; its update policy is not approved.
- Latency is from plaintext acceptance to output-valid availability without backpressure. A range indicates the unresolved input/output register convention.
- Steady-state II is the spacing between accepted plaintexts after warm-up with continuous input valid and output always ready.
- Throughput is the arithmetic `128 * 200 MHz / II`, not a verified Fmax or silicon result.

## Comparison

| Candidate | Round lanes | Data S-boxes | 128-bit MixColumns units | Principal state/registering | Block schedule | Latency | II | Nominal throughput | Cost trend | Disposition |
|---|---:|---:|---:|---|---|---:|---:|---:|---|---|
| Fully unrolled round pipeline | 10 | 160 | 9 | 10 round stages + output | One round per stage; all blocks advance concurrently | 10–11 | 1 | 25.6 Gb/s | Highest nonlinear logic, state, routing, and key-epoch complexity | Feasible, not area-conscious |
| Five-round folded cascade | 5 | 80 | 5 | Pass state + output | R1–5 in pass 1; R6–10 in pass 2 | 2–3 | 2 | 12.8 Gb/s | Medium-high logic; five-round combinational depth | Feasible, timing risk unquantified |
| Two-round iterative core | 2 | 32 | 2 | 128-bit pass state + counter + output | (R1,R2), (R3,R4), (R5,R6), (R7,R8), (R9,R10) | 5–6 | 5 | 5.12 Gb/s | Lowest direct resource count meeting II target; two-round combinational depth | **Recommended** |
| One-round iterative core | 1 | 16 | 1 | 128-bit pass state + counter + output | R1 through R10 on ten passes | 10–11 | 10 | 2.56 Gb/s | Lowest datapath cost but inadequate throughput | **Eliminated: II > 6** |

## Concrete recommended schedule

| Interval after acceptance | Work | Keys | MixColumns |
|---|---|---|---|
| Acceptance edge | External mapping and AddRoundKey | K0 | None |
| Cycle 1 | Rounds 1 and 2 | K1, K2 | Both lanes |
| Cycle 2 | Rounds 3 and 4 | K3, K4 | Both lanes |
| Cycle 3 | Rounds 5 and 6 | K5, K6 | Both lanes |
| Cycle 4 | Rounds 7 and 8 | K7, K8 | Both lanes |
| Cycle 5 | Rounds 9 and 10 | K9, K10 | Round 9 only; final-round lane bypasses it |
| Completion edge | Capture/present ciphertext | — | — |

With separate output storage, the next plaintext can be accepted at completion when capacity exists, giving II=5. If the output is stalled and no additional capacity exists, the core must preserve the completed block and apply backpressure; no result may be overwritten.

## Key-storage consequences

One immutable bank contains 11 x 128 = 1408 round-key bits. An idle-only or barrier update can safely use one bank by refusing updates/inputs until old work drains and the new expansion completes. Supporting overlapping old/new key epochs with precomputed keys requires at least two immutable 1408-bit banks plus epoch ownership; merely retaining a 128-bit source key is not enough if active processing reads a bank being overwritten.

## Limits of this comparison

Physical S-box/MixColumns counts and cycle schedules are architectural counts, not synthesized gate/cell area. QuestaSim can validate functional scheduling and measured handshake II, but it cannot prove 200 MHz timing. No synthesis, STA, PDK, Liberty data, placement, or timing closure is in scope.

Detailed specialist analysis is retained in `docs/design/architecture_notes.md`.
