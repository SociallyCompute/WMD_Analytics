@echo off
del /f /q .\detail\*
for /f %%t in ('more forums_23.csv') do (
    if /i not %%t==table .\GenerateDetail.exe . %%t
)