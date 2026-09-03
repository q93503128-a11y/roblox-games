@echo off
cd /d "%~dp0"

if exist "tools\rojo.exe" (
    tools\rojo.exe plugin install
    echo.
    echo Plugin install command finished. Restart Studio once if the Rojo button does not appear.
    pause
    exit /b
)

where rojo >nul 2>nul
if %errorlevel%==0 (
    rojo plugin install
    echo.
    echo Plugin install command finished. Restart Studio once if the Rojo button does not appear.
    pause
    exit /b
)

echo Rojo CLI was not found.
echo Put rojo.exe in the tools folder first.
pause
