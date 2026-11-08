# Paste into the MAIN Codex chat — Phase 0 only

Act as the orchestrator of exactly two project custom subagents named `rtl_designer` and `dv_verifier`. First confirm that `.codex/agents/rtl_designer.toml` and `dv_verifier.toml` are discoverable; if your runtime cannot select custom agents, tell me and use strict sequential role scopes rather than claiming you spawned them.

Read the PDF file in this repository, AGENTS.md and `.codex/config.toml`. This is an EMPTY repo except for project bootstrap/config files and the course PDF; do not invent test results or existing RTL.

Deliver PHASE 0 ONLY. First, as root, draft `docs/spec_traceability.md` and `docs/interface_contract.md` from the PDF and explicitly flag gaps. THEN spawn BOTH custom subagents for independent, bounded tasks:
- `rtl_designer`: write `docs/design/architecture_notes.md` with >=3 architecture candidates and a concrete feasible resource/cycle schedule; do not edit root/shared docs or create RTL yet.
- `dv_verifier`: write `docs/verification/testplan_draft.md` with a spec-driven verification matrix, reference-model plan and risky handshake/key/reset scenarios; do not create UVM yet.
Wait for both. Root synthesizes results into the deliverables below, while retaining unresolved decisions and independent DV checks.

Root deliverables:
- `docs/spec_traceability.md`: enumerate required behavior and cite PDF page/section; distinguish user additions from PDF requirements.
- `docs/interface_contract.md`: top interface, handshake acceptance and transfer conditions, reset, key-update policy proposals including in-flight transaction protection, byte order and block ordering. Clearly mark underspecified choices for owner approval.
- `docs/architecture_tradeoffs.md`: compare >=3 candidate AES-128 architectures with physical resource counts, cycle schedules, latency, steady-state II, nominal throughput at 200 MHz, approximate non-cell-cost trend. Eliminate II >6 candidates.
- `docs/architecture_decision.md`: recommended feasible area-conscious design and exact assumptions; leave approval status PENDING.
- validate `command -v vlog`, `vsim`, `vcover` plus a non-destructive UVM availability/version check where possible; document blockers.

Do NOT write RTL/UVM during Phase 0. Do not synthesize, run STA, or claim a verified 200 MHz clock. Root resolves open local choices, records them, applies the quality gate, and advances automatically when sufficient requirements exist.
