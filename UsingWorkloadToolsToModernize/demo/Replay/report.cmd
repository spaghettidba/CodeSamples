sqlcmd -SSQL2019 -Q"DELETE FROM sqlworkload03.capture.Intervals WHERE end_time > '20190226'"
sqlcmd -SSQL2019 -Q"DELETE FROM sqlworkload03.replay.Intervals WHERE end_time > '20190226'"

"%programfiles%\workloadtools\WorkloadViewer" --BaselineServer SQL2019 --BaselineDatabase SqlWorkload03 --BaselineSchema capture --BenchmarkServer SQL2019 --BenchmarkDatabase SqlWorkload03 --BenchmarkSchema replay