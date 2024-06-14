sqlcmd -S(local) -Q"DELETE FROM sqlworkload01.capture.Intervals WHERE end_time > '20190226'"

"%programfiles%\workloadtools\WorkloadViewer" --BaselineServer SQL2019 --BaselineDatabase SqlWorkload01 --BaselineSchema capture 