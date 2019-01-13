cd jpeg-6b
copy jconfig.vc jconfig.h
copy makelib.ds jpeg.mak
REM copy makeapps.ds apps.mak

nmake /f jpeg.mak
REM nmake /f apps.mak

cd ..
