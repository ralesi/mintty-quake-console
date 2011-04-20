; Mintty quake console: Visor-like functionality for Windows
; Version: 1.1
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
VERSION := 1.1
iniFile := "mintty-quake-console.ini"
IniRead, minttyPath, %iniFile%, General, mintty_path, % cygwinBinDir . "\mintty.exe"
IniRead, minttyArgs, %iniFile%, General, mintty_args, -
IniRead, consoleHotkey, %iniFile%, General, hotkey, ^``
IniRead, startWithWindows, %iniFile%, Display, start_with_windows, 0
IniRead, startHidden, %iniFile%, Display, start_hidden, 1
IniRead, initialHeight, %iniFile%, Display, initial_height, 380
IniRead, pinned, %iniFile%, Display, pinned_by_default, 1
IniRead, animationStep, %iniFile%, Display, animation_step, 20
IniRead, animationTimeout, %iniFile%, Display, animation_timeout, 10
IfNotExist %iniFile%
{
	SaveSettings()
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
Menu, Tray, Add, Pinned, TogglePinned
if (pinned)
	Menu, Tray, Check, Pinned
Menu, Tray, Add
Menu, Tray, Add, Options, ShowOptionsGui
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
	global animationStep, animationTimeout, pinned
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
	If (Dir = "In") And (Ypos >= 0) {
		WinMove, %Window%,,, 0 
		if (!pinned)
			SetTimer, HideWhenInactive, 250
	}
	If (Dir = "Out") And (Ypos <= (-WinHeight)) {
		WinHide %Window%
		if (!pinned)
			SetTimer, HideWhenInactive, Off
	}
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
		
		if (state = "init" and initCount = 1 and startHidden) {
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

HideWhenInactive:
	IfWinNotActive ahk_pid %hw_mintty%
	{
		Slide("ahk_pid" . hw_mintty, "Out")
		SetTimer, HideWhenInactive, Off
	}
return

ToggleScriptState:
	if(scriptEnabled)
		toggleScript("off")
	else
		toggleScript("on")
return

TogglePinned:
	pinned := !pinned
	Menu, Tray, ToggleCheck, Pinned
	SetTimer, HideWhenInactive, Off
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

ShowOptionsGui:
	OptionsGui()
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

;*******************************************************************************
;				Options					
;*******************************************************************************
SaveSettings() {
	global
	IniWrite, %minttyPath%, %iniFile%, General, mintty_path
	IniWrite, %minttyArgs%, %iniFile%, General, mintty_args	
	IniWrite, %consoleHotkey%, %iniFile%, General, hotkey
	IniWrite, %startWithWindows%, %iniFile%, Display, start_with_windows
	IniWrite, %startHidden%, %iniFile%, Display, start_hidden
	IniWrite, %initialHeight%, %iniFile%, Display, initial_height
	IniWrite, %pinned%, %iniFile%, Display, pinned_by_default
	IniWrite, %animationStep%, %inifile%, Display, animation_step
	IniWrite, %animationTimeout%, %iniFile%, Display, animation_timeout
	CheckWindowsStartup(startWithWindows)
}

CheckWindowsStartup(enable) {
	SplitPath, A_ScriptName, , , , OutNameNoExt
	LinkFile=%A_Startup%\%OutNameNoExt%.lnk

	if !FileExist(LinkFile) {
		if (enable) {
			FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%
		}
	}
	else {
		if(!enable) {
			FileDelete, %LinkFile%
		}
	}
}

OptionsGui() {
	global
	; Gui, Destroy
	If not WinExist("ahk_id" GuiID) {
	Gui, Add, GroupBox, x12 y10 w450 h110 , General
	Gui, Add, GroupBox, x12 y130 w450 h180 , Display
	Gui, Add, Button, x242 y360 w100 h30 Default, Save
	Gui, Add, Button, x362 y360 w100 h30 , Cancel
	Gui, Add, Text, x22 y30 w70 h20 , Mintty Path:
	Gui, Add, Edit, x92 y30 w250 h20 VminttyPath, %minttyPath%
	Gui, Add, Button, x352 y30 w100 h20, Browse
	Gui, Add, Text, x22 y60 w100 h20 , Mintty Arguments:
	Gui, Add, Edit, x122 y60 w330 h20 VminttyArgs, %minttyArgs%
	Gui, Add, Text, x22 y90 w100 h20 , Hotkey Trigger:
	Gui, Add, Hotkey, x122 y90 w100 h20 VconsoleHotkey, %consoleHotkey%
	Gui, Add, CheckBox, x22 y150 w100 h30 VstartHidden Checked%startHidden%, Start Hidden
	Gui, Add, CheckBox, x22 y180 w100 h30 Vpinned Checked%pinned%, Pinned
	Gui, Add, CheckBox, x22 y210 w120 h30 VstartWithWindows Checked%startWithWindows%, Start With Windows
	Gui, Add, Text, x22 y250 w100 h20 , Initial Height (px):
	Gui, Add, Edit, x22 y270 w100 h20 VinitialHeight, %initialHeight%
	Gui, Add, Text, x232 y170 w220 h20 , Animation Delta (px):
	Gui, Add, Text, x232 y220 w220 h20 , Animation Time (ms):
	Gui, Add, Slider, x232 y190 w220 h30 VanimationStep Range5-50, %animationStep%
	Gui, Add, Slider, x232 y240 w220 h30 VanimationTimeout Range5-50, %animationTimeout%
	Gui, Add, Text, x232 y280 w220 h20 +Center, Animation Speed = Delta / Time
	}
	; Generated using SmartGUI Creator 4.0
	Gui, Show, h410 w482, TerminalHUD Options
	Gui, +LastFound
	GuiID := WinExist()
	
	Loop {
		;sleep to reduce CPU load
        Sleep, 100 

        ;exit endless loop, when settings GUI closes 
        If not WinExist("ahk_id" GuiID) 
            Break 
	}

	ButtonSave:
		Gui, Submit
		SaveSettings()
		; Gui, Destroy
	return
	
	ButtonBrowse:
		FileSelectFile, SelectedPath, 3, %A_MyDocuments%, Path to mintty.exe, Executables (*.exe)
		if SelectedPath != 
			GuiControl,, MinttyPath, %SelectedPath%
	return
	
	GuiClose:
	GuiEscape:
	ButtonCancel:
		; Gui, Destroy
		Gui, Cancel
	return
}
