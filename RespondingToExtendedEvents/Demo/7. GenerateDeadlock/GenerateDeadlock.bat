for /f "delims== tokens=1,2" %%G in (..\demo.config) do set %%G=%%H

if not exist c:\temp mkdir c:\temp
copy "%~dp0generatedeadlock.sql" "c:\temp"
"C:\Program Files\Microsoft Corporation\RMLUtils\ostress.exe" -E -S%SERVER1% -n10 -r10 -mstress -i"c:\temp\generatedeadlock.sql"