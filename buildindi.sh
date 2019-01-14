#!/bin/bash

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

cd
echo -e "\e[33m--> Retrieving indi v1.3\e[0m"
wget -c https://github.com/indilib/indi/archive/v1.3.tar.gz

echo -e "\e[33m--> Extracting archive\e[0m"
tar xzf ./v1.3.tar.gz && cd ./indi-1.3
mkdir -p build/libindi
cd build/libindi
echo -e "\e[33m--> Building...\e[0m"
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Debug ../../libindi
make -j4
sudo make install

echo -e "\e[33m--> Building drivers...\e[0m"

for DRV in libapogee libfishcamp libsbig libqsi libqhy libfli fliusb generic-ccd; do build_driver $DRV; done

for DRV in indi-aagcloudwatcher indi-apogee indi-asi indi-dsi indi-duino indi-eqmod indi-ffmv indi-fishcamp indi-fli indi-gige indi-gphoto indi-gpsd indi-maxdomeii indi-mi indi-nexstarevo indi-qhy indi-qsi indi-sbig indi-shelyak indi-spectracyber indi-ssag indi-sx indi-tess
do
	build_driver $DRV 
done

echo -e "\e[33mInstalled drivers:\e[0m"
ls /usr/local/bin/indi_*
