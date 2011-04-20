# mintty-quake-console

A little [AutoHotkey](http://www.autohotkey.com/) script that enables a quake-style (like [Visor](http://visor.binaryage.com/) for osx) console for [mintty](http://code.google.com/p/mintty/)

## Requirements
1. [Cygwin](http://www.cygwin.com/)
2. [mintty](http://code.google.com/p/mintty/) (installed through Cygwin)

## Usage
download and run **mintty-quake-console.exe**  
**NEW** right click icon in system tray -> options
press **ctrk + ~** (or configured keybinding) to toggle console  

note: after changing the ini file, reload the script by right-clicking the tray icon and selecting **Reload**

## Ini/Option Reference
**mintty_path** = path to mintty.exe  
**mintty_args** = arguments to pass to mintty.exe  
**hotkey** = key combination to show/hide console

**start_with_windows** = add this script to Windows startup (1) or disable (0)
**start_hidden** = show mintty.exe when script is started (0) or wait for hotkey (1)  
**initial_height** = height (in pixels) of the mintty console  
**pinned_by_default** = set to 0 to automatically hide mintty when it loses focus
**animation_step** = number of pixels to shift each step of the slide animation  
**animation_timeout** = how long (in ms) to wait between each animation_step

## Tips
See <http://www.autohotkey.com/docs/Hotkeys.htm> and <http://www.autohotkey.com/docs/KeyList.htm> for Autohotkey reference.

Use **Ctrl+Alt+Numpad(+/-)** to increase or decrease the console height

To use ZSH instead of BASH, set the following in mintty-quake-console.ini (zsh must be installed through cygwin):

	mintty_args="/bin/zsh -li"

## TO DO
* add gui for configuring options **(done)**
* add support for putty and/or console2
