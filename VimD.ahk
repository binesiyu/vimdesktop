﻿#NoEnv
#SingleInstance, Force
#MaxHotkeysPerInterval 200

CoordMode, Tooltip, Screen
CoordMode, Mouse, Screen
CoordMode, Menu, Window
SetControlDelay, -1
SetKeyDelay, -1
; DetectHiddenWindows, On
FileEncoding, UTF-8
; SetTitleMatchMode, 2
SetTitleMatchMode, RegEx
SendMode, Input

Menu, Tray, Icon, %A_ScriptDir%\vimd.ico
if (A_IsCompiled){
    Menu, Tray, NoStandard
}
Menu, Tray, Add, 热键 &K, <VimDConfig_Keymap>
Menu, Tray, Add, 插件 &P, <VimDConfig_Plugin>
Menu, Tray, Add, 配置 &C, <VimDConfig_EditConfig>
Menu, Tray, Add,
Menu, Tray, Add, 禁用 &S, <Suspend>
Menu, Tray, Add, 重启 &R, <Reload>
Menu, Tray, Add, 退出 &X, <Exit>
Menu, Tray, Default, 热键 &K
Menu, Tray, Click, 1

VimdRun()
LoadConfigs("config.ini")
LoadGui()

return

#Include %A_ScriptDir%\core\Main.ahk
#Include %A_ScriptDir%\core\Renzo.ahk
#Include %A_ScriptDir%\core\Vim.ahk
#Include %A_ScriptDir%\core\VimDConfig.ahk
#Include %A_ScriptDir%\lib\EasyIni.ahk
#Include %A_ScriptDir%\lib\Acc.ahk
#Include %A_ScriptDir%\lib\GDIP.ahk
#Include %A_ScriptDir%\lib\Logger.ahk
#Include %A_ScriptDir%\plugins\Plugins.ahk
; 用户自定义配置
#Include *i %A_ScriptDir%\custom.ahk
