audsela/rc/external/libindi/readme.md  

Ce repertoire contient les fichiers indipensables pour compiler les librairies 
de Audela (libindicam et libinditel)  clientes de libindi 
sans avoir a installer libindi sur la machine où Audela est compilé. 

Ce repertoire peut etre remplacé si on ajoute dans la audela/src/configure 
la detection de la presence de lindi et si on stocke dans audela/src/Makefile.defs des 
variables pointant vers les repertoire des includes et des librairies de libindi.