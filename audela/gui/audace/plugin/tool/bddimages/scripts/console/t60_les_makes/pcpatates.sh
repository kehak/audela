#!/bin/sh

# pkill pcpatates.sh
# pkill audela
# bditmp
# remove *
# nohup pcpatates.sh &
# tail -f nohup.out 
# ps -edf | grep audela
# ps -edf | grep pcpatates.sh

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

tps=1
count=0
while [ $count -ge -1 ]
do
   # On tue toutes les instances pouvant exister
   for pid in `ps -edf | grep tank.tcl | awk '{print $2}'`
   do 
      echo "PID = ${pid}"
      kill -9 ${pid}
   done

   # On lance le programme
   count=$(( $count + 1 ))

   # on effectue une verification avec reparation sur la base. 2 fois...
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/verif/verif.tcl
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/verif/verif.tcl
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/verif/verif.tcl
   
   # on deplace les fichiers vers le incoming
   nbget=$($HOME/bin/getimgbyftp.sh)
   echo "`date` : Recup par ftp nbget = ${nbget}"
   
   # on commence par tout inserer
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/import/import.tcl

   # puis on traite
   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/tank/tank.tcl
   err=$?
   echo "TANK : Sortie Audela : ERR = ${err}"
   
   # on deplace les fichiers vers le incoming
   if [ $err -eq 99 ]; then
      nbget=$($HOME/bin/getimgbyftp.sh)
      echo "`date` : Recup par ftp nbget = ${nbget}"
      while [ $nbget -eq 0 ]
      do
         sleep 180
         nbget=$($HOME/bin/getimgbyftp.sh)
         echo "`date` : Recup par ftp nbget = ${nbget}"
      done
   else
      if [ -f "/bddimages/bdi_t60_les_makes/tmp/nohup.out"  ]; then
         tail -100 /bddimages/bdi_t60_les_makes/tmp/nohup.out \
              | mail -s "[T60lesmakes][TANK] ERROR" \
              frederic.vachier@obspm.fr,jerome.berthier@obspm.fr;
      fi
   fi

done

exit 0
