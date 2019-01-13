#!/bin/sh

# Prerequis : existence de la variable globale AUDELADIR
if [ "x$AUDELA_DIR" == "x" -o "x$AUDELA_CNF" == "x" ]; then
  printf "The global variable AUDELA_DIR is not set. Please define it, by adding the following lines into your .bashrc file:\n"
  printf "AUDELA_DIR=/srv/develop/audela\n"
  printf "AUDELA_CNF=~/.audela\n"
  printf "export AUDELA_DIR AUDELA_CNF\n"
  exit 1
fi

if [ -z "$LD_LIBRARY_PATH" ]; then
 typeset -x LD_LIBRARY_PATH=$chemin
else
 typeset -x LD_LIBRARY_PATH="$AUDELA_DIR/bin:$LD_LIBRARY_PATH"
fi

if [ $# -lt 1 ]; then
   if [ -f "${AUDELA_CNF}/bdi.server.synchro.ini"  ]; then
      printf "Utilisation de la conf ${AUDELA_CNF}/bdi.server.synchro.ini\n"
   else
      printf "${AUDELA_CNF}/bdi.server.synchro.ini n'existe pas, voulez vous en creer un ? (y/N)\n"
      read a
      if [ "x${a}" == "xy" ]; then
          cp $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/synchro/bdi.server.synchro.ini ${AUDELA_CNF}/bdi.server.synchro.ini
          printf "${AUDELA_CNF}/bdi.server.synchro.ini cree, veuillez le completer...\n"
          exit 0
      fi
      printf "Veuillez fournir un fichier ini\n"
      exit 0
   fi
else
   printf "Utilisation de la conf %s\n" "$1"
   cp $1 ${AUDELA_CNF}/bdi.server.synchro.ini
fi

$AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/synchro/bdi.server.synchro.tcl

