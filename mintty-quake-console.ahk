; Mintty quake console: Visor-like functionality for Windows
; Version: 1.0
; Author: Jon Rogers (lonepie@gmail.com)
; URL: https://github.com/lonepie/mintty-quake-console
; Credits:
;	Originally forked from: https://github.com/marcharding/mintty-quake-console
;	mintty: http://code.google.com/p/mintty/
;	Visor: http://visor.binaryage.com/

;*******************************************************************************
;				Settings					
;*******************************************************************************
#NoEnv
#SingleInstance force
SendMode Input
DetectHiddenWindows, on
SetWinDelay, -1

; get path to cygwin from registry
RegRead, cygwinRootDir, HKEY_LOCAL_MACHINE, SOFTWARE\Cygwin\setup, rootdir
cygwinBinDir := cygwinRootDir . "\bin"

;*******************************************************************************
;				Preferences & Variables
;*******************************************************************************
VERSION := 1.0
iniFile := "mintty-quake-console.ini"
IniRead, minttyPath, %iniFile%, General, mintty_path, % cygwinBinDir . "\mintty.exe"
IniRead, minttyArgs, %iniFile%, General, mintty_args, -
IniRead, consoleHotkey, %iniFile%, General, hotkey, ^``
IniRead, startHidden, %iniFile%, Display, start_hidden, True
IniRead, initialHeight, %iniFile%, Display, initial_height, 380
IniRead, animationStep, %iniFile%, Display, animation_step, 20
IniRead, animationTimeout, %iniFile%, Display, animation_timeout, 10
IfNotExist %iniFile%
{
	IniWrite, %minttyPath%, %iniFile%, General, mintty_path
	IniWrite, %minttyArgs%, %iniFile%, General, mintty_args	
	IniWrite, %consoleHotkey%, %iniFile%, General, hotkey
	IniWrite, %startHidden%, %iniFile%, Display, start_hidden
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

;*******************************************************************************
;				Hotkeys						
;*******************************************************************************
Hotkey, %consoleHotkey%, ConsoleHotkey

;*******************************************************************************
;				GUI						
;*******************************************************************************
Menu, Tray, NoStandard
; Menu, Tray, MainWindow
Menu, Tray, Tip, mintty-quake-console %VERSION%
Menu, Tray, Add, Enabled, ToggleScriptState
Menu, Tray, Check, Enabled
Menu, Tray, Add
Menu, Tray, Add, About, AboutDlg
Menu, Tray, Add, Reload, ReloadSub
Menu, Tray, Add, Exit, ExitSub

init()
return
;*******************************************************************************
;				Functions / Labels						
;*******************************************************************************
init()
{
	global
	initCount++
	; get last active window
	WinGet, hw_current, ID, A
	if !WinExist("ahk_class mintty") {
		Run %minttyPath%, %cygwinBinDir%, Hide, hw_mintty
		WinWait ahk_pid %hw_mintty%
	}
	else {
		WinGet, hw_mintty, PID, ahk_class mintty
	}
	
	WinGetPos, OrigXpos, OrigYpos, OrigWinWidth, OrigWinHeight, ahk_pid %hw_mintty%
	toggleScript("init")
}

toggle()
{
	global

	IfWinActive ahk_pid %hw_mintty%
	{
		Slide("ahk_pid" . hw_mintty, "Out")
		; reset focus to last active window
		WinActivate, ahk_id %hw_current%
	}
	else
	{
		; get last active window
		WinGet, hw_current, ID, A

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
	If (Xpos != 0)
		WinMove, %Window%,,0
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

toggleScript(state) {
	; enable/disable script effects, hotkeys, etc
	global
	; WinGetPos, Xpos, Ypos, WinWidth, WinHeight, ahk_pid %hw_mintty%
	if(state = "on" or state = "init") {
		If !WinExist("ahk_pid" . hw_mintty) {
			init()
			return
		}
		WinHide ahk_pid %hw_mintty%
		WinSet, Style, -0xC00000, ahk_pid %hw_mintty% ; hide caption/title
		WinSet, Style, -0x40000, ahk_pid %hw_mintty% ; hide thick border
		; WinGetPos, Xpos, Ypos, WinWidth, WinHeight, ahk_pid %hw_mintty%
		if (OrigYpos >= 0 or OrigWinWidth < A_ScreenWidth)
				WinMove, ahk_pid %hw_mintty%, , 0, -%heightConsoleWindow%, A_ScreenWidth, %heightConsoleWindow% ; resize/move
		
		scriptEnabled := True
		Menu, Tray, Check, Enabled
		
		if (state = "init" and initCount = 1 and %startHidden%) {
			return
		}
		
		WinShow ahk_pid %hw_mintty%
		WinActivate ahk_pid %hw_mintty%
		Slide("ahk_pid" . hw_mintty, "In")
	}
	else if (state = "off") {
		WinSet, Style, +0xC00000, ahk_pid %hw_mintty% ; show caption/title
		WinSet, Style, +0x40000, ahk_pid %hw_mintty% ; show thick border
		if (OrigYpos >= 0)
			WinMove, ahk_pid %hw_mintty%, , %OrigXpos%, %OrigYpos%, %OrigWinWidth%, %OrigWinHeight% ; restore size / position
		else
			WinMove, ahk_pid %hw_mintty%, , %OrigXpos%, 100, %OrigWinWidth%, %OrigWinHeight%
		WinShow, ahk_pid %hw_mintty% ; show window
		scriptEnabled := False
		Menu, Tray, Uncheck, Enabled
	}
}

ToggleScriptState:
	if(scriptEnabled)
		toggleScript("off")
	else
		toggleScript("on")
return

ConsoleHotkey:
	If (scriptEnabled) {
		IfWinExist ahk_pid %hw_mintty%
		{
			toggle()
		}
		else
		{
			init()
		}
	}
return

ExitSub:
	if A_ExitReason not in Logoff,Shutdown
	{
		MsgBox, 4, , Are you sure you want to exit?
		IfMsgBox, No
			return
		toggleScript("off")
	}
ExitApp

ReloadSub:
Reload
return

AboutDlg:
	MsgBox, 64, About, mintty-quake-console AutoHotkey script`nVersion: %VERSION%`nAuthor: Jonathon Rogers <lonepie@gmail.com>`nURL: https://github.com/lonepie/mintty-quake-console
return

;*******************************************************************************
;				Extra Hotkeys						
;*******************************************************************************
#IfWinActive ahk_class mintty
; why this method doesn't work, I don't know...
; Hotkey, IfWinActive, ahk_pid %hw_mintty%
; Hotkey, ^!NumpadAdd, IncreaseHeight
; Hotkey, ^!NumpadSub, DecreaseHeight
; IncreaseHeight:
^!NumpadAdd::
	if(WinActive("ahk_pid" . hw_mintty)) {
		if(heightConsoleWindow < A_ScreenHeight) {
			heightConsoleWindow += animationStep
			WinMove, ahk_pid %hw_mintty%,,,,, heightConsoleWindow
		}
	}
return
; DecreaseHeight:
^!NumpadSub::
	if(WinActive("ahk_pid" . hw_mintty)) {
		if(heightConsoleWindow > 100) {
			heightConsoleWindow -= animationStep
			WinMove, ahk_pid %hw_mintty%,,,,, heightConsoleWindow
		}
	}
return
#IfWinActive
