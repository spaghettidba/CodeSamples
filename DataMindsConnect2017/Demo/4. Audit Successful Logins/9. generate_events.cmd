@ECHO OFF

:doItAgain

sqlcmd -S(local)\SQL2014 -E -h-1 -i"%cd%\7. Generate Events.sql"

GOTO doItAgain