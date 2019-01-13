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
      printf ""
   else
      printf -1
      exit 0
   fi
else
   printf "Utilisation de la conf %s\n" "$1"
   cp $1 ${AUDELA_CNF}/tank.ini
fi

   $AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/tank/tank.todo.tcl
   err=$?
   [ ${err} == 99 ] && exit 0
