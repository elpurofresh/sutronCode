
'Main Routine

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub Measurement
Public Declare Sub SwitchTo(Output)

Public Declare Sub ModemInit(Port)
Public Declare Sub SendSBD(Port)
Declare Function ReceiveSBD(Port)

Declare Function ReadLog(LogName, Sensor, TimeStamp)
Public Declare Sub FlushPort(Handle)
Public Declare Function OpenPort(ComPort, RejectWhen)
Public Declare Sub ClosePort(Handle)
Public Declare Function ReadPort(Handle, BytesToRead, BytesRead, BytesRemain,
TimeoutSec)
Public Declare Sub WritePort(Handle, Data)
Public Declare Function HayesCommand(Handle, Command, TimeoutSec)
Public Declare Sub SetDTRPort(Handle)
Public Declare Sub ClrDTRPort(Handle)
Public Declare Sub SetRTSPort(Handle)
Public Declare Sub ClrRTSPort(Handle)
Public Declare Sub SetBreakPort(Handle)
Public Declare Sub ClrBreakPort(Handle)
Public Declare Function CDPort(Handle)

Static Rate = 1

Public Sub SCHED_Main

	StatusMsg "Main"
	
	StatusMsg "Minute(Now): " & Minute(Now)
	
	'If ((Rate = 0) AND (Minute(Now) = 0)) OR ((Rate = 1) AND ((Minute(Now) // 5)= 0)) THEN   ' Records every hour (every 5 mins, high rate)
		'Call Measurement
		'Sleep 1.0											 ' Sleep 1 sec.
		Call ModemInit("COM3:") 								' Initialize the modem
		'Call SendSBD("COM3:")                                ' Send Data through Iridium
		StatusMsg "Rate= " & Rate
    ' Else   
    '   Sleep 58.0                                 ' Sleep 58 seconds before checking to see if time for next reading
    'Endif
	
End Sub


