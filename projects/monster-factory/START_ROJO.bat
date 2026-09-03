@echo off
cd /d "%~dp0"

if exist "tools\rojo.exe" (
    echo [Monster Factory] Starting bundled Rojo...
    tools\rojo.exe serve default.project.json
    pause
    exit /b
)

where rojo >nul 2>nul
if %errorlevel%==0 (
    echo [Monster Factory] Starting system Rojo...
    rojo serve default.project.json
    pause
    exit /b
)

echo.
echo Rojo CLI was not found.
echo Download the Windows x86_64 Rojo release and put rojo.exe in:
echo %~dp0tools\
echo.
pause
