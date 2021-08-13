@echo off
setlocal

set /p url_text="Enter Onedrive-URL: "
call :btoa b64 "%url_text%"
set command="powershell '%b64%' -replace '=','' -replace '/','_' -replace '\+','-'"
for /f "delims=" %%I in (
    '%command%'
) do set "url_part=%%I"

set "direct_url=not found"
echo %url_text% | findstr /C:"/u/s!" 1>nul
if not errorlevel 1 (
    REM found pattern for file
    set "direct_url=https://api.onedrive.com/v1.0/shares/u!%url_part%/root/content"
)

echo %url_text% | findstr /C:"/f/s!" 1>nul
if not errorlevel 1 (
    REM found pattern for folder
    Powershell.exe -NoProfile -ExecutionPolicy remotesigned -File ./folder-helper.ps1 -EncodedSharingUrl %url_part% -DownloadSwitch
    set "direct_url=look for .zip in home directory"
)
echo %direct_url%

pause
goto :EOF

:btoa <var_to_set> <str>
for /f "delims=" %%I in (
    'powershell "[convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\"%~2\"))"'
) do set "%~1=%%I"
goto :EOF

:atob <var_to_set> <str>
for /f "delims=" %%I in (
    'powershell "[Text.Encoding]::UTF8.GetString([convert]::FromBase64String(\"%~2\"))"'
) do set "%~1=%%I"
goto :EOF
