@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
title XiaoNian Widgets Tool
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
echo                              小念Win11优化工具 v1.0
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
echo     欢迎使用小念Win11优化工具
echo    ==========================
echo.
echo     功能分类：
echo     1. Windows 11 小组件：卸载/恢复、任务栏图标显隐
echo     2. 右键菜单：经典菜单 / Win11 菜单 切换
echo.
echo     说明：卸载优先用 winget，失败自动回退 PowerShell；
echo           恢复需联网，从 Microsoft Store 拉取安装包。
echo.
echo     按下任意键，进入主菜单。
echo.
echo    ==========================
echo.
pause >nul

REM ======== 主菜单（一级） ========
:menu
set "backmenu=menu"
cls
echo.
echo    --------------------------------
echo        小念Win11优化工具 v1.0
echo    --------------------------------
echo.
echo       请选择功能分类：
echo       1. Windows 11 小组件
echo       2. 右键菜单
echo       3. 退出
echo.
set /p "key=    请选择 (1-3) 后按 回车键 确认："
if "%KEY%"=="1" goto wmenu
if "%KEY%"=="2" goto rmenu
if "%KEY%"=="3" goto end
echo.
echo    (*) 输入有误，请输入 1-3 之间的数字。
timeout /t 2 >nul
goto %backmenu%

REM ======== 二级菜单：小组件 ========
:wmenu
set "backmenu=wmenu"
cls
echo.
echo    [小组件] 请选择操作：
echo.
echo       1.卸载小组件
echo       2.恢复小组件
echo       3.隐藏任务栏小组件图标
echo       4.显示任务栏小组件图标
echo       5.返回上级菜单
echo.
set /p "key=    请选择 (1-5) 后按 回车键 确认："
if "%KEY%"=="1" goto one
if "%KEY%"=="2" goto two
if "%KEY%"=="3" goto three
if "%KEY%"=="4" goto four
if "%KEY%"=="5" goto menu
echo.
echo    (*) 输入有误，请输入 1-5 之间的数字。
timeout /t 2 >nul
goto wmenu

REM ======== 二级菜单：右键菜单 ========
:rmenu
set "backmenu=rmenu"
cls
echo.
echo    [右键菜单] 请选择操作：
echo.
echo       1.使用 Windows 经典右键菜单
echo       2.恢复 Windows 11 右键菜单
echo       3.返回上级菜单
echo.
set /p "key=    请选择 (1-3) 后按 回车键 确认："
if "%KEY%"=="1" goto five
if "%KEY%"=="2" goto six
if "%KEY%"=="3" goto menu
echo.
echo    (*) 输入有误，请输入 1-3 之间的数字。
timeout /t 2 >nul
goto rmenu

:one
cls
echo.
echo    [1/4] 正在卸载小组件 ...
echo.
echo    (*) 结束小组件进程
taskkill /f /im WidgetService.exe >nul 2>&1
echo    (*) 尝试 winget 卸载
winget uninstall MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy
if errorlevel 1 echo    (*) winget 未成功，改用 PowerShell 卸载
if errorlevel 1 powershell -NoProfile -Command "Get-AppxPackage *WebExperience* | Remove-AppxPackage"
echo    (*) 重启资源管理器
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 小组件已卸载。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%

:two
cls
echo.
echo    [2/4] 正在恢复小组件 ...
echo.
echo    (*) 通过 Store 包 ID 重装 (需联网)
winget install 9MSSGKG348SP
if errorlevel 1 echo    (*) winget 未成功，改用 PowerShell 本地注册
if errorlevel 1 powershell -NoProfile -Command "Get-AppxPackage -AllUsers *WebExperience* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register ($_.InstallLocation + '\AppXManifest.xml')}"
echo    (*) 重启资源管理器
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 小组件已恢复。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%

:three
cls
echo.
echo    [3/4] 正在隐藏任务栏小组件图标 ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 任务栏小组件图标已隐藏。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%

:four
cls
echo.
echo    [4/4] 正在显示任务栏小组件图标 ...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 1 /f
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 任务栏小组件图标已显示。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%


:five
cls
echo.
echo    [5/6] 正在切换到 Windows 经典右键菜单 ...
echo.
echo    (*) 写入注册表 (需管理员权限，本工具已自动提权)
reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo    (*) 重启文件资源管理器以生效
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 已切换为 Windows 经典(旧版)右键菜单。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%

:six
cls
echo.
echo    [6/6] 正在恢复 Windows 11 右键菜单 ...
echo.
echo    (*) 删除注册表项 (需管理员权限，本工具已自动提权)
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
echo    (*) 重启文件资源管理器以生效
taskkill /f /im explorer.exe >nul 2>&1
start explorer
echo.
echo    [完成] 已恢复 Windows 11 右键菜单。
echo    按任意键返回菜单 ...
pause >nul
goto %backmenu%

:end
echo.
echo     再见，记得常来玩 ~
timeout /t 2 >nul
exit /b
