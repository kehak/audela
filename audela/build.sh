#!/bin/sh
cd src
autoconf
./configure
make -j 2 external 
make -j 2 contrib 
make
