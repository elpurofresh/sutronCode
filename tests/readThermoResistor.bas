
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Function to read and log the value of a thermoresistor
' by Andres Mora, SESE, November 14th, 2011.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

TimeToStop = 0
N = Now

Public Function ReadThermoresistor(mod, chan, exc_chan, exc_volt)

	' Return 0 to schedule the function for the next minute
	ProcessingLoop = 0
	' Average A/D channel 1 once per second for the next 10 seconds
	For i = 1 To 10
		
		result = AdTherm(mod, chan, exc_chan, exc_volt)
		' Create a reading
		R1 = Reading(N, "Thermoresistor 1", result, "G", "ohms")
		' Now log the reading to \Flash Disk\tests\thermoresistor.log
		Log "thermoresistor", R1
		
		' Exit and stop processing if the TimeToStop event is raised
		' otherwise delay a second between samples
		If WaitEvent(1, TimeToStop) = 1 Then
			ProcessingLoop = -1
			Exit Function
		End If
	Next i
	
End Function

Sub START_PROGRAM
	StatusMsg "Start Program"
	ResetEvent TimeToStop
	' Run the main processing loop every minute on the minute
	StartTask "ReadThermoresistor", 0, TimeSerial(0, 0, 0), TimeSerial(0, 1, 0)
End Sub

Sub STOP_PROGRAM
	StatusMsg "Stop Program"
	SetEvent TimeToStop
	StopTask "ReadThermoresistor"
End Sub
