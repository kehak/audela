@echo off
rem  parametre %1 = Release ou Debug
rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == ""     set CONFIG=Release

echo copy libdcraw.dll to bin directory
copy %CONFIG%\*.dll     ..\..\..\..\bin

echo copy libdcraw.lib to lib directory
copy %CONFIG%\*.lib     ..\..\lib

echo copy libdcraw.h to include directory
copy ..\src\libdcraw.h ..\..\include
