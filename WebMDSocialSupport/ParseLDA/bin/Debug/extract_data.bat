@echo off
del /f /q d:\temp\forumtree\data\*
for /f %%t in ('more %1') do (
    ParseLDA %%t
)