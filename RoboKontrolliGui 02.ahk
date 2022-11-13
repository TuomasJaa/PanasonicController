/*
Nyt tyˆn alla.

- Tallennus

*/


/*
Gui - Robo ohjauspaneeli

Toiminnot:

v.04
-Gain ja Aukko numero esitys. Kun gain on k‰ytˆss‰ korostuu tieto punaisella

v.1
Ohjaus napeissa:
- Ristiohjain oikea/vasen. Aukko + gain. Kun Aukko on t‰ysin auki jatketaan gainill‰.
- Ylˆs alas. Tarkennus.



v.2
-Kameroiden IP osoitteet
-Kameroiden standBy-tila
v.3
-kameroiden presetit

DONE-----------
-Aktiivinen kamera indikaattori Cam1, Cam2, Cam3
-Valkobalanssi
-Pan/Tilt DualRaten s‰‰tˆ herkemm‰ksi hitaammaksi
-Try catch



*/

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; Muuttujien alustukset
;--------------------------
;----------------------------------
VersioNumero := "0.0"
cam1var := "Cam 1"
cam2var := "Cam 2"
cam3var := "Cam 3"

Cam1 := "192.168.0.10"
Cam2 := "192.168.0.11"
Cam3 := "192.168.0.12"

CamActive := Cam1
zoom :=""
panTiltNopeus := "1" ;mit‰ isompi luku sen hitaampi
alaLahetaXY := "0" ;Onko x ja y suunta 50 l‰hetetty 
alaLahetaZ := "0"
autoFocus := "0"
saveCam := ""

;Luodaan Array jolla saadaan k‰‰nnetty‰ joystickin x liike p‰invastaiseksi
;Arrayssa global vaaditaan myˆs kun luodaan array?
global xflip := []
sata := 100
nolla := 0
while sata > 0
	{
	
		;Arrayn sis‰ll‰ numeron muoto pit‰‰ olla 01 eik‰ 1.
		if (sata < 10)
		{
		xflip[nolla] := "0" . sata
		}
		else
		{
		xflip[nolla] := sata
		}
		
		sata := sata - 1
		nolla := nolla + 1

		;send % sata . "w" . nolla . "`n"

	}


; WEB Objektin alustus
;---------------------

whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")


; Gui Layot
;------------
;--------------------------------------

;CAM 1 __________________________________
Gui, Add, Button, x0 y1 w100 h50 gCam1Pressed, %cam1var%
Gui, Add, DropDownList, x110 y2 w70 vColorChoice1 gCam1WB Choose7, Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y1 w70 h23 gCam1ATW, ATW
Gui, Add, Button, x110 y28 w140 gCam1AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y55 w30 h30 gCam1Mem1, 1
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem2, 2
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem3, 3
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem4, 4
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem5, 5
Gui, Add, Button, x+0 y55 w100 h30 gCam1Store, Save Position

;CAM 2 __________________________________
Gui, Add, Button, x0 y100 w100 h50 gCam2Pressed, %cam2var%
Gui, Add, DropDownList, x110 y102 w70 vColorChoice2 gCam2WB Choose7, Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y101 w70 h23 gCam2ATW, ATW
Gui, Add, Button, x110 y128 w140 gCam2AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y155 w30 h30 gCam2Mem1, 1
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem2, 2
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem3, 3
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem4, 4
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem5, 5
Gui, Add, Button, x+0 y155 w100 h30 gCam2Store, Save Position

;CAM 3 __________________________________
Gui, Add, Button, x0 y200 w100 h50 gCam3Pressed, %cam3var%
Gui, Add, DropDownList, x110 y202 w70 vColorChoice3 gCam3WB Choose7, |Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y201 w70 h23 gCam3ATW, ATW
Gui, Add, Button, x110 y228 w140 gCam3AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y255 w30 h30 gCam3Mem1, 1
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem2, 2
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem3, 3
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem4, 4
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem5, 5
Gui, Add, Button, x+0 y255 w100 h30 gCam3Store, Save Position




/*
Gui, Add, Button, x0 y60 w100 h50 gCam2Pressed, %cam2var%
Gui, Add, DropDownList, x+0 y60 vColorChoice2, Black|White|Red|Green|Blue

Gui, Add, Button, x0 y120 w100 h50 gCam3Pressed, %cam3var%
*/

Gui, Add, Statusbar,,Kuutiomedia Oy

Gui, +AlwaysOnTop
;Gui, Color, Black
Gui, Show, w250, RoboControl v.%VersioNumero%


;Tallennusikkuna______________________________________________
Gui, Tallennus1Gui:Add, Text,, Select memory bank to save PTZ preset.
Gui, Tallennus1Gui:Add, Button, x0 y30 w30 h30 gStore1Mem1, 1
Gui, Tallennus1Gui:Add, Button, x+0 y30 w30 h30 gStore1Mem2, 2
Gui, Tallennus1Gui:Add, Button, x+0 y30 w30 h30 gStore1Mem3, 3
Gui, Tallennus1Gui:Add, Button, x+0 y30 w30 h30 gStore1Mem4, 4
Gui, Tallennus1Gui:Add, Button, x+0 y30 w30 h30 gStore1Mem5, 5
Gui, Tallennus1Gui:Add, Button, x+0 y30 w100 h30 gSave1Cancel, Cancel
Gui, Tallennus1Gui:+AlwaysOnTop
;Gui, TallennusGui:Show



return



; Labels
;-----------
;------------------------------------

	
Cam1Pressed:
	GuiControl,,Button1,** CAM 1 **
	GuiControl,,Button10,Cam 2
	GuiControl,,Button19,Cam 3
	CamActive := Cam1
	return 

Cam2Pressed:
	GuiControl,,Button10,** CAM 2 **
	GuiControl,,Button1,Cam 1
	GuiControl,,Button19,Cam 3
	CamActive := Cam2
	return 
	
Cam3Pressed:
	GuiControl,,Button19,** CAM 3 **
	GuiControl,,Button1,Cam 1
	GuiControl,,Button10,Cam 2
	CamActive := Cam3
	return 
	
Cam1WB:
	GuiControlGet, ColorChoice1
	If (ColorChoice1 = "Awb")
		whiteBalance(cam1,0) 
	If (ColorChoice1 = "Awb A")
		whiteBalance(cam1,1)
	If (ColorChoice1 = "Awb B")
		whiteBalance(cam1,2)
	If (ColorChoice1 = "ATW")
		whiteBalance(cam1,3)
	If (ColorChoice1 = "3200K")
		whiteBalance(cam1,4)
	If (ColorChoice1 = "5600K")
		whiteBalance(cam1,5)
	If (ColorChoice1 = "VAR")
		whiteBalance(cam1,9)
	return
	
	/*
	whiteBalance(IPosoite,WB)
{
	/*
	OAW:data
	0 = ATW
	1 = AWB A
	2 = AWB B
	3 = ATW
	4 = Preset 3200k
	5 = Preset 5600k
	9 = Var
	
	*/
	
Cam2WB:
	return

Cam3WB:
	return

Cam1ATW:
	whiteBalanceSet(cam1)
	return

Cam2ATW:
	return
	
Cam3ATW:
	return
	
Cam1AutoFocus:
	;GuiControl,,Button3,Auto Focus ON
	AutofocusOnOff(Cam1, "Button3")
	return

Cam2AutoFocus:
	AutofocusOnOff(Cam2, "Button12")
	return

Cam3AutoFocus:
	AutofocusOnOff(Cam3, "Button21")
	return

Cam1Mem1:
	return

Cam1Mem2:
	return

Cam1Mem3:
	return

Cam1Mem4:
	return

Cam1Mem5:
	return

Cam2Mem1:
	return

Cam2Mem2:
	return

Cam2Mem3:
	return

Cam2Mem4:
	return

Cam2Mem5:
	return

Cam3Mem1:
	return

Cam3Mem2:
	return

Cam3Mem3:
	return

Cam3Mem4:
	return

Cam3Mem5:
	return


Cam1Store:
	saveCam := "1"
	Gui, Tallennus1Gui:Show
	return
	
Cam2Store:
	return

Cam3Store:
	;SB_SetText("Teksti‰")
	
	return

Store1Mem1:
	saveCamPosition(Cam1,"1")
	Gui, Tallennus1Gui:Hide
	return

Store1Mem2:
	Gui, Tallennus1Gui:Hide
	return
	
Store1Mem3:
	Gui, Tallennus1Gui:Hide
	return

Store1Mem4:
	Gui, Tallennus1Gui:Hide
	return

Store1Mem5:
	Gui, Tallennus1Gui:Hide
	return

Save1Cancel:
	Gui, Tallennus1Gui:Hide
	return


OhjaaKameraa:

	global whr
	global CamActive
	global panTiltNopeus
	
	JoystickSuunnat := JoystickPositio()
	x := JoystickSuunnat[1]
	y := JoystickSuunnat[2]
	z := JoystickSuunnat[3]


	osoiteXY := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23PTS" . x . y . "&res=1"
	osoiteZ := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23Z" . z . "&res=1"
	osoiteZoomPositio := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23GZ&res=1"


	;luetaan zoomin positio
	
	try 
	{
		whr.Open("GET", osoiteZoomPositio, true)
		whr.Send()
		whr.WaitForResponse(3) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
		zoomPositio := whr.ResponseText
		;siistiti‰‰n palautettu data
		StringTrimLeft, zoomPositio, zoomPositio, 2
		;muutetaan hexa desimaali muotoon 
		zoomPositio := Format("{:i}", "0x" zoomPositio)
		zoomPositio := zoomPositio / 1365
		zoomPositio := Round(zoomPositio, 1)
		panTiltNopeus := 1.5 + zoomPositio / 2
		;SB_SetText("Cam: " . CamActive . " Connected.")
	}
	catch e
	{
		;MsgBox % "Error in " e.What ", whitch was called at line " e.Line
		;SB_SetText("Error in " . e.What . ", whitch was called at line " . e.Line)
		SB_SetText("Cam: " . CamActive . " Connection error.")
	}
	
	
	;send % zoomPositio . "`n"

	;Ohjaa kamera X ja Y akseleita
	;L‰hett‰‰ komennon jos alaLahetaXY on 0 eli joystick ei ole keskell‰
	if alaLahetaXY = 0 
	{
		;whr.Open("GET", osoiteXY, true) ; Using 'true' allows the script to remain responsive.
		;whr.Send()
		;;Send % osoiteXY . "`n"
		webSend(CamActive, "PTS", x . y)
	}
	
	;Ohjaa kameran Zoomia
	;L‰hett‰‰ komennon jos alaLahetaZ on 0 eli joystick ei ole keskell‰.
	;Keskell‰ arvo on 50
	if alaLahetaZ = 0
	{
		Sleep, 150 ; Odotetaan ennen kuin l‰hetet‰‰n komento jotta saadaan komennot kulkemaan
		whr.Open("GET", osoiteZ, true) ; Using 'true' allows the script to remain responsive.
		whr.Send()
		;Send % osoiteZ . "`n"
	}
	

	;Jos joystick on keskell‰ asettaa alaLaheta arvoksi 1 jolloin keskitys
	;arvoa ei l‰hetet‰ turhantakia
	if (x = 50) and (y = 50)
	{
		alaLahetaXY := 1
	}
	else
	{
		alaLahetaXY := 0
	}
	
	;ZOOM
	if (z = 50)
	{
		alaLahetaZ := 1
	}
	else
	{
		alaLahetaZ := 0
	}
	
	return



;Viittaa ruksi nappiin jolla ikkuna suljetaan ja t‰ll‰ koko ohelma suljetaan.
GuiClose:
	;MsgBox, sulje
	ExitApp
	return
	
; Functions
;------------------
;--------------------------------------

;Funktio, joka lukee joystickin sijainnin ja l‰hett‰‰ datan
JoystickPositio()
{
	global panTiltNopeus
	global xflip
	
	GetKeyState, JoyX, JoyX
	GetKeyState, JoyY, JoyY
	GetKeyState, JoyZ, JoyZ
	
	JoyX := Round(JoyX, 0)
	JoyY := Round(JoyY, 0)
	JoyZ := Round(JoyZ, 0)
	
	
	
	
	x := 50 + ((50 - JoyX)/panTiltNopeus)
	y := 50 + ((50 - JoyY)/panTiltNopeus)
	x := Round(x, 0)
	y := Round(y, 0)
	z := JoyZ
	
	
	if (x < 10)
		{
		if (x < 1)
		{
		x := 1
		}
		;x  := "0" . x
		}
	else if (x > 99)
		{
		x := 99
		}
	
	if (y < 10)
		{
		if (y < 1)
		{
		y := 1
		}
		y  := "0" . y
		}
	else if (y > 99)
		{
		y := 99
		}
		
	if (z < 10)
		{
			if (z < 1)
			{
			z := 1
			}
			z  := "0" . z
		}
	else if (z > 99)
		{
		z := 99
		}
	
	
	;teksti := "Tikku X: " . JoyX . " Tikku Y:" . JoyY . "`n"
	;send % teksti
	;return Laheta(JoyX,JoyY,JoyZ)
	
	;Send % x . " flip " . xflip[x] . "`n"
	
	;K‰‰nnet‰‰n x:n liikesuunta
	x := xflip[x]

	
 
	;Send % "X " . x . "	Y " . y  . " Z " . z . "`n"
	
	joyStickSuunnat := [x,y,z]
	
	return joyStickSuunnat
}	

webSend(IPosoite,komento,data)
{
	global whr
	
	; T‰m‰ ok ;osoiteXY := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23PTS" . x . y . "&res=1"
	;osoiteZ := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23Z" . z . "&res=1"
	;osoiteZoomPositio := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23GZ&res=1"
	
	
	
	osoite := "http://" . CamActive . "/cgi-bin/aw_ptz?cmd=`%23" . komento . data . "&res=1"
	
	;whr.Open("GET", osoite, true) ; Using 'true' allows the script to remain responsive.
	;whr.Send()
	
	try whr.Open("GET", osoite, true)
	catch error
		MsgBox virhe
	whr.Send()
	
	;whr.WaitForResponse()
	
	
	; Error 0x80072EE2
	
	return
}

AutofocusOnOff(IPosoite, ButtonID)
{
	global autoFocus
	;global CamActive
	
	
	if (autoFocus = 0)
	{
	autoFocus := "1"
	
	osoiteAutoFocus := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23D11&res=1"
	whr.Open("GET", osoiteAutoFocus, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	GuiControl,,%ButtonID%,AutoFocus ON
	Sleep, 150
	;send % osoiteAutoFocus
	
	return
	}
	
	if (autoFocus = 1)
	{
	autoFocus := "0"
	osoiteAutoFocus := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23D10&res=1" 
	whr.Open("GET", osoiteAutoFocus, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	GuiControl,,%ButtonID%,Auto Focus OFF
	Sleep, 150
	;send % osoiteAutoFocus
	}
	
	
}

whiteBalance(IPosoite,WB)
{
	/*
	OAW:data
	0 = ATW
	1 = AWB A
	2 = AWB B
	3 = ATW
	4 = Preset 3200k
	5 = Preset 5600k
	9 = Var
	
	OWS = Auto White
	*/
	
	osoiteWB := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=OAW:" . WB . "&res=1"
	whr.Open("GET", osoiteWB, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150

	return
}

whiteBalanceSet(IPosoite)
{
	
	osoiteWB := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=OWS&res=1"
	whr.Open("GET", osoiteWB, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150

	return
}

saveCamPosition(IPosoite,memoryBank)
{


osoiteZoomPositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23GZ&res=1"
osoiteXYpositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=%23APC&res=1"

try 
	{
		whr.Open("GET", osoiteZoomPositio, true)
		whr.Send()
		whr.WaitForResponse(3) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
		zoomPositio := whr.ResponseText
		;siistiti‰‰n palautettu data
		StringTrimLeft, zoomPositio, zoomPositio, 2
		
		whr.Open("GET", osoiteXYpositio, true)
		whr.Send()
		whr.WaitForResponse(3) ;Odotetaan x sekuntia vastausta
		XYpositio := whr.ResponseText
		StringTrimLeft, XYpositio, XYpositio, 2
		
		;SB_SetText("z:" . zoomPositio . " - xy:" . XYpositio)
		;MsgBox % "z:" . zoomPositio . " - xy:" . XYpositio
		
		/*
		;muutetaan hexa desimaali muotoon 
		zoomPositio := Format("{:i}", "0x" zoomPositio)
		zoomPositio := zoomPositio / 1365
		zoomPositio := Round(zoomPositio, 1)
		panTiltNopeus := 1.5 + zoomPositio / 2
		*/
		
		;SB_SetText("Cam: " . CamActive . " Read OK")
	}
	catch e
	{
		SB_SetText("Cam: " . CamActive . " Connection error.")
	}
	
	;Tallennetaan tiedostoon_______________________________
	/*
	FileSelectFile, FileName, S16,, Create a new file:
	if (FileName = "")
		return
	*/
	
	file := FileOpen("ohoKoe.txt", "w")
	if !IsObject(file)
	{
		MsgBox Can't open "%FileName%" for writing.
		return
	}
	
	TestString := "z:" . zoomPositio . "xy:" . XYpositio . "`r`n"  ; When writing a file this way, use `r`n rather than `n to start a new line.
	file.Write(TestString)
	file.Close()



}



; Hotkeys
;------------------
;--------------------------------------

Joy1::
	if GetKeyState("Joy5")
	{
		;CamActive := Cam1
		gosub Cam1Pressed
		;MsgBox yhdistelma 1
	}
	else
	{
		Send {F1}
	}
	return
	
Joy2::
	if GetKeyState("Joy5")
	{
		;CamActive := Cam2
		gosub Cam2Pressed
		;MsgBox yhdistelma 2
	
	}
	else
	{
		Send {F2}
	}
	return
	
Joy4::
	if GetKeyState("Joy5")
	{
		;CamActive := Cam3
		gosub Cam3Pressed
		;MsgBox yhdistelma 3
	}
	else
	{
		Send {F3}
	}
	return

Joy3::
	if GetKeyState("Joy5")
	{
		;CamActive = %Cam4%
		;MsgBox yhdistelma 4
	}
	else
	{
		Send {F4}
	}
	return
	
Joy6::
	Send {Shift}
	return

Joy7::
	ExitApp


Joy8::
	#Persistent
	SetTimer, OhjaaKameraa, 200 ; V‰hint‰‰n 130ms viive komennon l‰hetykseen
	return

	
Joy10::
	global CamActive
	;AutofocusOnOff(CamActive)
	return
/*	
	
	global autoFocus
	global CamActive
	
	if (autoFocus = 0)
	{
	autoFocus := "1"
	
	osoiteAutoFocus := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23D11&res=1"
	whr.Open("GET", osoiteAutoFocus, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	;send % osoiteAutoFocus
	return
	}
	
	if (autoFocus = 1)
	{
	autoFocus := "0"
	osoiteAutoFocus := "http://" CamActive "/cgi-bin/aw_ptz?cmd=`%23D10&res=1"
	whr.Open("GET", osoiteAutoFocus, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	;send % osoiteAutoFocus
	}
*/

^x::ExitApp