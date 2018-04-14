@echo off
powershell -Command [Environment]::GetFolderPath('MyDocuments') > docpath.tmp
set /p DOCPATH=<docpath.tmp
del docpath.tmp
"Warcraft III.exe" -window -loadfile "%DOCPATH%\Warcraft III\Replay\LastReplay.w3g"