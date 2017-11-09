@echo off
sqlcmd -S(local)\SQL2014 -E -i"%cd%\01. Setup Session.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\02. Setup Database.sql"
pause