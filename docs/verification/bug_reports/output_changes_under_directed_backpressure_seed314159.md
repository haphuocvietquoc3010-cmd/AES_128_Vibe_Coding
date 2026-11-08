# Output changes under deterministic backpressure

Status: CLOSED — RTL fix verified by seed 314159 and the passing 18-run matrix  
Seed: 314159  
Test: `aes_coverage_test`  
Suspected owner: `rtl_designer`

## Reproduction

```powershell
$env:UVM_HOME='C:/questasim/verilog_src/uvm-1.1d/src'
$env:AES_PROJECT_ROOT='C:/Users/ADMIN/Downloads/AES128~1'
Set-Location sim
vsim -c -do compile.do
$env:TEST='aes_coverage_test'; $env:SEED='314159'; vsim -c -do run.do
```

## Stimulus

- Key: `ffffffffffffffffffffffffffffffff`
- Three ordered plaintexts, starting with all ones.
- Output ready is held low deterministically for cycles 1–40, high for cycles 41–42, low for cycles 43–52, then high. This targets the feasible 16+ and 6–15 stall bins.

## Failure evidence

- 132.5 ns: black-box assertion `a_output_stable_when_stalled` fails; it requires `o_cipher_valid` and `o_ciphertext` to remain stable while `i_cipher_ready=0`.
- First transferred ciphertext: expected `bcbf217cb280cf30b2517052193ab979`, observed `89ffb33540e4b610bb328598e139a617`.
- Second transfer: expected `89ffb33540e4b610bb328598e139a617`, observed `fde88324622564b79522154e05e32e7f`.
- End of test: one expected ciphertext remains queued.
- UVM summary: 3 accepted, 2 transferred, 2 mismatches, 1 missing output.

The observed values are shifted by one transaction after the stalled output changes, consistent with overwriting or advancing a full output register while backpressured. The independent oracle and expected ordering are unchanged.

## Required fix verification order

1. Rerun `aes_coverage_test`, seed 314159.
2. Rerun smoke seed 1.
3. Rerun the complete regression and merge only passing UCDBs.

## Closure

The RTL fix preserves stalled output and prevents advancement into a full output slot. Seed 314159 and the complete 18-run regression pass. The merged result reports 100% assertion and functional covergroup coverage, including mid/long stalls. No oracle value or checker was weakened.
