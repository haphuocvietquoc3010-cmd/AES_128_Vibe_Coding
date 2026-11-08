$ErrorActionPreference = 'Stop'

if (-not $env:UVM_HOME) {
    $env:UVM_HOME = 'C:\questasim\verilog_src\uvm-1.1d'
}

$projectRoot = (Resolve-Path "$PSScriptRoot\..").Path
$env:AES_PROJECT_ROOT = $projectRoot.Replace('\', '/')

$tests = @(
    'aes_smoke_test',
    'aes_pattern_test',
    'aes_random_test',
    'aes_reset_test',
    'aes_throughput_test',
    'aes_coverage_test',
    'aes_key_toggle_test'
)
$seeds = @(1, 17, 20261109)
$reportRoot = Join-Path $PSScriptRoot 'reports'
$passingUcdbs = [System.Collections.Generic.List[string]]::new()

Push-Location $PSScriptRoot
try {
    vsim -c -do compile.do
    if ($LASTEXITCODE -ne 0) {
        throw 'Questa compile failed.'
    }

    foreach ($test in $tests) {
        foreach ($seed in $seeds) {
            $env:TEST = $test
            $env:SEED = "$seed"

            vsim -c -do run.do
            if ($LASTEXITCODE -ne 0) {
                throw "FAIL test=$test seed=$seed"
            }

            $logPath = Join-Path $reportRoot "${test}_${seed}.log"
            $log = Get-Content $logPath -Raw
            $hasUvmFailure = $log -match 'UVM_ERROR\s*:\s*[1-9]' -or
                $log -match 'UVM_FATAL\s*:\s*[1-9]'
            $hasAssertionFailure = $log -match '\*\* Error: Assertion'

            if ($hasUvmFailure -or $hasAssertionFailure) {
                throw "Log failure test=$test seed=$seed"
            }

            $passingUcdbs.Add((Join-Path $reportRoot "${test}_${seed}.ucdb"))
        }
    }

    $expectedUcdbCount = $tests.Count * $seeds.Count
    if ($passingUcdbs.Count -ne $expectedUcdbCount) {
        throw "Expected $expectedUcdbCount passing UCDBs, found $($passingUcdbs.Count)"
    }

    $ucdbListPath = Join-Path $reportRoot 'ucdb_inputs.txt'
    $passingUcdbs | Set-Content $ucdbListPath

    $mergedUcdbPath = Join-Path $reportRoot 'merged.ucdb'
    vcover merge -inputs $ucdbListPath $mergedUcdbPath
    if ($LASTEXITCODE -ne 0) {
        throw 'UCDB merge failed.'
    }

    $htmlDirectory = Join-Path $reportRoot 'coverage_html'
    vcover report -html -htmldir $htmlDirectory -code bcesft -cvg $mergedUcdbPath

    $codeReportPath = Join-Path $reportRoot 'coverage_code.txt'
    vcover report -code bcesft -totals $mergedUcdbPath |
        Out-File $codeReportPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Questa code coverage report failed.'
    }

    $functionalReportPath = Join-Path $reportRoot 'coverage_functional.txt'
    vcover report -cvg -details $mergedUcdbPath |
        Out-File $functionalReportPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Questa functional coverage report failed.'
    }

    $rtlReportPath = Join-Path $reportRoot 'coverage_rtl_statement.txt'
    Remove-Item $rtlReportPath -ErrorAction SilentlyContinue

    $rtlDesignUnits = @(
        'aes128_pkg',
        'aes128_key_expand',
        'aes128_block_engine',
        'aes128_core'
    )

    foreach ($designUnit in $rtlDesignUnits) {
        "RTL design unit: $designUnit" |
            Out-File $rtlReportPath -Append
        vcover report -code s -du $designUnit $mergedUcdbPath |
            Out-File $rtlReportPath -Append

        if ($LASTEXITCODE -ne 0) {
            throw "RTL statement report failed for $designUnit"
        }
    }

    $rtlDetailReportPath = Join-Path $reportRoot 'coverage_rtl_code.txt'
    Remove-Item $rtlDetailReportPath -ErrorAction SilentlyContinue
    foreach ($designUnit in $rtlDesignUnits) {
        "RTL design unit: $designUnit" |
            Out-File $rtlDetailReportPath -Append
        vcover report -code bcesft -du $designUnit -details $mergedUcdbPath |
            Out-File $rtlDetailReportPath -Append

        if ($LASTEXITCODE -ne 0) {
            throw "RTL code coverage report failed for $designUnit"
        }
    }

    $excludedReportPath = Join-Path $reportRoot 'coverage_excluded.txt'
    vcover report -excluded -user $mergedUcdbPath |
        Out-File $excludedReportPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Questa user exclusion report failed.'
    }
} finally {
    Pop-Location
}
