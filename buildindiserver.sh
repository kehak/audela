#!/bin/bash

#
# This will download, build and install libindi $RELEASE with all the 3rd-party drivers
#

# Desired release:
RELEASE=1.8.0

#--- Driver list:
#- Selection:
lib_list="libapogee libfishcamp libsbig libqsi libqhy libfli fliusb generic-ccd"
driver_list="indi-apogee indi-asi indi-dsi indi-eqmod indi-fli indi-gphoto indi-mi indi-qhy indi-qsi indi-sbig indi-ssag indi-sx"

#- Everything (do not edit)
#api_list_all="libapogee libfishcamp libsbig libqsi libqhy libfli fliusb generic-ccd"
#driver_list_all="indi-aagcloudwatcher indi-apogee indi-asi indi-dsi indi-duino indi-eqmod indi-ffmv indi-fishcamp indi-fli indi-gige indi-gphoto indi-gpsd indi-maxdomeii indi-mi indi-nexstarevo indi-qhy indi-qsi indi-sbig indi-shelyak indi-spectracyber indi-ssag indi-sx indi-tess"

#--- Functions:
build_driver() {
	cd ..
	mkdir $1
	cd $1
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local ../../3rdparty/$1
	make -j4
	sudo make install
	sudo ldconfig
}

if [ ! -e "/usr/bin/sudo" ]; then
	echo "sudo not found. Aborting."
	exit 1
fi

sudo true

echo -e  "\e[33m--> Removing stock libindi...\e[0m"
sudo apt remove -y libindi-dev libindi-data libindi-plugins

echo -e "\e[33m--> Installing dependencies...\e[0m"
sudo apt install -y libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtiff-dev

echo -e "\e[33m--> Retrieving indi v$RELEASE\e[0m"
cd; wget -c https://github.com/indilib/indi/archive/v$RELEASE.tar.gz

echo -e "\e[33m--> Extracting archive\e[0m"
tar xzf ./v$RELEASE.tar.gz && cd ./indi-$RELEASE
mkdir -p build/libindi
cd build/libindi

echo -e "\e[33m--> Building...\e[0m"
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Debug ../../libindi
make -j4
sudo make install

echo -e "\e[33m--> Building drivers...\e[0m"
for DRV in $lib_list ; do build_driver $DRV; done
for DRV in $driver_list; do build_driver $DRV; done

echo -e "\e[33mInstalled drivers:\e[0m"
ls /usr/local/bin/indi_*
