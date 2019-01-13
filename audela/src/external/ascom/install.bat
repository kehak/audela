@echo -----------------------------------------------------------
@echo --- Note pour le developpement de l'interface ASCOM
@echo Les fichiers AscomMasterInterfaces.h et AscomMasterInterfaces.lib
@echo ne sont plus fournis ASCOM. Ils sont generes automatiquement par
@echo VisualC++ v9 a partir du fichier AscomMasterInterfaces.tlb
@echo en fonction du systeme d'exploitation.
@echo
@echo --- Note pour l'utilisation de l'interface de camera ASCOM
@echo Avant de lancer Audela , l'utilisateur doit installer le driver de
@echo ASCOM disponible sur http://ascom-standards.org
@echo -----------------------------------------------------------

set ASCOM=ascom
@echo --- Je cree le repertoire external\lib
mkdir ..\lib
@echo --- Je copie le fichier AscomMasterInterfaces.tlb
copy %ASCOM%\lib\AscomMasterInterfaces.tlb ..\lib
