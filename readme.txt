HW Version 2.1.X (EVO)
SW Version 1.19S1 Pro
Steveis

V1.19S1Pro changes since V1.18S1Pro for KK2.1.X & EVO

a) Added LCD contrast adjustment under Misc. Settings 3

b) Added self level option NONE which disables the ACC.  This is useful if the ACC is faulty and can't be calibrated because it's out of limits.

c) Optimised sensor read code to save approx 100msec.


HW Version 2.1.X
SW Version 1.18S1 Pro
Steveis

V1.18S1Pro changes since V1.17S1Pro for KK2.1.X

a) Added board offset of -90, +90 & 180 degrees.

b) Added new self level setting to be Always On (Aux, Stick & Always)

c) Added receiver channel 8 to receiver sliders (only visible/available for CPPM and SBus).

d) Now allows you to switch between SS & PI profiles when self level is set to "stick".

e) Fixed a bug with the servos jumping on output 7 & 8 (noticed on SSG) which also improves servo operation for a tricopter with the servo on M7.

f) You can now, individually, reverse the Roll, Pitch and Yaw directions by using negative stick scaling values in Profile 1.  This enables people to use transmitters where you can't reverse the direction.



V1.17S1Pro changes since V1.16S1Pro for KK2.1.X
 
a) Much improved self level code that more accurately calculates which way is “up”.  
   This improves switching to self level after aggressive flying and will improve the Camera Gimbal operation as the accuracy of the angles is now much better.
   The receiver interrupts no longer screw with the Self Level calculation.

b) Fixed a bug where the Switch SS & PI flag wasn't cleared after a Factory Reset.

c) Added all 25 serial buffer bytes to debug.  Only the first 16 used for a DSM satellite.  All 25 are used for SBus.  
   Note, only the first 16 bytes are used in the KK2.1.X control code.  SBus channels above 16 bytes can not be used to control the multicopter.
   When on the Safe screen, the servos will be centred.  When in the menu, no signal is sent to the servos.

d) Servo Always On now user selectable in Misc Options 3 (Servos On Arm). If set to yes, servos will move (rather than centre) when armed and the throttle is at zero.
   Tricopter users will probably want to leave this as "No" so the yaw servo doesn't move when arming/disarming.
 

V1.16S1Pro changes since V1.15S1Pro for KK2.1.X

a) Bug fix that prevented Orange R100's going into bind mode (was only in V1.15S1Pro).

b) Select receiver type in Mode Settings. Options are Std, CPPM, DSM2, DSMX, SBus.  Note, if you change the receiver type, you will need to power cycle the KK2.1.X
   Also note that if Profile 1 and Profile 2 have different receiver types, you will need to power cycle when changing between the two.

c) SBus support tested with Orange R710 (thanks to JustPlanesChris for the receiver).  Note that you will need an SBus inverter cable.  SBus uses throttle input.
   Futaba receivers and Orange receivers also have a different channel order (as always) so you need to set that correctly in Rx Channel Map.
   It may also be necessary to map some channels in your transmitter.

d) Orange R110X satellite now binds (thanks to MikeF74 for the receiver).

e) If you have a tx or satellite that can only work as DSM2, binding is achieved by holding buttons 2&3 on power up.
   If you have a tx and satellite that can work as DSMX, binding is achieved by holding button 3 on power up.
   The firmware only supports 1 frame of data.  To check it is set as one frame, look at debug and make sure the numbers don't keep swapping on Satellite buffer.
   DSM2 setting needs to be DSM2 1024 / 22ms.  DSMX settings should be DSMX 2048 / 22ms.  My DX8 only says DSMX 22ms. 

f) No longer able to adjust servos when on Safe screen (for safety reasons) but servos still work when armed and throttle at zero.

g) More efficient Satellite code which has freed up some memory and exectues quicker so I've got more time and space for more features :-)



V1.15S1Pro changes since V1.14S1Pro for KK2.1.X

a) Added menu option called "Channel Map" in Mode Settings 2 to map KK2.1 receiver inputs using the Receiver Channal Map list.
   See Note 7 below.

b) Added menu option to change Safe screen info ("Alt Safe Screen" in Misc. Settings 2).

c) Added menu option to control gimbal pitch with aux input while allowing you to switch self level on or off.
   -1000 to 0 and 0 to 1000 are both full servo offset so you can control full offset with SL on or SL off. 
   Gimbal Control in Misc. Settings 2 is now "No", "Aux" or "6&7" where 6&7 uses Ch6&Ch7 of Satellite or CPPM.
   
d) Small bug fix for Safe screen pwmgen error counter.

e) Added menu option to "trim" the battery voltage reading.

f) Improved SS Gimbal Offset.  Now, 50% offsest is 50%.  Thanks to RC911.

g) SAFE screen says ERROR in big text if there is an error.

h) End Point Limit adjustment available for servos.  Range is 0 to 100%.  Set min and max limits for each output.  Note, this is ignored for ESCs.
   I don't recommend this method of adjusting end points.  It is much better to set things up mechanically.

i) Profile selection.  You can select between two profiles P1 & P2.  P1 or P2 is displayed at the top right of the Safe screen.
   Note that everything has to be set up in each profile - motor layout, acc calibration, receiver type, everything!
   It may be easier to configure Profile 1 and use the menu option to Copy it to Profile 2.  Then reconfigure Profile 1.

j) Ability to switch Stick Scaling and all PI gains and limits (including Self Level) during flight. See Note 6 below.

k) All servos now operate on the Safe screen and when throttle is at zero, if you are on the Safe or Armed screen.


V1.14S1Pro changes since HK V1.6 for KK2.1.X

Default MPU6050 settings now 500 deg/sec and 4g which are close to KK2.0 so P&I and Stick Scale values should be close to those used on KK2.0

If you fly aggressive acro, you will need to increase the gyro rate to 2000 deg/sec.

***** No need to change P&I or stick scaling settings when changing gyro rate *****

Warnings:

i)  Firmware will reset all settings and you will need to select a motor layout.

Critical bug(s) corrected: 

i)	Corrected pin assignment for Output 5 and Output 6
ii)	Initialisation settings didn't get written to the MPU6050 so it was stuck on 250 deg/sec and 2g

Minor bug(s) corrected: 

i)	Updated KK1_6_MPU6050 to remove unused code for menu button press (thanks RC911)
ii) Updated KK1_6_MPU6050 to correct Meny code to disable OCR1A and B interrupt (thanks RC911)
iii)Changed/Corrected I2C routines so they actually work now
iv) Tidied up I2C routine for burst reading of sensor data
v)  More accurate battery voltage - adjusted to read the same as my KK2.0 (thanks HappySundays) - updated again from V1.14S1 after testing on three KK2.1s.
vi) Corrected low voltage alarm calculation
vii)Correct constants are now used in imu.asm and trigonometry.asm depending on acc and gyro setting so no problems with self level
viii)Stick Scaling does not need to be modified (except for fine tuning) when changing gyro rate
ix) RC911 bug fix in the Number Editor (original firmware) that allowed setting a value to zero (CLR) when the lower limit was higher.
x) RC911 bug fix in the original firmware that kept the "Link Roll Pitch" flag from being updated until the user returned to the SAFE screen.
xi) From V1.14S1, small bug fixed in imu.asm for 0.5G to 1.5G test (thanks jmdhuse).

Additions: 

i) Debug Menu (added back) plus some extra values displayed
ii) Version Menu
iii) Sensor Max Min Menu (records max and min gyro and acc values when armed and SL is off)
iv) MPU6050 Settings Menu (view and change gyro deg/sec, acc g and digital low pass filter - see Note 3 below)
v) MPU6050 Temperature shown on SAFE screen
vi) Receiver Sliders Menu that shows you the msec value and sliders for the receiver inputs - for info, not calibrated - includes CH6 & CH7 for CPPM and Satellites
vii) Output Sliders Menu that shows you the msec value and sliders for the motor/servo outputs - this is for info as it is not calibrated 
viii) Acc Bubble Level Menu for accelerometers
vix) Gyro Bubble Level Menu for gyros (could be good for dynamic balancing)
x) Added support for Spektrum (R) Satellite and clones (See Note 1 below)
xi) Configurable accelerometer software filter in Misc Settings (See Note 4 below)
xii) New, 8.32 maths library to accomodate high gyro rates for self level
xiii) Lost model alarm.  Constant alarm when the KK2.1 auto disarms.  To kill alarm, either arm, disarm or press Menu.
xiv) Error check for "no motor layout" on Safe screen.
xv) Better handling of receiver signal loss.  Throttle drops to zero on roll or pitch signal loss to stop sudden flipping.
xvi) Limited camstab offset to 0 through 100 as this is percentage travel
xvii) Selectable "motors spin on arm" (misc settings 2).  This prevents the motors stopping when flying which could help with motors that have problems starting up.
xviii) Selectable KK2.1 board offset (misc settings 2) - see Note 5 below.
xix) Support for Super Simple Gimbal (misc settings 2).
xx) Gimbal offset can be set using TX channel 6 & 7.  
xxi) Added arming test to recevier test menu.  Tells you when the yaw and throttle stick positions will arm or disarm.
xx) Minimised jitter for servos connected to M7 & M8 (thanks for RC911).  
xxi) Added a new Motor Layout called "Tricopter Servo M7".
xxii) Added an error counter to the SAFE screen in top left corner.  You should not see anything there.  If you do, there could be something wrong with your board.  Please report receiver used, new features enabled, approx flight time and number of errors.

Changes in operation:

i)  Defaults to AUX for Self Level On/Off
ii) All mixing resets to zero when you do a factory reset so you have to select a motor layout
iii) If KK2.1 autodisarms, it will buzz continuously (Lost Model Alarm) until you press Menu or arm or disarm with TX

Note 1 (Many thanks to David Thompson of OpenAero(2) fame for this feature)

Supports Spektrum(R) satellite with Tarot cable
Tested with Spektrum AR7/8000 DSM2 satellite, Orange R100 Satellite, Orange R110X Satellite
Causes jitter on servos - except outputs M7 & M8
Only supports 10 bit with all data in 1 frame 
Only supports 7 channels
Uses Throttle input for Tarot cable
Hold buttons 2&3 (for DSM2) or button 3 (for DSMX) on power up to enter binding mode
If you switch between receivers, you have to power cycle the KK2.1
Debug lists 16 frame bytes from satellite - you'll know if there are 2 frames of data (so bind again).
KK2.1 Settings: -
You will need to set the receiver to "DSM2 or DSMX" in Mode Settings
You will need to assign the channels correctly in "Receiver Channel Map" (previously Sat-CPPM Channels) as  A=2,E=3,T=1,R=4,Aux=5
If using TX for gimbal control, CH6 & Ch7 are assigned

Note 2

No need to change P&I or stick scaling settings when changing gyro rate now.

Note 3 (MPU Settings)

Set gyro rate and acc rate high if you like acro and low if you like sedate/fpv flying
If you exceed the gyro rate when flying, it will spin/flip/roll really fast.
Set the filter to a lower value to filter out vibrations in your frame - try to leave on default if you can as too low slows the control loop down and results in oscillations.

Note 4 (Acc Software Filter)

Default is 8.  Best to leave this as it is.

Note 5 (Board Offset)

This allows you compensate for the KK2.1 not facing forward.

Normal operation is with the KK pointing in the direction of flight and Board Offset 0.

Say you have a +Quad setup and want to change to an XQuad but can't rotate the KK board.
No problem, leave the board and motor connections as they are and select Board Offset -45.
You must also change the Motor Layout to XQuad.

Say you have an XQuad setup and want to change to a +Quad but can't rotate the KK board.
No problem, leave the board and motor connections as they are and select Board Offset +45.
You must also change the Motor Layout to +Quad.


Note 6 (Switchable SS & PI in flight)

In the Profiles menu option, if you select Yes for "Switch SS & PI" you will fly with Profile 1 when Self Level is switched off and
when you switch Self Level On, you will switch in Profile 2's Stick Scaling and PI gains and limit (including Self Level) settings.
On the Safe screen, you will see PI1 or PI2 in the top right corner.  If you want to use Profile 2's SS & PI but don't want Self Level, 
set Profile 2's self level P gain to zero.  When this is done, you will see that Self Level is always Off on the Safe screen.
When switching between the two, be very careful if you are changing Stick Scaling.  Best to do this with sticks at neutral.


Note 7 (Channel Map)

This option allows you to swap the order of the inputs for a standard receiver. Say the Roll input appears faulty (input 1).  
Set the Receiver Channel Map to 5,2,3,4,1 to swap Roll and Aux inputs. Connect your rx roll output to KK2.1 Aux input to use that for the roll input.
Note, if you are using Sat-CPPM, you need to use the Receiver Channel Map (previously "Sat-CPPM Channels").
You still need to use input 1 for CPPM and input 3 for satellites.