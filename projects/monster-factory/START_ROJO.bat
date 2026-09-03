@echo off
cd /d "%~dp0"

if exist "tools\rojo.exe" (
    echo [Monster Factory] Starting bundled Rojo...
    tools\rojo.exe serve default.project.json
    pause
    exit /b
)

if exist "%USERPROFILE%\Desktop\Rojo\rojo.exe" (
    echo [Monster Factory] Starting Desktop Rojo...
    "%USERPROFILE%\Desktop\Rojo\rojo.exe" serve default.project.json
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
echo Checked:
echo   %~dp0tools\rojo.exe
echo   %USERPROFILE%\Desktop\Rojo\rojo.exe
echo   PATH: rojo

echo.
pause
