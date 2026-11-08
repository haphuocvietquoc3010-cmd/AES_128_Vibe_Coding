# AES-128 Interface Contract

Status: **FROZEN after PDF review (2026-11-09)**

## Required top-level interface

Module name: `aes128_core` (project decision). Port names and widths follow PDF p.11 §2.2 Table 2 exactly.

| Signal | Direction | Width | Meaning |
|---|---:|---:|---|
| `i_clk` | input | 1 | Rising-edge core clock |
| `i_rst_n` | input | 1 | Active-low asynchronous reset |
| `i_key_valid` | input | 1 | Key producer valid |
| `o_key_ready` | output | 1 | DUT can accept key |
| `i_key` | input | 128 | AES-128 key |
| `i_data_valid` | input | 1 | Plaintext producer valid |
| `o_data_ready` | output | 1 | DUT can accept plaintext |
| `i_plaintext` | input | 128 | Plaintext block |
| `o_cipher_valid` | output | 1 | Ciphertext valid |
| `i_cipher_ready` | input | 1 | Consumer ready |
| `o_ciphertext` | output | 128 | Ciphertext block |

## Handshake and stability

- Key acceptance: rising edge with `i_key_valid && o_key_ready`.
- Plaintext acceptance: rising edge with `i_data_valid && o_data_ready`.
- Ciphertext transfer: rising edge with `o_cipher_valid && i_cipher_ready`.
- A producer may assert valid before ready and holds valid/payload until transfer or reset.
- While `o_cipher_valid && !i_cipher_ready`, DUT holds `o_cipher_valid` and `o_ciphertext` stable.
- Each accepted, non-reset-flushed plaintext produces exactly one ciphertext in order; no loss, duplication, or reordering.

## Reset

`i_rst_n` asynchronously clears key-valid/setup, computation, and output-valid state. All untransferred work is flushed and no pre-reset ciphertext may appear after release. A new key must complete setup before plaintext acceptance.

## Key update policy

- Idle barrier: `o_key_ready=1` only when no expansion, computation, or untransferred output exists.
- Key handshake starts a 10-cycle iterative expansion into K0–K10; `o_data_ready=0` until complete.
- The round-key bank cannot change while any block/output uses it.
- When key and data valid are presented together while idle, key has priority: only key handshakes (`o_data_ready=0`).
- Before first completed key setup, plaintext is stalled.

## Byte/order semantics

- External byte 0 is `[127:120]` through byte 15 `[7:0]`.
- Byte `4*c+r` maps to AES state row `r`, column `c`.
- Initial AddRoundKey; rounds 1–9 include MixColumns; round 10 omits it.

## Performance measurement

With completed key setup, continuous `i_data_valid=1`, and `i_cipher_ready=1`, steady-state II is the maximum cycle gap between successive plaintext handshakes after warm-up. Required II <=6; selected architecture predicts II=5. Throughput at assumed 200 MHz is `128*200e6/II`; this is not timing closure.
