#!/bin/sh
LD_LIBRARY_PATH=/usr/local/lib:/opt/intel/lib/intel64
export LD_LIBRARY_PATH
/usr/local/bin/ephemcc asteroide -n 45 -j /mnt/userdata/mylinux/develop/audela/gui/audace/plugin/tool/bddimages/utils/prediction/dateforephem.dat 1 -tp 1 -te 1 -tc 5 -d 1 -e utc --julien -g -0.413962962963 47.02666666666 680
