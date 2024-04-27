:: This script installs the Fortran compilers provided in Intel OneAPI.
:: See https://github.com/oneapi-src/oneapi-ci
:: https://github.com/oneapi-src/oneapi-ci/blob/master/scripts/install_windows.bat
::
:: Usage: cmd.exe "/K" '"install_oneapi_windows.bat"'
:: N.B.: This is a cmd script, which may not work in PowerShell.
::
:: Zaikun Zhang (www.zhangzk.net), January 9, 2023

:: URL for the offline installer of Intel OneAPI Fortran compiler. To get the latest URL, search for
:: "Intel Fortran Compiler Classic and Intel Fortran Compiler for Windows" at
:: https://www.intel.com/content/www/us/en/developer/articles/tool/oneapi-standalone-components.html
:: and take the URL for the "Offline" installer.
:: Default version: 2024.1.0 (updated on 20240427)
set URL=https://registrationcenter-download.intel.com/akdlm/IRC_NAS/f6a44238-5cb6-4787-be83-2ef48bc70cba/w_fortran-compiler_p_2024.1.0.466_offline.exe
if "%1"=="2023" (
    set URL=https://registrationcenter-download.intel.com/akdlm/IRC_NAS/1720594b-b12c-4aca-b7fb-a7d317bac5cb/w_fortran-compiler_p_2023.2.1.7_offline.exe
)
if "%1"=="2022" (
    set URL=https://registrationcenter-download.intel.com/akdlm/irc_nas/18976/w_HPCKit_p_2022.3.1.19755_offline.exe
)
if "%1"=="2021" (
    set URL=https://registrationcenter-download.intel.com/akdlm/irc_nas/18247/w_HPCKit_p_2021.4.0.3340_offline.exe
)

:: Component to install.
set COMPONENTS=intel.oneapi.win.ifort-compiler

:: Download the installer. curl is included by default in Windows since Windows 10, version 1803.
::cd %Temp%  :: CD does not work if %Temp% is on a different drive.
curl.exe --output webimage.exe --url %URL% --retry 5 --retry-delay 5
start /b /wait webimage.exe -s -x -f webimage_extracted --log extract.log

:: Install the compiler.
webimage_extracted\bootstrapper.exe -s --action install --components=%COMPONENTS% --eula=accept -p=NEED_VS2017_INTEGRATION=0 -p=NEED_VS2019_INTEGRATION=0 -p=NEED_VS2022_INTEGRATION=0 --log-dir=.
set installer_exit_code=%ERRORLEVEL%

:: Run the script that sets the necessary environment variables and then damp them to $GITHUB_ENV
:: so that they are available in subsequent steps.
:: N.B.: `grep 'intel\|oneapi'` does not work on Windows.
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"
set | grep -i "intel" >> %GITHUB_ENV%
set | grep -i "oneapi" >> %GITHUB_ENV%

:: Show the result of the installation.
echo The path to ifort is:
where ifort.exe
echo The path to ifx is:
where ifx.exe

:: Remove the installer.
del webimage.exe
rd /s/q "webimage_extracted"

:: Exit with the installer exit code.
exit /b %installer_exit_code%
