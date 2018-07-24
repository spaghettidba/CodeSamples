#
# Capture.ps1
# 
Import-Module $PSScriptRoot\..\WorkloadUtils\WorkloadUtils.psm1

$VerbosePreference = "Continue"
#$ErrorActionPreference = "Inquire"

$Database = "DS3"

#############################################################
# NOTE TO SELF: Remember to start the synthetic workload!!!
#############################################################

Invoke-WorkloadCapture -ServerName "SQLDEMO\SQL2014" `
    -ServerOutputPath "E:\replay\temp\capture" `
    -OutputPath "E:\replay\results" `
    -Capture "$($Database)_CAPTURE" `
    -BackupDatabases "" `
    -TraceFilters "exec sp_trace_setfilter @TraceID, 35, 1, 0, N'$Database'" `
    -DurationMinutes 2 `
    -Verbose

