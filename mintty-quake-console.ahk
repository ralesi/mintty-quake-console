#NoEnv
#SingleInstance force
SendMode Input
DetectHiddenWindows, on

; get path to cygwin from registry
RegRead, cygwinRootDir, HKEY_LOCAL_MACHINE, SOFTWARE\Cygwin\setup, rootdir
cygwinBinDir := cygwinRootDir . "\bin"

; path to mintty (same folder as script), start with default shell
; minttyPath := cygwinBinDir . "\mintty.exe -"
minttyPath := cygwinBinDir . "\mintty.exe /bin/zsh -li"

; initial height of console window
heightConsoleWindow := 380

init()
{
	global
	; get last active window
	WinGet, hw_current, ID, A
	if !WinExist("ahk_class mintty") {
		Run %minttyPath%, %cygwinBinDir%, Hide, hw_mintty
		WinWait ahk_pid %hw_mintty%
	}
	else {
		WinGet, hw_mintty, PID, ahk_class mintty
	}
	WinGetPos, Xpos, Ypos, WinWidth, WinHeight, ahk_pid %hw_mintty%
	; OutputDebug, init... pid = %hw_mintty%
	if (Ypos >= 0) {
		WinHide ahk_pid %hw_mintty%
		WinSet, Style, -0xC00000, ahk_pid %hw_mintty% ; hide caption/title
		WinSet, Style, -0x40000, ahk_pid %hw_mintty% ; hide thick border
		WinMove, ahk_pid %hw_mintty%, , 0, -%heightConsoleWindow%, A_ScreenWidth, %heightConsoleWindow% ; resize/move
		WinShow ahk_pid %hw_mintty%
		WinActivate ahk_pid %hw_mintty%
	}
	else {
		WinShow ahk_pid %hw_mintty%
		WinActivate ahk_pid %hw_mintty%
		Slide("ahk_pid" . hw_mintty, "In")
	}
}

toggle()
{
	global

	IfWinActive ahk_pid %hw_mintty%
	{
		; get latest size^, remembers size when toggeling
		; WinGetPos, minttyX, minttyY, minttyWidth, minttyLastHeight, ahk_pid %hw_mintty%
		; WinHide ahk_pid %hw_mintty%
		; FadeOut()
		Slide("ahk_pid" . hw_mintty, "Out")
		; reset focus to last active window
		WinActivate, ahk_id %hw_current%
	}
	else
	{
		; get last active window
		WinGet, hw_current, ID, A
		; WinMove, ahk_pid %hw_mintty%, , -%dragableBorderWith%, -%menubarHeight%, A_ScreenWidth + ( %dragableBorderWith% * 2 ), %minttyLastHeight%
		; WinShow ahk_pid %hw_mintty%
		; FadeIn()
		WinActivate ahk_pid %hw_mintty%
		Slide("ahk_pid" . hw_mintty, "In")
	}
}

/*
SlideDown()
{
	global hw_mintty
	; move window y coord back toward 0
	WinGetPos, X, Y, width, height, ahk_pid %hw_mintty%
	OutputDebug, slidedown start y = %Y%
	while (Y < 0)
	{
		; Y++
		Y := Round((Y + 1) / 2)
		OutputDebug, slidedown loop y = %Y%
		WinMove, ahk_pid %hw_mintty%, , 0, Y
		; Sleep 1
	}
}

SlideUp()
{
	global hw_mintty
	; move window y coord toward -heightConsoleWindow
	WinGetPos, X, Y, width, height, ahk_pid %hw_mintty%
	OutputDebug, slideup start y = %Y%
	; Loop 15
	while (Y >= -height)
	{
		; Y--
		Y := (Y - 1) * 2
		OutputDebug, slideup loop y = %Y%
		WinMove, ahk_pid %hw_mintty%, , 0, Y
		; Sleep 1
		; WinGetPos, , Y, , , ahk_pid %hw_mintty%
	}
}
*/

; Slide(Window, Dir, Rate=10, Speed=1)
Slide(Window, Dir)
{
	WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
	Loop
	{
	  If (Dir = "In") And (Ypos >= 0) Or (Dir = "Out") And (Ypos <= (-WinHeight))
		 Break
	  
	  ; dY := % (Dir = "In") ? A_Index*Rate - WinHeight : (-A_Index)*Rate
	  ; dY := % (Dir = "In") ? Ypos + Rate : Ypos - Rate
	  dRate := WinHeight // 4
	  dY := % (Dir = "In") ? Ypos + dRate : Ypos - dRate
	  ; OutputDebug, dY=%dY%
	  WinMove, %Window%,,, dY
	  WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
	  ; Sleep, %Speed%
	}
	If (Dir = "In") And (Ypos >= 0) 
	  WinMove, %Window%,,, 0 
}
/*
Slide(Win, Dir, Rate=4, Sleep=5) ; Thanks Infogulch for the idea behind this.
{
	WinGetPos, X, Y, width, height, %Win%
	Loop % height/Rate
	{
		WinMove, %Win%,,, % (Dir = "In") ? A_Index*Rate - height : (-A_Index)*Rate
		Sleep, %Sleep%
	}	
	WinMove, %Win%,,, % (Dir = "In") ? 0 : Pos
}
FadeIn(Speed="1")
{
   global
   ; DetectHiddenWindows, On
   ; WinGet, is_transparent, Transparent, ahk_pid %hw_mintty%
   if(!is_visible) {
	   WinSet, Transparent, 0, ahk_pid %hw_mintty%
	   WinShow, ahk_pid %hw_mintty%
	   Loop 15
	   {
		  Sleep %Speed%
		  WinSet, Transparent, % A_Index * 17, ahk_pid %hw_mintty%
	   }
	   is_visible := true
   }
   Return
}

FadeOut(Speed="1")
{
   global
   WinGet, Trans, Transparent, ahk_pid %hw_mintty%
   If Not Trans {
      WinHide, ahk_pid %hw_mintty%
      WinSet, Transparent, 0, ahk_pid %hw_mintty%
      Return
   }
   Loop 15
   {
      WinSet, Transparent, % 255 - A_Index * 17, ahk_pid %hw_mintty%
      Sleep %Speed%
   }
   WinHide, ahk_pid %hw_mintty%
   is_visible := false
   Return
}
*/
/*
SlideFade(Window, Dir, FromAlpha=255, ToAlpha=30, Rate=2, Sleep=1)
{
   WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%,
   Variance:= FromAlpha-ToAlpha
   Alphanow:= (Ypos >= 0 ) ? FromAlpha : ToAlpha
   IncrementAlpha:= Variance//(WinHeight//Rate)
   Loop
   {
      IF (Dir = "In") And (Ypos >= 0) Or (Dir = "Out") And (Ypos <= (-WinHeight))
         Break
      
      AlphaNow := (Dir = "In") ? AlphaNow+IncrementAlpha : AlphaNow-IncrementAlpha
      WinSet, Transparent, %AlphaNow%, %Window%
      WinMove, %Window%,,, % (Dir = "In") ? Ypos + Rate : Ypos - Rate
      WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
      Sleep, %Sleep%
   }
   If (Dir = "In") And (Ypos >= 0) 
      WinMove, %Window%,,, 0      
   IF (Dir = "In") And (Ypos >= 0)
      WinSet, Transparent, %FromAlpha%, %Window%
}
*/
; #Escape::
^`::
IfWinExist ahk_pid %hw_mintty%
{
	toggle()
}
else
{
	init()
}
return
