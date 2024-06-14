sqlcmd -SSQL2019 -Q"DELETE FROM sqlworkload04.capture.Intervals WHERE end_time > '20190226'"
sqlcmd -SSQL2019 -Q"DELETE FROM sqlworkload04.replay.Intervals WHERE end_time > '20190226'"

"%programfiles%\workloadtools\WorkloadViewer" --BaselineServer SQL2019 --BaselineDatabase SqlWorkload04 --BaselineSchema capture --BenchmarkServer SQL2019 --BenchmarkDatabase SqlWorkload04 --BenchmarkSchema replay