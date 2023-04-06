@echo off

REM  --> Check for permissions
 >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
 if '%errorlevel%' NEQ '0' (
     echo Requesting administrative privileges...
     goto UACPrompt
 ) else ( goto gotAdmin )

:UACPrompt
     echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
     echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
     exit /B

:gotAdmin
     if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
     pushd "%CD%"
     CD /D "%~dp0"

secedit.exe /export /cfg C:\secconfig.cfg 

echo %time%
timeout 0.5 > NUL
echo %time%

powershell -Command "(gc C:\secconfig.cfg) -replace 'PasswordComplexity = 0', 'PasswordComplexity = 1' | Out-File -encoding ASCII C:\secconfigupdated.cfg" 

echo %time%
timeout 0.5 > NUL
echo %time%

secedit.exe /configure /db %windir%\securitynew.sdb /cfg C:\secconfigupdated.cfg /areas SECURITYPOLICY 

echo %time%
timeout 0.1 > NUL
echo %time%

del c:\secconfig.cfg 

echo %time%
timeout 0.1 > NUL
echo %time%

del c:\secconfigupdated.cfg 

echo %time%
timeout 0.1 > NUL
echo %time%

net accounts /maxpwage:90
net accounts /minpwage:1
net accounts /minpwlen:9
net accounts /forcelogoff:5

reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d 300 /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveIsSecure" /t REG_SZ /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "C:\WINDOWS\system32\scrnsave.scr" /f

exit
