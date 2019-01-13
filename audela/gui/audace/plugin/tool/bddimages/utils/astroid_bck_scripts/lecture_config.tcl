
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/lecture_config.tcl


##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages

##
# creation de fonctions utiles pour socreq
#
global ssp_image


source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/config.tcl


set err [read_default_config "/srv/develop/audela/gui/audace/plugin/tool/bddimages/config/bddimages_cador_fv.xml"]

::console::affiche_resultat "NAME)       =$bddconf(name)    \n"
::console::affiche_resultat "DBNAME)     =$bddconf(dbname)  \n"
::console::affiche_resultat "LOGIN)      =$bddconf(login)   \n"
::console::affiche_resultat "PASS)       =$bddconf(pass)    \n"
::console::affiche_resultat "IP)         =$bddconf(serv)    \n"
::console::affiche_resultat "PORT)       =$bddconf(port)    \n"
::console::affiche_resultat "ROOT)       =$bddconf(dirbase) \n"
::console::affiche_resultat "INCOMING)   =$bddconf(dirinco) \n"
::console::affiche_resultat "FITS)       =$bddconf(dirfits) \n"
::console::affiche_resultat "CATA)       =$bddconf(dircata) \n"
::console::affiche_resultat "ERROR)      =$bddconf(direrr)  \n"
::console::affiche_resultat "LOG)        =$bddconf(dirlog)  \n"
::console::affiche_resultat "SCREENLIMIT)=$bddconf(limit)   \n"

