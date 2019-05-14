sqlcmd -SSQL2019 -E -i"%cd%\0. Create Session.sql"
sqlcmd -SSQL2019 -E -i"%cd%\1. Create Tables.sql"
pause