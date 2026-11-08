# Reset test stalls after post-reset key presentation

Status: CLOSED — DV driver defect fixed in debug iteration 2  
Seed: 17  
Test: `aes_reset_test`  
Suspected owner: DV first; RTL only if an interface monitor confirms a real post-reset key handshake and ten subsequent expansion cycles without `o_data_ready`

## Minimal reproduction

```powershell
$env:UVM_HOME='C:\questasim\verilog_src\uvm-1.1d'
$env:AES_PROJECT_ROOT='C:/Users/ADMIN/Downloads/AES128~1'
Set-Location sim
vsim -c -do compile.do
$env:TEST='aes_reset_test'; $env:SEED='17'; vsim -c -do run.do
```

## Observed sequence

- 17.5 ns: driver reports pre-reset key accepted.
- 72.5 ns: driver reports pre-reset plaintext accepted.
- 80 ns: reset asserted on falling edge.
- 90 ns: reset released on falling edge.
- 97.5 ns: driver reports post-reset key accepted after two clean rising edges.
- No post-reset plaintext acceptance follows.
- 100 us: bounded UVM watchdog emits `UVM_FATAL [PH_TIMEOUT]`.

Expected: reset flushes the pre-reset block; a new key handshakes, expands for ten cycles, post-reset plaintext is accepted, and the smoke sequence drains normally.

## Iteration 1 changes and classification

DV moved reset transitions to falling edges, added two clean recovery edges, changed the driver to cancel valid during reset and retry unaccepted items, added handshake/reset progress messages, and added bounded watchdogs. The failure remains. The driver message currently indicates sampled ready, not an independently observed `valid && ready` monitor event, so ownership cannot yet be reassigned to RTL.

## Iteration 2 resolution

Independent input-monitor logging proved that the driver-reported post-reset key acceptance was not an actual sampled `i_key_valid && o_key_ready` handshake. The driver asserted/deasserted through a clocking block in a way that could acknowledge ready and remove valid before the monitor/DUT observed a transfer.

The request driver now asserts payload/valid on a falling edge, samples ready on rising edges, and deasserts valid only on a later falling edge. Reset still cancels unaccepted presentation. Rerunning seed 17 produced:

- Actual post-reset key handshake: 112.5 ns, monitor cycle 23.
- Actual first post-reset data handshake: 167.5 ns, monitor cycle 34 (11 sampled-edge count including the key edge; consistent with ten expansion cycles before readiness).
- Four data acceptances were observed in total including the pre-reset block; three post-reset ciphertexts transferred, with the pre-reset expectation correctly flushed.
- `UVM_ERROR=0`, `UVM_FATAL=0`, no assertion failures, maximum same-key II=5.

The failing seed now passes. No RTL reassignment is required.
