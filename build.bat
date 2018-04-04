@echo off
node .\lni2json.js
node .\json2w3a.js
MPQEditor.exe add .\ZAM_ruins.w3x .\objects\war3map.w3a "war3map.w3a"
echo Success - war3map.w3a injected to map
REM clijasshelper.exe .\objects\common.j .\objects\blizzard.j .\ZAM_ruins.w3x