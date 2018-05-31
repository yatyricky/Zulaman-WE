@echo off
set argC=0
for %%x in (%*) do set /A argC+=1

if %argC% == 0 (
    "Warcraft III.exe" -window -loadfile "%~dp0\build\ZAM_ruins_slk.w3x"
) else (
    "Warcraft III.exe" -window -loadfile "%~dp0\build\ZAM_ruins.w3x"
)

