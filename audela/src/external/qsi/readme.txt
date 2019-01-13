# $Id: calaphot_calcul.tcl 7116 2011-04-07 15:26:19Z jacquesmichelet
=====
Windows : Le répertoire qsi contient les bibliothèques de QSI pré-compilée pour Windows
=====
Linux : Le répertoire qsiapi-x.y.z contient le code source de la bibliothèque de QSI pour Linux, code qu'il faut donc compiler. 
Le fichier Makefile est en charge de cette compilation pour Linux. Il gère les commandes build, install (qui inclue build), clean, distclean et uninstall.
Les fichier résultats (.so) sont copiés dans le répertoires external/lib. Les fichiers exécutables de test (qsiapitest et qsidemo) de cette librairie sont rangés dans un sous-répertoire bin de qsiapi.x.y.z.

