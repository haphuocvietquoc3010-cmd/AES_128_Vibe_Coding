# Coverage Closure and Exclusions

Status: **CLOSED for the named RTL code metrics and mandatory functional bins.**

## Method and scope

Coverage was measured with QuestaSim 10.2c from the merged UCDB produced by
`sim/regression.ps1`. The regression compiles RTL with `-cover bcesft`, runs
seven UVM tests at seeds 1, 17, and 20261109 (21 runs), and reports the RTL
design units separately from the complete RTL/testbench/reference-model
database. `aes_key_toggle_test` drives accepted key loads `0 -> all ones -> 0`
with a data block after each load, so the independent scoreboard checks each
key epoch.

## Final RTL metrics

| RTL design unit | Statements | Branches | FEC conditions | FEC expressions | Toggle bins after exclusion |
|---|---:|---:|---:|---:|---:|
| `aes128_pkg` | 45/45 (100%) | 13/13 (100%) | N/A | N/A | N/A (0 instrumented bins) |
| `aes128_key_expand` | 18/18 (100%) | 6/6 (100%) | N/A | N/A | 524/524 (100%) |
| `aes128_block_engine` | 27/27 (100%) | 13/13 (100%) | 2/2 (100%) | 9/9 (100%) | 1556/1556 (100%) |
| `aes128_core` | 2/2 (100%) | 0/0 | N/A | 5/5 (100%) | 792/792 (100%) |
| **RTL total** | **92/92 (100%)** | **32/32 (100%)** | **2/2 (100%)** | **14/14 (100%)** | **2872/2872 (100%)** |

The literal >=98% code-coverage acceptance check is satisfied for the named
RTL statement metric (100%); each separately reported RTL branch, condition,
expression, and attainable toggle metric is also 100%. `aes128_pkg` has no
instrumented toggle bins, so its 0/0 must not be interpreted as exercised
toggle coverage.

## Excluded bins and reason

Exactly one RTL node is excluded: both toggle directions (two bins total) for
`aes128_block_engine.round_num[0]`. The RTL assigns
`round_num = {pass_count, 1'b0} + 4'd1`. The concatenation is even and adding
one makes bit 0 constant 1 for every legal value of `pass_count`; consequently
neither 0-to-1 nor 1-to-0 can occur. These are structurally unreachable bins,
not missing stimulus. The RTL Designer audited the node and the DV Verifier
independently peer-reviewed the exact two-bin exclusion. No RTL logic was
removed or altered to improve coverage.

Questa records the scoped exclusion in each run UCDB. The merged report lists
only `coverage exclude -scope /tb_top/dut/u_block_engine -togglenode
{round_num[0]}`. Before excluding it, the all-node RTL toggle denominator was
2874 with 2872 reachable bins hit (99.93%); after excluding only those two
bins, 2872/2872 attainable RTL toggle bins are hit (100%). The added key
transition test covers the previously missed environment-driven `i_key`
transitions; no key-port bins are excluded.

## Complete database and functional results

The whole UCDB includes verification and reference code, so it has different
coverage from RTL alone. The final merged report contains 32 files: statements
425/629 (67.5%), branches 87/290 (30.0%), FEC conditions 10/14 (71.4%), FEC
expressions 20/20 (100%), and toggle bins 3930/3930 (100%). The code-only
filtered total is 73.7%. These aggregate figures are reported as-is and are
not the RTL acceptance metric.

Functional coverage is 100%: all operation/data-class crosses and all five
output-stall bins are hit. Assertion coverage is 4/4 with no assertion
failures. No functional bins, feasible RTL code bins, or key input toggle bins
were excluded. The exclusion does not conceal a behavioral gap.

## Evidence files

- `sim/reports/coverage_rtl_statement.txt`: RTL statement percentages by DU.
- `sim/reports/coverage_rtl_code.txt`: detailed RTL statement, branch, FEC,
  and toggle reports by DU.
- `sim/reports/coverage_excluded.txt`: Questa's merged user exclusion list.
- `sim/reports/coverage_code.txt` and `coverage_functional.txt`: complete
  merged database reports.
- `sim/reports/ucdb_inputs.txt` and the named run UCDBs: regression provenance.

Generated reports/UCDB files are local simulation artifacts and are ignored by
Git; the measured results and the exact exclusion rationale are retained in
the project documentation.
