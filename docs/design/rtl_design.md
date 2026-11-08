# AES-128 RTL Design

## Implemented module

`rtl/aes128_core.sv` implements the frozen `aes128_core` interface from `docs/interface_contract.md`. The implementation is split into four cohesive source units, all synthesizable SystemVerilog with no delays, DPI, vendor primitives, or testbench constructs.

## RTL structure

- `aes128_pkg.sv` owns the shared, stateless AES transformations: S-box lookup, SubBytes, ShiftRows, MixColumns, one-round transform, Rcon, and next-round-key calculation.
- `aes128_key_expand.sv` owns the single 10-cycle iterative key-expansion state machine and packed K0–K10 bank.
- `aes128_block_engine.sv` owns the two-round shared datapath, five-pass sequencing, input replacement at pass 4, and stable output register.
- `aes128_core.sv` is the protocol shell. It enforces the idle key barrier and connects the key bank to the block engine while preserving the PDF interface unchanged.

Compile in this dependency order:

1. `rtl/aes128_pkg.sv`
2. `rtl/aes128_key_expand.sv`
3. `rtl/aes128_block_engine.sv`
4. `rtl/aes128_core.sv`

## Datapath and cycle behavior

The core maps external byte `4*c+r` to AES state row `r`, column `c`. On plaintext acceptance it applies AddRoundKey K0 and captures the state. A two-round combinational datapath is then reused for five passes:

| Pass | Rounds | MixColumns |
|---:|---|---|
| 0 | 1, 2 | Both rounds |
| 1 | 3, 4 | Both rounds |
| 2 | 5, 6 | Both rounds |
| 3 | 7, 8 | Both rounds |
| 4 | 9, 10 | Round 9 only; round 10 bypasses it |

With an available output slot, the fifth pass writes the ciphertext register and may accept the next plaintext on the same edge. Therefore no-stall acceptance-to-valid latency is five cycles and sustained II is five. These are RTL schedule predictions pending simulation measurement.

## Key expansion and barrier

A key handshake stores K0 and starts an iterative ten-cycle expansion. Each cycle derives one 128-bit round key using four S-box lookups, RotWord, Rcon, and XOR chaining. Plaintext remains backpressured until K10 is stored. `o_key_ready` is asserted only when expansion, data computation, and the output register are all idle, so the single round-key bank cannot change while referenced.

When `i_key_valid` is asserted, `o_data_ready` is suppressed. This gives a waiting key request priority and lets an active block drain instead of being immediately replaced by another block at pass 4.

## Ready/valid and backpressure

- A key, plaintext, or ciphertext moves only on its corresponding valid-and-ready edge.
- The output register is overwritten only when empty, consumed on the same edge, or receiving the just-completed result.
- While `o_cipher_valid && !i_cipher_ready`, output data and valid remain unchanged and fifth-pass completion is stalled by `o_data_ready`/capacity control. In the selected single-block core, a full output register occurs only after computation has finished.
- Reset is asynchronous active-low and clears expansion, schedule-valid, busy, output-valid, state, ciphertext, and round-key storage. A new key is required after reset.

## Physical operation count represented by RTL

The data expression contains two AES round calls: 32 byte S-box lookups and two 128-bit MixColumns networks, with the second MixColumns bypassed for round 10. The iterative key expression contains four byte S-box lookups. Tool optimization and actual physical mapping are not measured in this Questa-only project.

## DV checks

- Validate the independent AES model against standard known-answer vectors before comparing the DUT.
- Check key setup takes exactly ten rising edges after key acceptance before data ready can assert.
- Check accepted blocks at five-cycle spacing with continuous data valid and cipher ready.
- Apply asymmetric byte patterns to expose state-order errors.
- Hold cipher ready low and confirm output payload/valid stability.
- Present a key request during every data pass and verify it drains the old-key block, then accepts the key only after the old ciphertext transfers.
- Assert reset during expansion, each pass, and output stall; confirm all prior work is flushed.

## RTL change note

- 2026-11-09: The initial structural-refactor extraction accidentally shortened the S-box constant to 471 hexadecimal digits. Because the declared vector was still 2048 bits, Questa zero-extended the literal and compilation succeeded, but KAT ciphertexts failed. The table is now expressed as sixteen explicit 128-bit rows (exactly 256 bytes), preventing silent width loss. Control, scheduling, and the independent DV oracle were unchanged.
- 2026-11-09: Directed backpressure seed 314159 exposed that the block engine committed a pass-4 result even when an older output occupied the stalled output register. Pass 4 now holds its state and counter until `!o_cipher_valid || i_cipher_ready`; on the release edge it may still replace the consumed output and accept the next plaintext atomically. This preserves output stability and the no-stall II=5 schedule.

## Files

- `rtl/aes128_pkg.sv` — common AES transformation package.
- `rtl/aes128_key_expand.sv` — iterative key expansion and round-key bank.
- `rtl/aes128_block_engine.sv` — two-round iterative block engine and output holding register.
- `rtl/aes128_core.sv` — external protocol shell and module integration.
- `docs/design/architecture_notes.md` — Phase 0 alternatives and schedule study.
- `docs/design/rtl_design.md` — implemented design behavior and DV handoff.
