# Integration and Refactor Iteration Log

## Pre-refactor baseline

- Workspace had no `.git` metadata; `git status --short` returned “not a git repository.” Changes were preserved by inspecting the file inventory and keeping generated evidence under `sim/reports/`.
- QuestaSim 10.2c/UVM 1.1d clean compilation passed.
- 15 combinations across smoke, pattern, random, reset, and throughput tests at seeds 1, 17, and 20261109 passed; no UVM errors/fatals/assertion errors. Maximum measured no-stall II was 5.
- Baseline coverage: statements 62.0%, branches 25.4%, conditions 87.5%, expressions 96.6%, toggles 89.6%, functional covergroups 77.2%. Missed functional bins were key/ones and mid/long output stalls.
- Reset seed 17 initially hung due to a DV driver clocking/deassert race. Monitor-confirmed handshaking after moving valid drive/deassert to falling edges fixed it; reset seed 17 then passed.

## Refactor iteration

- RTL split into package, key expander, block engine, and core. UVM was split into models, testbench, packages, environment, sequences, and tests while retaining one agent.
- First post-refactor smoke caught a refactor-introduced AES S-box table truncation (471 hex digits instead of 512); Questa silently zero-extended it, so compile passed while AES results failed.
- RTL owner restored all 256 S-box entries as sixteen explicit 128-bit rows. The exact smoke seed 1 passed afterward (3 accepted/3 transferred, no UVM errors/fatals, max II=5).
- Full post-fix matrix of 15 test/seed runs passed. Merged coverage: statements 67.9%, branches 30.9%, conditions 85.7%, expressions 100.0%, toggles 93.8%, aggregate code-only 72.8%, functional covergroups 77.2%, assertions 100%.
- Per-RTL design-unit statement coverage: `aes128_pkg` 100%, `aes128_key_expand` 100%, `aes128_block_engine` 100%, `aes128_core` 100%. This is the named RTL statement metric; aggregate reports including TB are separate.
- `sim/regression.ps1` reporting syntax was corrected for Questa 10.2c (`-totals` on code report, `-cvg -details` on functional report). Corrected report generation succeeds.

## Final refactor and coverage closure

- Directed coverage initially exposed a real output-register overwrite while stalled. RTL now holds the completed fifth-pass state until the output slot is available; the exact reproducer passed before smoke and full regression.
- Final matrix: 18/18 combinations passed across six test classes and seeds 1, 17, and 20261109; separate directed reproducer seed 314159 also passed.
- Final merged metrics: all-source statements 67.7%, branches 31.0%, conditions 85.7%, expressions 100.0%, toggles 94.2%; functional covergroups 100%, assertions 4/4, named RTL statement coverage 100% for all four RTL design units.
- No exclusions were applied. Full HTML report lacks testplan metadata due license availability, while UCDB merge and text reports succeed.
- The reproducible `sim/regression.ps1` now performs clean compilation, runs the 18 cases, validates logs, merges only the UCDBs from the current run matrix, and emits aggregate plus per-RTL-unit coverage reports.

## Formatting and per-class split follow-up

- RTL owner reformatted all four RTL files; DV owner split sequencer, driver, input/output monitors, coverage, scoreboard, and environment into separate source fragments. All seven sequence classes and all seven test classes are now each in their own file. The one-agent architecture and independent AES oracle were preserved.
- Root audited RTL/TB for tabs and lines over 120 columns; none were found. Integrated smoke seed 1 passed, and the complete `sim/regression.ps1` matrix passed all six tests at seeds 1, 17, and 20261109 (18/18). Directed `aes_coverage_test` seed 314159 passed afterward.
- Updated merged UCDB reflects the split source files: statements 67.9% (410/603), branches 31.0% (87/280), conditions 85.7%, expressions 100%, toggles 94.2%, code-only filtered total 72.9%. All four RTL DUs remain at 100% named statement coverage; functional coverage is 100%, assertions 4/4; no exclusions.

## Final key-toggle coverage follow-up

- Added an independent UVM sequence/test that accepts keys `0 -> all ones -> 0`, with one plaintext per accepted key epoch. Focused seed 4242 passed 3/3 transfers with no UVM errors/fatals or scoreboard mismatch.
- RTL and DV peers audited the only structurally impossible RTL toggles: `aes128_block_engine.round_num[0]` is always one from `{pass_count,1'b0} + 1`. Applied exactly one scoped Questa exclusion for its two transition directions. No RTL code was removed, and no feasible key input bins were excluded.
- Recompiled from a fresh Questa work library. All seven UVM tests passed at seeds 1, 17, and 20261109 (21/21). Clean smoke seed 1 passed 3/3, max II=5; directed backpressure seed 314159 passed 3/3, max II=23; no UVM errors/fatals, scoreboard mismatches, or assertion failures.
- Final RTL metrics: statements 92/92, branches 32/32, FEC conditions 2/2, FEC expressions 14/14, and attainable toggle bins 2872/2872 (all 100%). Full UCDB: statements 425/629 (67.5%), branches 87/290 (30.0%), FEC conditions 10/14 (71.4%), FEC expressions 20/20, toggles 3930/3930, code-only filtered total 73.7%. Functional coverage 100%, assertions 4/4.
- README, final verification summary, phase status, and detailed coverage exclusion evidence now reflect this final run. GitHub push remains pending repository authentication.
- An initial post-script compile warned about locked optimized library artifacts. Root verified no Questa process was active, removed only the generated `sim/work/`, and reran the full regression; the final compile used a fresh library without cleanup warnings. Questa's optional UVM-aware debug note remains because `questa_uvm_pkg` is not separately compiled; HTML testplan metadata remains unavailable due license availability.
- Git status remains unavailable because this workspace has no `.git` metadata.
