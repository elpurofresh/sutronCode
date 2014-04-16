''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' November, 2011
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Declare Sub SwitchTo(Output)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' This program measures the thermistor connected to Channel 3
' and switches among 5 different thermistors using the subroutine SwitchTo.
' It logs the data taken into \Flash Disk\test.log
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub SCHED_Thermo1
	
	StatusMsg "Main"
	
	LogFile=FreeFile
	Open "test.log" For Log As LogFile

	For i = 0 to 4
		'StatusMsg "Got here"
		Call SwitchTo(0)
				
		SData = AdTherm(1, 3, 4, 3)
		StatusMsg "Read SData: " & SData
		Log LogFile, Now, "Sensor" & 0, Format("%3.3f", SData), "G", "Deg"

		Sleep 0.5 					'Sleep for 1 second
		Call SwitchTo(-1) 			'Reset the ADC Switch
	Next i
	
	Close LogFile

End Sub

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The subroutine receives the desired channel to be measured and turns ON and OFF
' the corresponding digital outputs to +5V or 0V. 
' Those digital outputs are given by the Digital channels 2, 3, 4, and 5 of
' module 1 and represent the binary values of the EN, A0, A1, A2, and A3 of the
' multiplex switch ADG407BNZ. 
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Sub SwitchTo(Output)

	StatusMsg "SwitchTo"
	
	Select Case Output
		Case -1				'Chipselect OFF, A0 to A3 all OFF
			Digital 1, 2, -1 'Turn OFF Enable (False +0V, inverse logic)
			Digital 1, 3, -1  
			Digital 1, 4, -1
			Digital 1, 5, -1
			StatusMsg "0 0 0 0"
			
		Case 0				'Chipselect ON, A0 to A3 all OFF
			Digital 1, 2, 0 'Turn ON Enable (True +5V, inverse logic)
			Digital 1, 3, -1 
			Digital 1, 4, -1
			Digital 1, 5, -1
			StatusMsg "1 0 0 0"
			
		Case 1				'Chipselect ON, A0 ON
			Digital 1, 2, 0 
			Digital 1, 3, 0 
			Digital 1, 4, -1
			Digital 1, 5, -1
			StatusMsg "1 0 0 1"
			
		Case 2				'Chipselect ON, A1 ON
			Digital 1, 2, 0 
			Digital 1, 3, -1 
			Digital 1, 4, 0
			Digital 1, 5, -1
			StatusMsg "1 0 1 0"
		
		Case 3				'Chipselect ON, A0 and A1 ON
			Digital 1, 2, 0 
			Digital 1, 3, 0
			Digital 1, 4, 0 
			Digital 1, 5, -1
			StatusMsg "1 0 1 1"
			
		Case 4				'Chipselect ON, A2 ON
			Digital 1, 2, 0
			Digital 1, 3, -1
			Digital 1, 4, -1
			Digital 1, 5, 0
			StatusMsg "1 1 0 0"
		
	End Select

End Sub
