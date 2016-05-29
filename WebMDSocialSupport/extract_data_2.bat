@echo off

del /f /q .\data\*
del /f /q .\topics.txt

for /f %%t in ('more forums_23.csv') do (
    if /i not %%t==table .\ParseLDA.exe . %%t
)