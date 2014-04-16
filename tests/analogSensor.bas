' Measure analog voltage on channel 1 of module 1
' Provide excitation on channel 2 of 3 volts
' Set ouput 3 of block with the data

Public Sub SENSOR_AdcCh1
	'*** error codes
	Const BE_NO_ERROR=0
	Const BE_INVALID_IO_HANDLE=27
	Const BE_IO_FAILED=28
	'********* initialize
	QFlag = "B"
	Result = -99.999
	
	On Error Resume Next
	SData = Ad(1, 3, 4, 2)
	E = Err
	If E = BE_NO_ERROR Then
		QFlag = "G"
		Result = SData
		' Could also add equations here to process data
		'*** add error message to system log if failed
	Else
		Select Case E
			Case BE_INVALID_IO_HANDLE
				ErrorMsg "Failed to find specified AIO module"
			Case BE_IO_FAILED
				ErrorMsg "Failed to get data from AIO module"
		End Select
	End If
	
	' Use output 3 for data
	SetOutput 3, Reading(Now, "VOLT-1", SData, QFlag, "Volts”)
	
End Sub

