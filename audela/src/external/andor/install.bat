set ANDOR=sdk_32bits_2_095_3
mkdir ..\include
mkdir ..\lib
copy %ANDOR%\include\Atmcd32d.h ..\include
copy %ANDOR%\lib\atmcd32m.lib ..\lib
copy %ANDOR%\bin\*.* ..\..\..\bin
