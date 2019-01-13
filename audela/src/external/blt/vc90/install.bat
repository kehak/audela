rem  parametre %1 = Release ou Debug

rem Si pas de parametre , la valeur par defaut est Release
if not "%1" == "" set CONFIG=%1
if "%1" == "" set CONFIG=Release

set sourceDir=..\blt2.4z
set destDir=..\..\..\..\lib\blt2.4

mkdir %destDir%
mkdir %destDir%\dd_protocols

copy /Y %sourceDir%\library\*.* %destDir%
copy /Y %sourceDir%\library\dd_protocols\* %destDir%
echo on
copy pkgindex.tcl        %destDir%
copy %CONFIG%\blt24.dll  %destDir%
