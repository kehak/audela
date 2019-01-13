#!/bin/sh

# Prerequis : existence de la variable globale AUDELADIR
if [ "x$AUDELA_DIR" == "x" -o "x$AUDELA_CNF" == "x" ]; then
  printf "The global variable AUDELA_DIR is not set. Please define it, by adding the following lines into your .bashrc file:\n"
  printf "AUDELA_DIR=/srv/develop/audela\n"
  printf "AUDELA_CNF=~/.audela\n"
  printf "AUDELA_MAIL=my@adress.com"
  printf "export AUDELA_DIR AUDELA_CNF\n"
  printf "\n"
  printf "Pour l envoie de mail verifier la commande suivante : \n"
  printf "    sudo postfix check\n"
  printf "  Si erreur : \n"
  printf "    sudo chgrp -R maildrop /usr/sbin/postqueue /usr/sbin/postdrop \n"
  printf "    sudo chmod g+s /usr/sbin/postqueue /usr/sbin/postdrop\n"
  exit 1
fi

if [ -z "$LD_LIBRARY_PATH" ]; then
 typeset -x LD_LIBRARY_PATH=$chemin
else
 typeset -x LD_LIBRARY_PATH="$AUDELA_DIR/bin:$LD_LIBRARY_PATH"
fi

if [ $# -lt 1 ]; then
   if [ -f "${AUDELA_CNF}/tank.ini"  ]; then
      printf "Utilisation de la conf ${AUDELA_CNF}/tank.ini\n"
   else
      printf "${AUDELA_CNF}/tank.ini n'existe pas, voulez vous en creer un ? (y/N)\n"
      read a
      if [ "x${a}" == "xy" ]; then
          cp $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/tank/tank.ini ${AUDELA_CNF}/tank.ini
          printf "${AUDELA_CNF}/tank.ini cree, veuillez le completer...\n"
          exit 0
      fi
      printf "Veuillez fournir un fichier ini\n"
      exit 0
   fi
else
   printf "Utilisation de la conf %s\n" "$1"
   cp $1 ${AUDELA_CNF}/tank.ini
fi

tps=5
count=0
while [ $count -le 1000 ]
do
   # On tue toutes les instances pouvant exister
   for pid in `ps -edf | grep tank.tcl | awk '{print $2}'`
   do 
      echo "PID = ${pid}"
      kill -9 ${pid}
   done

   # On lance le programme
   count=$(( $count + 1 ))
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/tank/tank.tcl
   err=$?
   echo "TANK : Sortie Audela : ERR = ${err}"

   [ ${err} == 99 ] && exit 0

   # On avertie de la sortie
   echo "----------------------------------------"
   date
   echo `date` > out
   echo `hostname` >> out
   echo `uname -a` >> out
   cat out | mail -s "Audela - Bddimages - Tank : `hostname` STOPPED `date`" $AUDELA_MAIL
   echo "Sleep $tps Sec"
   echo "----------------------------------------"
   sleep $tps
done

exit 0
