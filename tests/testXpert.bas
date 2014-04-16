
Public Sub SCHED_Test

LogFile=FreeFile
Open "test.log" For Log As LogFile

	For i = 0 to 3
		SData = AdTherm(1, 3, 4, 2)
		
		StatusMsg "Result: " & SData		
		Log LogFile, Now, "Sensor" & i, Format("%3f", SData), "G", "Deg"
	Next i
	
Close LogFile
A=MsgBox("Adios")

End Sub




