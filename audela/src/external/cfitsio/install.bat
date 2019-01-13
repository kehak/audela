rem  parametre %1 = Release ou Debug

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release
set FITSIO=..\cfitsio3340
@echo on
mkdir ..\..\include
mkdir ..\..\lib
copy %CONFIG%\cfitsio.lib ..\..\lib
copy %FITSIO%\fitsio.h ..\..\include
copy %FITSIO%\longnam.h ..\..\include
