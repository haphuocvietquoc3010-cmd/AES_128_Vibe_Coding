# Final Coverage Closure

Status: **CLOSED — no open mandatory feasible functional bins**

The targeted all-ones key/data and deterministic 6–15/16+ output-stall scenarios pass and are included in the merged database. Final functional coverage is 100%:

- Input operation bins: 2/2.
- Input data-class bins: 3/3.
- Operation × data-class cross: 6/6, including key/all-ones.
- Output stall bins: 5/5 (`none`, `one`, `short`, `mid_len`, `long_len`).
- Assertions: 4/4 covered with no failures.

There are no exclusions and no remaining functional holes.

| Scope/metric | Final result |
|---|---:|
| Named RTL statement: four RTL DUs | **100% each** |
| All-source statement | 67.9% |
| All-source branch | 31.0% |
| All-source condition | 85.7% |
| All-source expression | 100.0% |
| All-source toggle | 94.2% |
| All-source FSM | 100.0% reported, zero active state/transition bins |
| Code-only filtered total | 72.9% |

The >=98% claim applies only to the named RTL statement metric. No >=98% claim is made for the aggregate metrics.
