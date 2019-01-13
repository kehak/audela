echo off
set MAJOR=3
set MINOR=0
set PATCH=0
rem  extra="." if stable, or "a" if alpha, or "b" if beta  
set EXTRA=b1
set REL_DATE=%DATE%

rem  je recupere la revision svn 
rem  svnrevision help:
rem  If the working copy is all at the same revision (e.g., immediately after an update), 
rem  then that revision is printed out:
rem   4168
rem  For a mixed-revision working copy, the range of revisions present is printed:
rem   4123:4168
rem  If the working copy contains modifications, a trailing 'M' is added:
rem   4168M
rem  If the working copy is switched, a trailing 'S' is added:
rem   4168S
set REVISION=
for /f %%d in ('svnversion --no-newline ..') do set REVISION=%%d


echo AUDELA_MAJOR=%MAJOR%
echo AUDELA_MINOR=%MINOR%
echo AUDELA_PATCH=%PATCH%
echo AUDELA_EXTRA=%EXTRA%
echo AUDELA_DATE=%REL_DATE%
echo SVN_REVISION=%REVISION%

setlocal enabledelayedexpansion
FOR %%f IN ( ..\bin\version.tcl ..\bin\pkgindex.tcl include\version.h ) DO ( 
	echo update file=%%f
	set txtfile=%%f.in
	set newfile=%%f
	if exist "!newfile!" del /f /q "!newfile!"
	for /f "tokens=*" %%a in (!txtfile!) do (
	   set newline=%%a
	   set newline=!newline:@MAJOR@=%MAJOR%!
	   set newline=!newline:@MINOR@=%MINOR%!
	   set newline=!newline:@PATCH@=%PATCH%!
	   set newline=!newline:@EXTRA@=%EXTRA%!
	   set newline=!newline:@REL_DATE@=%REL_DATE%!
	   set newline=!newline:@REVISION@=%REVISION%!
	   echo !newline! >> !newfile!
	)
)