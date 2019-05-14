for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H
@echo off
sqlcmd -S%SERVER1% -E -i"%cd%\0. Create Session.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\1. Create Tables.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\2. Consolidate SP.sql"
if not exist c:\temp mkdir c:\temp
copy "%cd%\5. Collect_Audit_Login.ps1" c:\temp
sqlcmd -S%SERVER1% -E -i"%cd%\3. Collect job.sql" -v targetDir="c:\temp"
sqlcmd -S%SERVER1% -E -i"%cd%\4. Consolidate job.sql"
pause