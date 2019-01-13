@echo off
rem  parametre %1 = Release ou Debug
rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == ""     set CONFIG=Release

set sourceDir=..\..\gsl-1.8\gsl
set include_dir=..\..\..\include\gsl

set lib_dir=..\..\..\lib
set bin_dir=..\..\..\..\..\bin

if %CONFIG% == clean  goto target_clean

rem definition de la commande copy
rem
set COPY=xcopy /D /Y /I

rem copie des entetes des librairies
%COPY% %CONFIG%\libgslcblas.lib     %lib_dir%


goto target_end

:target_clean
@del /Q /s %include_dir%

del /Q %lib_dir%\libgslcblas.lib

del /Q %bin_dir%\libgslcblas.dll

:target_end

