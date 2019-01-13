#!/bin/sh
#
# Extraction des logs de TANK par SLAVE[i]
#

usage(){
   printf "Usage:\n"
   printf "   %s [-h] [-c <n>] [-f <logfile>] [FIRST [LAST]]\n" "$0"
   printf "\n with:\n"
   printf "     -c <n>        List the last slave status for each n threads.\n"
   printf "     -f <logifle>  Name of the input log file (./nohup.out by default).\n"
   printf "     FIRST, LAST   Ordered numbers of threads. By default, FIRST = LAST = 1.\n"
   printf "\n Example:\n"
   printf "  To list the current work of slaves into ./nohup.out\n"
   printf "    %s i-c 8 \n" "$0"
   printf "  To list all logs for slave 1 to 3 into ./nohup.out\n"
   printf "    %s 1 3\n" "$0"
   printf "  To list all logs for slave 2 into ./nohup.out\n"
   printf "    %s 2\n" "$0"
}

current=0
nbThreads=1
first=1
last=1
fic=./nohup.out

nbarg=0
while getopts :c:hf: option
do
   case "$option" in
    c)
      current=1
      nbThreads=$OPTARG
      ;;
    h)
      usage
      exit 1
      ;;
    f)
      fic=$OPTARG
      ;;
    *)
      printf "$0: Unknown argument, skipped"
      ;;
   esac
done

if [ ! -f ${fic} ]; then
   printf "Error: $0: fichier de log inconnu (./nohup.out par defaut)\n"
   exit 1
fi

if [ $current -eq 1 ]; then
   for i in $(seq 1 $nbThreads)
   do
      grep_tank.sh $i | tail -n 1
   done
   exit 0
fi


if [ $# -ge 1 ]; then
   first=$1
   last=$1
fi

if [ $# -eq 2 ]; then
   last=$2
fi

echo "fic, first, last = $fic, $first, $last"

for i in $(seq $first $last)
do
   printf "\n### SLAVE $i ################################################\n\n"
   grep "SLAVE \[$i\]" ${fic}
done
