#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
ListLines Off
Process, Priority, , H
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
SetWorkingDir %A_ScriptDir%

magX := A_ScreenWidth / 4
magY := A_ScreenHeight / 4
magW := A_ScreenWidth / 2
magH := A_ScreenHeight / 2

srcX := 0
srcY := 0
srcW := 128
srcH := 128

zoom = 1.414213562	; Start at base zoom
isAntiAliasing := false
pStretchBlt :=  DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "gdi32", "Ptr"), "AStr", "StretchBlt", "Ptr")
pGetDC :=  DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32", "Ptr"), "AStr", "GetDC", "Ptr")
pSetStretchBltMode :=  DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "gdi32", "Ptr"), "AStr", "SetStretchBltMode", "Ptr")

; Create GUI to display 
Gui, +AlwaysOnTop -Resize +ToolWindow +E0x20 +AlwaysOnTop -Caption -border
Gui, Show, %  "x" magX " y" magY " w" magW " h" magH, Magnifier
WinGet, winMagId, Id, Magnifier				; Get window ID of magnification window
WinSet Transparent, 255, Magnifier 			; Allows the user to click through it
hdcMag := DllCall(pGetDC, "Ptr",  winMagId)	; Get device context handle of magnification window
Gui, Cancel

Home::
	isMagnifying := !isMagnifying
	if isMagnifying
		SetTimer, Magnify, -0
return

Magnify:
	WinGet, winSrcId, Id , A						; Get window ID of source
	hdcSource := DllCall(pGetDC, "Ptr", winSrcId)	; Get device contex handle of source
	UpdateZoom()
	Gui, Show, NA									; Show magnification window

	while isMagnifying {
		DllCall(pStretchBlt, "Ptr", hdcMag, "Int", 0, "Int", 0, "int", magW, "Int", magH, "Ptr", hdcSource, "Int", srcX, "Int", srcY, "Int", srcW, "Int", srcH, "UInt", 0x00CC0020)
		Sleep, 1	; Sleep minimum amount without stalling the system
	}	
	Gui, Cancel
return 

+WheelUp::					; Shift+WheelUp to zoom in
	if (zoom < 31.9) {		; Anti Aliasing (halftone) has inconsistent results past 16 x	
		zoom *= 1.414213562 ; Multiply zoom by sqrt(2)
		UpdateZoom()
	}
return 
	
+WheelDown::				; Shift+WheelUp to zoom out
	if (zoom > 1.01) {
		zoom /= 1.414213562	; Divide zoom by sqrt(2)
		UpdateZoom()
	}
return 

+*Home::
	isAntiAliasing := !isAntiAliasing
	if isAntiAliasing
		DllCall(pSetStretchBltMode, "Ptr", hdcMag, "Int", 4)
	else
		DllCall(pSetStretchBltMode, "Ptr", hdcMag, "Int", 0)
return

+*End:: 
GuiClose:
	DllCall("DeleteDC", "Ptr", hdcMag)
	TrayTip, Mahknify, Successfully Closed
	ExitApp
return

UpdateZoom() {
	global
	MouseGetPos, mouseX, mouseY
	WinGetPos, , ,winW, winH, A
	srcW := A_ScreenWidth / zoom
	srcH := A_ScreenHeight / zoom
	srcX := mouseX - srcW / 2
	
	if srcX < 0
		srcX = 0
	else if (srcX + srcW > winW)
		srcX := winW - srcW
		
	srcY := mouseY - srcH / 2
	if srcY < 0
		srcY = 0
	else if (srcY + srcH > winH)
		srcY := winH - srcH
}
