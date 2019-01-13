#!/bin/sh

[ $# -lt 1 ] && fic=./nohup.out || fic=$1

if [ ! -f ${fic} ]; then
   printf "Error: $0: fichier de log inconnu (./nohup.out par defaut)\n"
   exit 1
fi

cmd="grep 'SUCCESS' ${fic} | echo \"SUCCES = \$(wc -l)\" &&  grep 'Termine & ERROR' ${fic} | echo \"ERROR  = \$(wc -l)\""
watch ${cmd}
