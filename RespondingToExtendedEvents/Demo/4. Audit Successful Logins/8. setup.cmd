@echo off
sqlcmd -S(local)\SQL2014 -E -i"%cd%\0. Create Session.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\1. Create Tables.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\2. Consolidate SP.sql"
if not exist c:\temp mkdir c:\temp
copy "%cd%\5. Collect_Audit_Login.ps1" c:\temp
sqlcmd -S(local)\SQL2014 -E -i"%cd%\3. Collect job.sql" -v targetDir="c:\temp"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\4. Consolidate job.sql"
pause