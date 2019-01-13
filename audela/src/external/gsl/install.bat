mkdir ..\include
mkdir ..\include\gsl
@echo on
copy include\*.* ..\include\gsl
copy lib\*.* ..\lib
copy bin\*.* ..\..\..\bin
