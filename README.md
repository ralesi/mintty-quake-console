# mintty-quake-console

A little [AutoHotkey](http://www.autohotkey.com/) script that enables a quake-style (like [Visor](http://visor.binaryage.com/) for osx) console for [mintty](http://code.google.com/p/mintty/)

## Requirements
1. [Cygwin](http://www.cygwin.com/)
2. [mintty](http://code.google.com/p/mintty/) (installed through Cygwin)
3. *optional* [AutoHotkey](http://www.autohotkey.com/)

## Usage
download and run **mintty-quake-console.exe**  
edit **mintty-quake-console.ini** to specify custom configuration (automatically generated if it doesn't exist)  
press **ctrk + ~** (or configured keybinding) to toggle console  

## Ini/Option Reference
**mintty_path** = path to mintty.exe  
**mintty_args** = arguments to pass to mintty.exe  
**hotkey** = key combination to show/hide console

**start_hidden** = show mintty.exe when script is started (False) or wait for hotkey (True)  
**initial_height** = height (in pixels) of the mintty console  
**animation_step** = number of pixels to shift each step of the slide animation  
**animation_timeout** = how long (in ms) to wait between each animation_step

## Tips
See <http://www.autohotkey.com/docs/Hotkeys.htm> and <http://www.autohotkey.com/docs/KeyList.htm> for Autohotkey reference.

To use ZSH instead of BASH, set the following in mintty-quake-console.ini (zsh must be installed through cygwin):

	mintty_args="/bin/zsh -li"
