#!/bin/sh
#
# make_packages.sh [debian/ubuntu/mandriva]
#
#     Ce script permet de generer une archive deb et rpm a partir d'un repertoire de dev.
#
# Version initiale : Denis Marchais
# Version actuelle : Benjamin Mauclaire
#
########################################################################################

# Mise a jour $Id: make_packages.sh,v 1.20 2010-12-19 21:49:32 bmauclaire Exp $


#--- Utilisation du script :
# 1. chmod u+x ./make_packages.sh
# 2. ./make_packages.sh nom_distribution_linux (debian ou ubuntu ou mandriva)
# Rem: les actions root sont faites via sudo) :
#
#--- Compilation sous Debian :
# 1. cd audela/src
# 2. make clean
# 3. chmod u+x ./configure
# 4. ./configure --with-tcl=/usr/share/tcltk/tcl8.5 --with-tk=/usr/share/tcltk/tk8.5
# 5. make external && make contrib && make
# 6. Modifier le numero de version dans audela/bin/version.tcl
#
#--- Compilation multithreadee avant le 10/11/2009 (obsolete) :
# 1. Avoir, dans cet exemple, un repetoire lib contenant les .a de tcltk multithreade au meme niveau que le repertoire audela issu de CVS.
# 2. Compiler tcl/tk avec les options de multithread
# 3. Copier les fichiers libtcl8.4.so et libtk8.4.so multithreadés dans le repertoire audela/bin sinon "plantage Exception point flottant"
# 4. chmod u+x ./configure
# 5. ./configure --with-tcl=/home/mauclaire/audela/lib/lib --with-tk=/home/mauclaire/audela/lib/lib
# 6. make external && make contrib && make // ou make all.
# 7. Renommer les fichiers speciaux libthread2.6.5.1.so_debian (issu de la compilation d'Audela) et placer Thread2.6.5.1.so_mandriva dans le repertoire audela/lib/thread2.6.5.1/
# La version fabriquee sera notee comme multithreadee si les 2 fichiers libtcl8.4.so et libtk8.4.so sont presents dans le rep bin d'Audela.
#
#--- Compilation monothreadee avant le 10/11/2009 (obsolete) :
# 1. chmod u+x ./configure ;
# 2. ./configure
# 3. make external && make contrib && make // ou make all.
#
#--- Modifications a faire avant execution avaltn le 10/11/2009 (obsolete) :
# 1. Que la version soit multithreadee ou non, il faut que les fichiers libtcl8.4.so et libtcl8.4.so soient presents dans /usr/lib/ de la machine destination pour que BLT fonctionne. Donc installer les paquets tcl et tk.
# 2. Effacer le repertoire audela/lib/thread2.6/
# 3. cp audela/src/external/libftd2xx/lib/libftd2xx.so.0.4.16 audela/audela/bin/
# 4. Dans audela/bin : chmod a+x libftd2xx.so.0* ; ln -s libftd2xx.so.0.4.16 libftd2xx.so.0
# 5. Facultatif : donner le bon numero de version dans audela/bin/version.tcl
#
##------------------------------------------------------------------------------#


#--- Variables de focntionnement :
# Visiblement non necessaires : tclxml, tcllib, tclvfs.
#---- Dependances Linux du paquet :
#--- Debian :
#-- debian 8 :
depends_debian="libstdc++6, libgsl0ldbl, gnuplot-x11, libusb-0.1-4, tcl-vfs, libtk-img, tk8.6, tcl-thread"
#-- debian 7 :
# depends_debian="libstdc++6, libgsl0ldbl, gnuplot-x11, libusb-0.1-4, tcl-vfs, libtk-img, tk8.5"
#-- debian 6 :
## depends_debian="tk8.4, libstdc++6, libgsl0, gnuplot-x11, gzip, libusb-0.1-4, tclxml, tcllib, tclvfs, libtk-img, blt"
## depends_debian="libc6, libgcc1, libgsl0, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, tclthread, libx11-6, libxau6, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"

#--- Ubuntu :
#-- ubuntu 15.10 :
depends_ubuntu="tk8.6, libgsl0ldbl | libgsl2, gnuplot-x11, libstdc++6, libusb-0.1-4, libusb-1.0-0, tcl-thread, tcl-vfs, libtk-img"
#-- ubuntu 12.10 :
#depends_ubuntu="libstdc++6, libgsl0ldbl, gnuplot-x11, libusb-0.1-4, tclvfs, libtk-img, tk8.5"
#-- ubuntu 10.04 :
## depends_ubuntu="tk8.4, libstdc++6, libgsl0ldbl, gnuplot-x11, gzip, libusb-0.1-4, tclxml, tcllib, tclvfs, libtk-img, blt"
## depends_ubuntu="libc6, libgcc1, libgsl0ldbl, libstdc++6, libusb-0.1-4, tcl8.4, tk8.4, gnuplot-x11, gzip, tclxml, tcllib, tclvfs, libtk-img, blt"

#--- Mandriva :
depends_mandriva="gsl, libstdc++6, gnuplot, libusb, tcl-tcllib"
# depends_mandriva="libtk8.4, gsl, libstdc++6, gnuplot, gzip, libusb, tcl-tcllib, blt"
# depends_mandriva="glibc, libgcc1, libgphoto, gsl, libstdc++6, libusb, libtcl8.4, libtk8.4, gnuplot, gzip, tcl-tcllib, blt"
# unfound : gnuplot-x11 tclxml tclvfs, libtk-img

#-- Variables d'environnement a parametrer avant utilisation du script :
rep_audela_ready="../../.."
rep_bin="$rep_audela_ready/bin"
rep_audela_src="../.."
#-- A ADAPTER AVEC L'ACTUEL !
sous_rep_libthread="lib/thread2.7.1"  ; # Anciennement : thread2.6.5.1
version_tcltk="8.6" ; # Necessaire pour faire un lien symbolique vers libtcl*.so sur les distro qui ne l'ont pas.
#-- Sont aussi definis apres les choix :
# BUILD_DIR=audela-$DAILY
# INST_DIR=/usr/lib/audela-$DAILY
# DIRECTORY=$BUILD_DIR$INST_DIR
# rep_libtcltk="/usr/lib" ou rep_libtcltk="$INST_DIR/bin"
#- Le paquet s'appelle desormais "audela" et non plus "audela-thread" :
nom_paquet="audela"
lesuffixe=""
rep_libtcltk="/usr/lib"
#-- Determine l'architecture de la machine de compilation :
archi=`uname -m`
case $archi in
  i386) architecture="i386";;
  i686) architecture="i386";;
  x86_64) architecture="amd64";;
  amd64) architecture="amd64";;
esac
lesuffixe="${lesuffixe}-$architecture"

#--- Choix de la distro et parametrages en consequence :
if test "$1" = "debian"
then
    echo "La distribution est une Debian."
    depends="$depends_debian"
    ladistro="$1"
elif test "$1" = "ubuntu"
then
    echo "La distribution est une *Ubuntu."
    depends="$depends_ubuntu"
    ladistro="$1"
elif test "$1" = "mandriva"
then
    echo "La distribution est une Mandriva."
    depends="$depends_mandriva"
    ladistro="$1"
elif test "$1" = "-h"
then
    echo "make_packages.sh [debian/ubuntu/mandriva]"
    exit 0
elif test $# = 0
then
  #--- Desactive car inutilise et pour permettre l'affichage de l'aide :
  if [ 1 -eq 0 ] ; then
    #-- Detection automatique de la distro de la plateforme de travail :
    distro1=`cat /etc/issue`
    distro=`expr "$distro1" : '\(.*\)'`

    if test "`expr "$distro" : '.*\(Debian\).*'`" = "Debian"
    then
        echo "La distribution est une Debian."
        depends="$depends_debian"
        ladistro="debian"
    elif test "`expr "$distro" : '.*\(buntu\).*'`" = "buntu"
    then
        echo "La distribution est une *Ubuntu."
        depends="$depends_ubuntu"
        ladistro="ubuntu"
    else
        echo "La distribution est inconnue."
        depends="$depends_mandriva"
        ladistro="mandriva"
    fi
  fi
  #-------------------------------#
  echo "make_packages.sh [debian/ubuntu/mandriva]"
  exit 0
else
    echo "make_packages.sh [debian/ubuntu/mandriva]"
    exit 0
fi


#--- Construit le numero de version :
#-- En dur :
#DAILY=20080509
#DAILY=`date +"%Y%m%d"`
#-- Dynamique :
#- Ancien :
# noteversion=`grep "audela(version)" $rep_bin/version.tcl | tr -d '"'`
# laversion=`expr "$noteversion" : '.*\s\([0-9]*\.[0-9]*\.[0-9]*\).*'`
#- Nouveau :
ver_major_long=`grep -m 1 "audela(major)" $rep_bin/version.tcl | tr -d '"'`
ver_major=`expr "$ver_major_long" : '.*\s\([0-9]*\).*'`
ver_minor_long=`grep -m 1 "audela(minor)" $rep_bin/version.tcl | tr -d '"'`
ver_minor=`expr "$ver_minor_long" : '.*\s\([0-9]*\).*'`
ver_patch_long=`grep -m 1 "audela(patch)" $rep_bin/version.tcl | tr -d '"'`
ver_patch=`expr "$ver_patch_long" : '.*\s\([0-9]*\).*'`
ver_extra_long=`grep -m 1 "audela(extra)" $rep_bin/version.tcl | tr -d '"'`
if [ "$ver_extra_long" != "" ] ; then
  ver_extra=`expr "$ver_extra_long" : 'set audela(extra)\s\([A-Za-z0-9]*\).*'`
else
  ver_extra=""
fi
# echo "ver_extra=$ver_extra"
laversion="$ver_major.$ver_minor.$ver_patch$ver_extra"
# echo "version=$laversion"
if [ "$laversion" = "" ] ; then
  echo "Numero de version vide !"
  exit
fi

#info_audela=`ls -gGl --time-style=long-iso $rep_bin/audela`
#ladate=`expr "$info_audela" : '.*\([0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]\).*'`
#DAILY=$laversion.`echo $ladate | tr -d '-'`
d1=`grep "audela(date)" $rep_bin/version.tcl | tr -d '"'`
d2=`expr "$d1" : '.*\s\([0-9]*\/[0-9]*\/[0-9]*\).*'`
ladate=`echo "$d2" | sed -e 's/\///g'`
#- DAILY=$laversion-$ladate
DAILY=$laversion
echo "Creation des paquets AudeLA version : $DAILY."

BUILD_DIR=audela-$DAILY
INST_DIR=/usr/lib/audela-$DAILY
DIRECTORY=$BUILD_DIR$INST_DIR

#--- Menage :
#-- Efface les paquets et le repertoire BUIL_DIR :
#- rm -rf $BUILD_DIR
#- sudo rm -rf audela-*
rm -rf audela-*
#- rm -f $BUILD_DIR.deb
rm -rf rpm
#-- Cree le repertoire de fabrication du paquet :
mkdir -p $BUILD_DIR


#--- Creation des fichiers necessaire a l'empaquetage :
echo "Creation des fichiers necessaire a l'empaquetage..."
#-- Gesion multithreadee avec la variable $liens qui seront a realiser en postinst :
if test "$ladistro" != "ubuntu" ; then
  if test ! -e $rep_libtcl/libtcl$version_tcltk.so
  then
    liens="#
#- Fichiers libs .so necessaires pour BLT mais fournis que par les paquets tcl/tk-dev :
ln -s $rep_libtcltk/libtcl$version_tcltk.so.0 $rep_libtcltk/libtcl$version_tcltk.so
ln -s $rep_libtcltk/libtk$version_tcltk.so.0 $rep_libtcltk/libtk$version_tcltk.so
"
    liens=""
  fi
fi


#-- Creation du fichier "control" pour Debian :
mkdir -p $BUILD_DIR/DEBIAN
echo "Package: $nom_paquet
Version: $DAILY
Section: science 
Priority: optional
Architecture: $architecture
Essential: no
Depends: $depends
Installed-Size: 57521
Maintainer: Benjamin MAUCLAIRE <bma.ova@gmail.com>
Provides: audela
Description: Free cross plateform software (Windows, Linux, Mac), allowing the CCD acquisitions, the steering telescopes, processing and exploitation of images and spectra. Automation possible thanks to the TCL scripts. This couples with Sky Charts for the score. Homepage : http://www.audela.org.
" > $BUILD_DIR/DEBIAN/control

# AudeLA is a TCL extension aimed at providing amateur astronomers with image processing, telescope controling, ccd camera driving, and various astronomical algorithms.


#-- Creation du fichier "postinst" pour Debian :
echo "#!/bin/sh
set -e
#--- Cree un lien symbolique pour la derniere version d'Audela instalee :
if test -h /usr/bin/audela ; then rm -f /usr/bin/audela ; fi
ln -s $INST_DIR/bin/audela.sh /usr/bin/audela
$liens

#--- Gestion de libgsl2 qui ne contient pas libgsl.so.0 :
#if [ '`uname -m`' = 'x86_64' ] ; then
  if [ -e /usr/lib/x86_64-linux-gnu/libgsl.so.19.0.0 ] && [ ! -e /usr/lib/x86_64-linux-gnu/libgsl.so.0 ] ; then
    ln -s /usr/lib/x86_64-linux-gnu/libgsl.so.19.0.0 /usr/lib/x86_64-linux-gnu/libgsl.so.0
  fi
#fi

#--- Mise a jour des menus :
case \"\$1\" in
  configure)
    # Automatically added by dh_installmenu
    if [ -x \"`which update-menus 2>/dev/null`\" ]; then
        update-menus
    fi
    # End automatically added section
    ;;
  abord-upgrade|abord-remove|abord-deconfigure)

    ;;
  *)
    echo \"postinst called with unknown argument \'\$1'\" >&2
    exit 1
    ;;
esac
" > $BUILD_DIR/DEBIAN/postinst
chmod 555 $BUILD_DIR/DEBIAN/postinst

#-- Creation du fichier "postrm" pour Debian :
echo "#!/bin/sh
set -e
rm -f /usr/bin/audela
# rm -rf $INST_DIR
#-- Automatically added by dh_installmenu
if [ -x \"`which update-menus 2>/dev/null`\" ]; then update-menus ; fi
#-- End automatically added section
" > $BUILD_DIR/DEBIAN/postrm
chmod 555 $BUILD_DIR/DEBIAN/postrm



#--- Creation de l'arborescence, copie des repertoires entiers :
echo "Creation de l'arborescence, copie des repertoires entiers..."
mkdir -p $DIRECTORY
cp -r $rep_audela_ready/bin $DIRECTORY
cp -r $rep_audela_ready/lib $DIRECTORY
cp -r $rep_audela_ready/gui $DIRECTORY
cp -r $rep_audela_ready/images $DIRECTORY

#--- Petit menage :
echo "Effacement des fichiers et repertoires inutiles..."
#-- Effacement des repertoire .svn
dirw=`pwd`
cd $DIRECTORY
find . -name .svn -print0 | xargs -0 rm -rf
cd $dirw

#-- Reste du menage :
cp $rep_audela_src/COPYING $DIRECTORY
cp $rep_audela_ready/readme.txt $DIRECTORY
rm -f $DIRECTORY/bin/version.tcl.in
find $DIRECTORY | grep CVS | xargs rm -rf
rm -f $DIRECTORY/bin/Makefile
chmod a-x $DIRECTORY/bin/*.so*
cp $DIRECTORY/readme.txt $DIRECTORY/bin/audela.txt
#rm -f $DIRECTORY/bin/audace.txt
#if test -e $DIRECTORY/bin/libtk8.4.so ; then rm -f $DIRECTORY/bin/libtk8.4.so ; fi
#-- Librairies non necessaires sous GNU/Linux :
if test -e $DIRECTORY/lib/tk$version_tcltk ; then rm -rf $DIRECTORY/lib/tk$version_tcltk ; fi
if test -e $DIRECTORY/lib/tcl$version_tcltk ; then rm -rf $DIRECTORY/lib/tcl$version_tcltk ; fi
if test -e $DIRECTORY/lib/tcom ; then rm -rf $DIRECTORY/lib/tcom ; fi
if test -e $DIRECTORY/lib/tls1.6 ; then rm -rf $DIRECTORY/lib/tls1.6 ; fi
if test -e $DIRECTORY/lib/tmci ; then rm -rf $DIRECTORY/lib/tmci ; fi
if test -e $DIRECTORY/lib/twapi ; then rm -rf $DIRECTORY/lib/twapi ; fi


#--- Gestion de libthread :
#if [ "$ladistro" = "debian" ] || [ "$ladistro" = "ubuntu" ]
#then
#    ln -s libthread2.6.5.1.so_debian libthread2.6.5.1.so
if test "$ladistro" = "mandriva"
then
    dirlocal=`pwd`
    cd $DIRECTORY/$sous_rep_libthread
    #- cp -f /home/mauclaire/Audela/audela-cvs/binlibs/libthread/Thread2.6.5.1.so_mandriva libthread2.6.5.1.so
    cp -f libthread2.6.5.1.so libthread2.6.5.1.so.dflt
    cp -f ../../../../../../../../../../binlibs/libthread/Thread2.6.5.1.so_mandriva libthread2.6.5.1.so
    cd $dirlocal
fi
#-- Desactive l'utilisation de la lib thread*.dll presente dans Audela :
if [ -e $DIRECTORY/$sous_rep_libthread/pkgIndex.tcl ] ; then
    mv -f $DIRECTORY/$sous_rep_libthread/pkgIndex.tcl $DIRECTORY/$sous_rep_libthread/_pkgIndex.tcl
fi


#--- Creation du fichier de demarrage d'Audela :
echo "#!/bin/sh
export LD_LIBRARY_PATH=$INST_DIR/bin:\$LD_LIBRARY_PATH
cd $INST_DIR/bin
./audela \$*
" > $DIRECTORY/bin/audela.sh
chmod +x $DIRECTORY/bin/audela.sh
#- sudo chown -R root.root $DIRECTORY/*
## sudo chmod a+w $DIRECTORY/bin/audace.txt


#--- Creation du fichier d'entree pour la presence d'Audela dans le menu du gestionnaire de fenetres :
#- La derniere version du logo (AK) se trouve dans audela/src/audela/audela/linux
mkdir -p $BUILD_DIR/usr/share/applications/
echo "[Desktop Entry]
Name=AudeLA
Comment=Astronomy images and spectra processing, telescope controling, and ccd camera driving software
Comment[fr]=Logiciel de traitement d'images et de spectres astronomiques, de contôle de télescopes et de pilotage de caméra ccd
Exec=audela
Icon=audela.xpm
Terminal=false
Type=Application
Categories=Astronomy;Science;Education;
" > $BUILD_DIR/usr/share/applications/audela.desktop
chmod a+r $BUILD_DIR/usr/share/applications/audela.desktop
#- sudo chown -R root.root $BUILD_DIR/usr/share/*

mkdir $BUILD_DIR/usr/share/menu
echo "?package(audela):needs=\"X11\" section=\"Applications/Science\" \\
  title=\"AudeLA\" \\
  longtitle=\"AudeLA: astronomy software\" \\
  hints=\"AudeLA: astronomy software\" \\
  command=\"/usr/bin/audela\" \\
  icon=\"/usr/share/pixmaps/audela.xpm\"
" > $BUILD_DIR/usr/share/menu/audela

mkdir $BUILD_DIR/usr/share/pixmaps
cp audela.xpm $BUILD_DIR/usr/share/pixmaps/


#--- Creation du paquet :
echo "Creation du paquet Debian..."
#- sudo dpkg -b $BUILD_DIR $BUILD_DIR$lesuffixe.deb
#- luser=`whoami`
#- sudo chown $luser.$luser *.deb
#-- dpkg-buildpackage -b -ai386 -rfakeroot ou Rapide : fakeroot debian/rules binary
fakeroot dpkg -b $BUILD_DIR $BUILD_DIR$lesuffixe.deb
if test -e $BUILD_DIR$lesuffixe.deb ; then
   echo "Paquet DEB cree."
else
   echo "Echec à la création du paquet DEB."
fi


#--- Creation du rpm :
if test "$ladistro" = "mandriva"
then
    echo "Creation du paquet RPM..."
    #-- Creation d'un repertoire rpm car des fichiers sont crees :
    mkdir rpm
    cd rpm
    #-- Fabrication du paquet rpm :
    #- sudo alien -v --to-rpm --scripts ../$BUILD_DIR$lesuffixe.deb
    #- sudo chown $luser.$luser *.rpm
    fakeroot alien -v --to-rpm --scripts ../$BUILD_DIR$lesuffixe.deb
    #-- Menage :
    mv *.rpm ..
    cd ..
    rm -rf rpm
    rm -f *.deb
    if test -e $BUILD_DIR$lesuffixe.rpm ; then
       echo "Paquet RPM cree."
    else
       echo "Echec à la création du paquet RPM."
    fi
fi

rm -rf $BUILD_DIR

#--- Fin du script :


