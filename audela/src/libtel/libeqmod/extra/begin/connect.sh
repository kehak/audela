#!/bin/bash
#Bus 003 Device 005:
lsu=`lsusb| grep "Future Technology"`
lsu=`echo $lsu | sed 's/ Device /\//'`
lsu=`echo $lsu | sed 's/Bus //'`
lsu=`echo $lsu | sed 's/:.*//g'`
echo "Device USB = /dev/bus/usb/$lsu"

uv=`udevadm info -q path -n /dev/bus/usb/$lsu`
#echo "uv = $uv"

ma=`udevadm info -a -p $uv | grep manufacturer | grep FTDI | wc -l`
echo "Connected (O No, 1 Yes) = $ma"

ls -al /dev/bus/usb/$lsu
ls -al /dev/ttyUSB0
