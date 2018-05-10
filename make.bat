@echo off
copy .\ZAM_ruins.w3x .\build
clijasshelper.exe .\assets\data\common.j .\assets\data\blizzard.j .\build\ZAM_ruins.w3x

set argC=0
for %%x in (%*) do set /A argC+=1

if %argC% == 0 (
    del .\logs\*.j
)