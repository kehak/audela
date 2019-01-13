
# source  $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_votable/main.tcl

##
# @file
#
# @author fv
#
# @brief Traitement des archives dans bddimages a partir de la base de donnees SSP

   source [file join $bddconf(astroid) libastroid.tcl]

   source /usr/local/src/audela/gui/audace/vo_tools.tcl

   ::bddimagesXML::load_xml_config
   ::bddimagesXML::load_config bddimages_cador
    get_info

   set tt0 [clock clicks -milliseconds]

   gren_info "\n****************************************************************** \n"
   gren_info "** Chargement d'une image \n"
   gren_info "****************************************************************** \n"


   set r [get_one_image]
   #set r [get_one_image 1071388]


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

   set catafile "$bddconf(dirbase)/$ssp_image(dir_cata_file)/$ssp_image(cata_filename)"
   ::console::affiche_resultat "CATA : $catafile\n"

   # Recupere le catalogue des sources correspondant a l image
   set listsources [get_cata_txt $catafile]

   gren_info "\n****************************************************************** \n"
   gren_info "** Impressions \n"
   gren_info "****************************************************************** \n"

   ::manage_source::imprim_3_sources $listsources


   gren_info "\n****************************************************************** \n"
   gren_info "** ecrit le VOTABLE \n"
   gren_info "****************************************************************** \n"

   write_cata_votable $listsources

   # FIN
   gren_info "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n"
   gren_info "** [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: "
   gren_info "FIN de script\n"
   
   set tt1 [clock clicks -milliseconds]
   set tt [expr ($tt1 - $tt0)/1000.]
   gren_info "Total duration $tt sec \n"
   gren_info "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ \n"

   


