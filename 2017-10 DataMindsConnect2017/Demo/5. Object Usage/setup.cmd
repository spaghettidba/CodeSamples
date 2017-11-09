sqlcmd -S(local)\SQL2014 -E -i"%cd%\0. Create Session.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\1. Create Tables.sql"
pause