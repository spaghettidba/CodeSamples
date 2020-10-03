[CmdletBinding()]
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string] $Server
)


$sb = {
    param([string]$Server,[string]$Script)
    Start-Process "sqlcmd" -ArgumentList @("-S$Server", "-i$Script") -WindowStyle Hidden
}

$jobs = @()
foreach($i in 1..10){
    $jobs += Start-Job -ScriptBlock $sb -ArgumentList @($server,"$PSScriptRoot\Recipe_04_Generate_Deadlock.sql")
}

Receive-Job -Job $jobs -Wait -WriteEvents -AutoRemoveJob
