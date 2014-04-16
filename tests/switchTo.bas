Public Sub SwitchTo(Output)
'Sets the 3 bit values of the selector in the ADC switch (A0-A3)
'to choose the desired output

	StatusMsg "SwitchTo"
	
	Select Case Output
		Case -1				'Chipselect OFF, A0 to A3 all OFF
			Digital 1, 2, -1 'Turn OFF Enable (False +0V, inverse logic)
			Digital 1, 3, -1  
			Digital 1, 4, -1
			Digital 1, 5, -1
			
		Case 0				'Chipselect ON, A0 to A3 all OFF
			Digital 1, 2, 0 'Turn ON Enable (True +5V, inverse logic)
			Digital 1, 3, -1 
			Digital 1, 4, -1
			Digital 1, 5, -1
			
		Case 1				'Chipselect ON, A0 ON
			Digital 1, 2, 0 
			Digital 1, 3, 0 
			Digital 1, 4, -1
			Digital 1, 5, -1
			
		Case 2				'Chipselect ON, A1 ON
			Digital 1, 2, 0 
			Digital 1, 3, -1 
			Digital 1, 4, 0
			Digital 1, 5, -1
		
		Case 3				'Chipselect ON, A0 and A1 ON
			Digital 1, 2, 0 
			Digital 1, 3, 0
			Digital 1, 4, 0 
			Digital 1, 5, -1
			
		Case 4				'Chipselect ON, A2 ON
			Digital 1, 2, 0
			Digital 1, 3, -1
			Digital 1, 4, -1
			Digital 1, 5, 0
		
	End Select

End Sub




