# AES-128 Verification Test Plan (Phase 0 Planning Record)

Status: **SUPERSEDED — implementation and verification results are recorded in [phase1_status.md](phase1_status.md) and [final_verification_report.md](../final_verification_report.md).**  
This file preserves the initial planning draft. Its pending requirements and proposed scenarios describe the state before the project PDF, interface decisions, RTL, and UVM environment were integrated; they are not the current project status. Use `docs/spec_traceability.md` and `docs/interface_contract.md` for the resolved requirements and interface policy.

## Verification objectives and independence

DV will verify AES-128 encryption results, complete and ordered transaction delivery, ready/valid behavior, reset behavior, key/data association, and sustained initiation interval. The scoreboard oracle will be independently implemented under `tb/**`; it will not import RTL packages or S-box/key-expansion functions and will not use DUT internals to predict results. DUT internals may be observed only for debug or separately justified white-box coverage, never as expected-value inputs.

## Requirement-to-verification matrix

| Req. ID | Check intent | Planned stimulus | Planned checker/coverage | Gate |
|---|---|---|---|---|
| AES-001 | Correct AES-128 encryption for runtime 128-bit keys | NIST KATs, multiple keys, random plaintext/key pairs | Independent model and in-order scoreboard | PDF and ports required |
| AES-002 | Initial AddRoundKey is reflected in final ciphertext | KATs selected to expose byte/key mapping errors | Final ciphertext oracle; optional independent round-state unit validation of model | Black-box AES KAT sufficient for DUT |
| AES-003 | Nine full main rounds including MixColumns | KATs and randomized vectors | Independent final ciphertext oracle | Black-box AES KAT sufficient for DUT |
| AES-004 | Final round omits MixColumns | KATs and randomized vectors | Independent final ciphertext oracle | Black-box AES KAT sufficient for DUT |
| AES-005 | MSB-first external byte serialization and column-major AES state | FIPS/NIST vectors plus one-hot/walking-byte plaintext/key tests | Scoreboard; byte-position functional coverpoints | Needs PDF confirmation |
| IF-001 | No accepted block is lost, duplicated, or reordered | Back-to-back requests, ready/valid races, randomized and long output stalls | Acceptance-based queue, transaction IDs in TB metadata, conservation/order assertions | Contract approval required |
| IF-002 | In-flight data remains bound to the correct key | Key changes at idle/busy/boundary, same-cycle key/data attempts | Key-epoch scoreboard and crosses | Key policy approval required |
| PERF-001 | Sustained II <= 6 under defined conditions | Continuous valid after key load, output always ready, warm-up then long burst | Input-handshake cycle deltas; maximum and histogram | II definition approval required |
| PERF-002 | Nominal throughput calculation >= 4 Gb/s at assumed 200 MHz | Reuse measured II | Report `128*200e6/II`; no Fmax claim | Simulation can verify II only |
| DV-001 | Oracle independence | Code review and dependency audit | No imports/calls into RTL; KAT self-test before DUT comparison | Mandatory |
| DV-002 | Coverage goal and mandatory bins | Directed plus constrained-random regression | Questa code metrics and functional coverage | Exact metric/exclusions approval required |

## Independent reference-model plan

1. Implement AES-128 encryption separately in SystemVerilog within the DV scope, using FIPS-197 transformation definitions encoded independently of RTL organization.
2. Keep model data layout conversion explicit: external byte `i` is `[127-8*i -: 8]`; state byte `4*c+r` maps to row `r`, column `c`.
3. Implement an independent key expansion that produces K0 through K10; do not share constants, tables, packages, or functions with RTL.
4. Before connecting the model to the scoreboard, self-test it against authoritative, traceable AES-128 known-answer vectors. At minimum plan to use the standard key `000102030405060708090a0b0c0d0e0f`, plaintext `00112233445566778899aabbccddeeff`, ciphertext `69c4e0d86a7b0430d8cdb78070b4c55a`, and verify intermediate round states against an authoritative source during Phase 1. The source citation must be recorded then; the absent project PDF is not treated as that source.
5. Add at least a second independently sourced vector and randomized cross-checks against a trusted external model only if project policy permits it. External software is a model-validation aid, not a replacement for the standalone SV oracle.
6. Fail model self-test before any DUT result can be scored. Never change expected ciphertext merely to match the DUT.

## Monitor, scoreboard, and assertion plan

- The input monitor creates an expectation only on an approved plaintext acceptance edge (`in_valid && in_ready` in the proposed contract). It snapshots the applicable accepted key epoch according to the eventual same-cycle precedence rule.
- The key monitor increments an epoch only on an approved key-channel handshake and stores immutable key values by epoch.
- The output monitor compares/dequeues only on `out_valid && out_ready`. It reports unexpected output, mismatch, duplication symptoms, and missing queued output at test completion.
- Reset handling must match the approved contract. Under the current proposal the scoreboard flushes pending expectations on reset and rejects any later pre-reset result.
- Scoreboard records acceptance cycle, key epoch, plaintext, expected ciphertext, output-transfer cycle, observed ciphertext, seed, and transaction sequence number.
- Planned black-box assertions include: output payload/valid stability while stalled; no output transfer without valid; valid input payload stability if the environment is the producer; reset clearing/flush behavior; no acceptance before key load if approved; bounded/progress checks only where a defensible latency bound exists; and transaction conservation using TB bookkeeping.
- Assertions must not assume the producer waits for ready before asserting valid. Environment protocol assertions and DUT assertions will be distinguished so a driver fault is not misclassified as RTL failure.

## Directed and constrained-random scenarios

### AES data correctness

- Authoritative AES-128 KAT and at least one additional independent vector.
- All-zero, all-one, alternating, walking-one, and walking-zero plaintexts and keys.
- Same plaintext under multiple keys and multiple plaintexts under the same key.
- Repeated identical blocks to expose accidental duplicate suppression.
- Byte-position patterns targeting MSB-first and column-major mapping mistakes.

### Handshake and backpressure

- Input valid before ready, ready before valid, and both rising together.
- Single-cycle and multi-cycle valid holds; ready toggles around acceptance.
- Back-to-back accepted inputs at the architecture's supported II.
- Output ready low before valid, deasserted on the first valid cycle, and randomized thereafter.
- Long output stalls, including the maximum practical randomized stall, checking stable ciphertext/valid.
- Simultaneous input acceptance and output transfer, including buffer-full/empty boundaries.
- End-of-test drain with exact accepted-versus-transferred accounting.

### Key epochs

- First key load, repeated identical key loads, and alternating keys.
- Key update while idle, while blocks are in flight, while output is stalled, and on a prospective plaintext-acceptance edge.
- Attempts to present plaintext before any key is loaded.
- Bursts straddling a key boundary, with every expected result labeled by key epoch.
- Tests for all approved key policy behaviors: snapshot, idle-only backpressure, or barrier behavior. Only the selected policy becomes mandatory; alternatives must not be encoded as simultaneous expectations.

### Reset

- Reset at idle, during input presentation before acceptance, immediately after acceptance, mid-computation, coincident with output valid, and during a stalled output.
- Reset pulses of approved legal duration and reset release with valid/ready already asserted.
- Check post-reset key-valid state, pending-queue flush/retention behavior, output validity, payload stability requirements, and first legal post-reset transaction.
- Reset polarity, synchronicity, edge precedence, and traffic legality remain blocked on the PDF/owner decision.

### Performance

- Load a valid key, hold input valid continuously with a long sequence, keep output ready high, discard warm-up effects, and record every input acceptance cycle.
- Calculate each consecutive acceptance delta and require the approved steady-state maximum to be <= 6. Also measure first-block latency from acceptance to output transfer and drain latency, without turning an architecture estimate into a requirement unless approved.
- Report nominal throughput as a formula based on measured II. Do not claim a verified 200 MHz clock or physical timing.

## Functional coverage plan

Mandatory-bin candidates, subject to owner approval:

- Handshake states and transitions for each channel: idle, wait-for-ready, transfer, and consecutive transfers.
- Input and output stall-length bins: 0, 1, 2–5, 6–15, and 16+ cycles.
- Key operation: first load, same-key reload, changed key; idle/busy/output-stalled timing.
- Same-cycle key/plaintext handshake crossed with approved old/new-key precedence.
- Reset phase: idle, input wait, in-flight compute, output valid/ready, output stalled.
- Data classes: zero, ones, alternating, walking bit, repeated, random; key classes likewise.
- Key epoch transition crossed with position in burst (first, middle, last).
- Acceptance-cycle delta bins: 1 through 6 and greater than 6 (the latter is an error bin under the performance setup).
- Ciphertext result comparison outcome; mismatch is an illegal/error condition, not a closure target.

Coverage will be sampled from interface-visible events and scoreboard metadata, not inferred from DUT internals. Mandatory bins cannot be finalized until the PDF and contract are approved.

## Code coverage plan

Use Questa-generated RTL statement, branch, condition, expression, toggle, and FSM metrics where supported by the installed version. The owner must choose whether the >=98% target applies to statement coverage, a named aggregate, or multiple individual metrics. DV will publish each metric separately rather than averaging unlike quantities. Exclusions require evidence of unreachability or non-functional boilerplate, review by the root/RTL owner, and a recorded justification; no exclusions exist yet. No coverage threshold is claimed or verified in Phase 0.

## Regression evidence and bug triage

- Every run will preserve its deterministic seed and exact Questa command once scripts exist in a later phase.
- A mismatch is presumed to be a bug until independently classified.
- Bug reports under `docs/verification/bug_reports/` will include seed, accepted transactions/key epochs, first failing time/cycle, expected and actual values, minimal reproduction command, and suspected owner.
- After a fix: rerun the failing seed, then smoke, then full regression. Root assigns ownership; DV never edits RTL or weakens an expected result.
- Acceptance requires no compiler errors, `UVM_FATAL`, unexpected `UVM_ERROR`, scoreboard mismatches, or assertion failures. Missing tools or unavailable coverage is **NOT VERIFIED**, never PASS.

## Phase 0 blockers and approvals needed

1. Supply the actual PDF so this matrix can cite and cover all requirements.
2. Approve exact ports, reset polarity/synchronicity, and channel semantics.
3. Select key-update policy and same-cycle key/plaintext precedence.
4. Decide whether plaintext before first key is stalled and approve reset flush semantics.
5. Approve the II definition and any latency bound.
6. Name the Questa code-coverage metric(s) subject to >=98%, the mandatory functional bins, and the exclusion-review policy.

No Phase 1 verification implementation should begin until these blockers are resolved.
