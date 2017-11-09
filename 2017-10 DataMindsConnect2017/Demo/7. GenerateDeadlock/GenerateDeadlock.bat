if not exist c:\temp mkdir c:\temp
copy "%~dp0generatedeadlock.sql" "c:\temp"
"C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -E -S(local)\SQL2014 -n10 -r10 -mstress -i"c:\temp\generatedeadlock.sql"