@echo -----------------------------------------------------------
@echo --- Note pour le developpement de l'interface de camera QSI
@echo Les fichiers QSICamera.h et QSICamera.lib ne sont plus fournis par le
@echo le fabriquant.  Ils sont generes automatiquement par VisualC++ v9.
@echo Il faut auparavant enregistrer QSICamera.dll dans la base de registre
@echo de Windows avec la commande regsvr32 sur le poste de developpement.

@echo --- Note pour l'utilisation de l'interface de camera QSI
@echo Avant de lancer Audela , l'utilisateur doit installer le driver de
@echo la camera QSI disponible sur http://www.qsimaging.com
@echo -----------------------------------------------------------

set QSI=qsi
@echo --- Je cree le repertoire external\lib
mkdir ..\lib
@echo --- Je copie le fichier QSICamera.dll
copy %QSI%\lib\QSICamera.dll ..\lib
@echo --- J'enregistre le fichier QSICamera.dll dans la base de registre
set fullDir=%0
set dirName=%fullDir:\install.bat=%
regsvr32 %dirName%\qsi\lib\QSICamera.dll
