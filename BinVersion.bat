@echo off
if not exist Output\ mkdir Output\
for /f "tokens=*" %%i in ('..\Publish\GetAssemblyVersion\GetAssemblyVersion.exe -v -b %1') do echo !define BinVersion "%%i" > Output\BinVersion.txt
