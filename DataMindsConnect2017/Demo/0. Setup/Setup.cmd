sqlcmd -S(local)\SQL2014 -E -i"%cd%\0. XERMLCapture.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\1. ReplayDB.sql"
sqlcmd -S(local)\SQL2016 -E -i"%cd%\1. ReplayDB.sql"
sqlcmd -S(local)\SQL2014 -E -i"%cd%\2. ReplayUser.sql"
pause