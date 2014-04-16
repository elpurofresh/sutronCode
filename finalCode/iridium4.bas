''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
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
Public Declare Sub SendSBD(Port, DataLog)
Public Declare Sub FormatData(DataSet1, DataLog)
Public Declare Sub ReceiveSBD(Port)

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

Static Rate = 0
Static TotalNumSensors
Static Sensor

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' The iridium modem "looses" its baud rate whenever it is powered up
' or when DTR is dropped. The solution is to send an AT command on power up
' and to not use DTR. This routine sends the AT command and must be scheduled
' to run a few seconds after the modem is powered up.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub ModemInit(Port)

	StatusMsg "ModemInit @ " & Port & " Mdm R= " &Rate

	ModemInit = True
	Handle = OpenPort(Port, LoggingIn Or LoggedIn) ' <- use this to open even if in use
	
		If Handle Then
			Call SetDTRPort(Handle) 'note: DTR should already be high
			Sleep(1) ' Allow the modem time to wake up Sleep(1)<- original
			Txt = HayesCommand(Handle, "AT", 2) 
			'StatusMsg "Txt<" &Txt & ">"
			
			If Txt="" Then
				ErrorMsg "Hayes Command AT failed" & " <" & Txt & ">"
			ElseIf Right(Txt,2) = "OK" then		'ElseIf Txt="OK" then 
				StatusMsg "Hayes Command AT returned:" + Txt
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
		Sleep(2) 								' Allow the modem time to wake up
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
			Call FormatData(DataSet1, DataLog)
			BinString = DataSet1
			LenData = Format("%2d", Len(BinString))
			Result = ComputeCRC(0,0,BinString) Mod 65536'
			StatusMsg "CRC " &(Result>>8) &" " &(Result Mod 256)
			BinString = BinString & Chr(Result>>8) & Chr(Result Mod 256)
			StatusMsg "BinString<" &BinString & ">"
			
			Cmd = "AT+SBDWB="&LenData
			StatusMsg "Cmd<" &Cmd & ">"
			
			Txt = HayesCommand(Handle, Cmd, 2)
			
			StatusMsg "Cmd Back<" &Txt & ">"
		
				If Right(Txt, 5)="READY" then
					Txt = HayesCommand(Handle, BinString, 2)
					StatusMsg "SBDWB: " &Txt
				
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
			StatusMsg "AT+SBDI"
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
Public Sub ReceiveSBD(Port)
	StatusMsg "ReceiveSBD @ " & Port 
	
	Const RegTimeout = 100
	Const SendTimeout = 100	
	RemoteCmd = ""

	Handle = OpenPort(Port, LoggingIn Or LoggedIn)
	
	If Handle Then
		Call SetDTRPort(Handle)
		Sleep(1) ' Allow the modem time to wake up
				
		StatusMsg "I'm here" 
		RemoteCmd = HayesCommand(Handle, "AT+SBDRT", 10)
		StatusMsg "RemoteCmd: " & RemoteCmd
	
		If Right(RemoteCmd,2) = "OK" then		
			If Right(RemoteCmd,8) = "Rate=1" then        '<--Burst Mode
				Rate = 1
				StatusMsg "Rate=1" & " Rate= " &Rate
			ElseIf Right(RemoteCmd,8) = "Rate=0" then    '<--Regular Mode
				Rate = 0
				StatusMsg "Rate=" & " Rate= " &Rate
			Else
				Rate = 0								 '<--Maintain Regular Mode
				ErrorMsg "Didn't receive any msg"
				goto ErrorHandler
			End If
		End If
		StatusMsg "I finished!"
	
		ErrorHandler:
			'Call ClrDTRPort(Handle)
			Call ClosePort(Handle)
	Else
		ErrorMsg "Could not access the Iridium Modem"
	End If
	
End Sub


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Format data to be sent through the modem
' Sensors to tx:
' 15minute interval- S1, S2, B
' make tx look like this: mm/dd/yyyy,hh:mm:ss,S1,S2,B
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public Sub FormatData(DataSet1, DataLog)

	'INITIALIZE local variables
	StatusMsg "Starting format routine"	
	LogName = DataLog 							'where to get the data from
	TimeNow = now 								'What time are we starting
	DataToTx = ""
	
	StatusMsg "TimeNow: " & TimeNow							' Debugging only
	
	'Get the number of values specified (recent data first),
	'Add good data to sensor tx string, place an M in bad or missing data	
	'mm/dd,hh:mm,S1,S2,...,Sn
	'DateStr = Month(TimeNow) & "/" & Day(TimeNow)
	'TimeStr = Format("%02d",Hour(TimeNow)) & ":" & Format("%02d",Minute(TimeNow))
	DateStr = Month(TimeNow) & Day(TimeNow)
	TimeStr = Format("%02d",Hour(TimeNow)) & Format("%02d",Minute(TimeNow))
	DateTimeStr = DateStr & TimeStr
		
	For I = 0 To (TotalNumSensors-1)
		If I = 0 then
			DataToTx = Bin(Sensor(I), 3) 		'Transforms Sensor's data into a 3-byte, 18-bit value
			'DataToTx = Sensor(I)
		Else		
			DataToTx = DataToTx & "," & Bin(Sensor(I), 3)
			'DataToTx = DataToTx & "," & Sensor(I)
			StatusMsg "<" + DataToTx + " >"		'Debugging
		End If
	Next I
	
	DataToTx = DataToTx + ",R" + Rate 			' + CR+LF
	
	'Grab First Set of data
	'DataSet1 = DateTimeStr + "," + DataToTX
	DataSet1 = DateTimeStr + DataToTX

	StatusMsg "<" + DataSet1 + ">"
End Sub



