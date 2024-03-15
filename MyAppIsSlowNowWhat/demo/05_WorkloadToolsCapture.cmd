sqlcmd -S(local) -i"%~dp0\setup.sql"
"%PROGRAMFILES%\WorkloadTools\sqlworkload.exe" --File "%~dp0\analyze.json"
