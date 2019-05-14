for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H

sqlcmd -S%SERVER1% -E -i"%cd%\0. Create Sessions.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\1. Setup dbmail.sql"
sqlcmd -S%SERVER1% -E -i"%cd%\2. Create Collection Sets.sql"
pause