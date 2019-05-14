for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H

@ECHO OFF

:doItAgain

sqlcmd -S%SERVER1% -Ureplayuser -Preplayuser -h-1 -i"%cd%\1. SimpleWorkload.sql"

GOTO doItAgain