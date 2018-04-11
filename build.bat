@echo off
REM node .\lni2json.js
REM node .\json2w3a.js
REM MPQEditor.exe add .\ZAM_ruins.w3x .\objects\war3map.w3a "war3map.w3a"
REM echo Success - war3map.w3a injected to map
clijasshelper.exe .\objects\common.j .\objects\blizzard.j .\src\Main.j .\ZAM_ruins.w3x
"Warcraft III.exe" -window -loadfile "D:\Documents\Warcraft III\Maps\Zulaman-WE\ZAM_ruins.w3x"