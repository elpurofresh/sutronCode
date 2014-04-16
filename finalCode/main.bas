
'Main Routine

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Public Declare Sub Measurement
Public Declare Sub Measurement(DataLog)
'Public Declare Sub SwitchTo(Output)

Public Declare Sub ModemInit(Port)
Public Declare Sub SendSBD(Port, DataLog)
Public Declare Sub ReceiveSBD(Port)

Static Rate 

Public Sub SCHED_Main

	StatusMsg "Main"
	
	StatusMsg "Minute(Now): " & Minute(Now)    				 ' For debugging
	StatusMsg "Main1 R= " & Rate							 ' For debugging
	
	'If ((Rate = 0) AND (Minute(Now) = 0)) OR ((Rate = 1) AND ((Minute(Now) / 5)= 0)) THEN   ' Records every hour (every 5 mins, high rate)
		Call Measurement("data.log")
		
		Sleep 1.0											 ' Sleep 1 sec.
		'Call ModemInit("COM3:") 							 ' Initialize the modem
		
		'Sleep 1.0											 ' Sleep 1 sec.
		'Call SendSBD("COM3:", "data.log")                    ' Send Data through Iridium
		
		'Sleep 1.0
		'Call ReceiveSBD("COM3:")
		'Rate = Rate+1
		StatusMsg "Main2 R= " & Rate						 ' For debugging
		
    'Else   
		StatusMsg "Sleeping for now"
		
    'End If
	'Rate = 0
	
End Sub


