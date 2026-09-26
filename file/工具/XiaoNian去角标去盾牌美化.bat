@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
title XiaoNian Delete
REM ======== UAC 提权 ========
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto gotAdmin)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" (del "%temp%\getadmin.vbs")
pushd "%CD%"
CD /D "%~dp0"

cls
echo.
echo          ===========================================================
echo.
echo.
echo                  ███╗    ██╗  ██╗   █████╗   ███╗    ██╗
echo                  ████╗   ██║  ██║  ██╔══██╗  ████╗   ██║
echo                  ██╔██╗  ██║  ██║  ███████║  ██╔██╗  ██║
echo                  ██║╚██╗ ██║  ██║  ██╔══██║  ██║╚██╗ ██║
echo                  ██║  ╚████║  ██║  ██║  ██║  ██║  ╚████║
echo                  ╚═╝   ╚═══╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝   ╚═══╝
echo                              小念去角标美化工具 v1.0
echo.
echo          ===========================================================
echo.
echo.
echo                              正在加载，请稍候 ...
echo.
echo.

REM ======== 进度条 ========
REM ESC (ASCII 27) - ANSI: ESC[2K 清整行, ESC[G 回行首
for /F "delims=#" %%a in ('"prompt #$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%a"
REM CR (ASCII 13) - ESC 生成失败时的降级方案
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"
if defined ESC (set "HOME=%ESC%[2K%ESC%[G") else (set "HOME=%CR%")

REM 1ms 延时脚本（主要延时来自 cscript 进程开销）
> "%temp%\sleep_step.vbs" echo WScript.Sleep 1

REM 视觉宽度 40 格 / 实际 20 步：每步填充 2 格，长度与速度兼顾
for /L %%i in (0,1,20) do (
    set "bar="
    set "remain="
    set /a "percent=%%i*100/20"
    set /a "filled=%%i*2"
    set /a "rest=40-!filled!"
    for /L %%k in (1,1,!filled!) do set "bar=!bar!█"
    for /L %%m in (1,1,!rest!) do set "remain=!remain!─"
    <nul set /p "=!HOME!                [!bar!!remain!] !percent!%%   "
    cscript //nologo "%temp%\sleep_step.vbs" >nul
)
del /f "%temp%\sleep_step.vbs" >nul 2>&1

echo.
echo.
echo                  [100%%] 加载完成，正在进入 ...
REM 100% 定格 450ms，随后自动进入第二屏
> "%temp%\sleep_end.vbs" echo WScript.Sleep 450
cscript //nologo "%temp%\sleep_end.vbs" >nul
del /f "%temp%\sleep_end.vbs" >nul 2>&1


REM ======== 欢迎页 ========
cls
echo.
echo    ==========================
echo      欢迎使用小念去角标美化工具
echo    ==========================
echo.
echo     功能简介：
echo     1.去除 / 恢复 Windows 快捷方式小箭头
echo     2.去除 / 恢复 快捷方式上的小盾牌
echo.
echo     按下任意键，进入主菜单。
echo.
echo    ==========================
echo.
pause >nul

REM ======== 主菜单 ========
:menu
cls
echo.
echo    --------------------------------
echo         小念激活工具 v1.0
echo    --------------------------------
echo.
echo       1.去除快捷方式角标
echo       2.去除小盾牌
echo       3.恢复快捷方式角标
echo       4.恢复小盾牌
echo       5.退出
echo.
set /p "key=    请选择 (1-5) 后按 回车键 确认："
if "%KEY%"=="1" goto one
if "%KEY%"=="2" goto two
if "%KEY%"=="3" goto three
if "%KEY%"=="4" goto four
if "%KEY%"=="5" goto end
echo.
echo    (*) 输入有误，请输入 1-5 之间的数字。
timeout /t 2 >nul
goto menu

:one
echo.
echo    [1/4] 正在去除快捷方式角标 ...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
taskkill /f /im explorer.exe
attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db"
del "%userprofile%\AppData\Local\iconcache.db" /f /q
start explorer
echo.
echo    [完成] 快捷方式角标已去除。
echo    按任意键返回菜单 ...
pause >nul
goto menu

:two
echo.
echo    [2/4] 正在去除小盾牌 ...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 77 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
taskkill /f /im explorer.exe
attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db"
del "%userprofile%\AppData\Local\iconcache.db" /f /q
start explorer
echo.
echo    [完成] 小盾牌已去除。
echo    按任意键返回菜单 ...
pause >nul
goto menu

:three
echo.
echo    [3/4] 正在恢复快捷方式角标 ...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
taskkill /f /im explorer.exe
attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db"
del "%userprofile%\AppData\Local\iconcache.db" /f /q
start explorer
echo.
echo    [完成] 快捷方式角标已恢复。
echo    按任意键返回菜单 ...
pause >nul
goto menu

:four
echo.
echo    [4/4] 正在恢复小盾牌 ...
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 77 /f
taskkill /f /im explorer.exe
attrib -s -r -h "%userprofile%\AppData\Local\iconcache.db"
del "%userprofile%\AppData\Local\iconcache.db" /f /q
start explorer
echo.
echo    [完成] 小盾牌已恢复。
echo    按任意键返回菜单 ...
pause >nul
goto menu

:end
echo.
echo     再见，记得常来玩 ~
timeout /t 2 >nul
exit /b
