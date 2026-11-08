# QuestaSim DV commands

Prerequisites: QuestaSim 10.2c commands on `PATH` and a working license. Set `UVM_HOME` to the installed UVM 1.1d directory when it is not at the local Questa default `C:\questasim\verilog_src\uvm-1.1d`. The compile script resolves the UVM source directory and compiles the AES package, RTL modules, independent model, interface, included UVM package fragments, assertions, and top in dependency order. Run from PowerShell:

```powershell
sim\smoke.ps1
sim\regression.ps1
```

Artifacts are written under `sim/reports/`. Tests and seeds are explicit in `regression.ps1`. Coverage uses Questa branch, condition, expression, statement, FSM, and toggle instrumentation (`-cover bcesft`). A generated report is required before any percentage is claimed.

Each UVM component is kept in its own include fragment under `tb/env/`; each major sequence and each test class has a separate file under `tb/sequences/` and `tb/tests/`. The fragments are included by `tb/packages/aes_uvm_pkg.sv` in dependency order.
