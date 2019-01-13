#!/bin/bash
# execute testUTC and other control scripts

if [ $# -lt 3 ]; then
	echo "Usage: $0 control_file output_file iteration_number"
	exit -1
fi

controlfile=$1
outfile=$2
itnum=$3
# perform the test
./testUTC $itnum $outfile >/dev/null
# get Meinberg status
mbgstatus > $controlfile
# get the ntp status
ntpq -c rl >> $controlfile
# get the kernel status
ntpdc -c kerninfo >> $controlfile
# get the used NTP servers
ntpq -p >> $controlfile

