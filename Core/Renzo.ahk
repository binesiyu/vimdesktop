; 键位映射 By Renzo —— 2021.7.11

; ----------------------------- Libs -----------------------------------
; https://github.com/Shambles-Dev/AutoHotkey-HashTable
#Include %A_ScriptDir%\Lib\HashTable.ahk
#include %A_ScriptDir%\Lib\TrayIcon.ahk
#Include %A_ScriptDir%\Lib\RenzoWinSwitch.ahk
#Include %A_ScriptDir%\Lib\RenzoFunc.ahk
; -----------------------------------------------------------------------
#Include %A_ScriptDir%\Lib\RenzoGui.ahk

; -----------------------------------------------------------------------

LoadConfigs(configFile) {
  ;------------------------------------------------------
  IniRead, appListStr, config.ini, WinSwitch, AppList
  StringSplit apps, appListStr, `,
  Loop %apps0% {
    appName := apps%A_Index%
    IniRead, hotKey, config.ini, %appName%, HotKey
    IniRead, exePath, config.ini, %appName%, ExePath
    IniRead, openPath, config.ini, %appName%, OpenPath
    IniRead, titleClass, config.ini, %appName%, TitleClass
    IniRead, titleRegexToGetPID, config.ini, %appName%, TitleRegex
    IniRead, recheck, config.ini, %appName%, Recheck
    IniRead, activeTray, config.ini, %appName%, ActiveTray

    If titleClass = ERROR
    {
      titleClass := ""
    }

    If openPath = ERROR
    {
      openPath := exePath
    }

    If titleRegexToGetPID = ERROR
    {
      titleRegexToGetPID := ""
    }

    If recheck = ERROR
    {
      recheck := True
    }
    Else
    {
      recheck := False
    }

    If activeTray = ERROR
    {
      activeTray := False
    }
    Else
    {
      activeTray := True
    }

    HotKey(hotKey, "ToggleApp", exePath, openPath,titleClass, titleRegexToGetPID, recheck, activeTray)
  }
}

LoadGui() {
  Gui 1:Default
  Gui 1:New, +Hwndswitchgui
  Gui 1:Font, S12 cNavy, Microsoft YaHei
  Gui 1:Add, ListView, xm r20 w1000 gMyListView AltSubmit, Title|App|Pid
}
