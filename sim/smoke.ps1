$ErrorActionPreference = 'Stop'

if (-not $env:UVM_HOME) {
    $env:UVM_HOME = 'C:\questasim\verilog_src\uvm-1.1d'
}

$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$env:AES_PROJECT_ROOT = $projectRoot.Replace('\', '/')

Push-Location $PSScriptRoot
try {
    vsim -c -do compile.do
    if ($LASTEXITCODE -ne 0) {
        throw 'Questa compile failed.'
    }

    $env:TEST = 'aes_smoke_test'
    $env:SEED = '1'
    vsim -c -do run.do
    if ($LASTEXITCODE -ne 0) {
        throw 'Smoke simulation failed.'
    }

    $logPath = Join-Path $PSScriptRoot 'reports\aes_smoke_test_1.log'
    $log = Get-Content $logPath -Raw
    $hasUvmFailure = $log -match 'UVM_ERROR\s*:\s*[1-9]' -or
        $log -match 'UVM_FATAL\s*:\s*[1-9]'
    $hasAssertionFailure = $log -match '\*\* Error: Assertion'

    if ($hasUvmFailure -or $hasAssertionFailure) {
        throw 'Smoke log contains a UVM or assertion failure.'
    }
} finally {
    Pop-Location
}
