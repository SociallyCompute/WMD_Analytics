@echo off

for /f %%t in ('more %1') do (
    ForumTree %%t
)