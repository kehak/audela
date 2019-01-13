@echo --- Carte  convertisseur USB parallele de National Intrument

set NIDAQMX=nidaqmx
@echo --- Je cree le repertoire external\include
mkdir ..\include
@echo --- Je cree le repertoire external\lib
mkdir ..\lib
@echo --- Je copie le fichier NIDAQmx.h
copy %NIDAQMX%\include\NIDAQmx.h ..\include
@echo --- Je copie le fichier NIDAQmx.lib
copy %NIDAQMX%\lib\NIDAQmx.lib ..\lib
