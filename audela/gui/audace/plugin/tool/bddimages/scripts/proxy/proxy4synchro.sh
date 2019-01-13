#!/bin/sh
#
# Start a proxy to connect to remote bddimages databases
# Default inputs provide an access to IMCCE servers
# 2014 J. Berthier & F. Vachier, IMCCE
#

USER=""
REMOTE_SERVER=audela.imcce.fr
GATE=valeriane.imcce.fr
PORT_IN=12345
PORT_OU=12345

usage() {
  printf "\nScript de mise en place d'un proxy ssh pour etablir une connection avec un\n"
  printf "serveur situe a l'interieur d'un reseau distant (par defaut audela.imcce.fr).\n\n"
  printf "Usage: $0 -u <user> [OPTS]\n"
  printf " with:\n"
  printf "       -u <user>    User login (e.g. berthier)\n"
  printf " and OPTS:\n"
  printf "       -g <gate>    Gateway (default %s)\n" ${GATE}
  printf "       -p <port>    Local port to connect (default %s)\n" ${PORT_IN}
  printf "       -q <port>    Remote port to connect (default %s)\n\n" ${PORT_OU}
  printf "       -r <server>  Remote server to connect (default ${REMOTE_SERVER})\n"
  printf "Examples:\n"
  printf "$0 -u berthier -r ${REMOTE_SERVER} -g ${GATE} -p ${PORT_IN} -q ${PORT_OU}\n"
  exit 0
}

# Lecture des options sur la ligne de commande
while getopts "g:p:q:r:u:h" Option
do
  case $Option in
    g ) GATE=$OPTARG;;
    p ) PORT_IN=$OPTARG;;
    q ) PORT_OU=$OPTARG;;
    r ) REMOTE_SERVER=$OPTARG;;
    u ) USER=$OPTARG;;
    h|* ) usage;;
  esac
done

[ "x${USER}" == "x" ] && printf "Error: unknown user (arg -u)\n" && exit 1
[ "x${REMOTE_SERVER}" == "x" ] && printf "Error: unknown remote server (arg -r)\n" && exit 1

# Mise en place du proxy
printf "Connection to remote serveur ${REMOTE_SERVER} on port ${PORT_IN}->${PORT_OU}\n"
printf "Enter Ctrl-c to close the connection\n"
ssh -N -L ${PORT_IN}:${REMOTE_SERVER}:${PORT_OU} ${USER}@${GATE}

