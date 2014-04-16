Public Sub ReadAdcSwitch(SensorInput)

	A=MsgBox("ReadAdcSwitch")

	LogFile=FreeFile
	Open "test.log" For Log As LogFile

	SData = AdTherm(1, 3, 4, 2)
	
	Log LogFile, Now, "Sensor" & SensorInput, Format("%3f", SData), "G", "Deg"
	Close LogFile


End Sub