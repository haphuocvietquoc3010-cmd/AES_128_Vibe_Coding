# Resume State

Updated: 2026-11-09

## Current project phase and task

- Project phase: P5 final package complete; publication blocked on GitHub authentication.
- Current task: Preserve the verified local commit; retry push after this environment has GitHub credentials configured.
- Last completed milestone: Full seven-test x three-seed regression passed (21/21); clean smoke, directed backpressure seed 314159, and focused key-toggle seed 4242 passed. RTL statement/branch/FEC/toggle metrics are each 100% after excluding only two structurally unreachable `round_num[0]` toggle bins.

## Agent status and ownership

- RTL Designer agent (`/root/rtl_architecture`): **completed**. Formatted the four RTL files; standalone Questa compile passed; no behavior/architecture change.
- DV Verifier agent (`/root/dv_planning`): **completed**. Split/formatted TB components, tests, and sequences; added and peer-reviewed the accepted key-toggle test and exclusion; seed 4242 passed.
- No other agents are authorized for this task. Do not have agents edit the same paths at the same time.
- Root owns `sim/`, shared project docs, integration, compilation/regression, and final review.

## Working tree and files

- Git status: unavailable in the source workspace; it has no `.git` metadata. The isolated `.publish_stage` clone is the Git working copy for the requested remote publication.
- The prior generated `sim/work/` was removed after verifying its resolved path and confirming no Questa process was active; regression recreated a fresh library. Source and coverage evidence were preserved.
- Modified root/shared docs: `AGENTS.md`; `docs/progress.md`; `docs/project_structure.md`; `docs/final_verification_report.md`; `docs/refactor_report.md`; `docs/iteration_log.md`; `docs/verification/phase1_status.md`; `docs/verification/coverage_gaps.md`; `sim/README.md`; this `docs/resume_state.md`.
- Latest publish-task edits: `README.md` documents structure, commands, current test/coverage results, and scope limits; `.gitignore` excludes generated Questa work and report outputs.
- Coverage follow-up adds `tb/sequences/aes_key_toggle_sequence.svh`, `tb/tests/aes_key_toggle_test.svh`, and a package include. `sim/run.do` excludes only the two toggle directions on structurally constant `u_block_engine.round_num[0]`; `sim/regression.ps1` includes the test and emits detailed per-RTL reports and the user exclusion list. The existing local commit under `.publish_stage` predates these changes; sync/update it before any push.
- Modified RTL: `rtl/aes128_pkg.sv`, `rtl/aes128_key_expand.sv`, `rtl/aes128_block_engine.sv`, `rtl/aes128_core.sv`.
- Modified TB: `tb/env/aes128_agent.svh`, `tb/env/aes_env.svh`, `tb/packages/aes_types.svh`, `tb/packages/aes_uvm_pkg.sv`.
- Added TB files: `tb/env/{aes_sequencer.svh,aes_driver.svh,aes_coverage.svh,aes_input_monitor.svh,aes_output_monitor.svh,aes_scoreboard.svh}`; `tb/sequences/{aes_base_sequence.svh,aes_smoke_sequence.svh,aes_random_sequence.svh,aes_pattern_sequence.svh,aes_throughput_sequence.svh,aes_pre_reset_sequence.svh,aes_coverage_sequence.svh,aes_key_toggle_sequence.svh}`; `tb/tests/{aes_base_test.svh,aes_smoke_test.svh,aes_random_test.svh,aes_pattern_test.svh,aes_reset_test.svh,aes_throughput_test.svh,aes_coverage_test.svh,aes_key_toggle_test.svh}`.
- Deleted aggregate TB files: `tb/sequences/aes_sequences.svh`, `tb/tests/aes_tests.svh`.
- Modified root-owned scripts: `sim/compile.do`, `sim/run.do`, `sim/smoke.ps1`, and `sim/regression.ps1`; they use dependency-ordered compilation, run the two-bin exclusion, and emit per-RTL detailed reports.
- Generated/updated evidence: seven test logs/UCDBs for seeds 1, 17, and 20261109 (21 cases); focused `aes_key_toggle_test_4242` and `aes_coverage_test_314159`; `merged.ucdb`, `ucdb_inputs.txt`, `coverage_code.txt`, `coverage_functional.txt`, `coverage_rtl_statement.txt`, new `coverage_rtl_code.txt`, `coverage_excluded.txt`, and `coverage_html/`. Questa also updated `sim/modelsim.ini`, `sim/transcript`, and `sim/vcover.log`; `sim/work/` is generated Questa state.

## Baseline verification already passed

- Available tools: `vlog`, `vsim`, and `vcover` found at the installed `C:\questasim\win64` location; previous successful runs used QuestaSim 10.2c and UVM 1.1d.
- Prior clean compile and smoke passed.
- Latest regression: 21/21 combinations passed across seven tests and seeds 1, 17, and 20261109. Focused `aes_key_toggle_test` seed 4242, clean smoke seed 1, and directed backpressure seed 314159 also passed.
- Prior results: no UVM errors/fatals, scoreboard mismatches, or assertion failures; maximum measured sustained no-stall II=5 cycles/block.
- Historical pre-closure coverage: RTL statement 100%; all-source statement 67.7%, branch 31.0%, conditions 85.7%, expressions 100%, toggles 94.2%; no exclusions at that point.
- Latest post-script smoke: PASS seed 1; accepted/transferred 3/3; max II=5; UVM errors/fatals 0/0.
- Latest full matrix: `sim/regression.ps1` exit 0; all 21 cases pass (seven tests x seeds 1, 17, 20261109), with zero UVM errors/fatals or assertion failures. UCDB merge/report generation succeeded.
- Latest post-script directed case: `aes_coverage_test`, seed 314159, exit 0; accepted/transferred 3/3; max II=23 under deterministic output stalls; UVM errors/fatals 0/0.
- Latest merged coverage: RTL statements 92/92, branches 32/32, FEC condition terms 2/2, expression terms 14/14, and attainable toggles 2872/2872 (all 100%). Exactly 2 structurally unreachable toggle bins for `aes128_block_engine.round_num[0]` are excluded. All-source statements 425/629 (67.5%), branches 87/290 (30.0%), FEC conditions 10/14 (71.4%), FEC expressions 20/20 (100%), toggles 3930/3930 (100%), code-only total 73.7%. Assertions 4/4; functional coverage 100%.
- Exact latency was not separately captured. Silicon timing, synthesis, STA, and area remain NOT VERIFIED and are out of scope.
- Evidence is under `sim/reports/`; the authoritative summary is `docs/final_verification_report.md`.

## Known failures and root causes

- No open failures at checkpoint. Previously closed: reset seed 17 DV driver scheduling race, and seed 314159 RTL output overwrite under backpressure. Bug reports are in `docs/verification/bug_reports/`.
- No open test failures. Fresh-library compile, smoke, 21-case regression, focused key-toggle case, and directed stall case passed. No `vdel`/existing-library warnings occurred on the final clean run. Questa notes missing compiled `questa_uvm_pkg` for optional UVM-aware debug; simulation is unaffected. The HTML report lacks testplan metadata due license availability.

## Pending work and next actions

1. Configure a supported Git credential helper or authenticate GitHub CLI outside this noninteractive session. Do not paste credentials into the chat or disable SSH host verification.
2. Retry the requested push from the prepared staging clone. The last noninteractive HTTPS attempt failed with `Cannot prompt because user interactivity has been disabled` and `unable to get password from user`; local source and commit remain preserved.

   ```powershell
   git -c "safe.directory=C:/Users/ADMIN/Downloads/AES128_TWO_AGENT_STARTER/.publish_stage" -C C:\Users\ADMIN\Downloads\AES128_TWO_AGENT_STARTER\.publish_stage push -u origin main
   ```

3. Verify remote `main` and report the resulting commit hash if the push succeeds. It had no branch before the failed authentication attempt.

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
- Latest HTTPS push attempt (with interactive prompts disabled) failed because no password/token credential is available to Git. The remote still has no `main` ref. `gh` is unavailable; SSH port 22 was blocked and SSH over port 443 failed host-key verification. Do not disable host verification or put a token in command output.
