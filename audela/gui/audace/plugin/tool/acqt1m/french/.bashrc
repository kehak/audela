# Sample .bashrc for SuSE Linux
# Copyright (c) SuSE GmbH Nuernberg

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# If you want to use a Palm device with Linux, uncomment the two lines below.
# For some (older) Palm Pilots, you might need to set a lower baud rate
# e.g. 57600 or 38400; lowest is 9600 (very slow!)
#
#export PILOTPORT=/dev/pilot
#export PILOTRATE=115200

test -s ~/.alias && . ~/.alias || true

export IFORT="/opt/intel/bin"
export LIBIFORT="/opt/intel/lib/intel64"
export MPICH2="/usr/local/mpich2-install/bin"
export WCSTOOLS="/usr/local/src/wcstools-3.8.1/bin"
export GENOIDE="/usr/local/src/genoide/calculs/genoide-1.0"
export GENOIDEWWW="/usr/local/src/genoide/www"
export DIRCLIENTCADOR="/srv/develop/ros_private_cador/client_cador"
export EPD="/usr/local/src/epd-6.2-2-rh5-x86/bin"
export MATLABDIR="/usr/local/matlab/bin/"

PGPLOT_DIR=/usr/local/lib/pgplot
PGPLOT_FONT=$PGPLOT_DIR/grfont.dat
PGPLOT_ENV=/xwin
PGPLOT_DEV=/xserve
export PGPLOT_DIR PGPLOT_FONT PGPLOT_ENV PGPLOT_DEV 

export PATH=$WCSTOOLS:$MPICH2:$IFORT:$MATLABDIR:$EPD:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$GENOIDE/lib:$LD_LIBRARY_PATH:$LIBIFORT:$PGPLOT_DIR 

export CVS_RSH=ssh








test -s ~/.alias && . ~/.alias || true
source ~/.eclipse-rc
test -s ~/.prompt && . ~/.prompt || true
