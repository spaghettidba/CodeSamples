::"c:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -Ureplayuser -Preplayuser -S(local)\SQL2012 -q -r10000 -mstress -i"D:\Documenti\Conferenze\SQLSaturday414\Demo\0.1. Workload\1. SimpleWorkload.sql"

@ECHO OFF

:doItAgain

sqlcmd -S(local)\SQL2014 -Ureplayuser -Preplayuser -h-1 -i"%cd%\1. SimpleWorkload.sql"

GOTO doItAgain