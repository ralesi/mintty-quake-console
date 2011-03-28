#NoEnv
#SingleInstance force
SendMode Input
DetectHiddenWindows, on

; get path to cygwin from registry
RegRead, cygwinRootDir, HKEY_LOCAL_MACHINE, SOFTWARE\Cygwin\setup, rootdir
cygwinBinDir := cygwinRootDir . "\bin"

; Read INI
iniFile := "mintty-quake-console.ini"
IniRead, minttyPath, %iniFile%, General, mintty_path, % cygwinBinDir . "\mintty.exe"
IniRead, minttyArgs, %iniFile%, General, mintty_args, -
IniRead, initialHeight, %iniFile%, General, initial_height, 380
IniRead, consoleHotkey, %iniFile%, General, hotkey, ^``
IfNotExist %iniFile%
{
	IniWrite, %minttyPath%, %iniFile%, General, mintty_path
	IniWrite, %minttyArgs%, %iniFile%, General, mintty_args
	IniWrite, %initialHeight%, %iniFile%, General, initial_height
	IniWrite, %consoleHotkey%, %iniFile%, General, hotkey
}

; path to mintty (same folder as script), start with default shell
; minttyPath := cygwinBinDir . "\mintty.exe -"
; minttyPath := cygwinBinDir . "\mintty.exe /bin/zsh -li"
minttyPath := minttyPath . " " . minttyArgs

; initial height of console window
heightConsoleWindow := initialHeight

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
		WinActivate ahk_pid %hw_mintty%
		Slide("ahk_pid" . hw_mintty, "In")
	}
}

Slide(Window, Dir)
{
	WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
	If (Dir = "In") And (Ypos < 0)
		WinShow %Window%
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
	If (Dir = "Out") And (Ypos <= (-WinHeight))
		WinHide %Window%
}

Hotkey, %consoleHotkey%, HotkeyLabel
; ^`::
HotkeyLabel:
IfWinExist ahk_pid %hw_mintty%
{
	toggle()
}
else
{
	init()
}
return
