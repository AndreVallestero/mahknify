; "A" = active window
; "" = screen
scrot(posX, posY, width, height, sOutput = "scrot.bmp", windowTitle = "A") {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
	WinGet, winId, ID, %windowTitle%
    hdc_frame := DllCall( "GetDC", "UInt",  winId )
    hdc_buffer := DllCall( "gdi32.dll\CreateCompatibleDC", "UInt", hdc_frame )
    hbm_buffer := DllCall( "gdi32.dll\CreateCompatibleBitmap", "UInt", hdc_frame, "Int", width, "Int", height )
    DllCall( "gdi32.dll\SelectObject", "UInt", hdc_buffer, "UInt", hbm_buffer )
    DllCall( "gdi32.dll\BitBlt", "UInt", hdc_buffer, "Int", 0, "Int", 0, "Int", width, "Int", height, "UInt", hdc_frame,  "Int", posX, "Int", posY, "UInt", 0x00CC0020 )
    if !DllCall("GetModuleHandle", "Str", "gdiplus", Ptr)
        DllCall( "LoadLibrary", "Str", "gdiplus")
    VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
    DllCall( "gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "UInt*", pToken, Ptr, &si, Ptr, 0)
    DllCall( "gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hbm_buffer, "UInt", 0, "UInt*", pBitmap )
    DllCall( "gdiplus\GdipGetImageEncodersSize", "UInt*", nCount, "UInt*", nSize)
    VarSetCapacity(ci, nSize)
    DllCall( "gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, Ptr, &ci)
    StrGet_Name := "StrGet"
    Loop, %nCount% {
        sString := %StrGet_Name%(NumGet(ci, (idx := (48+7*A_PtrSize)*(A_Index-1))+32+3*A_PtrSize), "UTF-16")
        if !InStr(sString, "*.bmp")
            continue
        pCodec := &ci+idx
        break
    }
    DllCall( "gdiplus\GdipSaveImageToFile", Ptr, pBitmap, Ptr, &sOutput, Ptr, pCodec, "UInt", p ? p : 0)
    DllCall( "gdiplus\GdipDisposeImage", Ptr, pBitmap)
    DllCall( "gdiplus\GdiplusShutdown", Ptr, pToken)
    if hModule := DllCall("GetModuleHandle", "Str", "gdiplus", Ptr)
        DllCall( "FreeLibrary", Ptr, hModule)
    DllCall( "gdi32.dll\DeleteObject", "UInt", hbm_buffer )
    DllCall( "gdi32.dll\DeleteDC", "UInt", hdc_frame )
    DllCall( "gdi32.dll\DeleteDC", "UInt", hdc_buffer )
}