@echo off
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as Administrator.
    echo Right-click the script and choose "Run as administrator".
    pause
    exit /b 1
)

bcdedit /enum {current} | findstr /i /r /c:"testsigning *Yes" >nul
if %errorlevel% equ 0 (
    echo Test signing is enabled, continuing
) else (
    echo Test signing is not enabled.

    reg query "HKLM\SYSTEM\CurrentControlSet\Control\SecureBoot\State" /v UEFISecureBootEnabled 2>nul | findstr /i "0x1" >nul
    if %errorlevel% equ 0 (
        echo UEFI Secure Boot is enabled
    ) else (
        echo UEFI Secure Boot is disabled
        bcdedit /set testsigning on
        echo Your system will reboot now and you must relaunch this script as admin again.
        pause
        shutdown /r /t 0
    )
)

rem Check which device we have
for /f "tokens=2,*" %%A in ('reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v BaseBoardProduct 2^>nul ^| findstr /i "BaseBoardProduct"') do set "board=%%B"
echo BaseBoard product: %board%

if /i "%board%"=="RUBIK Pi 3" (
    set "CertInf=components\Devices\RUBIKPi3\Signature\DesktopSignature\DesktopSignature.inf"
)

pnputil /add-driver %CertInf% /install
echo System needs to reboot now! Please launch InstallDrivers.bat as admin after system booted again.
pause
shutdown /r /t 0
