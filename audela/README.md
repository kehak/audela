#AudeLA-INDI

##This is an AudeLA-trunk fork with INDI compatibility.

Please test in a fresh Ubuntu Bionic 18.04 install. Debian Buster should work too.

###Dependencies:
  sudo apt-get install indi-bin 
  sudo apt-get install subversion gcc g++ make autoconf 
  sudo apt-get install linux-libc-dev tk8.6-dev libgsl-dev libftdi-dev libgphoto2-dev libindi-dev  libv4l-dev 
  sudo apt-get remove tk8.6-blt2.5 
  sudo apt-get install libindi-dev 

###Atik driver:
  sudo dpkg -i atikccd-1.30-amd64.deb
  sudo apt-get install libnova-0.16-0 
  sudo apt-get install libnova-dev 
  
###ASI driver:
  This driver ships with a proprietary binary blob so won't be bundled with the distro.

  sudo apt install cmake
  
  Retrieve the release from https://github.com/indilib/indi/releases
  (ex: wget https://github.com/indilib/indi/archive/v1.7.1.tar.gz )
  **use the same release as installed on your distribution**
  
  Extract and cd to the indi dir
  (ex: tar xzf v1.7.1.tar.gz; cd indi-1.7.1)
  mkdir -p build/indi-asi
  cd build/indi-asi
  cmake -DCMAKE_INSTALL_PREFIX=/usr ../../3rdparty/indi-asi
  make
  make install
  
  Optionally, install the udev rule:
  mkdir -p build/asi-common
  cd build/asi-common
  cmake -DCMAKE_INSTALL_PREFIX=/usr ../../3rdparty/asi-common
  make
  make install
  
  Check with indiserver indi_asi_ccd
  
