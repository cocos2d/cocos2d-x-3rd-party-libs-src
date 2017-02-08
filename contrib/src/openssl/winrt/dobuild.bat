@echo off

start /wait cmd /c "clean.bat"
start /wait cmd /c "download.bat"
start /wait cmd /c "build-win8.1.bat"
start /wait cmd /c "build-win10.bat"
