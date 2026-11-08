# Paste after you personally reviewed Phase 0 docs

Root reviews and freezes the architecture and interface contract recorded in docs/architecture_decision.md and docs/interface_contract.md, including exact key-update and reset behavior. Resolve local implementation choices conservatively and document them.

Update architecture_decision.md to record the automatic quality-gate decision and final selected resource counts and schedule. Ask `rtl_designer` for an implementation plan within rtl/** and docs/design/**, and ask `dv_verifier` for a verification plan within tb/**, sim/** and docs/verification/**. Ask each to identify risks and assumptions. Root consolidates into docs/phase_plan.md, checks there are no overlapping edit paths, and advances automatically.
