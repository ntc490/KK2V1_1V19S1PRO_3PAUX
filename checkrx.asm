

CheckRx:
	b16clr Temp
	b16cmp CheckRxDelay, Temp
	breq che1

	b16dec CheckRxDelay
	ret

che1:	rvbrflagtrue flagRollValid, che2
	lrv Status, 2
che2:	rvbrflagtrue flagPitchValid, che3
	lrv Status, 3
che3:	rvbrflagtrue flagThrottleValid, che4
	lrv Status, 4
che4:	rvbrflagtrue flagYawValid, che5
	lrv Status, 5
che5:;	rvbrflagtrue flagAuxValid, che6
;	lrv Status, 6				;AUX channel not flight critical.

che6:	ret
