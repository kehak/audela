if not exist jpeg-6b\release\jpeg.lib ( start /b /wait make.bat )
if not exist ..\include (mkdir ..\include )
if not exist ..\lib     (mkdir ..\lib)
copy jpeg-6b\*.h ..\include
copy jpeg-6b\release\jpeg.lib ..\lib
