@echo off
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as Administrator.
    echo Right-click the script and choose "Run as administrator".
    pause
    exit /b 1
)

rem Check which device we have
for /f "tokens=2,*" %%A in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v BaseBoardProduct 2^>nul ^| findstr /i "BaseBoardProduct"') do set "board=%%B"
echo BaseBoard product: %board%

if /i "%board%"=="RUBIK Pi 3" (
    set "Definition=.\definitions\Desktop\ARM64\Internal\RUBIKPi3.xml"
)

.\Tools\DriverUpdater\ARM64\DriverUpdater.exe -r . -d %Definition%

echo Driver installation has finished.
echo Please reboot your device.
pause
