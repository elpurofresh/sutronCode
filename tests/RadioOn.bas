
'  BASIC program to power on 9210 radio wired into a 
'  switched power port.

Public Sub SCHED_RadioOn

' Make sure switched power initially off
 Power 1, 0 'Switched power off
 
' Turn the switched power port on
 Power 1, 1		'Switched power on

End Sub
