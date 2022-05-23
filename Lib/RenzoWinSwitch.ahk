global winPathToIDMap
global debug
RenzoInit()
{
    global winPathToIDMap := new HashTable()
    ; global debug := False
    global debug := False
}

; 切换应用, 模拟 Manico
; 比较建议 3 个参数都填，这样可以确定 Pid 以唤起正确的窗口
; 参数 1：ahk_exe ProcessNameOrPath in WinTitle to identIfy a window belonging to any process with the given name or path.
; 参数 2：ahk_class ClassName in WinTitle to identIfy a window by its window class
; 参数 3：title regex：匹配正确的标题（\S 非空即可)
ToggleApp(exePath, openPath := "",titleClass := "", titleRegexToGetPID := "", recheck := True, activeTray := False)
{
    ; path, app.exe, app
    SplitPath, exePath, exeName, , , noExt

    ; --------------------------------------------------------------
    ; 进程名不存在，则运行 exePath（对多进程会失效）
    ; --------------------------------------------------------------
    If !checkProcessNameExist(exeName)
    {
        ; Run, %exePath%
        Run, %openPath%
        If titleClass
        {
            ; WinWait, ahk_class %titleClass%, , 1
            activeWinClass(exeName, titleClass, activeTray)
            ; WinActivate ahk_class %titleClass%
        }

        If debug {
            ShowText("Run " . openPath)
        }

        Return
    }

    ; --------------------------------------------------------------
    ; 是否需要重新确认窗口是否存在，不存在则运行 exePath
    ; --------------------------------------------------------------
    If titleClass AND recheck
    {
        WinGet windowCount, Count, ahk_class %titleClass%

        If debug {
            ShowText("windowCount = " . windowCount)
        }

        If (%windowCount% == 0)
        {
            ; Run, %exePath%
            Run, %openPath%

            If titleClass
            {
                ; WinWait, ahk_class %titleClass%, , 1
                activeWinClass(exeName, titleClass, activeTray)
                ; WinActivate ahk_class %titleClass%
            }

            Return
        }
    }

    ; --------------------------------------------------------------
    ; 若应用名对应的窗口为激活状态 (Active)，则需要隐藏
    ; --------------------------------------------------------------
    ; If WinActive("ahk_exe " . exeName)
    ; {
    ; If debug {
    ; ShowText("<" . exeName . "> is active, minimize now")
    ; }

    ; WinMinimize
    ; minimizeWin()
    ; Return
    ; }

    ; --------------------------------------------------------------
    ; 若应用名对应的窗口为未激活状态，则需要激活
    ; 可能会失败
    ; --------------------------------------------------------------
    If titleRegexToGetPID
    {
        ahkID := getMainProcessID(exeName, exePath, titleClass, titleRegexToGetPID)
        activeWinID(exeName, ahkID, activeTray)
        ; WinActivate, ahk_id %ahkID%
        If debug {
            ShowText("<" . exeName . " | pid = " . ahkID . "> not active, active now")
        }

        Return
    }

    If titleClass
    {
        ; WinActivate, ahk_class %titleClass%
        activeWinClass(exeName, titleClass, activeTray)
        If debug {
            ShowText("<" . exeName . " | class = " . titleClass . "> not active, active now")
        }

        Return
    }

    activeWinName(exeName, activeTray)
    ; WinActivate, ahk_exe %exeName%
    If debug {
        ShowText("<" . exeName . " | exe = " . exeName . "> not active, active now")
    }

    Return
}

; 判断进程是否存在（返回PID）
checkProcessNameExist(processName)
{
    Process, Exist, %processName% ; 比 IfWinExist 可靠
    Return ErrorLevel
}

; 获取类似 chrome 等多进程的主程序 ID
getMainProcessID(exeName,exePath, titleClass, titleRegexToGetPID := "")
{
    ; DetectSave := A_DetectHiddenWindows
    ; DetectHiddenWindows, Off
    ; DetectHiddenWindows, On
    ; 获取 exeName 的窗口列表，获取其 titleClass，并确认 title 匹配 titleRegexToGetPID
    WinGet, winList, List, ahk_exe %exeName%
    ; DetectHiddenWindows, %DetectSave%
    index := 0
    Array := "winList"
    ArrayCount := winList
    if (winList > 1)
    {
        ; Write to the array:
        ArrayCount := 0
        Array := "winListNew"
        Loop, % winList
        {
            ahkID := winList%A_Index%
            WinGet, State, MinMax, ahk_id %ahkID%
            if (State = -1)
            {
                Continue
            }
            ArrayIndex := 1
            Loop, % ArrayCount
            {
                ahkIDSave := %Array%%A_Index%
                if (ahkIDSave > ahkID)
                {
                    ArrayIndex := A_Index
                    break
                }
            }

            ArrayCount += 1 ; Keep track of how many items are in the array.
            Loop, % ArrayCount
            {
                if (A_Index <= ArrayIndex)
                {
                    Continue
                }

                localArrayIndex := A_Index - 1
                %Array%%A_Index% := %Array%%localArrayIndex% ; Store this line in the next array element.
            }
            %Array%%ArrayIndex% := ahkID ; Store this line in the next array element.

        }
    }

    if (ArrayCount > 1)
    {
        ; Sort,winList
        If winPathToIDMap.HasKey(exePath)
        {
            ahkIDSave := winPathToIDMap.Get(exePath)
            Loop, % ArrayCount
            {
                ahkID := %Array%%A_Index%
                if (ahkID = ahkIDSave)
                {
                    index := A_Index
                    break
                }
            }
        }
    }

    if (index >= ArrayCount)
    {
        index := 0
    }

    ; If debug {
    ;     ShowText("<" . exeName . " | index = " . index . "> index select")
    ; }
    Loop, % ArrayCount
    {
        if (A_Index <= index)
        {
            Continue
        }

        ahkID := %Array%%A_Index%

        WinGetClass, currentClass, ahk_id %ahkID%
        ; MsgBox,% A_Index . "/" . winList . "`n" . "currentClass = " .  currentClass . "`n" . "titleClass = " . titleClass
        ; 1/12：遍历至第几个
        ; 当前 class
        ; 目标 class
        If (currentClass ~= titleClass)
        {
            ; titleRegexToGetPID 为空，不需要判断标题
            If !StrLen(titleRegexToGetPID)
                Return ahkID

            ; 获取 Window 标题（字面含义）
            WinGetTitle, currentTitle, ahk_id %ahkID%
            ; MsgBox, %currentTitle%

            If (currentTitle ~= titleRegexToGetPID)
            {
                ; MsgBox, "titleLoop = " . %currentTitle%
                Return ahkID
            }
        }
    }

    Return False
}

; Window Active Helper Functions
activeWinClass(exeName, cls, activeTray)
{
    ; saveWindowToMap()
    If activeTray {
        TrayIcon_Button(exeName)
        Return
    }
    WinActivate ahk_class %cls%
    saveWindowToMap()
}

activeWinID(exeName, id, activeTray)
{
    If activeTray {
        TrayIcon_Button(exeName)
        Return
    }
    WinActivate, ahk_id %id%
    saveWindowToMap()
}

activeWinName(exeName, activeTray)
{
    If activeTray {
        TrayIcon_Button(exeName)
        Return
    }
    WinActivate, ahk_exe %exeName%
    saveWindowToMap()
}

minimizeWin()
{
    ; saveWindowToMap()
    WinMinimize
}

saveWindowToMap()
{
    ; 获取当前窗口 id, 保存到 map 用于下一次唤起时优先唤起
    WinGet, currentWinPath, ProcessPath, A
    WinGet, currentWinID,,A
    winPathToIDMap.Set(currentWinPath, currentWinID)
}

; 显示提示 t 秒并自动消失
ShowText(str, t := 1, ExitScript := 0, x := "", y := "")
{
    t *= 10000
    ToolTip, %str%, %x%, %y%
    SetTimer, removeTip, -%t%
    If ExitScript
    {
        Gui, Destroy
        Exit
    }
}

; 清除ToolTip
RemoveTip()
{
    ToolTip
}
