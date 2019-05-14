for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H

sqlcmd -S%SERVER1% -E -i"%cd%\0. XERMLCapture.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\1. ReplayDB.sql"
sqlcmd -S%SERVER2% -E -i"%cd%\1. ReplayDB.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\2. ReplayUser.sql"
pause