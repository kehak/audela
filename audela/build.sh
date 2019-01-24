#!/bin/sh
cd src
autoconf
./configure
make external 
make contrib 
make
