Declare Function SwitchTo(Output)
Declare Function ReadAdcSwitch(SensorInput)

Public Sub SCHED_TestChannels
	
A=MsgBox("Hola")

	For i = 0 to 4	
		Call SwitchTo(i)
		A=MsgBox("Iteration " & i)
		ReadAdcSwitch(i)   			'<<<<<---- have a problem here
		Sleep 5.0 					'Sleep for 3 seconds
		Call SwitchTo(-1) 			'Reset the ADC Switch
		Sleep 1.0 					'Sleep for 1 second
	Next i

End Sub