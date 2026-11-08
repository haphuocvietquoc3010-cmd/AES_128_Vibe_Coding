# Paste when architecture, interface contract and per-agent plans are approved

Implement the approved AES-128 project using EXACTLY two custom Codex subagents:
1) `rtl_designer` implements the full synthesizable AES-128 RTL in rtl/**, documents datapath, key expansion, FSM/elastic buffers, and design schedule in docs/design/**. It must not edit TB or golden model.
2) `dv_verifier` independently implements a NIST-validated pure SystemVerilog AES-128 reference model, UVM agents/sequences/monitors/scoreboard/coverage/assertions, and Questa scripts in tb/**, sim/**, docs/verification/**. It must not edit RTL or copy RTL helper functions.

They may work concurrently because files are disjoint. Root waits for both, reviews interface consistency and keeps integration decisions. Stage the first goal as compile + ONE KAT + handshake stall smoke; do not rush to 98% coverage before smoke passes. Do not edit a file concurrently in multiple agents. If UVM or Questa is not installed, still write sources but declare simulation NOT VERIFIED. Apply the smoke integration gate, record reproducible commands, compile/run status and files created, and advance automatically only if smoke passes.
