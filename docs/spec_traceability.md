# AES-128 Specification Traceability

Source: `docs/Big_Project_01_2026.pdf` (17 PDF pages; printed section page numbers are one less after the cover). Reviewed 2026-11-09.

| ID | Requirement | PDF evidence | Classification / disposition |
|---|---|---|---|
| AES-001 | AES-128 encryption only; 128-bit plaintext, key, ciphertext | PDF p.3 §1.1; p.10 §2.1 | PDF requirement |
| AES-002 | MSB-first external serialization | PDF pp.3–4 §§1.1–1.2 | PDF requirement |
| AES-003 | AES state filled column-major, `s[r,c]=p[4c+r]` | PDF pp.3–4 §1.2 | PDF requirement |
| AES-004 | Initial AddRoundKey K0, nine full rounds, final round without MixColumns | PDF p.4 §1.3; p.13 §2.5.3 | PDF requirement |
| AES-005 | Standard AES S-box; implementation/resource count justified | PDF p.5 §1.4 | PDF requirement |
| AES-006 | ShiftRows fixed row rotations, preferably wiring | PDF p.6 §1.5 | PDF requirement |
| AES-007 | MixColumns uses AES GF(2^8), XOR/xtime rather than generic multipliers | PDF pp.6–7 §1.6; p.14 §2.5.3 | PDF requirement |
| AES-008 | Generate/provide K0–K10 per AES-128 expansion; document storage/setup/pipeline/cost | PDF pp.8–9 §1.8; p.14 §2.5.4 | PDF requirement |
| IF-001 | Exact 11 top-level ports and widths | PDF p.11 §2.2 Table 2 | PDF requirement; frozen in interface contract |
| IF-002 | Key/data/output transfer only on respective valid-ready conjunction | PDF p.11 §2.2 | PDF requirement |
| IF-003 | Preserve output under arbitrary backpressure; no loss/duplication | PDF p.11 §2.2; p.15 §2.5.6 | PDF requirement |
| IF-004 | Newly accepted key cannot corrupt an in-flight block; protocol documented | PDF p.14 §2.5.4 | PDF requirement; exact idle-barrier policy is root addition |
| IF-005 | Preserve data/key association and valid propagation | PDF pp.14–15 §§2.5.3–2.5.5 | PDF requirement |
| PERF-001 | Sustained throughput >=4.0 Gb/s at target 200 MHz; integer II <=6 | PDF p.10 §2.1; p.12 §2.4 | PDF requirement; simulation verifies II only in project scope |
| ARCH-001 | Explore >=3 architectures and report round/S-box/MixColumns/key/stage/latency/II/throughput/trends | PDF pp.12–13 §2.5.1 | PDF requirement |
| ARCH-002 | Select lowest justified cost among feasible candidates and freeze resource budget | PDF p.13 §2.5.2 | PDF requirement |
| DV-001 | Traceable KAT, same-key multi-block, >=2 keys, backpressure, reset, order/conservation | PDF p.15 §2.5.7 | PDF requirement |
| DV-002 | All simulation sources SystemVerilog and use course simulator | PDF p.15 §2.5.7 | PDF requirement; QuestaSim selected by project |
| SCOPE-001 | PDF requests 45-nm synthesis/STA and 5 ns timing closure | PDF pp.10, 15–16 §§2.1, 2.5.8 | Explicitly excluded by current user/project scope; report NOT VERIFIED, never PASS |
| USER-001 | Independent UVM golden model, assertions, constrained random, bug triage | `AGENTS.md` and current user request | User addition beyond Milestone 1 basic TB |
| USER-002 | RTL code coverage >=98% and mandatory functional bins | `AGENTS.md` and current user request | User addition; requires genuine Questa evidence |

## Underspecified choices resolved by root

- PDF specifies active-low reset but not synchronous/asynchronous behavior: frozen as asynchronous assertion/reset behavior.
- PDF does not define key update during busy, plaintext-before-key, or simultaneous key/data precedence: frozen as idle-barrier update, plaintext stalled until setup complete, and key priority.
- PDF does not mandate key-expansion organization: selected 10-cycle iterative precompute with 11 stored round keys.
- PDF does not define output-buffer depth: selected one dedicated output register with upstream backpressure.

## Scope reconciliation

The PDF's synthesis, PDK, STA, area, and real 200 MHz closure requirements are traceable but intentionally not executed because the controlling project/user scope is QuestaSim RTL/UVM only. Therefore silicon timing and cell area remain **NOT VERIFIED**.
