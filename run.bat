@echo off
REM node .\lni2json.js
REM node .\json2w3a.js
REM MPQEditor.exe add .\ZAM_ruins.w3x .\objects\war3map.w3a "war3map.w3a"
REM echo Success - war3map.w3a injected to map
copy .\ZAM_ruins.w3x .\build
clijasshelper.exe .\objects\common.j .\objects\blizzard.j .\build\ZAM_ruins.w3x
"Warcraft III.exe" -window -loadfile "%~dp0\build\ZAM_ruins.w3x"