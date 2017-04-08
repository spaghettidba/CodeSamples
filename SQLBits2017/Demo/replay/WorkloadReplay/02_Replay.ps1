#
# Replay.ps1
# 
Import-Module $PSScriptRoot\..\WorkloadUtils\WorkloadUtils.psm1

$VerbosePreference = "Continue"
#$ErrorActionPreference = "Inquire"

$Database = "DS3"

Invoke-WorkloadReplay -ServerName "SQLDEMO\SQL2016" `
    -RMLInputFiles "E:\replay\results\$($Database)_CAPTURE\ReadTrace_output\*.rml" `
    -ServerOutputPath "E:\replay\temp\replay" `
    -OutputPath "E:\replay\results" `
    -CaptureName "$($Database)_REPLAY" `
    -RestoreDatabases "" `
    -KeepReplication $true `
    -RestoreSourcePath "E:\replay\results\$($Database)_CAPTURE\Backup" `
    -TraceFilters "exec sp_trace_setfilter @TraceID, 35, 1, 0, N'$Database'" `
    -OstressSettingsFile "C:\Program Files\Microsoft Corporation\RMLUtils\sample.ini" `
    -PostRestoreScript "ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130; EXEC sp_updatestats;" `
    -Verbose
