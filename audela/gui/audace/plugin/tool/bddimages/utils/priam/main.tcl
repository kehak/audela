# ******************************************************************
#                     Execution du programme 
# ******************************************************************
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/priam/main.tcl
# source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/priam/main.tcl

# ******************************************************************
#                     Entete Doxygen
# ******************************************************************
##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages a partir de la base de donnees SSP


# ******************************************************************
#                     Avant de commencer :
# ******************************************************************
#
# il est preferable d installer audela, comme pour la structure ros. cad : /srv/develop/audela
# inserer l image et le cata dans ton bddimages local.
# retrouver l idbddimage auquel il correspond
# modifier la valeur suivante pour le bon id :

   set idbddimg 20058

# puis lancer ce code en faisant un copier coller dans la console de la premiere ligne de ce fichier : source ...
# ******************************************************************
# A FAIRE : 
# Modifier le fichier priam.tcl pour qu il genere les fichiers Priam.
# Ajouter une procedure de lancement de Priam
# Ajouter une procedure de verification avant le lancement de Priam (reponse accepted / rejected )
#                        ce qui permet de voir si la donnee est suffisante a priam par exemple.
# Ajouter une procedure d interpretation de resultats de Priam, (accepted/rejected) pour savoir comment ca s est passé.
# ******************************************************************

   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/get_one_image.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/manage_source.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/priam/priam.tcl

   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/get_cata.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/visu.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/imprimlist.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/get_astrometric_catalog.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/photometry.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/identification.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/analyse_source.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/get_skybot.tcl

   source /usr/local/src/audela/gui/audace/vo_tools.tcl
   source /usr/local/src/audela/gui/audace/plugin/tool/av4l/av4l_photom.tcl

   ::bddimagesXML::load_xml_config
   ::bddimagesXML::load_config bddimages_cador

   cleanmark

   gren_info "\n****************************************************************** \n"
   gren_info "** info de la configuration \n"

   gren_info "SSP_PLUGIN: name    : $bddconf(name)    \n"
   gren_info "SSP_PLUGIN: dbname  : $bddconf(dbname)  \n"
   gren_info "SSP_PLUGIN: login   : $bddconf(login)   \n"
   gren_info "SSP_PLUGIN: pass    : $bddconf(pass)    \n"
   gren_info "SSP_PLUGIN: server  : $bddconf(server)  \n"
   gren_info "SSP_PLUGIN: port    : $bddconf(port)    \n"
   gren_info "SSP_PLUGIN: dirbase : $bddconf(dirbase) \n"
   gren_info "SSP_PLUGIN: dirinco : $bddconf(dirinco) \n"
   gren_info "SSP_PLUGIN: dirfits : $bddconf(dirfits) \n"
   gren_info "SSP_PLUGIN: dircata : $bddconf(dircata) \n"
   gren_info "SSP_PLUGIN: direrr  : $bddconf(direrr)  \n"
   gren_info "SSP_PLUGIN: dirlog  : $bddconf(dirlog)  \n"
   gren_info "SSP_PLUGIN: dirtmp  : $bddconf(dirtmp)  \n"
   gren_info "SSP_PLUGIN: limit   : $bddconf(limit)   \n"

   gren_info "\n****************************************************************** \n"
   gren_info "** info de la visu \n"
   gren_info "****************************************************************** \n"

   #set bddconf(visuno) [::visu::create $bddconf(bufno) 1]
   set bddconf(visuno) 1
   set bddconf(bufno) [::confVisu::getBufNo $bddconf(visuno)]
   gren_info "SSP_PLUGIN: bufNo   : $bddconf(bufno)   \n"
   gren_info "SSP_PLUGIN: visuNo  : $bddconf(visuno)   \n"

   gren_info "\n****************************************************************** \n"
   gren_info "** info de la base \n"
   gren_info "****************************************************************** \n"

   # Selection de la bdd
   set err [catch {::bddimages_sql::sql query "use $bddconf(dbname);"} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 1 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }

   # Nombre d image dans bddimages
   set sqlcmd "select count(*) from images;"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE SUR $bddconf(dbname) =<$resultsql>\n\n"

   set sqlcmd    "select count(*) from catas where ssp_date<now()"
   set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      gren_info "SSP_PLUGIN: ERREUR 2 \n"
      gren_info "SSP_PLUGIN:        NUM : <$err> \n" 
      gren_info "SSP_PLUGIN:        MSG : <$msg> \n"
      }
   gren_info "SSP_PLUGIN: NB IMAGE a traiter SUR $bddconf(dbname) =<$resultsql>\n\n"

   set nbimg $resultsql

   gren_info "\n****************************************************************** \n"
   gren_info "** Chargement d'une image \n"
   gren_info "****************************************************************** \n"

#   set r [get_one_image]
   set r [get_one_image_by_idbddimage $idbddimg]
   gren_info "SSP_PLUGIN: result one_ssp   : $r \n"

   gren_info "SSP_PLUGIN:idbddcata  = $ssp_image(idbddcata)\n"
   gren_info "SSP_PLUGIN:idbddimage = $ssp_image(idbddimg)\n"
   gren_info "SSP_PLUGIN:cata       = $ssp_image(dir_cata_file)/$ssp_image(cata_filename)\n"
   gren_info "SSP_PLUGIN:image      = $ssp_image(fits_dir)/$ssp_image(fits_filename)\n"
   gren_info "SSP_PLUGIN:idheader   = $ssp_image(idheader)\n"
   gren_info "SSP_PLUGIN:dateobs    = $ssp_image(dateobs)\n"
   gren_info "SSP_PLUGIN:ra         = $ssp_image(ra)\n"
   gren_info "SSP_PLUGIN:dec        = $ssp_image(dec)\n"
   gren_info "SSP_PLUGIN:telescop   = $ssp_image(telescop)\n"
   gren_info "SSP_PLUGIN:exposure   = $ssp_image(exposure)\n"
   gren_info "SSP_PLUGIN:filter     = $ssp_image(filter)\n"


   gren_info "\n****************************************************************** \n"
   gren_info "** Lecture du CATA \n"
   gren_info "****************************************************************** \n"

   # Recupere les noms des fichiers
   set fitsfile "$bddconf(dirbase)/$ssp_image(fits_dir)/$ssp_image(fits_filename)"
   ::console::affiche_resultat "FILE : $fitsfile\n"
   set catafile "$bddconf(dirbase)/$ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
   ::console::affiche_resultat "CATA : $catafile\n"

   # Recupere le catalogue des sources correspondant a l image
   set listsources [get_cata $catafile]

   # Affichage de l image
   affich_image $fitsfile
   ::console::affiche_resultat "IMAGE AFFICHEE\n"

   # Affichage centre champ de l image
   set centre [list {"CENTRE" {} {} } [list [list [list "CENTRE" [list $ssp_image(ra) $ssp_image(dec)] {}]]]]
   affich_rond $centre "CENTRE" "red" 1

   gren_info "\n****************************************************************** \n"
   gren_info "** Mesures photometriques \n"
   gren_info "****************************************************************** \n"

   set  listsources [::analyse_source::test2 $listsources 1]

   gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   gren_info "\n****************************************************************** \n"
   gren_info "** SkyBot \n"
   gren_info "****************************************************************** \n"
   
   set datejd  [ mc_date2jd $ssp_image(dateobs) ]
   set datejd  [ expr $datejd + $ssp_image(exposure)/86400.0/2.0 ]
   set dateiso [ mc_date2iso8601 $datejd ]
   gren_info "dateiso = $dateiso \n"
   set listskybot [ get_skybot $dateiso $ssp_image(ra) $ssp_image(dec) 1000 809 ]
   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listskybot]\n"

   gren_info "\n****************************************************************** \n"
   gren_info "** Impressions \n"
   gren_info "****************************************************************** \n"

   ::manage_source::imprim_3_sources $listskybot
   ::manage_source::imprim_3_sources $listsources

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " Identification \n"
   gren_info "****************************************************************** \n"

   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listsources]\n"
   set listsources [ identification $listsources "OVNI" $listskybot "SKYBOT" 30.0 10.0 10.0] 
   gren_info "rollup skybot= [::manage_source::get_nb_sources_rollup $listsources]\n"

   ::manage_source::imprim_sources $listsources "SKYBOT"
   affich_rond $listskybot "SKYBOT" "green" 1
   affich_rond $listsources "OVNI" "blue" 1

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " Champs 'common' \n"
   gren_info "****************************************************************** \n"

   #set listsources [::manage_source::set_common_fields $listsources IMG { ra dec 5 calib_mag err_mag }]
   set listsources [::manage_source::set_common_fields $listsources IMG { ra dec 5 calib_mag err_mag }]
   ::manage_source::imprim_3_sources $listsources

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " Chargement TYCHO2 \n"
   gren_info "****************************************************************** \n"

   affich_rond $listsources SKYBOT "green"  3

   gren_info "\n****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info " sortie pour priam\n"
   gren_info "****************************************************************** \n"

   # on extrait les skybot de l image, a la difference de la variable precedente
   # qui pointait vers tous les SKYBOT susceptible d etre dans l image
   set listmesure [::manage_source::extract_sources_by_catalog $listsources SKYBOT]
   ::priam::create_file_oldformat $listsources USNOA2 $listmesure



   # FIN
   gren_info "****************************************************************** \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info "FIN de script\n"


