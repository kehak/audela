AudeLA-2.x.0

Une présentation graphique décrit pas à pas la façon
de compiler AudeLA sous Windows et Linux dans le fichier:

audela/doc/compil/audela_svn_windows_linux_en.odp

et un exemple non graphique d'installation sur une OpenSuse 13.1 64 bits

audela/doc/compil/INSTALL.Linux.OpenSuse13.1_64b

1. Sources
==========
Voici la liste des sous-repertoires de AudeLA, avec la description
de ce que l'on peut y trouver :
- audela : Sources propres a audela.
- contrib : Modules ecrits specifiquement pour AudeLA, par des personnes
  exterieures au TACT, et dont la license n'est pas GPL.
- external : Repertoire contenant tous les modules externes utilises
  par AudeLA. Cela facilite l'indentification de ce qui est audela de
  ce qui a ete re-utilise.
- libak : Librairie maintenue par Alain KLOTZ.
- libaudela : Librairie principale d'AudeLA.
- libcam : Contient tous les drivers de camera.
- libgsltcl : Interface TCL <-> GSL.
- libgzip : Module de compression.
- libmc : Librairie de mecanique celeste.
- librgb : Permet d'utiliser des images en couleur.
- libtel : Contient tous les drivers de montures de telescope.
- libtt : Librairie de traitement d'images.


2. Pre-requis
=============

AudeLA necessite les modules externes suivants pour fonctionner:
 - Tcl 8.5 (avec Debian, paquets tcl85 et tcl85-dev)
 - Tk 8.5 (avec Debian, paquets tk85 et tk85-dev)

Optionnel:
 - gsl (http://www.gnu.org/software/gsl)

Autres:
 - Img 1.3 (http://prdownloads.sourceforge.net/tkimg/tkimg1.3.tar.gz?download)
 - Blt 2.4 (http://prdownloads.sourceforge.net/blt/BLT2.4z.tar.gz?download)


3. Compilation sous Windows
===========================

3.1 Apercu general
------------------

La compilation sous Windows s'effectue en trois temps. D'abord il faut
enregistrer la librairie "QSICamera.dll" (voir paragraphe 3.2), puis compiler
et installer tous les modules externes, depuis une ligne de commande (voir
paragraphe 3.3). Ensuite avec Visual C++, compiler tous les modules propres a AudeLA
(voir paragraphe 3.4).

3.2 Enregistrement de la librairie QSICamera.dll pour Windows
-------------------------------------------------------------

Il faut enregistrer la librairie "QSICamera.dll" uniquement avant
la premiere compilation avec Visual C++, pour cela :

Sous Windows XP :
-----------------
Vous devez double-cliquer sur le fichier "install.bat" qui se trouve dans "\src\external\qsi"
et puis c'est tout.

Sous Windows 7 :
----------------
Vous devez faire clic droit sur le nom du fichier "install.bat" qui se trouve dans "\src\external\qsi",
puis faire "Executer en tant qu'administrateur", et enfin cliquer sur "Oui" de la fenetre
"Controle de compte d'utilisateur" et puis c'est tout.
Sous Windows 7, cette etape ne peut se faire que si on est "administrateur".

3.3 Compilation des modules externes pour Windows
-------------------------------------------------

Avec Visual C++ 2008 aller directement à la section 3.4.

Avec Visual C++ v6 seulement:

Effectuez les operations suivantes dans une console "Invite de commande",

  - Repertoire src\external\andor,
    lancer make.bat puis install.bat

  - Repertoire src\external\cemes,
    lancer make.bat puis install.bat

  - Repertoire src\external\cfitsio,
    lancer vars.bat (regler les chemins si besoin), make.bat puis install.bat

  - Repertoire src\external\etel,
    extraire lib.zip dans ce repertoire, et lancer install.bat

  - Ouvrir et compiler avec visual c++, en mode release :
       src\external\fli\libfli\lib\windows\libfli.dsw
    Repertoire src\external\fli, lancer install.bat.

  - Repertoire src\external\gsl,
    lancer make.bat puis install.bat

  - Repertoire src\external\jpeg6b,
    lancer vars.bat (regler les chemins si besoin), make.bat puis install.bat

  - Repertoire src\external\libdcjpeg
    (inclus dans la procedure ci-apres pour compiler AudeLA)

  - Repertoire src\external\libdcraw
    (inclus dans la procedure ci-apres pour compiler AudeLA)

  - Repertoire src\external\libftd2xx
    lancer make.bat puis install.bat

  - Repertoire src\external\libusb
    (inclus dans la procedure ci-apres pour compiler AudeLA)
    telecharger libusb-win32-filter-bin-0.1.10.1.exe depuis le site web de
    sourceforge puis lancer libusb-win32-filter-bin-0.1.10.1.exe

  - Repertoire src\external\libgphoto2
    (Inclus dans la procedure ci-apres pour compiler AudeLA)

  - Repertoire src\external\porttalk,
    lancer make.bat puis install.bat

  - Repertoire src\external\sbig,
    lancer make.bat puis install.bat

  - Ouvrir et compiler avec visual c++, en mode release :
       src\external\sextractor\sextractor\vc60-2.5.0\sextractor.dsw
          (sex.exe est mis directement dans audela/bin)

  - Repertoire src\external\tcl,
    lancer make.bat puis install.bat

  - Repertoire src\external\truetime,
    lancer make.bat puis install.bat

  - Repertoire src\external\utils,
    lancer make.bat puis install.bat

3.4 Compilation de AudeLA pour Windows
----------------------------------------

Avec Visual C++ v6 seulement:

Ouvrir avec Visual C++ le fichier src/audela.dsw : Allez dans le menu Build,
puis Batch Build ; Selectionnez les differentes cibles que vous voulez
compiler, et effectuez la compilation. De preference compiler les cibles en
mode release.

Avec Visual C++ 2008 seulement:

Ouvrir avec Visual C++ le fichier src/audela.sln : Sélectionner le mode Release
ou Debug (de préfé"rence compiler en mode Release).
Allez dans le menu Générer, puis Générer la solution.

3.5 Installation optionnelles
-----------------------------

3.5.1 Installation ftd2xx
-------------------------

   Ce driver est necessaire seulement pour les liaisons avec quickremote et
   quickaudine.

   Telecharger D10620.zip
   URL:   http://www.ftdichip.com/Drivers/FT232-FT245/D2XX/Win/D10620.zip
   ou URL:   http://www.ftdichip.com/Drivers/D2XX/Win2000/D30104.zip
   dezipper le fichier dans un repertoire temporaire
   brancher un quickremote, lorsque Windows demande ou est le repertoire du
   driver, pointer le repertoire temporaire ou vient d'etre dezippe le fichier.

   Remarque :
   Les drivers pour les autres version d'OS sont aussi sur le site
   http://www.ftdichip.com.

3.5.2 Installation libusb-win32
-------------------------------

   Ce driver est necessaire seulement pour la liaison des appareils
   photo numerique USB (librairie libdigicam.dll et libgphoto2.dll).

   Telecharger libusb-win32-filter-bin-0.1.10.1.exe disponible sur site
   http://libusb-win32.sourceforge.net ,
   puis installer libusb-win32 en executant ce fichier.

4 Linux
=======

4.1 Compilation et installation de AudeLA
-----------------------------------------

-> Pour linux, il vous faut extraire les sources de audela a partir de l'archive :
	$ tar -xf audela-1.5.0-src.tar.gz

-> Configurez le paquetage AudeLA :
	$ cd audela-1.5.0/src
	$ ./configure

	Par defaut, configure devrait detecter correctement les parametres de
	configuration. Si tel n'etait pas le cas, ils peuvent etre passes en
	ligne de commande via les options suivantes :
	--with-tcl={path_to_tclConfig.sh}
	--with-tk={path_to_tkConfig.sh}
		Par defaut, configure va chercher les fichiers de configuration TCL/TK
		dans des emplacements standard. Sur certaines distributions, ces packages
		sont installes dans d'autres repertoires. Les deux fichiers tclConfig.sh
		et tkConfig.sh sont generes lors de la compilation de TCL/TK et permettent
		de retrouver ensuite les differentes options de compilation necessaires a
		AudeLA. Les deux options servent a indiquer les repertoires ou trouver
		chacun de ces deux fichiers.
		Utilisez la commande find / | grep "tclConfig" pour localiser les fichiers.
	--with-gsl-exec-prefix={path}
		La librairie GSL est recherchee a partir des emplacements standard.
		Cette option permet de preciser le prefix d'installation de GSL le cas
		echeant. Cette librairie n'est pas necessaire : Si elle est absente,
		quelques modules de AudeLA ne seront volontairement pas compiles.
		Cette option est equivalente a faire pointer la variable d'environnement
		GSL-CONFIG vers l'executable gsl-config.

	Par exemple, pour la Debian 3.0, il faut avoir installer les paquets de developpement
	(tcl-dev, tk-dev, gsl-dev), et utiliser :
	./configure --with-tcl=/usr/lib/tcl8.4/ --with-tk=/usr/lib/tk8.4/ --with-gsl-prefix=/usr

-> Compiler d'abord les modules externes :
	$ make external

-> Compiler ensuite les contributions :
	$ make contrib

-> Compilez enfin audela :
	$ make

Les binaires sont dans le repertoire bin.

Vous pouvez tout compiler d'un coup :
	$ make all

	Mais commencez par le faire pas a pas pour identifier la cause eventuelle
	d'un dysfonctionnement.

	A l'execution, il peut y avoir des problemes avec des librairies telles que BLT,
	Img, ou encore TkHtml. Dans ce cas, supprimez leur repertoire de audela/lib, et
	installez-les sur votre machine (paquet .deb, .rpm, ou from source), et ajoutez
	les lignes suivantes au debut du fichier audace/audace/aud.tcl :
	lappend auto_path /mon/chemin/vers/ma/lib1
	lappend auto_path /mon/chemin/vers/ma/lib2
	etc.

	!! Attention !! Sous certaines plateformes il y a un echec de compilation pour
	la librairie FLI, et libfli. Cela est lie a l'USB, et n'a pas ete encore elucide.
	Vous pouvez neanmoins supprimer ces modules dans le fichier Makefile.defs pour
	reprendre le cours normal de la compilation.

4.2 Installation des drivers optionels
--------------------------------------

4.2.1 Configuration du peripherique optionnel FTDI
-------------------------------------------------

   Le peripherique optionnel FTDI (USB/Serial converter) est utilise seulement par les liaisons avec quickremote
   et quickaudine.

   Le driver FTDI libftd2xx.so est livre avec AudeLA et il est installe automatiquement dans
   audela/bin quand on installe les modules externes (voir ci-dessus).

   Recommandations pour l'execution de AudeLA :
      - demarrer AudeLA avec un compte ayant les droits d'acces sur
        les ports USB (root par exemple)

      - pour eviter les confits avec d'autres drivers FTDI, desactiver
        les hotplugs :
         # rmmod ftdi_sio


5 MAC OS-X
==========

La procedure a suivre est identique a celle de Linux, et a ete testee sur un MacOS
X.3 (Darwin kernel 7.8.0, avec fink). TclTkAquaBi etait installe (voir www.tcl.tk),
et la GSL compilee et installee suivant la procedure standard GNU.

La ligne de commande pour le configure etait pour cette machine:
./configure --with-tcl=/Library/Frameworks/Tcl.framework
            --with-tk=/Library/Frameworks/Tk.framework
            --with-gsl-prefix=/usr/local

Appliquer les commandes suivantes:
make external
make
# Libtt pose probleme : la commande de compilation doit se faire a la main dans
# le repertoire macos:
cd audela/libtt/macos
make
# A la compilation de libtt il peut y avoir le probleme suivant:
# ld: table of contents for archive: ../../../external/lib/libjpeg.a is out of date;
# rerun ranlib(1) (can't load from it)
pushd ../../../external/lib ; ranlib libjpeg.a ; popd
make
cd ../../..
make libcam
make libtel
cd ..

# A la fin de la compilation, dans le repertoire bin il faut renommer les fichier
# libaudela.so et libmc.so en libaudela.dylib et libmc.dylib.
cd bin
mv libaudela.so libaudela.dylib
mv libmc.so libmc.dylib

# Vous pouvez executer audela :
./audela

Le support pour cette plateforme est tout recent, aussi nous sommes tres interesses
par les retours d'experience sur le sujet MacOS-X...

