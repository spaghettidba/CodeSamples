for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H
@ECHO OFF

:doItAgain

sqlcmd -S%SERVER1% -E -h-1 -i"%cd%\7. Generate Events.sql"

GOTO doItAgain