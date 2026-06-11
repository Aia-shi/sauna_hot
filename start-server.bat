@echo off
cd /d "%~dp0"
echo Uruchamianie serwera lokalnego...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-server.ps1"
pause
