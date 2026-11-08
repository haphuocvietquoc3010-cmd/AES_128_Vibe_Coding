# QuestaSim and UVM Prerequisite Check

Checked: 2026-11-09 (Asia/Saigon)  
Scope: Questa RTL/UVM compile, simulation, and coverage flows

| Item | Observed | Status |
|---|---|---|
| `vlog` | `C:\questasim\win64\vlog.exe`; reports QuestaSim-64 10.2c (2013.07) | FOUND |
| `vsim` | `C:\questasim\win64\vsim.exe`; reports Questa Sim-64 10.2c (2013.07) | FOUND |
| `vcover` | `C:\questasim\win64\vcover.exe`; report and merge commands executed | PASS for UCDB merge/text reports; full HTML testplan data unavailable |
| UVM source | `UVM_HOME=C:\questasim\verilog_src\uvm-1.1d\src`; `uvm_pkg.sv` exists | UVM 1.1d source AVAILABLE |
| UVM compile/elaboration | All RTL, reference, interface, UVM package, assertions, and top compiled | PASS |
| Simulator/license checkout | Repeated compile and simulation runs completed | PASS for required Questa simulation features |
| Coverage/UCDB operation | 18 UCDB runs merged; code, functional, per-RTL reports generated | PASS; HTML testplan metadata warning noted |

The installed versions are old (QuestaSim 10.2c/UVM 1.1d); scripts target their supported language and report options. The full HTML report warned that no license was found for testplan data, but UCDB merge and text coverage reports succeeded.
