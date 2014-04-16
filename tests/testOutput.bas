
Public Sub SCHED_TestOutput
	A=MsgBox("Hola")

	Digital 1, 2, -1 'Turn off Module 1, Channel 2 (False +0V, inverse logic)
	Sleep 1.0 ' for 1 seconds
	Digital 1, 2, 0 'Turn on (TRUE +5V, inverse logic)

End Sub




