[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=0)] 
  [string]$ServerName
)

$params = $(
    "--File",
    "$PsScriptRoot\Recipe_09_Telegraf.json",
    "--NoLogo",
    "--Quiet",
    "--GlobalVariables",
    "ServerName=$ServerName"
)


& "C:\Program Files\XESmartTarget\XESmartTarget.exe" $Params

exit 1