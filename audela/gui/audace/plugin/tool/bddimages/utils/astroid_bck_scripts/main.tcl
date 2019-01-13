
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/main.tcl


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

source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_one_image.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_cata.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/imprimlist.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/visu.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/get_astrometric_catalog.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/photometry.tcl
source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/astroid/identification.tcl
source /srv/develop/audela/gui/audace/vo_tools.tcl


::confVisu::addZoomListener $::audace(visuNo) "efface_rond"
::confVisu::addMirrorListener $::audace(visuNo) "efface_rond"
::confVisu::addFileNameListener $::audace(visuNo) "efface_rond"

set err [read_default_config "~/.audela/bddimages_ini.xml"]

   # Selection de la bdd
   set err [catch {::bddimages_sql::sql query "use $bddconf(dbname);"} msg]
   if {$err} {
      gren_info "solarsystemprocess: ERREUR 1 \n"
      gren_info "solarsystemprocess:        NUM : <$err> \n" 
      gren_info "solarsystemprocess:        MSG : <$msg> \n"
      }

   # Nombre d image dans bddimages
   set sqlcmd "select count(*) from images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "solarsystemprocess: ERREUR 2 \n"
      gren_info "solarsystemprocess:        NUM : <$err> \n" 
      gren_info "solarsystemprocess:        MSG : <$msg> \n"
      }
   ::console::affiche_resultat "NB IMAGE SUR $bddconf(dbname) =<$resultsql>\n\n"

   # Recupere une image de la base de donnees
   get_one_image

   ::console::affiche_resultat "GET_ONE_IMAGE\n"
   foreach n { idbddcata cata_filename dir_cata_file idbddimg idheader 
               fits_filename fits_dir header_tabname dateobs ra dec telescop 
               exposure filter } { 
               ::console::affiche_resultat "$n  =<$ssp_image($n)>\n"
               }

   # Recupere les noms des fichiers
   set fitsfile "$bddconf(dirbase)/$ssp_image(fits_dir)/$ssp_image(fits_filename)"
   ::console::affiche_resultat "FILE : $fitsfile\n"
   set catafile "$bddconf(dirbase)/$ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
   ::console::affiche_resultat "CATA : $catafile\n"

   # Recupere le catalogue des sources correspondant a l image
   set listsources [get_cata $catafile]

   # Affichage la liste des sources
   #imprim_sources $listsources

   # Affichage de l image
   affich_image $fitsfile
   ::console::affiche_resultat "IMAGE AFFICHEE\n"

   # Affichage centre champ de l image
   set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $ssp_image(ra) $ssp_image(dec)] {}]]]]
   affich_rond $centre "CENTRE" "red" 7
   ::console::affiche_resultat "ROND ROUGE: centre du champ provenant du header fits\n"
  

   # Recupere le catalog astrometrique
   set astrometric_list [get_astrometric_catalog $ssp_image(ra) $ssp_image(dec) 30]

   # Affichage des ronds verts
   affich_rond $astrometric_list "TYCHO2" "blue" 2
   ::console::affiche_resultat "ROND BLEU: Etoiles tycho 2\n"

   set astrometric_list [add_sun_star "TYCHO2" $astrometric_list]

   # Affichage des ronds verts
   affich_rond $astrometric_list "SUNLIKE" "yellow" 2
   ::console::affiche_resultat "ROND JAUNE: Etoiles de type solaire\n"

   set starident [ identification $listsources "USNOA2" $astrometric_list "TYCHO2" 30.0 10.0 10.0 ]
   affich_rond $starident "TYCHO2" "red" 2

