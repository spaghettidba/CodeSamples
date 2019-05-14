for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H

@echo off
sqlcmd -S%SERVER1% -E -i"%cd%\00. Stop Collection Set.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\01. Setup Session.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\02. Setup Database.sql"
pause