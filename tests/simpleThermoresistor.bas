

Public Sub SCHED_SimpleThermoresistor

	For i = 1 To 1000
		result = Ad(1,3)
		A=MsgBox(result)
		Log "test", Now, "Test", result, "G", "ohms"
	Next i
	
End Sub
	
	'Dim mod	= 1
	'Dim chan = 3
	'Dim exc_chan = 4
	'Dim exc_volt = 2
	'N = Now
	
	
	'For i = 1 To 10		
		'result = AdTherm(1, 3, 4, 2)
		'A=MsgBox(Format("%1.2f", result))
		' Create a reading
		'R1 = Reading(Now, "Thermoresistor 1", 12.345, "G", "ohm")
		' Now log the reading to \Flash Disk\tests\thermoresistor.log
		'Log "thermoresistor", R1
		'Log Now, "thermoresistor", Format("%1.2f", result), "G", "ohm"
		
		
	'Next i
	
'End Sub

 'A=MsgBox("Finished!")