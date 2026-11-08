# AGENTS.md — AES-128 RTL/UVM Project

## Goal
Build a synthesizable AES-128 encryption-only RTL accelerator and a SystemVerilog UVM verification environment using **QuestaSim only**. The user currently has a PDF specification and no implementation. Do not use or require ASIC synthesis, PDK, STA, Liberty cells, placement, or timing closure.

## Requirement priorities
1. Read the actual PDF and create `docs/spec_traceability.md` before implementation.
2. Preserve specified 128-bit top-level interface and byte ordering (MSB-first serialization, AES column-major state).
3. Implement initial AddRoundKey, 9 complete main rounds, and final round **without MixColumns**; support 128-bit runtime keys.
4. Never lose, duplicate or reorder accepted plaintext/ciphertext transactions during ready/valid stalls.
5. Prevent key changes from corrupting in-flight data. Freeze the exact policy in `docs/interface_contract.md` before coding; root resolves unspecified choices using conservative documented assumptions.
6. Architecture exploration must compare >=3 candidates and show concrete resource counts, cycle schedule, II and latency. Target **II <= 6** under continuous input and always-ready output; nominal throughput at an assumed 200 MHz is at least 4 Gb/s. QuestaSim alone cannot prove 200 MHz silicon timing or measured cell area.
7. Aim for RTL code coverage >= 98% with a clearly named Questa metric; close mandatory functional coverage bins. Never claim coverage without genuine tool reports; justify unreachable bins only with evidence.

## Collaboration
The root Codex thread is the **orchestrator**. Delegate to exactly two specialist roles, defined under `.codex/agents/`:
- `rtl_designer` owns `rtl/` and `docs/design/`, not `tb/`, `sim/` or DV reference/scoreboard.
- `dv_verifier` owns `tb/`, `sim/`, `docs/verification/`, not `rtl/` or RTL key schedule/S-box implementation.
- Root owns common spec/contracts, architecture approval, integration review, cross-role handoffs, and this AGENTS.md.
Never have two agents edit the same path at once. Use sequential iterations when there are shared dependencies. If custom subagents are unavailable in this CLI session, apply these exact roles as two sequential task runs; report the limitation.

## Workflow / stop gates
P0: PDF when available -> traceability + independent interface contract + architecture study. Root applies an automatic quality gate and records assumptions when source material is missing.
P1: RTL skeleton and independent AES reference model + directed KAT tests, then RTL+UVM build.
P2: Integration compile + smoke (reset, one NIST vector, 2 keys, repeated blocks). Block any further feature work on failing smoke.
P3: Directed corner scenarios + constrained-random + scoreboard + assertions + seed-preserving regression.
P4: Measure real code/functional coverage; close holes with valid stimulus or RTL bug fixes; record exclusions transparently.
P5: Final package, logs, measured II/latency, updated AGENTS.md, reproducible README. Continue automatically between gates; stop only for a genuine blocker or after acceptance.

## DV independence and bug triage
- DV reference model must not import RTL S-box/key schedule functions or rely on DUT internal signals to determine expected ciphertext.
- A mismatch is presumed a bug until independently classified; never modify the expected result simply to match the DUT.
- DV captures seed, accepted transactions/key epochs, first failing timestamp/cycle, observed/expected values, and minimal reproduction command in `docs/verification/bug_reports/`.
- Orchestrator assigns root cause: RTL design error -> `rtl_designer`; flawed test/model -> `dv_verifier`; ambiguous spec -> user decision. Only the owner agent edits its area.
- After each fix, run failing seed first, then smoke, then full regression; keep a changelog. Limit automatic repeated bug-fix cycles to 8; if still failing, report blocker honestly.

## Acceptance
- Tool prerequisites verified: `vlog`, `vsim`, `vcover`, UVM compatibility/availability, successful license checkout.
- No compiler errors, no UVM_FATAL, no unexpected UVM_ERROR, no scoreboard mismatches, no failed assertions.
- Reproducible directed, constrained-random and corner tests; fixed seeds persisted.
- Confirm measured sustained initiation interval <= 6 during back-to-back traffic with output ready=1; nominal 200 MHz throughput calculation is not a real timing claim.
- Code coverage >=98% per reported metric and coverage exclusions only with peer review; functional coverage mandatory bins hit.
- If tools are absent or coverage unavailable, state **NOT VERIFIED**, never PASS.
- Do not push to a remote or overwrite unrelated user files without permission.

## Current source layout and conventions

- `rtl/` contains `aes128_core.sv` (top/integration), `aes128_key_expand.sv`, `aes128_block_engine.sv`, and `aes128_pkg.sv` (shared combinational AES transforms/key primitive). Compile package before dependent modules.
- `tb/testbench/` contains the interface, assertions, and simulation top; `tb/models/` contains the independent AES oracle; `tb/packages/` contains UVM types/package; `tb/env/` contains one whole-interface `aes128_agent`, environment, and scoreboard; `tb/sequences/` and `tb/tests/` contain stimulus and test configurations.
- Do not add separate channel agents unless a concrete verification need justifies them. Preserve oracle independence.
- `sim/compile.do` is the source of truth for Questa 10.2c compile ordering; `sim/regression.ps1` runs fixed seeds and creates UCDB/text/HTML reports under `sim/reports/`.
- Report named RTL statement coverage by RTL design unit separately from aggregate code metrics that include testbench code. Never imply that a combined code score is an RTL-only metric.

## Formatting and refactor requirements

- All RTL, SystemVerilog verification, Questa Tcl, and PowerShell source uses exactly four spaces per indentation level, no tabs, one declaration per line, and one executable statement per line. Keep lines under 120 characters where practical and format control flow, functions, tasks, and instantiations across readable lines.
- Keep each meaningful synthesizable RTL module in its own `.sv` file; do not split trivial logic into needless modules.
- Keep the UVM organization under `tb/testbench/`, `tb/env/`, `tb/sequences/`, `tb/tests/`, `tb/models/`, and `tb/packages/`. Keep one main AES agent unless a concrete need justifies another.
- Put every UVM test class in its own source file and every major UVM sequence class in its own source file. Compile included class files in dependency order through the package and `sim/compile.do`.
- Every new Codex session must read this file before modifying the project. Before refactoring, capture the current status, source inventory, test inventory, and available baseline logs/results; preserve user changes.
- After any RTL/UVM code change, run a clean Questa compile, affected failing-seed reproducer if applicable, smoke, and the complete regression. Fix real failures and rerun the required sequence. Do not claim a test ran without its log/report evidence.
- Reproduce validation from the project root with:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\smoke.ps1`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\regression.ps1`
- Scripts must honor the installed Questa/UVM configuration, allow `UVM_HOME` overrides, and avoid assuming an unavailable installation path.
