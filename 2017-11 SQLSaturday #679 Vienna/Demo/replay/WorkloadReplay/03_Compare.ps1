#
# Compare.ps1
# 
Import-Module $PSScriptRoot\..\WorkloadUtils\WorkloadUtils.psm1

$VerbosePreference = "Continue"
#$ErrorActionPreference = "Inquire"

$Database = "DS3"

Invoke-WorkloadComparison -Baseline "$($Database)_CAPTURE" -Benchmark "$($Database)_REPLAY"
