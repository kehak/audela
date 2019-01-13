rem  parametre %1 = Release ou Debug
echo on

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release

set FLI=fli-dist-1.104\libfli
if not exist ..\include   mkdir ..\include
if not exist ..\lib       mkdir ..\lib
copy "%FLI%\libfli.h" ..\include
rem copy "%FLI%\windows\%CONFIG%\libfli.lib" ..\lib
rem copy "%FLI%\windows\%CONFIG%\libfli.dll" ..\..\..\bin
copy "%FLI%\..\..\..\lib\libfli.dll" ..\..\..\bin
