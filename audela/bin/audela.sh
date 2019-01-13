#!/bin/bash
#------ Benjamin Mauclaire 2004 for AudeLA's team ---------#

echo -e "Lancement AudeLA..."

link=`readlink -f $0`

if [ -z "$link" ]; then
 chemin=`dirname $0`
else
 chemin=`dirname $link`
fi

if [ -z "$LD_LIBRARY_PATH" ]; then
 typeset -x LD_LIBRARY_PATH=$chemin
else
 typeset -x LD_LIBRARY_PATH="$chemin:$LD_LIBRARY_PATH"
fi

exec ${chemin}/audela "$@"
