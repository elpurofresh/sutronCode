﻿''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Created by Sutron
' Edited by Andres Mora
' Extreme Environments Robotics and Instrumentation Lab
' SESE, ASU
' January, 2012
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare Constants in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Const True = -1
Const False = 0
Const LoggingIn=2
Const LoggedIn=4
Const LF = Chr(10) ' Line feed character
Const CR = Chr(13) ' Carriage return character

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Declare the Subroutines in the program
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Declare Sub ModemInit(Port)
'Public Declare Sub SendSBD(Port)
Public Declare Sub SendSBD(Port, DataLog)
Declare Function ReceiveSBD(Port)

Declare Function ReadLog(LogName, Sensor, TimeStamp)
Public Declare Sub FlushPort(Handle)
Public Declare Function OpenPort(ComPort, RejectWhen)
Public Declare Sub ClosePort(Handle)
Public Declare Function ReadPort(Handle, BytesToRead, BytesRead, BytesRemain, TimeoutSec)
Public Declare Sub WritePort(Handle, Data)
Public Declare Function HayesCommand(Handle, Command, TimeoutSec)
Public Declare Sub SetDTRPort(Handle)
Public Declare Sub ClrDTRPort(Handle)
Public Declare Sub SetRTSPort(Handle)
Public Declare Sub ClrRTSPort(Handle)
Public Declare Sub SetBreakPort(Handle)
Public Declare Sub ClrBreakPort(Handle)
Public Declare Function CDPort(Handle)

' Variables used to store results of ReadLog function.
RLData = 0.0
RLQuality = "U"
RLUnits = ""
Static Rate = 9999

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The iridium modem "looses" its baud rate whenever it is powered up
' or when DTR is dropped. The solution is to send an AT command on power up
' and to not use DTR. This routine sends the AT command and must be scheduled
' to run a few seconds after the modem is powered up.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub ModemInit(Port)

	StatusMsg "ModemInit @ " & Port & " Mdm R= " &Rate

	ModemInit = True
	'Handle = OpenPort("COM2:", LoggingIn Or LoggedIn)
	'Handle = OpenPort("COM2:", 0) ' <- use this to open even if in use
	Handle = OpenPort(Port, LoggingIn Or LoggedIn)
	'Handle = OpenPort(Port, 0)
	
		If Handle Then
			Call SetDTRPort(Handle) 'note: DTR should already be high
			Sleep(1) ' Allow the modem time to wake up Sleep(1)<- original
			Txt = HayesCommand(Handle, "AT", 2)
			'StatusMsg "Txt<" &Txt & ">"
			
			If Txt="" Then
				ErrorMsg "Hayes Command AT failed" & " <" & Txt & ">"
			ElseIf Right(Txt,2) = "OK" then		'ElseIf Txt="OK" then 
				StatusMsg "Hayes Command AT returned:" + Txt
				
				'''''''''''''''''Modified for debugging '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
				'Txt = HayesCommand(Handle, "AT+CGSN", 5)
				'If Txt="" Then
				'	ErrorMsg "Hayes Command AT failed" & " <" & Txt & ">"
				'Else
				'	StatusMsg "Txt<" &Txt & ">"
				'End If
				
				'Txt = HayesCommand(Handle, "AT+SBDREG?", 5)
				'If Txt="" Then
				'	ErrorMsg "Hayes Command AT failed" & " <" & Txt & ">"
				'Else
				'	StatusMsg "Txt<" &Txt & ">"
				'End If
				
				'''''''''''''''''Modified for debugging '''''''''''''''''''''''''''''''''''''''''''''''''''''''''
			End If
			
			Call ClrDTRPort(Handle)
			Call ClosePort(Handle)
		Else
			ModemInit = False
			ErrorMsg "ModemInit could not access the Modem"
		End If
End Sub

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Send data through the modem
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub SendSBD(Port, DataLog)

	StatusMsg "SendSBD @ " & Port

	Const RegTimeout = 10 '10 seconds
	Const SendTimeout = 10 '10 seconds
	DataSet1 =""
	DataSet2 =""
	
	RemoteCmd = ""

	Handle = OpenPort(Port, 0) '<- use this to openport even if in use.

	If Handle Then
		Call SetDTRPort(Handle)
		Sleep(5) 								' Allow the modem time to wake up
												' Wait for the modem to be registered
		StartTime = Time
			
		''''--Clear SBD Message Buffer--''''
		StatusMsg "AT+SBDD0"
		txt = HayesCommand(Handle, "AT+SBDD0", 2)
		
		StatusMsg "Txt<" &txt & ">"
		
		If txt="" OR Right(Txt,3) = "1OK" Then
			ErrorMsg "Command AT+SBDD failed " &txt
			goto ErrorHandler
						
		Else
			Call FormatData(DataSet1,DataSet2, DataLog)
			BinString = DataSet1
			LenData = Format("%d", Len(BinString))
			Result = ComputeCRC(0,0,BinString) Mod 65536'
			StatusMsg "CRC " &(Result>>8) &" " &(Result Mod 256)
			BinString = BinString & Chr(Result>>8) & Chr(Result Mod 256)
			Cmd = "AT+SBDWB="&LenData
			Txt = HayesCommand(Handle, Cmd, 2)
		
				If Left(Txt, 5)="READY" then
					Txt = HayesCommand(Handle, BinString, 2)
					StatusMsg "SBDWB: " &txt
				
					If Left(Txt,1) <> "0" then
						ErrorMsg "Command SBDWB failed " &Txt
						goto ErrorHandler
					End If
				End If
		End If
	
		'Initiate SBD Session to send the data
		StartTime = Time
		DataSent = false
		Do
			statusmsg "AT+SBDI"
			txt = HayesCommand(Handle, "AT+SBDI", 15)
			StatusMsg "SBDI=" &txt
		
			If Left(txt, 8) = "+SBDI: 1" then
				DataSent = true
			End If
			
			If CDPort(Handle) <> 0 then
				StatusMsg "CD active on modem ... abort"
				goto errorhandler
			End If
	
		Loop Until (DataSent OR ((Time - StartTime)> SendTimeout))
		
		If ((Time - StartTime) > SendTimeout) then
			ErrorMsg "SBDI timeout " &txt
			goto ErrorHandler
		End If
	

	
	'''''''''''''''''''''''''''''''''''''''''''''''
	' Read the buffer from the modem
	'''''''''''''''''''''''''''''''''''''''''''''''
		Sleep 1.0 
		RemoteCmd = HayesCommand(Handle, "AT+SBDRB", 18)
		StatusMsg "RemoteCmd: " & RemoteCmd
		If Left(RemoteCmd, 6) = "Rate=1" then
			Rate = 1
			StatusMsg "Rate=1" & " Rate= " &Rate
		Else
			Rate = 0
			StatusMsg "Rate=1" & " Rate= " &Rate
		End If
	
	ErrorHandler:
		'Call ClrDTRPort(Handle)
		Call ClosePort(Handle)
	Else
		ErrorMsg "Could not access the Iridium Modem"
	End If
		
End Sub

			
'Public Declare Function FormatData
'Public Sub FormatData(DataSet1,DataSet2)
Public Sub FormatData(DataSet1,DataSet2, DataLog)
		
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''		
' Sensors to tx:
' 15minute interval- S1, S2, B
' make tx look like this: mm/dd/yyyy,hh:mm:ss,S1,S2,B
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

	'INITIALIZE local variables
	StatusMsg "Starting format routine"
	'Const LogName = "SSP.LOG" 'where to get the data from
	'Const LogName = DataLog ' "test.log" 
	LogName = DataLog ' "test.log" 
	Const MinTx = 96 	'15min values to tx ALWAYS MAKE THIS AN EVEN NUMBER
	Const DataInt = 900
	Const TotalNumSensors = 16-1  'Total number of sensors constant
	TimeNow = now 		'What time are we starting
	
	'Set up sensors array
	'Sensors(2) = "B"
	'Sensors(1) = "S2"
	'Sensors(0) = "S1"
	
	For i = 0 to TotalNumSensors
		Sensors(i) = "Sensor" & i
	Next i

	'Initialize array at 0 to hold data for transmission, start with :sensor
	NumSensors = Ubound(Sensors)

	' Loop to get data from log
	'Get all defined sensors and build their string
	'Get recent timestamp based on sensor interval and add time offset and interval to sensor message
	TSens = TimeNow - (TimeNow Mod DataInt)
	DataToTx = ""
	
	For T = 1 to (MinTx/2)
	'Get the number of values specified (recent data first),
	'Add good data to sensor tx string, place an M in bad or missing data
	'mm/dd/yyyy,hh:mm:ss,S1,S2,B
	DateStr = Month(Tsens) & "/" & Day(Tsens) & "/" & Year(Tsens)
	TimeStr = Format("%02d",Hour(Tsens)) & ":" & Format("%02d",Minute(Tsens)) & ":" & Format("%02d",Second(Tsens))
	DateTimeStr = DateStr & "," & TimeStr
	
		For I = 0 To NumSensors
			If (ReadLog(LogName, Sensors(I), TSens) = 1) Then
				Select Case I
					Case 0
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.2f",RLData) ' format 2 rights digits
			
					Case 1
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.2f",RLData) ' format 2 rights digits
			
					Case 2
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.1f",RLData) ' format 1 rights digits
				End Select
			Else
				DataToTx = DataToTx + DateTimeStr & ",M"
			End If
	
			DataToTx = DataToTx + CR+LF
			TSens = TSens - DataInt
		Next I
	Next T
	
	'Grab First Set of data
	DataSet1 = DataToTX

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Loop to get data from log
' Get all defined sensors and build their string
' Get recent timestamp based on sensor interval and add time offset and interval to sensor message
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	DataToTx = ""
		
	For T = ((MinTx/2) + 1) to MinTx

'Get the number of values specified (recent data first),
'Add good data to sensor tx string, place an M in bad or missing data
'mm/dd/yyyy,hh:mm:ss,S1,S2,B
	
		DateStr = Month(Tsens) & "/" & Day(Tsens) & "/" & Year(Tsens)
		TimeStr = Format("%02d",Hour(Tsens)) & ":" & Format("%02d",Minute(Tsens)) & ":" &
		Format("%02d",Second(Tsens))
		DateTimeStr = DateStr & "," & TimeStr

		For I = 0 To NumSensors
			If (ReadLog(LogName, Sensors(I), TSens) = 1) Then
				Select Case I
					Case 0
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.2f",RLData) ' format 2 rights digits
				
					Case 1 
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.2f",RLData) ' format 2 rights digits
				
					Case 2
					DataToTx = DataToTx + DateTimeStr & "," + Format("%.1f",RLData) ' format 1 rights digits
				End Select
			Else
				DataToTx = DataToTx + DateTimeStr & ",M"
			End If
			DataToTx = DataToTx + CR+LF
			TSens = TSens - DataInt
		Next I
Next T

'Grab Second Set of data
	DataSet2 = DataToTX
	Statusmsg DataSet1 & DataSet2
End Sub


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' LogName, Sensor, and TimeStamp are inputs. RLData, RLQuality, and RLUnits
' are global variables that receive this function's outputs.
' If Sensor at Timestamp is found, 1 is returned. Otherwise, 0.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function ReadLog(LogName, Sensor, TimeStamp)

	ReadLog = 0
	Type = 0
	TimeFound = 0
	SensorFound = ""
	FileNum = FreeFile

	Open LogName for Log as FileNum
	Seek FileNum, TimeStamp
	If Not Eof(FileNum) Then
		Input FileNum, Type, TimeFound, SensorFound, RLData, RLQuality, RLUnits
		Do While TimeFound = TimeStamp And Not EOF(FileNum)
			If SensorFound = Sensor Then
				If RLQuality = "G" Then
					ReadLog = 1
				End If
				Exit Do
			Else
				' Log may contain multiple entries for this time-slot so keep looking.
				' Original Seek finds last entry for specified time, so move to previous.
				Seek FileNum, Next
				Input FileNum, Type, TimeFound, SensorFound, RLData, RLQuality, RLUnits
			End If
		End Loop
	End If
	Close FileNum

End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Send data through the modem
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub SendSBD(Port, DataLog)

	StatusMsg "SendSBD @ " & Port

	Const RegTimeout = 10 '300 seconds
	Const SendTimeout = 10 '300 seconds
	DataSet1 =""
	DataSet2 =""
	
	RemoteCmd = ""
	
	'Handle = OpenPort("COM2:", LoggingIn Or LoggedIn)
	'Handle = OpenPort("COM2:", 0) '<- use this to openport even if in use.
	'Handle = OpenPort(Port, LoggingIn Or LoggedIn)
	Handle = OpenPort(Port, 0)

	If Handle Then
		Call SetDTRPort(Handle)
		Sleep(5) 								'Allow the modem time to wake up
		' wait for the modem to be registered
		StartTime = Time
		'ModemRegistered = false <----- for now debugging 24-1-12
		'Do
		'	StatusMsg "AT+CREG?"
		'	txt = HayesCommand(Handle, "AT+CREG?", 10)
		'	StatusMsg "CREG=" &txt
		'	If Right(txt,5) = "001OK" then
		'		ModemRegistered = true
		'	End If
	
		'	If CDPort(Handle) <> 0 then
		'		StatusMsg "CD active on modem ... abort"
		'		goto errorhandler
		'	End If

		'Loop Until (ModemRegistered OR ((Time - StartTime)> RegTimeout))

		'If ((Time - StartTime) > RegTimeout) then
		'	ErrorMsg "Timeout waiting for Registration -- CREG: " &txt
		'	goto ErrorHandler
		'End If					<----- for now debugging 24-1-12
	
		''''--Clear SBD Message Buffer--''''
		StatusMsg "AT+SBDD0"
		txt = HayesCommand(Handle, "AT+SBDD0", 2)
		
		StatusMsg "Txt<" &txt & ">"
	
		'If txt="" OR txt="1" Then
		If txt="" OR Right(Txt,3) = "1OK" Then
			ErrorMsg "Command AT+SBDD failed " &txt
			goto ErrorHandler
			'End If
	
			'If 0 = 1 Then
			'If Right(Txt,3) = "0OK" Then
			'	' Send some text to the message buffer
			'	StatusMsg "AT+SDBWT"
			'	txt = HayesCommand(Handle, "AT+SBDWT=SBDWT Text Test", 2)
		
			'	StatusMsg "Txt<" &txt & ">"
		
			'	'If txt="" OR txt <>"OK" Then
			'	If txt="" OR Right(Txt,2) <>"OK" Then
			'		ErrorMsg "Command AT+SBDWT failed " &txt
			'		goto ErrorHandler
			'	End If
			
			'	StatusMsg "Txt<" &txt & ">"
			
		Else
			Call FormatData(DataSet1,DataSet2, DataLog)
			BinString = DataSet1
			LenData = Format("%d", Len(BinString))
			Result = ComputeCRC(0,0,BinString) Mod 65536'
			StatusMsg "CRC " &(Result>>8) &" " &(Result Mod 256)
			BinString = BinString & Chr(Result>>8) & Chr(Result Mod 256)
			Cmd = "AT+SBDWB="&LenData
			Txt = HayesCommand(Handle, Cmd, 2)
		
				If Left(Txt, 5)="READY" then
					Txt = HayesCommand(Handle, BinString, 2)
					StatusMsg "SBDWB: " &txt
				
					If Left(Txt,1) <> "0" then
						ErrorMsg "Command SBDWB failed " &Txt
						goto ErrorHandler
					End If
				End If
		End If
	
		'Initiate SBD Session to send the data
		StartTime = Time
		DataSent = false
		Do
			statusmsg "AT+SBDI"
			txt = HayesCommand(Handle, "AT+SBDI", 15)
			StatusMsg "SBDI=" &txt
		
			If Left(txt, 8) = "+SBDI: 1" then
				DataSent = true
			End If
			
			If CDPort(Handle) <> 0 then
				StatusMsg "CD active on modem ... abort"
				goto errorhandler
			End If
	
		Loop Until (DataSent OR ((Time - StartTime)> SendTimeout))
		
		If ((Time - StartTime) > SendTimeout) then
			ErrorMsg "SBDI timeout " &txt
			goto ErrorHandler
		End If
	
'StatusMsg "first done"
'****************************

		BinString = DataSet2
		LenData = Format("%d", Len(BinString))
		Result = ComputeCRC(0,0,BinString) Mod 65536'
		StatusMsg "CRC " &(Result>>8) &" " &(Result Mod 256)
		BinString = BinString & Chr(Result>>8) & Chr(Result Mod 256)
		Cmd = "AT+SBDWB="&LenData
		Txt = HayesCommand(Handle, Cmd, 2)
	
		If Left(Txt, 5)="READY" then
			Txt = HayesCommand(Handle, BinString, 2)
			StatusMsg "SBDWB: " &txt
		
			If Left(Txt,1) <> "0" then
				ErrorMsg "Command SBDWB failed " &Txt
				goto ErrorHandler
			End If
		End If
	
'Initiate SBD Session to send the data
		StartTime = Time
		DataSent = false
	
		Do
			statusmsg "AT+SBDI"
			txt = HayesCommand(Handle, "AT+SBDI", 15)
			StatusMsg "SBDI=" &txt
		
			If Left(txt, 8) = "+SBDI: 1" then
				DataSent = true
			End If

			If CDPort(Handle) <> 0 then
				StatusMsg "CD active on modem ... abort"
				goto Errorhandler
			End If
	
		Loop until (DataSent OR ((Time - StartTime)> SendTimeout))

		If ((Time - StartTime) > SendTimeout) then
			ErrorMsg "SBDI timeout " &txt
			goto ErrorHandler
		End If

	'StatusMsg "Second done"
	
	'''''''''''''''''''''''''''''''''''''''''''''''
	' Read the buffer from the modem
	'''''''''''''''''''''''''''''''''''''''''''''''
		Sleep 1.0 
		RemoteCmd = HayesCommand(Handle, "AT+SBDRB", 18)
		StatusMsg "RemoteCmd: " & RemoteCmd
		If Left(RemoteCmd, 6) = "Rate=1" then
			Rate = 1
			StatusMsg "Rate=1" & " Rate= " &Rate
		Else
			Rate = 0
			StatusMsg "Rate=1" & " Rate= " &Rate
		End If
	
	ErrorHandler:
		'Call ClrDTRPort(Handle)
		Call ClosePort(Handle)
	Else
		ErrorMsg "Could not access the Iridium Modem"
	End If
		
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''
' Read the buffer from the modem
'''''''''''''''''''''''''''''''''''''''''''''''
Public Function ReceiveSBD(Port)
	StatusMsg "ReceiveSBD @ " & Port 
	
	Const RegTimeout = 100
	Const SendTimeout = 100	
	RemoteCmd = ""
	
	'Handle = OpenPort("COM2:", LoggingIn Or LoggedIn)
	Handle = OpenPort(Port, LoggingIn Or LoggedIn)
	'Handle = OpenPort("COM2:", 0) '<- use this to openport even if in use.

	If Handle Then
		Call SetDTRPort(Handle)
		Sleep(5) ' Allow the modem time to wake up
		' wait for the modem to be registered
		StartTime = Time
		ModemRegistered = false
		Do
			StatusMsg "AT+CREG?"
			txt = HayesCommand(Handle, "AT+CREG?", 10)
			StatusMsg "CREG=" &txt
			If Right(txt,5) = "001OK" then
				ModemRegistered = true
			End If
	
		If CDPort(Handle) <> 0 then
			StatusMsg "CD active on modem ... abort"
			goto errorhandler
		End If
		
	Loop Until (ModemRegistered OR ((Time - StartTime)> RegTimeout))

	If ((Time - StartTime) > RegTimeout) then
		ErrorMsg "Timeout waiting for Registration -- CREG: " &txt
		goto ErrorHandler
	End If
	
	RemoteCmd = HayesCommand(Handle, "AT+SBDRB", 18)
	
	StatusMsg "RemoteCmd: " & RemoteCmd
	If Left(RemoteCmd, 6) = "Rate=1" then
		SBDReceive = 1
		StatusMsg "Rate=1"
	Else
		SBDReceive = 0
		StatusMsg "Rate=0"
	End If
	
	ErrorHandler:
		' Call ClrDTRPort(Handle)
		Call ClosePort(Handle)
	Else
		ErrorMsg "Could not access the Iridium Modem"
	End If
End Function

