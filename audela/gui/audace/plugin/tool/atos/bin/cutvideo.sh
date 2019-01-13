#!/bin/sh
#
# Coupe une portion de video et reformattage codec (huff) 
#
# usage: $0 video start end
# avec start et end exprimes en seconde
#
video=$1
start=$2
end=$3

if [ "x$start" == "x" -o "x$end" == "x" ]; then
   ffmpeg -i $video -map 0:v -c:v huffyuv "${video%%.*}-atos.avi"
else
   ffmpeg -ss $start -t $end -i $video -map 0:v -c:v huffyuv "${video%%.*}-atos-crop.avi"
fi

