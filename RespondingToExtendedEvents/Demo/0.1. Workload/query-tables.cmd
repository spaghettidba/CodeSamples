:doItAgain
@echo off
cls
sqlcmd -i"2. QueryTables.sql"
timeout 1
GOTO doItAgain