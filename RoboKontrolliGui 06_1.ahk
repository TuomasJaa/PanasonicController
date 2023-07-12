/*
Nyt tyˆn alla.
!! Kameroiden valotus ja gain arvojen luku hidastaan k‰yttˆliittym‰n k‰ynnistymist‰

-!! Gain s‰‰tˆ n‰kyy GUIssa camera 1:sen kohdalla!!!!
-Ei osaa p‰ivitt‰‰ GUIhin aukko ja gain arvoja kun ne luetaan muistista


*/


/*
Gui - Robo ohjauspaneeli

Toiminnot:

v.1.0

DONE-----------
-Tallennus
-Preset
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
cam1var := "CAM 1"
cam2var := "CAM 2"
cam3var := "CAM 3"
cam1exposure := "--"
cam2exposure := "--"
cam3exposure := "--"
cam1gain := "-"
cam2gain := "-"
cam3gain := "-"

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



;Alustetaan tallentamiseen ja muistipaikkoihin tarvittava array
memory := []
camMemory :={(Cam1): (memory), (Cam3): (memory), (Cam3): (memory)}

;Luetaan vanhat muistit ini tiedostosta
camMemory := readFromFile(camMemory)

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

global whr2 := ComObjCreate("WinHttp.WinHttpRequest.5.1")

; K‰ynnistet‰‰n luupit
;---------------------
#Persistent
SetTimer, OhjaaKameraa, 130 ; V‰hint‰‰n 130ms viive komennon l‰hetykseen
SetTimer, JoyPOVohjain, 20 ;Ristikko-ohjaimen tsekkaus

;Luetaan kamerasta valotusarvot
;------------------------------
/*
cam1exposure := setExposure(Cam1,"0x0")
cam2exposure := setExposure(Cam2,"0x0")
cam3exposure := setExposure(Cam3,"0x0")
*/
; Gui Layout
;------------
;--------------------------------------

;CAM 1 __________________________________
cam1exposureA := cam1exposure[2]
Gui, Add, Button, x0 y1 w100 h50 gCam1Pressed, %cam1var%`r%cam1exposureA% / %cam1gain%
Gui, Add, DropDownList, x110 y2 w70 vColorChoice1 gCam1WB Choose3, |Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y1 w70 h23 gCam1ATW, ATW
Gui, Add, Button, x110 y28 w140 gCam1AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y55 w30 h30 gCam1Mem1, 1
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem2, 2
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem3, 3
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem4, 4
Gui, Add, Button, x+0 y55 w30 h30 gCam1Mem5, 5
Gui, Add, Button, x+0 y55 w100 h30 gCam1Store, Save Position
;Gui, Add, Text, x0 y87, F--  -db

;CAM 2 __________________________________
Gui, Add, Button, x0 y100 w100 h50 gCam2Pressed, %cam2var%`r%cam2exposure% / %cam2gain%
Gui, Add, DropDownList, x110 y102 w70 vColorChoice2 gCam2WB Choose3, |Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y101 w70 h23 gCam2ATW, ATW
Gui, Add, Button, x110 y128 w140 gCam2AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y155 w30 h30 gCam2Mem1, 1
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem2, 2
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem3, 3
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem4, 4
Gui, Add, Button, x+0 y155 w30 h30 gCam2Mem5, 5
Gui, Add, Button, x+0 y155 w100 h30 gCam2Store vBut2save, Save Position

;CAM 3 __________________________________
Gui, Add, Button, x0 y200 w100 h50 gCam3Pressed, %cam3var%`r%cam3exposure% / %cam2gain%
Gui, Add, DropDownList, x110 y202 w70 vColorChoice3 gCam3WB Choose3, |Awb|Awb A|Awb B|ATW|3200K|5600K|VAR
Gui, Add, Button, x180 y201 w70 h23 gCam3ATW, ATW
Gui, Add, Button, x110 y228 w140 gCam3AutoFocus, Auto Focus OFF

Gui, Add, Button, x0 y255 w30 h30 gCam3Mem1, 1
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem2, 2
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem3, 3
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem4, 4
Gui, Add, Button, x+0 y255 w30 h30 gCam3Mem5, 5
Gui, Add, Button, x+0 y255 w100 h30 gCam3Store, Save Position

;---Guin status bar --
Gui, Add, Statusbar,,Kuutiomedia Oy

Gui, +AlwaysOnTop
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
	GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gain% **
	GuiControl,,Button10,%cam2var%`r%cam2exposure%
	GuiControl,,Button19,%cam3var%`r%cam3exposure%
	CamActive := Cam1
	return 

Cam2Pressed:
	GuiControl,,Button10,** %cam2var% **`r** %cam2exposure% / %cam2gain% **
	GuiControl,,Button1,%cam1var%`r%cam1exposure%
	GuiControl,,Button19,%cam3var%`r%cam3exposure%
	CamActive := Cam2
	return 
	
Cam3Pressed:
	GuiControl,,Button19,** %cam3var% **`r** %cam3exposure% / %cam3gain% **
	GuiControl,,Button1,%cam1var%`r%cam1exposure%
	GuiControl,,Button10,%cam2var%`r%cam2exposure%
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
	GuiControlGet, ColorChoice2
	If (ColorChoice1 = "Awb")
		whiteBalance(cam2,0) 
	If (ColorChoice1 = "Awb A")
		whiteBalance(cam2,1)
	If (ColorChoice1 = "Awb B")
		whiteBalance(cam2,2)
	If (ColorChoice1 = "ATW")
		whiteBalance(cam2,3)
	If (ColorChoice1 = "3200K")
		whiteBalance(cam2,4)
	If (ColorChoice1 = "5600K")
		whiteBalance(cam2,5)
	If (ColorChoice1 = "VAR")
		whiteBalance(cam2,9)
	return
	

Cam3WB:
	GuiControlGet, ColorChoice3
	If (ColorChoice3 = "Awb")
		whiteBalance(cam1,0) 
	If (ColorChoice3 = "Awb A")
		whiteBalance(cam1,1)
	If (ColorChoice3 = "Awb B")
		whiteBalance(cam1,2)
	If (ColorChoice3 = "ATW")
		whiteBalance(cam1,3)
	If (ColorChoice3 = "3200K")
		whiteBalance(cam1,4)
	If (ColorChoice3 = "5600K")
		whiteBalance(cam1,5)
	If (ColorChoice3 = "VAR")
		whiteBalance(cam1,9)
	return
	

Cam1ATW:
	whiteBalanceSet(cam1)
	return

Cam2ATW:
	whiteBalanceSet(cam2)
	return
	
Cam3ATW:
	whiteBalanceSet(cam3)
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
	readMemory(Cam1, "1", camMemory)
	return

Cam1Mem2:
	readMemory(Cam1, "2", camMemory)
	return

Cam1Mem3:
	readMemory(Cam1, "3", camMemory)
	return

Cam1Mem4:
	readMemory(Cam1, "4", camMemory)
	return

Cam1Mem5:
	readMemory(Cam1, "5", camMemory)
	return

Cam2Mem1:
	readMemory(Cam2, "1", camMemory)
	return

Cam2Mem2:
	readMemory(Cam2, "2", camMemory)
	return

Cam2Mem3:
	readMemory(Cam2, "3", camMemory)
	return

Cam2Mem4:
	readMemory(Cam2, "4", camMemory)
	return

Cam2Mem5:
	readMemory(Cam2, "5", camMemory)
	return

Cam3Mem1:
	readMemory(Cam3, "1", camMemory)
	return

Cam3Mem2:
	readMemory(Cam3, "2", camMemory)
	return

Cam3Mem3:
	readMemory(Cam3, "3", camMemory)
	return

Cam3Mem4:
	readMemory(Cam3, "4", camMemory)
	return

Cam3Mem5:
	readMemory(Cam3, "5", camMemory)
	return


Cam1Store:
	;GuiControl, Disable, But2save
	saveCam := Cam1
	Gui, Tallennus1Gui:Show
	return
	
Cam2Store:
	saveCam := Cam2
	Gui, Tallennus1Gui:Show
	return

Cam3Store:
	saveCam := Cam3
	Gui, Tallennus1Gui:Show
	return

Store1Mem1:
	camMemory := saveCamPosition(saveCam,"1",camMemory)
	Gui, Tallennus1Gui:Hide
	
	return

Store1Mem2:
	camMemory := saveCamPosition(saveCam,"2",camMemory)
	Gui, Tallennus1Gui:Hide
	return
	
Store1Mem3:
	camMemory := saveCamPosition(saveCam,"3",camMemory)
	Gui, Tallennus1Gui:Hide
	return

Store1Mem4:
	camMemory := saveCamPosition(saveCam,"4",camMemory)
	Gui, Tallennus1Gui:Hide
	return

Store1Mem5:
	camMemory := saveCamPosition(saveCam,"5",camMemory)
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
		whr.WaitForResponse(1) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
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
		;SB_SetText("Cam: " . CamActive . " Connection error.")
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
		Sleep, 130 ; Odotetaan ennen kuin l‰hetet‰‰n komento jotta saadaan komennot kulkemaan
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


JoyPOVohjain:
	;Ristikko-ohjain
	;Oikea-Vasen valotus
	;Ylˆs-Alas tarkennus
	
	/*
	GuiControl,,Button1,** %cam1var% **`r** %cam1exposure% **
	GuiControl,,Button10,%cam2var%`r%cam2exposure%
	GuiControl,,Button19,%cam3var%`r%cam3exposure%
	CamActive := Cam1
	*/
	
	
	GetKeyState, POV, JoyPOV  ; Get position of the POV control.
	if (POV < 0){   ; No angle to report
		DoNothing := True
	}
	else if (POV = 0){
		;MsgBox, Up
		if (CamActive = Cam1){
			cam1gain := setGain(Cam1,1)
			cam1GainA := cam1gain[2]
			GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gainA% **
		}else if (camActive = Cam2){
			cam2gain := setGain(Cam2,1)
			cam2GainA := cam2gain[2]
			GuiControl,,Button1,** %cam2var% **`r** %cam2exposureA% / %cam2gainA% **		
		}else if (camActive = Cam3){
			cam3gain := setGain(Cam3,1)
			cam3GainA := cam3gain[2]
			GuiControl,,Button1,** %cam3var% **`r** %cam3exposureA% / %cam3gainA% **		
		}
		
	}
	else if (POV = 9000){
		;Right
		if (CamActive = Cam1){
			cam1exposure := setExposure(Cam1,"0x1A")
			cam1exposureA := cam1exposure[2] 
			GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gainA% **
		}else if (camActive = Cam2){
			cam2exposure := setExposure(Cam2,"0x1A")
			cam2exposureA := cam2exposure[2]
			GuiControl,,Button10,** %cam2var% **`r** %cam2exposureA% / %cam2gainA% **
		}else if (camActive = Cam3){
			cam3exposure := setExposure(Cam3,"0x1A")
			cam3exposureA := cam3exposure[2]
			GuiControl,,Button19,** %cam3var% **`r** %cam3exposureA% / %cam3gainA% **
		}
		;MsgBox, Right
	}
	else if (POV = 18000){
		;MsgBox, Down
		if (CamActive = Cam1){
			cam1gain := setGain(Cam1,-1)
			cam1GainA := cam1gain[2]
			GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gainA% **
		}else if (camActive = Cam2){
			cam2gain := setGain(Cam2,-1)
			cam2GainA := cam2gain[2]
			GuiControl,,Button1,** %cam2var% **`r** %cam2exposureA% / %cam2gainA% **		
		}else if (camActive = Cam3){
			cam3gain := setGain(Cam3,-1)
			cam3GainA := cam3gain[2]
			GuiControl,,Button1,** %cam3var% **`r** %cam3exposureA% / %cam3gainA% **	
		}
	}
	else if (POV = 27000){
		;Left
		if (CamActive = Cam1){
			cam1exposure := setExposure(Cam1,"-0x1A")
			cam1exposureA := cam1exposure[2]
			GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gainA%  **
		}else if (camActive = Cam2){
			cam2exposure := setExposure(Cam2,"-0x1A")
			cam2exposureA := cam2exposure[2]
			GuiControl,,Button10,** %cam2var% **`r** %cam2exposureA% / %cam2gainA%  **
		}else if (camActive = Cam3){
			cam3exposure := setExposure(Cam3,"-0x1A")
			cam3exposureA := cam3exposure[2]
			GuiControl,,Button19,** %cam3var% **`r** %cam3exposureA% / %cam3gainA%  **
		}
	
		;MsgBox, Left
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


/*
camButtonTextUpdate(Cam1, ButtonNumber)
{
	cam1exposureA := cam1exposure[2]
	cam1gain := setGain(Cam1,1)
	cam1GainA := cam1gain[2]
	GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %cam1gainA% **
}
*/



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
	Sleep, 130
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
	Sleep, 130
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
	Sleep, 130

	return
}

whiteBalanceSet(IPosoite)
{
	
	osoiteWB := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=OWS&res=1"
	whr.Open("GET", osoiteWB, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 130

	return
}

saveCamPosition(IPosoite,memoryBank,camMemory)
{


osoiteZoomPositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23GZ&res=1"
osoiteXYpositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=%23APC&res=1"
osoiteGain := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=QGU&res=1"
osoiteAukko := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=QRV&res=1"
osoiteFocus := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23GF&res=1"

try 
	{
		whr.Open("GET", osoiteZoomPositio, true)
		whr.Send()
		whr.WaitForResponse(3) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
		zoomPositio := whr.ResponseText
		;siistiti‰‰n palautettu data
		StringTrimLeft, zoomPositio, zoomPositio, 2
		
		sleep, 130
		
		whr.Open("GET", osoiteXYpositio, true)
		whr.Send()
		whr.WaitForResponse(3) ;Odotetaan x sekuntia vastausta
		XYpositio := whr.ResponseText
		StringTrimLeft, XYpositio, XYpositio, 3
		
		sleep, 130
		
		whr.Open("GET", osoiteGain, true)
		whr.Send()
		whr.WaitForResponse(3) ;Odotetaan x sekuntia vastausta
		gainArvo := whr.ResponseText
		StringTrimLeft, gainArvo, gainArvo, 4
		
		sleep, 130
		
		whr.Open("GET", osoiteAukko, true)
		whr.Send()
		whr.WaitForResponse(3) ;Odotetaan x sekuntia vastausta
		aukkoArvo := whr.ResponseText
		StringTrimLeft, aukkoArvo, aukkoArvo, 4
		
		sleep, 130
		
		whr.Open("GET", osoiteFocus, true)
		whr.Send()
		whr.WaitForResponse(3) ;Odotetaan x sekuntia vastausta
		focusArvo := whr.ResponseText
		StringTrimLeft, focusArvo, focusArvo, 2
		
		sleep, 130
		
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
		;SB_SetText("Cam: " . IPosoite . " Connection error.")
	}
	
	/*Tallennetaan asetus muistin
	camMemory:n sis‰ll‰ on tallennettu kamera + kameran muistipaikat
	memory:n sis‰ll‰ on kamerakohtaiset muistipaikat
	preset:in sis‰ll‰ on kamera asetukset
	*/
	
	memory := camMemory[IPosoite]
	
	;preset tallentaa kameran yhden sijainnin
	preset := {z: (zoomPositio), xy: (XYpositio), gain: (gainArvo), aukko: (aukkoArvo), f: (focusArvo)}
	;memory tallentaa taas presetin muistipaikkaan
	memory[memoryBank] := preset
			
	;muistipaikka tallennetaan tietyn kameran alle
	camMemory :={(IPosoite): (memory)}
	
	/*
	;De Buggaus osio t‰lle kameran asetuksien muistille
	;---------------------------------------------------
	;Luetaan cam1 muistipaikat
	testiCamera := IPosoite
	testiMuistipaikat := camMemory[testiCamera]

	;Luetaan kameran muistipaikka 1
	ho := memoryBank
	noniin := testiMuistipaikat[ho]
	
	MsgBox, % "XY: " . noniin.xy . " Z:" . noniin.z . " IP: " . IPosoite . " Mem: " . memoryBank
	;De Bug- p‰‰ttyy------------------------------------
	*/
	
	;tallennetaan t‰m‰ tiedostoon
	saveToFile(camMemory)
	return camMemory

}

saveToFile(camMemory)
{
	;Tallennetaan camMemory ini tiedostoon______________________________
	;[192.168.0.10/1]
	;xy=9B927925
	;z=AD0
	
	For IPosoite, memory in camMemory
		for memoryBank, preset in memory
			for nimi, data in preset
				;MsgBox, % data
				IniWrite,%data%,camerapresets.ini,%IPosoite%-%memoryBank%,%nimi%
	
	;t‰ss‰ vain testaus tarkoituksessa POISTA
	;readFromFile(camMemory)
	return
	
}

readFromFile(camMemory)
{	
	;Luetaan otsikot rivi rivilt‰
	IniRead, var,camerapresets.ini
	Loop, parse, var, `n, `r 
	{
			;erotetaan otsikosta ip-osoite ja muistipaikan numero
			;MsgBox, Line number %A_Index% is %A_LoopField%
			lines := StrSplit(A_LoopField, "-")
			otsikko := A_LoopField
			IPosoite := lines[1]
			memoryBank := lines[2]
			
			IniRead,zoomPositio,camerapresets.ini,%otsikko%,z
			IniRead,XYpositio,camerapresets.ini,%otsikko%,xy
			IniRead,gainArvo,camerapresets.ini,%otsikko%,gain
			IniRead,aukkoArvo,camerapresets.ini,%otsikko%,aukko
			IniRead,focusArvo,camerapresets.ini,%otsikko%,f
			;MsgBox, % luettuZ
			
			
			
			/*Tallennetaan asetus muistin
			camMemory:n sis‰ll‰ on tallennettu kamera + kameran muistipaikat
			memory:n sis‰ll‰ on kamerakohtaiset muistipaikat
			preset:in sis‰ll‰ on kamera asetukset
			*/
	
			memory := camMemory[IPosoite]
	
			;preset tallentaa kameran yhden sijainnin
			preset := {z: (zoomPositio), xy: (XYpositio), gain: (gainArvo), aukko: (aukkoArvo), f: (focusArvo)}
			;memory tallentaa taas presetin muistipaikkaan
			memory[memoryBank] := preset
					
			;muistipaikka tallennetaan tietyn kameran alle
			camMemory :={(IPosoite): (memory)}
			
			
			
			
	}
	
	;MsgBox, % var
	
	return camMemory
	
}

readMemory(IPosoite, memoryBank, camMemory)
{
	;Haetaan oikean kameran ja oikean muistipaikan tiedot muuttujaan asetukset
	muistipaikat := camMemory[IPosoite]
	asetukset := muistipaikat[memoryBank]
	
	;MsgBox, % asetukset.xy
	;MsgBox, % "XY: " . asetukset.xy . " Z:" . asetukset.z . " IP: " . IPosoite . " Mem: " . memoryBank
	
	;alustetaan http komennot
	osoiteZoomPositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23AXZ" . asetukset.z . "&res=1"
	osoiteXYpositio := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=%23APC" . asetukset.xy . "&res=1"
	osoiteGain := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=OGU:" . asetukset.gain . "&res=1"
	osoiteAukko := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=ORV:" . asetukset.aukko . "&res=1"
	osoiteFocus := "http://" . IPosoite . "/cgi-bin/aw_ptz?cmd=`%23AXF" . asetukset.f . "&res=1"
	
	;MsgBox, % osoiteXYpositio
	
	whr.Open("GET", osoiteXYpositio, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	whr.Open("GET", osoiteZoomPositio, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	whr.Open("GET", osoiteGain, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	whr.Open("GET", osoiteAukko, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	whr.Open("GET", osoiteFocus, true) ; Using 'true' allows the script to remain responsive.
	whr.Send()
	Sleep, 150
	
	
	return
	
}

setExposure(IPosoite,change){
	;luetaan auko arvo
	;http://192.168.0.10/cgi-bin/aw_cam?cmd=QRV&res=1
	
	
	;l‰hetet‰‰n aukon arvo
	;http://192.168.0.10/cgi-bin/aw_cam?cmd=ORV:3FF&res=1
	;Max 3FF = 1023 ja min = 000
	
	osoiteExposureArvo := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=QRV&res=1"

	try 
		{
			;Luetaan nykyinen aukon arvo
			whr2.Open("GET", osoiteExposureArvo, true)
			whr2.Send()
			whr2.WaitForResponse(3) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
			exposureArvo := whr2.ResponseText
			
			;MsgBox, % exposureArvo . " k‰sittelem‰tˆn"
			;Toimitaan HEX muodossa
			SetFormat, Integer, H
			;siistiti‰‰n palautettu data
			StringTrimLeft, exposureArvo, exposureArvo, 4
			
				;MsgBox, % exposureArvo . " stripattu"
	
			exposureArvo := "0x" . exposureArvo
			
			;exposureArvo := exposureArvo
			;change := change
			
			;MsgBox, % exposureArvo . " lis‰tty x0 alkuun"
			
			
			;MsgBox, % exposureArvo . " + " . change
			
			exposureArvo := exposureArvo + change ;0xA
			
			;MsgBox, % exposureArvo . " summattu 0xA"
			
			
			if (exposureArvo > 0x3FF){
				exposureArvo := 0x3FF
			}else if (exposureArvo < 0x0){
				exposureArvo := 0x0
			}
			
			returnExposureArvo := exposureArvo
			
			StringTrimLeft, exposureArvo, exposureArvo, 2
			
				;MsgBox, % exposureArvo . " strip 0x ja jos yli 3FF"
			
			if (StrLen(exposureArvo) = 1){
				exposureArvo := "00" . exposureArvo
			}else if(StrLen(exposureArvo) = 2){
				exposureArvo := "0" . exposureArvo
			}
			
			
			
			;MsgBox, % exposureArvo
			Sleep, 130
			
			sendExposureArvo := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=ORV:" . exposureArvo . "&res=1"
			
				;MsgBox, % sendExposureArvo

			
			whr.Open("GET", sendExposureArvo, true)
			whr.Send()
			
			
			
		}
		catch e
		{
			;SB_SetText("Cam: " . IPosoite . " Connection error.")
		}
		
	
	SetFormat, Integer, D
	returnGainArvo := returnGainArvo + 0
	
	returnExposureArvoArray := [exposureArvo, returnExposureArvo]
	
	return returnExposureArvoArray ;palautetaan aukko arvo
}

setGain(IPosoite,change){
	;change 1= lis‰‰ valoa, -1= v‰henn‰ valoa 0= ei tehd‰ mit‰‰n
	
	if (change = 1){
		change := 0x3
	}else if (change = -1){
		change := -0x3
	}
	
	;HE40, HE65 HE70 -malleille
	;Gain 08 - 38
	;08 - 0dB
	;0B - 3dB
	;0E - 6dB
	;jne 
	;
	;Luetaan gain
	;http://192.168.0.10/cgi-bin/aw_cam?cmd=QGU&res=1
	;Kirjoitetaan gain
	;http://192.168.0.10/cgi-bin/aw_cam?cmd=OGU:08&res=1
	
	osoiteGainArvo := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=QGU&res=1"
	
	;MsgBox, % osoiteGainArvo

	try 
		{
			;Luetaan nykyinen aukon arvo
			whr2.Open("GET", osoiteGainArvo, true)
			whr2.Send()
			whr2.WaitForResponse(3) ;Kerrotaan kuinka monta sek. halutaan odottaa vastausta kameralta
			gainArvo := whr2.ResponseText
			
			;MsgBox, % gainArvo . " k‰sittelem‰tˆn"
			;Toimitaan HEX muodossa
			SetFormat, Integer, H
			;siistiti‰‰n palautettu data
			StringTrimLeft, gainArvo, gainArvo, 4
			
				;MsgBox, % exposureArvo . " stripattu"
	
			gainArvo := "0x" . gainArvo
			
			;exposureArvo := exposureArvo
			;change := change
			
			;MsgBox, % exposureArvo . " lis‰tty x0 alkuun"
			
			
			;MsgBox, % exposureArvo . " + " . change
			
			gainArvo := gainArvo + change ;0xA
			
			;MsgBox, % exposureArvo . " summattu 0xA"
			
			
			if (gainArvo > 0x1A){
				gainArvo := 0x1A
			}else if (gainArvo < 0x8){
				gainArvo := 0x8
			}
			
			returnGainArvo := gainArvo
			
			StringTrimLeft, gainArvo, gainArvo, 2
			
				;MsgBox, % exposureArvo . " strip 0x ja jos yli 3FF"
			
			if (StrLen(gainArvo) = 1){
				gainArvo := "0" . gainArvo
			}
			
			
			
			;MsgBox, % exposureArvo
			Sleep, 130
			
			sendGainArvo := "http://" . IPosoite . "/cgi-bin/aw_cam?cmd=OGU:" . gainArvo . "&res=1"
			
			;MsgBox, % sendGainArvo

			
			whr.Open("GET", sendGainArvo, true)
			whr.Send()
			
			
			
		}
		catch e
		{
			;SB_SetText("Cam: " . IPosoite . " Connection error.")
		}
		
	;Gain 08 - 38
	;08 - 0dB
	;0B - 3dB
	;0E - 6dB
	SetFormat, Integer, D
	returnGainArvo := returnGainArvo + 0
	returnGainArvo := returnGainArvo - 8 
	returnGainArvo := returnGainArvo . "dB"
	
	returnGainArvoArray := [gainArvo, returnGainArvo]
	
	
	
	
	
	;cam1exposureA := cam1exposure[2]
	;cam1gain := setGain(Cam1,1)
	;cam1GainA := cam1gain[2]
	;Testi
	;GuiControl,,Button1,** %cam1var% **`r** %cam1exposureA% / %returnGainArvo% jee **
	
	
	
	
	
	
	return returnGainArvoArray ;palautetaan gain arvo

	
	
	
}

; Hotkeys
;------------------
;--------------------------------------

;SetKeyDelay, -1, 150	; 1st number is time to wait after each key, 2nd number is time to hold each key

Joy1::

	;ottaa obs ikkunan aktiiviseksi
	if WinExist("Multiview (Windowed)")
	{
	WinActivate
	}
	
	if GetKeyState("Joy9")
	{
		;CamActive := Cam1
		gosub Cam1Pressed
		;MsgBox yhdistelma 1
	}
	else if GetKeyState("Joy5")
	{
		Send {Numpad5}
	}
	else
	{
		Send {Numpad1}
	}
	return
	
Joy2::

	;ottaa obs ikkunan aktiiviseksi
	if WinExist("Multiview (Windowed)")
	{
	WinActivate
	}

	if GetKeyState("Joy9")
	{
		;CamActive := Cam2
		gosub Cam2Pressed
		;MsgBox yhdistelma 2
	
	}
	else if GetKeyState("Joy5")
	{
		Send {Numpad6}
	}
	else
	{
		Send {Numpad2}
	}
	return
	
Joy4::

	;ottaa obs ikkunan aktiiviseksi
	if WinExist("Multiview (Windowed)")
	{
	WinActivate
	}

	if GetKeyState("Joy9")
	{
		;CamActive := Cam3
		gosub Cam3Pressed
		;MsgBox yhdistelma 3
	}
	else if GetKeyState("Joy5")
	{
		Send {Numpad7}
	}
	else
	{
		Send {Numpad3}
	}
	return

Joy3::

	;ottaa obs ikkunan aktiiviseksi
	if WinExist("Multiview (Windowed)")
	{
	WinActivate
	}

	if GetKeyState("Joy9")
	{
		;CamActive = %Cam4%
		;MsgBox yhdistelma 4
	}
	else if GetKeyState("Joy5")
	{
		Send {Numpad8}
	}
	else
	{
		Send {Numpad4}
	}
	return
	
Joy6::
	;ottaa obs ikkunan aktiiviseksi
	if WinExist("Multiview (Windowed)")
	{
	WinActivate
	}
	Send {Numpad0}
	;SoundPlay *-1
	return

Joy7::
	AutofocusOnOff(CamActive, "Button3")
	return


Joy8::
/*	#Persistent
	SetTimer, OhjaaKameraa, 150 ; V‰hint‰‰n 130ms viive komennon l‰hetykseen
	SetTimer, JoyPOVohjain, 20 ;Ristikko-ohjaimen tsekkaus
	return
*/
	
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