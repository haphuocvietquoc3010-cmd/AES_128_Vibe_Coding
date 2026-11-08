# Paste after the first smoke build

Run a bounded RTL↔DV debug loop under root orchestration, maximum 8 repair iterations in this run:

A) DV compiles and runs KAT, reset, backpressure, key update and multi-block tests with reproducible seeds. DV checks scoreboard, assertions, compile warnings/errors and logs; it writes docs/verification/bug_reports/BUG-*.md for every actionable mismatch.
B) Root assigns each issue: RTL implementation -> rtl_designer only; DV model/TB/script -> dv_verifier only; ambiguous contract -> root selects and records the most conservative requirement-preserving interpretation.
C) Correct owner makes smallest justified change, describes root cause and affected tests.
D) DV FIRST reruns exact failing seed, THEN full smoke, THEN randomized regression; preserve the seed in report.
E) Root records outcomes, issue closure and remaining blockers in docs/iteration_log.md.

Never change the reference model to match a wrong DUT or waive a failed assertion to obtain a PASS. Never claim test execution if Questa is unavailable. If all regression tests pass and no open blockers remain, move to coverage closure; otherwise after 8 iterations STOP with an actionable blocker summary.
