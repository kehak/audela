set TCL=tcl
mkdir ..\include
mkdir ..\lib
mkdir ..\include
copy %TCL%\bin\*.* ..\..\..\bin
copy %TCL%\include\*.* ..\include
mkdir ..\include\x11
copy %TCL%\include\x11\*.* ..\include\x11
copy %TCL%\lib\*.* ..\lib
