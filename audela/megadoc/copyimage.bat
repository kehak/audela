rem copyFrenchPluginImages.bat
rem
rem copie les images des plugins dans le repertoire doxygen
rem
rem Parametres de xcopy :
rem  /D  copie uniquement les fichiers dont l'heure source est plus récente que l'heure de destination.
rem  /I  Si la destination n'existe pas et que plus d'un fichier est copié, considérer la destination comme devant être un répertoire.
rem  /S  Copie les répertoires et sous-répertoires à l'exception des répertoires vides.
rem  /Y  Supprime la demande de confirmation de remplacement de fichiers de destination existants.

set cameraList=(dslr webcam)
for %%A in %cameraList% do (
xcopy /D /I /S /Y ..\gui\audace\plugin\camera\%%A\french\images   doc_doxygen\images
)

set chartList=(carteducielv3)
for %%A in %chartList% do (
xcopy /D /S /I /Y ..\gui\audace\plugin\chart\%%A\french\images   doc_doxygen\images
)

set equipmentList=(scopedome usb_focus)
for %%A in %equipmentList% do (
xcopy /D /S /I /Y ..\gui\audace\plugin\equipment\%%A\french\images   doc_doxygen\images
)

set telescopeList=(temma)
for %%A in %telescopeList% do (
xcopy /D /S /I /Y ..\gui\audace\plugin\mount\%%A\french\images   doc_doxygen\images
)

set toolList=(acqapn acqdslr acqvideo autoguider bddimages catalogexplorer collector echip fieldchart foc magnifier modpoi2 pretrfc satellites scan scanfast sn_tarot spytimer supernovae testaudela updateaudela visio2 vo_tools)
for %%A in %toolList% do (
xcopy /D /S /I /Y ..\gui\audace\plugin\tool\%%A\french\images   doc_doxygen\images
)

set configList=(01presentation 02programmation 03fichier 04affichage 05images 07analyse 10configuration 11aide 12tutoriel)
for %%A in %configList% do (
xcopy /D /S /I /Y ..\gui\audace\doc_html\french\%%A\images   doc_doxygen\images
)

set subConfigList=(01audace 02camera 03monture 04link 04optique 05equipement 06raquette 07carte)
for %%A in %subConfigList% do (
xcopy /D /S /I /Y ..\gui\audace\doc_html\french\10configuration\%%A\images   doc_doxygen\images
)

xcopy /D /S /I /Y audela_site\images   doc_doxygen\images

xcopy /D /S /I /Y doxy_conf\images   doc_doxygen\images
