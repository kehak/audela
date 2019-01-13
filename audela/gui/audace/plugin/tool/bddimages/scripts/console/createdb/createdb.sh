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

$AUDELA_DIR/bin/audela --console --file $AUDELA_DIR/gui/audace/plugin/tool/bddimages/scripts/console/createdb/load_audela.tcl

