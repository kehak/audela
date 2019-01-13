#!/bin/sh

if [ ! `id -u` -eq 0 ]; then
	echo "You must run this script as root"
	exit 2
fi

ARCH=`arch`

# TODO compilation
BASE_DIR=/usr/local/xcap/drivers/$ARCH
DIR=$BASE_DIR/`uname -r`
if [ ! -e $BASE_DIR ]; then
	echo "Unable to find the driver for your architecture"
	exit 1
fi
if [ ! -e $DIR ]; then
	echo "You must compile the PIXCI driver for your kernel"
  VERSION_1=`uname -r | awk '{split($1,a,"\n"); split(a[1],b,"."); print b[1];}'`
  VERSION_2=`uname -r | awk '{split($1,a,"\n"); split(a[1],b,"."); print b[2];}'`
	if [ $VERSION_1 -eq 2 ] && [ $VERSION_2 -eq 6 ]; then
		SRC_DIR="$BASE_DIR/src_2.6"
	elif [ $VERSION_1 == "3" ]; then
		SRC_DIR="$BASE_DIR/src_3.x"
	else
		echo "Unsupported kernel version"
		exit 1
	fi

	echo -n "Entering the source directory..."
	cd $SRC_DIR
	echo "done."

	echo  "Compiling the driver..."
	make
	echo "done."

	echo -n "Moving the driver in the right directory..."
	mkdir $DIR
	mv $SRC_DIR/pixci_$ARCH.ko $DIR/pixci_$ARCH.ko
	echo "done."
	
fi

BH=1671168
OPT=10
PART=524288
TIMESTAMP=2 #using do_gettimeofday()
#TIMESTAMP=1 #using jiffies
#MEM=8388608 #8G
#MEM=16777216 #16G
#MEM=25165824 #24G
MEM=31457280 #30G

if [ `lsmod | grep pixci | wc -l` -eq 1 ]; then
	echo "Driver already loaded"
else
	echo -n "Loading driver..."
	insmod $DIR/pixci_x86_64.ko PIXCIPARM=-IM\_$MEM\_-MU\_$OPT\_-MB\_$PART\_-MH\_$BH\_-TI\_$TIMESTAMP
	echo "done"
fi

echo -n "Creating device..."
rm -f /dev/pixci
DEV=`awk "\\$2==\"PIXCI(R)\" {print \\$1}" /proc/devices`
mknod /dev/pixci c $DEV 0
chmod 666 /dev/pixci
echo "done"
exit 0
