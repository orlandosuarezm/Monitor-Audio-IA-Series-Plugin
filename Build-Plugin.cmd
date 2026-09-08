@echo off
setlocal
cd /d "%~dp0"

set "COMPILER=%~dp0tools\PluginCompile\PLUGCC.exe"
set "NAME=MonitorAudioIASeries"
set "SOURCE=%~dp0plugin.lua"
set "ROOT_OUTPUT=%~dp0%NAME%.qplug"
set "DIST=%~dp0dist"
set "PLUGIN_DIR=%USERPROFILE%\Documents\QSC\Q-SYS Designer\Plugins\%NAME%"
set "PLUGIN_ROOT=%USERPROFILE%\Documents\QSC\Q-SYS Designer\Plugins"

if not exist "%COMPILER%" (
    echo PLUGCC.exe not found at "%COMPILER%".
    exit /b 1
)

if exist "%ROOT_OUTPUT%" del /q "%ROOT_OUTPUT%"
"%COMPILER%" "%NAME%" "%SOURCE%"
if errorlevel 1 exit /b 1
if not exist "%ROOT_OUTPUT%" (
    echo PLUGCC did not create "%ROOT_OUTPUT%".
    exit /b 1
)

if not exist "%DIST%" mkdir "%DIST%"
copy /Y "%ROOT_OUTPUT%" "%DIST%\%NAME%.qplug" > nul

luac -p "%DIST%\%NAME%.qplug"
if errorlevel 1 (
    echo Lua syntax validation failed.
    exit /b 1
)

if /I "%1"=="--install" (
    if not exist "%PLUGIN_ROOT%" mkdir "%PLUGIN_ROOT%"
    copy /Y "%DIST%\%NAME%.qplug" "%PLUGIN_ROOT%\%NAME%.qplug" > nul
    if not exist "%PLUGIN_DIR%" mkdir "%PLUGIN_DIR%"
    copy /Y "%DIST%\%NAME%.qplug" "%PLUGIN_DIR%\%NAME%.qplug" > nul
    echo Installed: "%PLUGIN_ROOT%\%NAME%.qplug"
)

echo Q-SYS plugin build and Lua syntax validation passed.