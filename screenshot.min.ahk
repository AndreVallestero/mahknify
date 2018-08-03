Windowshot(sOutput = "windowshot.png") {
	WinGet, activeWinId, ID, A
	SplitPath, sOutput,,, Extension
	if Extension not in BMP,DIB,RLE,GIF,TIF,TIFF,PNG
		return -1
	Extension := "." Extension
	hdcSource := DllCall("GetDC", "UInt",  activeWinId)
	hbmSource := DllCall("GetCurrentObject", "Ptr", hdcSource, "UInt", 7) ; OBJ_BITMAP = 7 in msdn
	hModule := DllCall("LoadLibrary", "Str", "gdiplus" )
	si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "Ptr*" , pToken, "Ptr", &si, "Ptr", 0)
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbmSource, "UInt", 0, "UInt*", pBitmap)
	DllCall("gdiplus\GdipGetImageEncodersSize", "UInt*", nCount, "UInt*", nSize)
	VarSetCapacity(ci, nSize)
	DllCall("gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "Ptr", &ci)
	Loop, %nCount% {
		sString := StrGet(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
		if !InStr(sString, "*" Extension)
			continue
		pCodec := &ci+idx
		break
	}
	DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Ptr", &sOutput, "Ptr", pCodec, "UInt", 0)
	DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
	DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
	DllCall("FreeLibrary", "Ptr", hModule)
	DllCall("DeleteObject", "UInt", hbmSource)
	DllCall("DeleteDC", "UInt", hdcSource)
}

Windowshot()