@echo off
copy .\ZAM_ruins.w3x .\build
clijasshelper.exe .\objects\common.j .\objects\blizzard.j .\build\ZAM_ruins.w3x
del .\logs\*.j