#NoEnv
#SingleInstance force
SendMode Input
DetectHiddenWindows, on
SetWinDelay, 0

; get path to cygwin from registry
RegRead, cygwinRootDir, HKEY_LOCAL_MACHINE, SOFTWARE\Cygwin\setup, rootdir
cygwinBinDir := cygwinRootDir . "\bin"

; Read INI
iniFile := "mintty-quake-console.ini"
IniRead, minttyPath, %iniFile%, General, mintty_path, % cygwinBinDir . "\mintty.exe"
IniRead, minttyArgs, %iniFile%, General, mintty_args, -
IniRead, consoleHotkey, %iniFile%, General, hotkey, ^``
IniRead, initialHeight, %iniFile%, Display, initial_height, 380
IniRead, animationStep, %iniFile%, Display, animation_step, 20
IniRead, animationTimeout, %iniFile%, Display, animation_timeout, 10
IfNotExist %iniFile%
{
	IniWrite, %minttyPath%, %iniFile%, General, mintty_path
	IniWrite, %minttyArgs%, %iniFile%, General, mintty_args	
	IniWrite, %consoleHotkey%, %iniFile%, General, hotkey
	IniWrite, %initialHeight%, %iniFile%, Display, initial_height
	IniWrite, %animationStep%, %inifile%, Display, animation_step
	IniWrite, %animationTimeout%, %iniFile%, Display, animation_timeout
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
	global animationStep, animationTimeout
	WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
	If (Dir = "In") And (Ypos < 0)
		WinShow %Window%
	Loop
	{
	  If (Dir = "In") And (Ypos >= 0) Or (Dir = "Out") And (Ypos <= (-WinHeight))
		 Break
	  
	  ; dRate := WinHeight // 4
	  dRate := animationStep
	  ; dY := % (Dir = "In") ? A_Index*dRate - WinHeight : (-A_Index)*dRate
	  dY := % (Dir = "In") ? Ypos + dRate : Ypos - dRate
	  WinMove, %Window%,,, dY
	  WinGetPos, Xpos, Ypos, WinWidth, WinHeight, %Window%
	  Sleep, %animationTimeout%
	}
	If (Dir = "In") And (Ypos >= 0) 
	  WinMove, %Window%,,, 0 
	If (Dir = "Out") And (Ypos <= (-WinHeight))
		WinHide %Window%
}

Hotkey, %consoleHotkey%, ConsoleHotkey
; ^`::
ConsoleHotkey:
IfWinExist ahk_pid %hw_mintty%
{
	toggle()
}
else
{
	init()
}
return

#IfWinActive ahk_class mintty
; why this method doesn't work, I don't know...
; Hotkey, IfWinActive, ahk_pid %hw_mintty%
; Hotkey, ^!NumpadAdd, IncreaseHeight
; Hotkey, ^!NumpadSub, DecreaseHeight
; IncreaseHeight:
^!NumpadAdd::
	heightConsoleWindow += 10
	WinMove, ahk_pid %hw_mintty%,,,,, heightConsoleWindow
return
; DecreaseHeight:
^!NumpadSub::
	heightConsoleWindow -= 10
	WinMove, ahk_pid %hw_mintty%,,,,, heightConsoleWindow
return
#IfWinActive
