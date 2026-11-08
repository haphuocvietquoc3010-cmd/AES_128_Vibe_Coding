# Resume State

Updated: 2026-11-09

## Current project phase and task

- Project phase: P5 project publish.
- Current task: README refresh and push. README and `.gitignore` are updated, and the full project is committed in temporary clone `.publish_stage`; push is pending valid GitHub authentication.
- Last completed milestone: Fresh Questa work library built successfully; regression passed 18/18; directed seed 314159 passed; local publish commit prepared.

## Agent status and ownership

- RTL Designer agent (`/root/rtl_architecture`): **completed**. Formatted the four RTL files; standalone Questa compile passed; no behavior/architecture change.
- DV Verifier agent (`/root/dv_planning`): **completed**. Split/formatted TB components, tests, and sequences; dependency-ordered compile and smoke passed; one main agent retained.
- No other agents are authorized for this task. Do not have agents edit the same paths at the same time.
- Root owns `sim/`, shared project docs, integration, compilation/regression, and final review.

## Working tree and files

- Git status: unavailable; this workspace has no `.git` metadata (`git status --short` previously returned “not a git repository”). Do not infer a clean tree or claim a commit/diff.
- The prior generated `sim/work/` was removed after verifying its resolved path and confirming no Questa process was active; regression recreated a fresh library. Source and coverage evidence were preserved.
- Modified root/shared docs: `AGENTS.md`; `docs/progress.md`; `docs/project_structure.md`; `docs/final_verification_report.md`; `docs/refactor_report.md`; `docs/iteration_log.md`; `docs/verification/phase1_status.md`; `docs/verification/coverage_gaps.md`; `sim/README.md`; this `docs/resume_state.md`.
- Latest publish-task edits: `README.md` now documents structure, commands, current test/coverage results, and scope limits; `.gitignore` excludes generated Questa work and report outputs.
- Modified RTL: `rtl/aes128_pkg.sv`, `rtl/aes128_key_expand.sv`, `rtl/aes128_block_engine.sv`, `rtl/aes128_core.sv`.
- Modified TB: `tb/env/aes128_agent.svh`, `tb/env/aes_env.svh`, `tb/packages/aes_types.svh`, `tb/packages/aes_uvm_pkg.sv`.
- Added TB files: `tb/env/{aes_sequencer.svh,aes_driver.svh,aes_coverage.svh,aes_input_monitor.svh,aes_output_monitor.svh,aes_scoreboard.svh}`; `tb/sequences/{aes_base_sequence.svh,aes_smoke_sequence.svh,aes_random_sequence.svh,aes_pattern_sequence.svh,aes_throughput_sequence.svh,aes_pre_reset_sequence.svh,aes_coverage_sequence.svh}`; `tb/tests/{aes_base_test.svh,aes_smoke_test.svh,aes_random_test.svh,aes_pattern_test.svh,aes_reset_test.svh,aes_throughput_test.svh,aes_coverage_test.svh}`.
- Deleted aggregate TB files: `tb/sequences/aes_sequences.svh`, `tb/tests/aes_tests.svh`.
- Modified root-owned scripts: `sim/compile.do`, `sim/run.do`, `sim/smoke.ps1`, and `sim/regression.ps1`; they use dependency-ordered compilation and readable formatting while retaining test behavior.
- Generated/updated evidence: `sim/reports/{aes_smoke_test,aes_pattern_test,aes_random_test,aes_reset_test,aes_throughput_test,aes_coverage_test}_{1,17,20261109}.{log,ucdb}` and `sim/reports/aes_coverage_test_314159.{log,ucdb}`; `merged.ucdb`, `ucdb_inputs.txt`, `coverage_code.txt`, `coverage_functional.txt`, `coverage_rtl_statement.txt`, and `coverage_html/`. Questa also updated `sim/modelsim.ini`, `sim/transcript`, and `sim/vcover.log`; `sim/work/` is generated Questa state.

## Baseline verification already passed

- Available tools: `vlog`, `vsim`, and `vcover` found at the installed `C:\questasim\win64` location; previous successful runs used QuestaSim 10.2c and UVM 1.1d.
- Prior clean compile and smoke passed.
- Prior regression: 18/18 test/seed combinations passed across `aes_smoke_test`, `aes_pattern_test`, `aes_random_test`, `aes_reset_test`, `aes_throughput_test`, and `aes_coverage_test`; seeds 1, 17, and 20261109. Directed backpressure reproducer `aes_coverage_test` seed 314159 also passed.
- Prior results: no UVM errors/fatals, scoreboard mismatches, or assertion failures; maximum measured sustained no-stall II=5 cycles/block.
- Prior coverage: named RTL statement metric 100% in all four RTL design units; functional coverage 100%; assertions 4/4. Aggregate all-source metrics: statements 67.7%, branches 31.0%, conditions 85.7%, expressions 100%, toggles 94.2%. No exclusions.
- Latest post-script smoke: PASS seed 1; accepted/transferred 3/3; max II=5; UVM errors/fatals 0/0.
- Latest post-script full matrix: `sim/regression.ps1` exit 0; all 18 cases pass (six tests x seeds 1, 17, 20261109), with zero UVM errors/fatals or assertion failures. UCDB merge/report generation succeeded.
- Latest post-script directed case: `aes_coverage_test`, seed 314159, exit 0; accepted/transferred 3/3; max II=23 under deterministic output stalls; UVM errors/fatals 0/0.
- Latest merged coverage: all-source statements 67.9% (410/603), branches 31.0% (87/280), conditions 85.7%, expressions 100%, toggles 94.2%, code-only total 72.9%; assertion coverage 4/4. Named RTL statement coverage is 100% for each of the four RTL DUs. Functional coverage is 100%, including all crosses and five output-stall bins; no exclusions.
- Exact latency was not separately captured. Silicon timing, synthesis, STA, and area remain NOT VERIFIED and are out of scope.
- Evidence is under `sim/reports/`; the authoritative summary is `docs/final_verification_report.md`.

## Known failures and root causes

- No open failures at checkpoint. Previously closed: reset seed 17 DV driver scheduling race, and seed 314159 RTL output overwrite under backpressure. Bug reports are in `docs/verification/bug_reports/`.
- No open failures. Fresh-library compile, smoke, 18-case regression, and directed case all passed after script formatting. No `vdel`/existing-library warnings occurred on the final clean run. Questa notes missing compiled `questa_uvm_pkg` for optional UVM-aware debug; simulation is unaffected. The HTML report lacks testplan metadata due license availability.

## Pending work and next actions

1. Authenticate this environment to the user's GitHub account using a supported credential helper or GitHub CLI login; do not share credentials in chat or bypass SSH host verification.
2. Retry the requested push from the prepared staging clone:

   ```powershell
   git -C C:\Users\ADMIN\Downloads\AES128_TWO_AGENT_STARTER\.publish_stage push -u origin main
   ```

3. Verify remote `main` and report the resulting commit hash. No source or simulation work remains pending.

## Reproduction commands

From the workspace root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\regression.ps1
```

The regression script attempts to clean/rebuild the Questa work library and runs the fixed matrix. Preserve `sim/reports/` evidence and do not delete source or unrelated files when cleaning. For the directed case, run from `sim/` after setting `TEST=aes_coverage_test`, `SEED=314159`, and `AES_PROJECT_ROOT` to the workspace root, then execute `vsim -c -do run.do`.

## Environment blockers

- No known Questa/license blocker from previous runs. The prior HTML report noted missing license support for HTML testplan metadata; merged UCDB and text reports succeeded.
- The target repository was empty when checked (`git ls-remote --heads` returned no branches).
- HTTPS push failed with `Invalid username or token. Password authentication is not supported for Git operations.` The `gh` CLI is unavailable. SSH port 22 was blocked and SSH over port 443 failed host-key verification; do not disable host verification or put a token in command output.
