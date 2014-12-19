

MainMenu:

men23:	ldy men1 * 2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 27

	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs men22		;BACK pressed?
	ret			;Yes, return
	
men22:	lsl xl			;No, calculate index    Z = *mem18 * 2 + xl * 2
	ldz men18 * 2
	add zl, xl
	clr t
	adc zh, t

	lpm xl, z+		; x = (Z)
	lpm xh, z
	
	movw z, x		;z = x
	
	icall			;go to choosen menu item code  (sound like an apple product!  lawlz)

	call Beep

	call LcdClear		;blank screen
	call LcdUpdate	

men20:	call GetButtons		;wait until buttons relesed
	cpi t, 0
	brne men20	
	
	jmp men23




men1:	
	.db "Donate              "
	.db "PI Editor           "
	.db "Receiver Test       "
	.db	"Receiver Sliders    "
	.db "Mode Settings       "
	.db "Stick Scaling       "
	.db "Misc. Settings 1    "
	.db "Misc. Settings 2    "
	.db "Misc. Settings 3    "
	.db "Self-level Settings "
	.db "Camera Stab Settings"
	.db "MPU6050 Settings    "
	.db "Sensor Test         "
	.db "Sensor Max Min      "
	.db "ACC Calibration     "
	.db "Receiver Channel Map"
	.db "Mixer Editor        "
	.db "Show Motor Layout   "
	.db "Load Motor Layout   "
	.db "Output Sliders      "
	.db "Gyro Bubble         "
	.db "Acc  Bubble         "
	.db "End  Point Limits   "
	.db "Profiles            "
	.db "Debug               "
	.db "Version             "
	.db "Factory Reset       "


men18:	
	.dw Donate
	.dw PiEditor
	.dw RxTest
	.dw RxSliders
	.dw SettingsC
	.dw SettingsA
	.dw SettingsB
	.dw AdvancedSettings1
	.dw AdvancedSettings2
	.dw SelflevelSettings
	.dw CameraStabSetup
	.dw MPUSettings
	.dw SensorTest
	.dw SensorMaxMin
	.dw CalibrateSensors
	.dw CppmSettings
	.dw MixerEditor
	.dw MotorLayout
	.dw LoadMixer
	.dw MotorSliders
	.dw GyroBubble
	.dw AccBubble
	.dw EndPointLimits
	.dw Profiles
	.dw DebugMeny
	.dw Version
	.dw FactoryReset


