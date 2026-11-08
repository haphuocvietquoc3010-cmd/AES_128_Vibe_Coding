# Paste after regression is clean

Have `dv_verifier` run reproducible, seeded Questa regression with code coverage and functional coverage enabled for the installed version. Merge UCDBs only when actual UCDB data exists; generate readable per-metric coverage reports. Include line/statement, branch, toggle, FSM (where applicable), and meaningful functional crosses; do not mix percentages invisibly. Require a clearly defined and measured RTL code coverage metric >= 98% and mandatory functional bins covered. Collect coverage holes into docs/verification/coverage_gaps.md.

For missed feasible coverage, DV adds legal constrained-random distributions, directed corner tests, temporal/sequential backpressure scenarios, or assertions. For unreachable RTL code, request a documented justification and owner-approved exclusion rather than fudging the result. For an RTL defect, transfer the bug to `rtl_designer`, then DV reruns reproducer and regression.

Have root report the exact measured numbers and limitations, measured II/latency via accepted handshakes without output stalls, nominal throughput calculation using assumed 200 MHz, run commands, final file tree and updated project AGENTS.md. Do not call synthesis, STA, cell area, or actual 200 MHz timing verified. Stop and report NOT VERIFIED if Questa or coverage collection is unavailable.
