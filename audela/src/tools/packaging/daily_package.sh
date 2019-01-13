#! /bin/sh
#
# daily_package.sh
#
#   Ce script permet de generer une archive deb et rpm a partir d'un repertoire de dev.
#

set -x

DAILY=`date +%Y%m%d`

BUILD_DIR=audela-2.0.$DAILY
INST_DIR=/usr/lib/audela/2.0.$DAILY
DIRECTORY=$BUILD_DIR$INST_DIR
MACHINE=`uname -m`
if [ $MACHINE = "x86_64" ] ; then
	ARCH=amd64
else
	ARCH=i386
fi
PACKET_NAME=$BUILD_DIR.$ARCH

# Menage
rm -rf $BUILD_DIR
rm -rf $BUILD_DIR.deb
rm -rf rpm

# Creation des fichiers necessaire a l'empaquetage
mkdir -p $BUILD_DIR/DEBIAN
echo "Package: audela
Version: 2.0.$DAILY-$ARCH
Section: science 
Priority: optional
Architecture: $ARCH
Essential: no
Depends: tcl8.5, tk8.5, libgcc1, libstdc++6, gsl-bin
Recommends: gzip, gnuplot, libusb-0.1-4
Installed-Size: 57521
Maintainer: Denis Marchais <denis.marchais@free.fr>
Homepage: http://www.audela.org
Provides: audela
Description: Daily snapshot generated on $DAILY.
" > $BUILD_DIR/DEBIAN/control

echo "#! /bin/bash
ln -s $INST_DIR/bin/audela.sh /usr/bin/audela
" > $BUILD_DIR/DEBIAN/postinst
chmod 755 $BUILD_DIR/DEBIAN/postinst

echo "#! /bin/bash
rm -f /usr/bin/audela
" > $BUILD_DIR/DEBIAN/postrm
chmod 755 $BUILD_DIR/DEBIAN/postrm


# Creation de l'arborescence, copie des repertoires entiers
mkdir -p $DIRECTORY
cp -r ../../../bin $DIRECTORY
cp -r ../../../lib $DIRECTORY
cp -r ../../../gui $DIRECTORY
cp -r ../../../images $DIRECTORY
cp ../../COPYING $DIRECTORY
cp ../../../readme.txt $DIRECTORY

# Petit menage
rm -f $DIRECTORY/bin/version.tcl.in
rm -f $DIRECTORY/bin/audace.txt
rm -f $DIRECTORY/bin/langage.tcl
rm -f $DIRECTORY/bin/Makefile
rm -f $DIRECTORY/gui/config.param
rm -f $DIRECTORY/gui/config.sex
rm -f $DIRECTORY/gui/default.nww


find $DIRECTORY | grep CVS | xargs rm -rf
find $DIRECTORY | grep .svn | xargs rm -rf

# Creation du fichier de demarrage de audela
echo "#!/bin/bash
export LD_LIBRARY_PATH=$INST_DIR/bin:\$LD_LIBRARY_PATH
cd $INST_DIR/bin
./audela $*
" > $DIRECTORY/bin/audela.sh
chmod +x $DIRECTORY/bin/audela.sh

# Creation du paquet
sudo dpkg -b $BUILD_DIR $PACKET_NAME.deb

# Creation du rpm
mkdir rpm
cd rpm
sudo alien -v --to-rpm --scripts ../$PACKET_NAME.deb
mv *.rpm ..
cd ..
rm -rf rpm
