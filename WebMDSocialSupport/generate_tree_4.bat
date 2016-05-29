@echo off

for /f %%t in ('more topics.txt') do (
    .\ForumTree.exe . %%t
)