## @file bdi_gui_cata.tcl
#  @brief     GUI de cr&eacute;ation des catalogues des images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_cata.tcl]
#  @endcode

# $Id: bdi_gui_cata.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_cata
# @brief GUI de cr&eacute;ation des catalogues des images
# @pre Requiert \c tools_cata .
# @pre Requiert le fichier d'internationalisation \c bdi_gui_cata.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_cata {

   global audace
   global bddconf

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.cap ]\""

   variable current_image
   variable current_cata
   variable fen
   variable stateback
   variable statenext
   variable current_appli

   variable color_button_good "green"
   variable color_button_bad  "red"
   variable color_wcs      
   variable color_cata      
   variable bddimages_wcs 

   variable gui_next 
   variable gui_back
   variable gui_create
   variable gui_fermer
   variable gui_nomimage
   variable gui_dateimage
   variable gui_stimage
   variable gui_wcs
   variable bdi_gui_cata
   variable gui_info
   variable gui_info2

   variable gui_img
   variable gui_usnoa2
   variable gui_ucac2
   variable gui_ucac3
   variable gui_ucac4
   variable gui_ppmx
   variable gui_ppmxl
   variable gui_tycho2
   variable gui_nomad1
   variable gui_2mass
   variable gui_wfibc
   variable gui_sdss
   variable gui_panstarrs
   variable gui_gaia1
   variable gui_skybot
   variable gui_astroid

   variable size_img
   variable size_usnoa2
   variable size_ucac2
   variable size_ucac3
   variable size_ucac4
   variable size_ppmx
   variable size_ppmxl
   variable size_nomad1
   variable size_2mass
   variable size_wfibc
   variable size_tycho2
   variable size_sdss
   variable size_panstarrs
   variable size_gaia1
   variable size_skybot
   variable size_astroid
   variable size_ovni

   variable color_img    
   variable color_usnoa2 
   variable color_ucac2  
   variable color_ucac3  
   variable color_ucac4  
   variable color_ppmx   
   variable color_ppmxl  
   variable color_nomad1 
   variable color_2mass  
   variable color_wfibc
   variable color_tycho2 
   variable color_sdss
   variable color_panstarrs
   variable color_gaia1
   variable color_skybot 
   variable color_ovni   
   variable color_astroid

   variable dssvisu
   variable dssbuf 

   variable man_xy_star
   variable man_ad_star

   variable use_uncosmic

   variable gui_astroid_bestdelta

}


#--------------------------------------------------
#
#  Structure de la liste image
#
# {               -- debut de liste
#
#   {             -- debut d une image
#
#     {ibddimg 1}
#     {ibddcata 2}
#     {filename toto.fits.gz}
#     {dirfilename /.../}
#     {filenametmp toto.fit}
#     {cataexist 1}
#     {cataloaded 1}
#     ...
#     {tabkey {{NAXIS1 1024} {NAXIS2 1024}} }
#     {cata {{{IMG {ra dec ...}{USNO {...]}}}} { { {IMG {4.3 -21.5 ...}} {USNOA2 {...}} } {source2} ... } } }
#
#   }             -- fin d une image
#
# }               -- fin de liste
#
#--------------------------------------------------
#
#  Structure du tabkey
#
# { {TELESCOP { {TELESCOP} {TAROT CHILI} string {Observatory name} } }
#   {NAXIS2   { {NAXIS2}   {1024}        int    {}                 } }
#    etc ...
# }
#
#--------------------------------------------------
#
#  Structure du cata
#
# {               -- debut structure generale
#
#  {              -- debut des noms de colonne des catalogues
#
#   { IMG   {list field crossmatch} {list fields}} 
#   { TYC2  {list field crossmatch} {list fields}}
#   { USNO2 {list field crossmatch} {list fields}}
#
#  }              -- fin des noms de colonne des catalogues
#
#  {              -- debut des sources
#
#   {             -- debut premiere source
#
#    { IMG   {crossmatch} {fields}}  -> vue dans l image
#    { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#    { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#
#   }             -- fin premiere source
#
#  }              -- fin des sources
#
# }               -- fin structure generale
#
#--------------------------------------------------
#
#  Structure intellilist_i (dite inteligente)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist           { 
#                        { valide     ... }
#                        { condition  ... }
#                        { champ      ... }
#                        { valeur     ... }
#                      }
#
#   }
#
# }
#
#--------------------------------------------------
#
#  Structure intellilist_n (dite normale)
#
#
# {
#   {name               ...  }
#   {datemin            ...  }
#   {datemax            ...  }
#   {type_req_check     ...  }
#   {type_requ          ...  }
#   {choix_limit_result ...  }
#   {limit_result       ...  }
#   {type_result        ...  }
#   {type_select        ...  }
#   {reqlist            { 
#                         {image_34 {134 345 677}}
#                         {image_38 {135 344 679}}
#                       }
#
#   }
#
# }
#
#--------------------------------------------------
# IMG CATALOG
# 0   id 
# 1   flag 
# 2   xpos 
# 3   ypos 
# 4   instr_mag 
# 5   err_mag 
# 6   flux_sex 
# 7   err_flux_sex 
# 8   ra 
# 9   dec 
# 10  calib_mag 
# 11  calib_mag_ss1 
# 12  err_calib_mag_ss1 
# 13  calib_mag_ss2 
# 14  err_calib_mag_ss2 
# 15  nb_neighbours 
# 16  radius 
# 17  background_sex 
# 18  x2_momentum_sex 
# 19  y2_momentum_sex 
# 20  xy_momentum_sex 
# 21  major_axis_sex 
# 22  minor_axis_sex 
# 23  position_angle_sex 
# 24  fwhm_sex 
# 25  flag_sex


proc ::bdi_gui_cata::inittoconf { } {

   global conf

   ::tools_cata::inittoconf

   # Check button GUI

   if {! [info exists ::bdi_gui_cata::gui_img] } {
      if {[info exists conf(bddimages,cata,gui_img)]} {
         set ::bdi_gui_cata::gui_img $conf(bddimages,cata,gui_img)
      } else {
         set ::bdi_gui_cata::gui_img 1
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_usnoa2] } {
      if {[info exists conf(bddimages,cata,gui_usnoa2)]} {
         set ::bdi_gui_cata::gui_usnoa2 $conf(bddimages,cata,gui_usnoa2)
      } else {
         set ::bdi_gui_cata::gui_usnoa2 1
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_ucac2] } {
      if {[info exists conf(bddimages,cata,gui_ucac2)]} {
         set ::bdi_gui_cata::gui_ucac2 $conf(bddimages,cata,gui_ucac2)
      } else {
         set ::bdi_gui_cata::gui_ucac2 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_ucac3] } {
      if {[info exists conf(bddimages,cata,gui_ucac3)]} {
         set ::bdi_gui_cata::gui_ucac3 $conf(bddimages,cata,gui_ucac3)
      } else {
         set ::bdi_gui_cata::gui_ucac3 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_ucac4] } {
      if {[info exists conf(bddimages,cata,gui_ucac4)]} {
         set ::bdi_gui_cata::gui_ucac4 $conf(bddimages,cata,gui_ucac4)
      } else {
         set ::bdi_gui_cata::gui_ucac4 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_ppmx] } {
      if {[info exists conf(bddimages,cata,gui_ppmx)]} {
         set ::bdi_gui_cata::gui_ppmx $conf(bddimages,cata,gui_ppmx)
      } else {
         set ::bdi_gui_cata::gui_ppmx 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_ppmxl] } {
      if {[info exists conf(bddimages,cata,gui_ppmxl)]} {
         set ::bdi_gui_cata::gui_ppmxl $conf(bddimages,cata,gui_ppmxl)
      } else {
         set ::bdi_gui_cata::gui_ppmxl 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_tycho2] } {
      if {[info exists conf(bddimages,cata,gui_tycho2)]} {
         set ::bdi_gui_cata::gui_tycho2 $conf(bddimages,cata,gui_tycho2)
      } else {
         set ::bdi_gui_cata::gui_tycho2 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_nomad1] } {
      if {[info exists conf(bddimages,cata,gui_nomad1)]} {
         set ::bdi_gui_cata::gui_nomad1 $conf(bddimages,cata,gui_nomad1)
      } else {
         set ::bdi_gui_cata::gui_nomad1 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_2mass] } {
      if {[info exists conf(bddimages,cata,gui_2mass)]} {
         set ::bdi_gui_cata::gui_2mass $conf(bddimages,cata,gui_2mass)
      } else {
         set ::bdi_gui_cata::gui_2mass 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_wfibc] } {
      if {[info exists conf(bddimages,cata,gui_wfibc)]} {
         set ::bdi_gui_cata::gui_wfibc $conf(bddimages,cata,gui_wfibc)
      } else {
         set ::bdi_gui_cata::gui_wfibc 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_sdss] } {
      if {[info exists conf(bddimages,cata,gui_sdss)]} {
         set ::bdi_gui_cata::gui_sdss $conf(bddimages,cata,gui_sdss)
      } else {
         set ::bdi_gui_cata::gui_sdss 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_panstarrs] } {
      if {[info exists conf(bddimages,cata,gui_panstarrs)]} {
         set ::bdi_gui_cata::gui_panstarrs $conf(bddimages,cata,gui_panstarrs)
      } else {
         set ::bdi_gui_cata::gui_panstarrs 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_gaia1] } {
      if {[info exists conf(bddimages,cata,gui_gaia1)]} {
         set ::bdi_gui_cata::gui_gaia1 $conf(bddimages,cata,gui_gaia1)
      } else {
         set ::bdi_gui_cata::gui_gaia1 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_skybot] } {
      if {[info exists conf(bddimages,cata,gui_skybot)]} {
         set ::bdi_gui_cata::gui_skybot $conf(bddimages,cata,gui_skybot)
      } else {
         set ::bdi_gui_cata::gui_skybot 0
      }
   }
   if {! [info exists ::bdi_gui_cata::gui_astroid] } {
      if {[info exists conf(bddimages,cata,gui_astroid)]} {
         set ::bdi_gui_cata::gui_astroid $conf(bddimages,cata,gui_astroid)
      } else {
         set ::bdi_gui_cata::gui_astroid 0
      }
   }

   # Taille des ronds
   if {! [info exists ::bdi_gui_cata::size_img] } {
      if {[info exists conf(bddimages,cata,size_img)]} {
         set ::bdi_gui_cata::size_img $conf(bddimages,cata,size_img)
      } else {
         set ::bdi_gui_cata::size_img 1
      }
   }
   set ::bdi_gui_cata::size_img_sav $::bdi_gui_cata::size_img
   
   if {! [info exists ::bdi_gui_cata::size_usnoa2] } {
      if {[info exists conf(bddimages,cata,size_usnoa2)]} {
         set ::bdi_gui_cata::size_usnoa2 $conf(bddimages,cata,size_usnoa2)
      } else {
         set ::bdi_gui_cata::size_usnoa2 1
      }
   }
   set ::bdi_gui_cata::size_usnoa2_sav $::bdi_gui_cata::size_usnoa2
   
   if {! [info exists ::bdi_gui_cata::size_ucac2] } {
      if {[info exists conf(bddimages,cata,size_ucac2)]} {
         set ::bdi_gui_cata::size_ucac2 $conf(bddimages,cata,size_ucac2)
      } else {
         set ::bdi_gui_cata::size_ucac2 1
      }
   }
   set ::bdi_gui_cata::size_ucac2_sav $::bdi_gui_cata::size_ucac2
   
   if {! [info exists ::bdi_gui_cata::size_ucac3] } {
      if {[info exists conf(bddimages,cata,size_ucac3)]} {
         set ::bdi_gui_cata::size_ucac3 $conf(bddimages,cata,size_ucac3)
      } else {
         set ::bdi_gui_cata::size_ucac3 1
      }
   }
   set ::bdi_gui_cata::size_ucac3_sav $::bdi_gui_cata::size_ucac3
   
   if {! [info exists ::bdi_gui_cata::size_ucac4] } {
      if {[info exists conf(bddimages,cata,size_ucac4)]} {
         set ::bdi_gui_cata::size_ucac4 $conf(bddimages,cata,size_ucac4)
      } else {
         set ::bdi_gui_cata::size_ucac4 1
      }
   }
   set ::bdi_gui_cata::size_ucac4_sav $::bdi_gui_cata::size_ucac4

   if {! [info exists ::bdi_gui_cata::size_ppmx] } {
      if {[info exists conf(bddimages,cata,size_ppmx)]} {
         set ::bdi_gui_cata::size_ppmx $conf(bddimages,cata,size_ppmx)
      } else {
         set ::bdi_gui_cata::size_ppmx 1
      }
   }
   set ::bdi_gui_cata::size_ppmx_sav $::bdi_gui_cata::size_ppmx

   if {! [info exists ::bdi_gui_cata::size_ppmxl] } {
      if {[info exists conf(bddimages,cata,size_ppmxl)]} {
         set ::bdi_gui_cata::size_ppmxl $conf(bddimages,cata,size_ppmxl)
      } else {
         set ::bdi_gui_cata::size_ppmxl 1
      }
   }
   set ::bdi_gui_cata::size_ppmxl_sav $::bdi_gui_cata::size_ppmxl

   if {! [info exists ::bdi_gui_cata::size_nomad1] } {
      if {[info exists conf(bddimages,cata,size_nomad1)]} {
         set ::bdi_gui_cata::size_nomad1 $conf(bddimages,cata,size_nomad1)
      } else {
         set ::bdi_gui_cata::size_nomad1 1
      }
   }
   set ::bdi_gui_cata::size_nomad1_sav $::bdi_gui_cata::size_nomad1

   if {! [info exists ::bdi_gui_cata::size_2mass] } {
      if {[info exists conf(bddimages,cata,size_2mass)]} {
         set ::bdi_gui_cata::size_2mass $conf(bddimages,cata,size_2mass)
      } else {
         set ::bdi_gui_cata::size_2mass 1
      }
   }
   set ::bdi_gui_cata::size_2mass_sav $::bdi_gui_cata::size_2mass
   
   if {! [info exists ::bdi_gui_cata::size_wfibc] } {
      if {[info exists conf(bddimages,cata,size_wfibc)]} {
         set ::bdi_gui_cata::size_wfibc $conf(bddimages,cata,size_wfibc)
      } else {
         set ::bdi_gui_cata::size_wfibc 1
      }
   }
   set ::bdi_gui_cata::size_wfibc_sav $::bdi_gui_cata::size_wfibc

   if {! [info exists ::bdi_gui_cata::size_tycho2] } {
      if {[info exists conf(bddimages,cata,size_tycho2)]} {
         set ::bdi_gui_cata::size_tycho2 $conf(bddimages,cata,size_tycho2)
      } else {
         set ::bdi_gui_cata::size_tycho2 1
      }
   }
   set ::bdi_gui_cata::size_tycho2_sav $::bdi_gui_cata::size_tycho2

   if {! [info exists ::bdi_gui_cata::size_sdss] } {
      if {[info exists conf(bddimages,cata,size_sdss)]} {
         set ::bdi_gui_cata::size_sdss $conf(bddimages,cata,size_sdss)
      } else {
         set ::bdi_gui_cata::size_sdss 1
      }
   }
   set ::bdi_gui_cata::size_sdss_sav $::bdi_gui_cata::size_sdss

   if {! [info exists ::bdi_gui_cata::size_panstarrs] } {
      if {[info exists conf(bddimages,cata,size_panstarrs)]} {
         set ::bdi_gui_cata::size_panstarrs $conf(bddimages,cata,size_panstarrs)
      } else {
         set ::bdi_gui_cata::size_panstarrs 1
      }
   }
   set ::bdi_gui_cata::size_panstarrs_sav $::bdi_gui_cata::size_panstarrs

   if {! [info exists ::bdi_gui_cata::size_gaia1] } {
      if {[info exists conf(bddimages,cata,size_gaia1)]} {
         set ::bdi_gui_cata::size_gaia1 $conf(bddimages,cata,size_gaia1)
      } else {
         set ::bdi_gui_cata::size_gaia1 1
      }
   }
   set ::bdi_gui_cata::size_gaia1_sav $::bdi_gui_cata::size_gaia1

   if {! [info exists ::bdi_gui_cata::size_skybot] } {
      if {[info exists conf(bddimages,cata,size_skybot)]} {
         set ::bdi_gui_cata::size_skybot $conf(bddimages,cata,size_skybot)
      } else {
         set ::bdi_gui_cata::size_skybot 1
      }
   }
   set ::bdi_gui_cata::size_skybot_sav $::bdi_gui_cata::size_skybot

   if {! [info exists ::bdi_gui_cata::size_astroid] } {
      if {[info exists conf(bddimages,cata,size_astroid)]} {
         set ::bdi_gui_cata::size_astroid $conf(bddimages,cata,size_astroid)
      } else {
         set ::bdi_gui_cata::size_astroid 1
      }
   }
   set ::bdi_gui_cata::size_astroid_sav $::bdi_gui_cata::size_astroid

   if {! [info exists ::bdi_gui_cata::size_ovni] } {
      if {[info exists conf(bddimages,cata,size_ovni)]} {
         set ::bdi_gui_cata::size_ovni $conf(bddimages,cata,size_ovni)
      } else {
         set ::bdi_gui_cata::size_ovni 1
      }
   }
   set ::bdi_gui_cata::size_ovni_sav $::bdi_gui_cata::size_ovni

   # Couleurs des cata
   if {! [info exists ::bdi_gui_cata::color_img] } {
      if {[info exists conf(bddimages,cata,color_img)]} {
         set ::bdi_gui_cata::color_img $conf(bddimages,cata,color_img)
      } else {
         set ::bdi_gui_cata::color_img "red"
      }
   }
   set ::bdi_gui_cata::color_img_sav $::bdi_gui_cata::color_img
   
   if {! [info exists ::bdi_gui_cata::color_usnoa2] } {
      if {[info exists conf(bddimages,cata,color_usnoa2)]} {
         set ::bdi_gui_cata::color_usnoa2 $conf(bddimages,cata,color_usnoa2)
      } else {
         set ::bdi_gui_cata::color_usnoa2 "green"
      }
   }
   set ::bdi_gui_cata::color_usnoa2_sav $::bdi_gui_cata::color_usnoa2
   
   if {! [info exists ::bdi_gui_cata::color_ucac2] } {
      if {[info exists conf(bddimages,cata,color_ucac2)]} {
         set ::bdi_gui_cata::color_ucac2 $conf(bddimages,cata,color_ucac2)
      } else {
         set ::bdi_gui_cata::color_ucac2 "cyan"
      }
   }
   set ::bdi_gui_cata::color_ucac2_sav $::bdi_gui_cata::color_ucac2

   if {! [info exists ::bdi_gui_cata::color_ucac3] } {
      if {[info exists conf(bddimages,cata,color_ucac3)]} {
         set ::bdi_gui_cata::color_ucac3 $conf(bddimages,cata,color_ucac3)
      } else {
         set ::bdi_gui_cata::color_ucac3 "#006cc0"
      }
   }
   set ::bdi_gui_cata::color_ucac3_sav $::bdi_gui_cata::color_ucac3
   
   if {! [info exists ::bdi_gui_cata::color_ucac4] } {
      if {[info exists conf(bddimages,cata,color_ucac4)]} {
         set ::bdi_gui_cata::color_ucac4 $conf(bddimages,cata,color_ucac4)
      } else {
         set ::bdi_gui_cata::color_ucac4 "#0000ff"
      }
   }
   set ::bdi_gui_cata::color_ucac4_sav $::bdi_gui_cata::color_ucac4

   if {! [info exists ::bdi_gui_cata::color_ppmx] } {
      if {[info exists conf(bddimages,cata,color_ppmx)]} {
         set ::bdi_gui_cata::color_ppmx $conf(bddimages,cata,color_ppmx)
      } else {
         set ::bdi_gui_cata::color_ppmx "orange"
      }
   }
   set ::bdi_gui_cata::color_ppmx_sav $::bdi_gui_cata::color_ppmx

   if {! [info exists ::bdi_gui_cata::color_ppmxl] } {
      if {[info exists conf(bddimages,cata,color_ppmxl)]} {
         set ::bdi_gui_cata::color_ppmxl $conf(bddimages,cata,color_ppmxl)
      } else {
         set ::bdi_gui_cata::color_ppmxl "orange"
      }
   }
   set ::bdi_gui_cata::color_ppmxl_sav $::bdi_gui_cata::color_ppmxl

   if {! [info exists ::bdi_gui_cata::color_nomad1] } {
      if {[info exists conf(bddimages,cata,color_nomad1)]} {
         set ::bdi_gui_cata::color_nomad1 $conf(bddimages,cata,color_nomad1)
      } else {
         set ::bdi_gui_cata::color_nomad1 "#b4b308"
      }
   }
   set ::bdi_gui_cata::color_nomad1_sav $::bdi_gui_cata::color_nomad1

   if {! [info exists ::bdi_gui_cata::color_2mass] } {
      if {[info exists conf(bddimages,cata,color_2mass)]} {
         set ::bdi_gui_cata::color_2mass $conf(bddimages,cata,color_2mass)
      } else {
         set ::bdi_gui_cata::color_2mass "#b4b308"
      }
   }
   set ::bdi_gui_cata::color_2mass_sav $::bdi_gui_cata::color_2mass
   
   if {! [info exists ::bdi_gui_cata::color_wfibc] } {
      if {[info exists conf(bddimages,cata,color_wfibc)]} {
         set ::bdi_gui_cata::color_wfibc $conf(bddimages,cata,color_wfibc)
      } else {
         set ::bdi_gui_cata::color_wfibc "#b4b308"
      }
   }
   set ::bdi_gui_cata::color_wfibc_sav $::bdi_gui_cata::color_wfibc

   if {! [info exists ::bdi_gui_cata::color_tycho2] } {
      if {[info exists conf(bddimages,cata,color_tycho2)]} {
         set ::bdi_gui_cata::color_tycho2 $conf(bddimages,cata,color_tycho2)
      } else {
         set ::bdi_gui_cata::color_tycho2 "orange"
      }
   }
   set ::bdi_gui_cata::color_tycho2_sav $::bdi_gui_cata::color_tycho2

   if {! [info exists ::bdi_gui_cata::color_sdss] } {
      if {[info exists conf(bddimages,cata,color_sdss)]} {
         set ::bdi_gui_cata::color_sdss $conf(bddimages,cata,color_sdss)
      } else {
         set ::bdi_gui_cata::color_sdss "cyan"
      }
   }
   set ::bdi_gui_cata::color_sdss_sav $::bdi_gui_cata::color_sdss
   
   if {! [info exists ::bdi_gui_cata::color_panstarrs] } {
      if {[info exists conf(bddimages,cata,color_panstarrs)]} {
         set ::bdi_gui_cata::color_panstarrs $conf(bddimages,cata,color_panstarrs)
      } else {
         set ::bdi_gui_cata::color_panstarrs "cyan"
      }
   }
   set ::bdi_gui_cata::color_panstarrs_sav $::bdi_gui_cata::color_panstarrs

   if {! [info exists ::bdi_gui_cata::color_gaia1] } {
      if {[info exists conf(bddimages,cata,color_gaia1)]} {
         set ::bdi_gui_cata::color_gaia1 $conf(bddimages,cata,color_gaia1)
      } else {
         set ::bdi_gui_cata::color_gaia1 "green"
      }
   }
   set ::bdi_gui_cata::color_gaia1_sav $::bdi_gui_cata::color_gaia1

   if {! [info exists ::bdi_gui_cata::color_skybot] } {
      if {[info exists conf(bddimages,cata,color_skybot)]} {
         set ::bdi_gui_cata::color_skybot $conf(bddimages,cata,color_skybot)
      } else {
         set ::bdi_gui_cata::color_skybot "magenta"
      }
   }
   set ::bdi_gui_cata::color_skybot_sav $::bdi_gui_cata::color_skybot

   if {! [info exists ::bdi_gui_cata::color_astroid] } {
      if {[info exists conf(bddimages,cata,color_astroid)]} {
         set ::bdi_gui_cata::color_astroid $conf(bddimages,cata,color_astroid)
      } else {
         set ::bdi_gui_cata::color_astroid "purple"
      }
   }
   set ::bdi_gui_cata::color_astroid_sav $::bdi_gui_cata::color_astroid

   # Uncosmic or not
   if {! [info exists ::bdi_gui_cata::use_uncosmic] } {
      if {[info exists conf(bddimages,cata,use_uncosmic)]} {
         set ::bdi_gui_cata::use_uncosmic $conf(bddimages,cata,use_uncosmic)
      } else {
         set ::bdi_gui_cata::use_uncosmic 1
      }
   }
   if {! [info exists ::tools_cdl::uncosm_param1] } {
      if {[info exists conf(bddimages,cata,uncosm_param1)]} {
         set ::tools_cdl::uncosm_param1 $conf(bddimages,cata,uncosm_param1)
      } else {
         set ::tools_cdl::uncosm_param1 0.8
      }
   }
   if {! [info exists ::tools_cdl::uncosm_param2] } {
      if {[info exists conf(bddimages,cata,uncosm_param2)]} {
         set ::tools_cdl::uncosm_param2 $conf(bddimages,cata,uncosm_param2)
      } else {
         set ::tools_cdl::uncosm_param2 100
      }
   }

   ::bdi_gui_cata::closetoconf

}


proc ::bdi_gui_cata::closetoconf { } {

   global conf

   ::tools_cata::closetoconf

   # Specifique a GUI cata
   set conf(bddimages,cata,gui_img)       $::bdi_gui_cata::gui_img
   set conf(bddimages,cata,gui_usnoa2)    $::bdi_gui_cata::gui_usnoa2
   set conf(bddimages,cata,gui_ucac2)     $::bdi_gui_cata::gui_ucac2
   set conf(bddimages,cata,gui_ucac3)     $::bdi_gui_cata::gui_ucac3
   set conf(bddimages,cata,gui_ucac4)     $::bdi_gui_cata::gui_ucac4
   set conf(bddimages,cata,gui_ppmx)      $::bdi_gui_cata::gui_ppmx
   set conf(bddimages,cata,gui_ppmxl)     $::bdi_gui_cata::gui_ppmxl
   set conf(bddimages,cata,gui_tycho2)    $::bdi_gui_cata::gui_tycho2
   set conf(bddimages,cata,gui_nomad1)    $::bdi_gui_cata::gui_nomad1
   set conf(bddimages,cata,gui_2mass)     $::bdi_gui_cata::gui_2mass
   set conf(bddimages,cata,gui_wfibc)     $::bdi_gui_cata::gui_wfibc
   set conf(bddimages,cata,gui_sdss)      $::bdi_gui_cata::gui_sdss
   set conf(bddimages,cata,gui_panstarrs) $::bdi_gui_cata::gui_panstarrs
   set conf(bddimages,cata,gui_gaia1)     $::bdi_gui_cata::gui_gaia1
   set conf(bddimages,cata,gui_skybot)    $::bdi_gui_cata::gui_skybot
   set conf(bddimages,cata,gui_astroid)   $::bdi_gui_cata::gui_astroid
   
   # Uncosmic or not!
   set conf(bddimages,cata,use_uncosmic)  $::bdi_gui_cata::use_uncosmic
   set conf(bddimages,cata,uncosm_param1) $::tools_cdl::uncosm_param1
   set conf(bddimages,cata,uncosm_param2) $::tools_cdl::uncosm_param2

   # Taille des ronds
   set conf(bddimages,cata,size_img)       $::bdi_gui_cata::size_img
   set conf(bddimages,cata,size_usnoa2)    $::bdi_gui_cata::size_usnoa2
   set conf(bddimages,cata,size_ucac2)     $::bdi_gui_cata::size_ucac2
   set conf(bddimages,cata,size_ucac3)     $::bdi_gui_cata::size_ucac3
   set conf(bddimages,cata,size_ucac4)     $::bdi_gui_cata::size_ucac4
   set conf(bddimages,cata,size_ppmx)      $::bdi_gui_cata::size_ppmx
   set conf(bddimages,cata,size_ppmxl)     $::bdi_gui_cata::size_ppmxl
   set conf(bddimages,cata,size_nomad1)    $::bdi_gui_cata::size_nomad1
   set conf(bddimages,cata,size_tycho2)    $::bdi_gui_cata::size_tycho2
   set conf(bddimages,cata,size_2mass)     $::bdi_gui_cata::size_2mass
   set conf(bddimages,cata,size_wfibc)     $::bdi_gui_cata::size_wfibc
   set conf(bddimages,cata,size_sdss)      $::bdi_gui_cata::size_sdss
   set conf(bddimages,cata,size_panstarrs) $::bdi_gui_cata::size_panstarrs
   set conf(bddimages,cata,size_gaia1)     $::bdi_gui_cata::size_gaia1
   set conf(bddimages,cata,size_skybot)    $::bdi_gui_cata::size_skybot
   set conf(bddimages,cata,size_astroid)   $::bdi_gui_cata::size_astroid
   set conf(bddimages,cata,size_ovni)      $::bdi_gui_cata::size_ovni

   # Couleurs des cata
   set conf(bddimages,cata,color_img)       $::bdi_gui_cata::color_img
   set conf(bddimages,cata,color_usnoa2)    $::bdi_gui_cata::color_usnoa2
   set conf(bddimages,cata,color_ucac2)     $::bdi_gui_cata::color_ucac2
   set conf(bddimages,cata,color_ucac3)     $::bdi_gui_cata::color_ucac3
   set conf(bddimages,cata,color_ucac4)     $::bdi_gui_cata::color_ucac4
   set conf(bddimages,cata,color_ppmx)      $::bdi_gui_cata::color_ppmx
   set conf(bddimages,cata,color_ppmxl)     $::bdi_gui_cata::color_ppmxl
   set conf(bddimages,cata,color_nomad1)    $::bdi_gui_cata::color_nomad1
   set conf(bddimages,cata,color_tycho2)    $::bdi_gui_cata::color_tycho2
   set conf(bddimages,cata,color_2mass)     $::bdi_gui_cata::color_2mass
   set conf(bddimages,cata,color_wfibc)     $::bdi_gui_cata::color_wfibc
   set conf(bddimages,cata,color_sdss)      $::bdi_gui_cata::color_sdss
   set conf(bddimages,cata,color_panstarrs) $::bdi_gui_cata::color_panstarrs
   set conf(bddimages,cata,color_gaia1)     $::bdi_gui_cata::color_gaia1
   set conf(bddimages,cata,color_skybot)    $::bdi_gui_cata::color_skybot
   set conf(bddimages,cata,color_astroid)   $::bdi_gui_cata::color_astroid

}



proc ::bdi_gui_cata::affiche_current_image { } {

   global bddconf

   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]

   loadima $file
   if {$::bdi_gui_cata::use_uncosmic} {
      ::tools_cdl::myuncosmic $::audace(bufNo)
   }
   ::audace::autovisu $::audace(visuNo)

}



proc ::bdi_gui_cata::loadDSS { fichier_fits_dss ra dec fov_x_deg fov_y_deg naxis1 naxis2 crota2} {
   #set url "http://skyview.gsfc.nasa.gov/cgi-bin/runquery.pl"
   set url "https://skyview.gsfc.nasa.gov/current/cgi/runquery.pl"
   set sentence "Position=%s,%s&Size=%s,%s&Pixels=%s,%s&Rotation=%s&Survey=DSS&Scaling=Linear&Projection=Tan&Coordinates=J2000&Return=FITS"
   set query [ format $sentence [mc_angle2deg $ra] [mc_angle2deg $dec 90] $fov_x_deg $fov_y_deg $naxis1 $naxis2 $crota2 ]
   ::bdi_gui_cata::downloadURL "$url" "$query" $fichier_fits_dss
}



proc ::bdi_gui_cata::downloadURL { url query fichier } {
   package require http
   package require tls

   ::http::register https 443 ::tls::socket
   set tok [ ::http::geturl "$url" -query "$query" ]
   upvar #0 $tok state   
   set f [ open $fichier w ]
   fconfigure $f -translation binary
   puts -nonewline $f [ ::http::data $tok ]
   close $f
   ::http::cleanup $tok
}



proc ::bdi_gui_cata::getDSS { } {

   gren_info "Get DSS image @ RA=$::tools_cata::ra deg, DEC=$::tools_cata::dec deg, fov=$::tools_cata::radius arcmin..."

   if {$::tools_cata::radius == ""} { set ::tools_cata::radius 15.0 }
   if {$::tools_cata::crota2 == ""} { set ::tools_cata::crota2 0.0 }

   set naxis1 600
   set naxis2 600
   set fov_x_deg [expr $::tools_cata::radius/60.]
   set fov_y_deg [expr $::tools_cata::radius/60.]
   ::bdi_gui_cata::loadDSS dss.fit $::tools_cata::ra $::tools_cata::dec $fov_x_deg $fov_y_deg $naxis1 $naxis2 $::tools_cata::crota2

   set ::bdi_gui_cata::dssvisu [ ::confVisu::create ]
   set ::bdi_gui_cata::dssbuf  [ visu$::bdi_gui_cata::dssvisu buf   ]
   buf$::bdi_gui_cata::dssbuf load dss.fit
   buf$::bdi_gui_cata::dssbuf setkwd {CROTA2 $crota2 double "" ""}
   ::audace::autovisu $::bdi_gui_cata::dssvisu

}




# Anciennement ::bdi_gui_cata::load_cata

proc ::bdi_gui_cata::load_cata {  } {

   global bddconf

   set catafilenameexist [::bddimages_liste::lexist $::tools_cata::current_image "catafilename"]
   if {$catafilenameexist == 0} {return}

   set catafilename [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
   set catadirfilename [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
      
   set catafile [file join $bddconf(dirbase) $catadirfilename $catafilename]
   set errnum [catch {set catafile [::tools_cata::extract_cata_xml $catafile]} msg ]
   if {$errnum} {
      return -code $errnum $msg
   }

   # Charge la liste des sources depuis les cata (les common sont vides)
   set listsources [::tools_cata::get_cata_xml $catafile]

   # Affecte les common selon le cata
   set listsources [::bdi_tools_sources::set_common_fields $listsources IMG       { ra dec 5.0 calib_mag_ss2 err_calib_mag_ss2 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources USNOA2    { ra_deg dec_deg 5.0 magR 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources UCAC2     { ra_deg dec_deg e_pos_deg U2Rmag_mag 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources UCAC3     { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources UCAC4     { ra_deg dec_deg sigra_deg im2_mag sigmag_mag }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources 2MASS     { ra_deg dec_deg err_dec jMag jMagError }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources TYCHO2    { RAdeg DEdeg 5.0 VT e_VT }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources PPMX      { RAJ2000 DECJ2000 errDec Vmag ErrVmag }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources PPMXL     { RAJ2000 DECJ2000 errDec magR1 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources NOMAD1    { RAJ2000 DECJ2000 errDec magV 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources WFIBC     { RA_deg DEC_deg error_Delta magR error_magR }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources SDSS      { ra dec 0.5 r Err_r }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources PANSTARRS { ramean decmean decmeanerr gmeanapmag gmeanapmagerr }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources GAIA1     { ra dec ra_error phot_g_mean_mag 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources SKYBOT    { ra de errpos magV 0.5 }]
   set listsources [::bdi_tools_sources::set_common_fields $listsources ASTROID   { ra dec 5.0 mag err_mag }]
   ::bdi_tools_cata_user::set_common_fields_on_listsources listsources

   set ::tools_cata::nb_img       [::manage_source::get_nb_sources_by_cata $listsources IMG]
   set ::tools_cata::nb_astroid   [::manage_source::get_nb_sources_by_cata $listsources ASTROID]
   set ::tools_cata::nb_skybot    [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
   set ::tools_cata::nb_gaia1     [::manage_source::get_nb_sources_by_cata $listsources GAIA1]
   set ::tools_cata::nb_sdss      [::manage_source::get_nb_sources_by_cata $listsources SDSS]
   set ::tools_cata::nb_panstarrs [::manage_source::get_nb_sources_by_cata $listsources PANSTARRS]
   set ::tools_cata::nb_usnoa2    [::manage_source::get_nb_sources_by_cata $listsources USNOA2]
   set ::tools_cata::nb_tycho2    [::manage_source::get_nb_sources_by_cata $listsources TYCHO2]
   set ::tools_cata::nb_ucac2     [::manage_source::get_nb_sources_by_cata $listsources UCAC2]
   set ::tools_cata::nb_ucac3     [::manage_source::get_nb_sources_by_cata $listsources UCAC3]
   set ::tools_cata::nb_ucac4     [::manage_source::get_nb_sources_by_cata $listsources UCAC4]
   set ::tools_cata::nb_ppmx      [::manage_source::get_nb_sources_by_cata $listsources PPMX]
   set ::tools_cata::nb_ppmxl     [::manage_source::get_nb_sources_by_cata $listsources PPMXL]
   set ::tools_cata::nb_nomad1    [::manage_source::get_nb_sources_by_cata $listsources NOMAD1]
   set ::tools_cata::nb_2mass     [::manage_source::get_nb_sources_by_cata $listsources 2MASS]
   set ::tools_cata::nb_wfibc     [::manage_source::get_nb_sources_by_cata $listsources WFIBC]

   set ::tools_cata::current_listsources $listsources

   return [::manage_source::get_nb_sources $listsources]
}




proc ::bdi_gui_cata::save_cata {  } {

   global bddconf

   set id_current_image 0
   foreach current_image $::tools_cata::img_list {

      # Tabkey
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      # Liste des sources
      incr id_current_image
      set listsources $::bdi_gui_cata::cata_list($id_current_image)
      # Noms du fichier cata
      set imgfilename [::bddimages_liste::lget $current_image filename]
      set imgdirfilename [::bddimages_liste::lget $current_image dirfilename]
      set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
      set cataxml "${f}_cata.xml"

      ::tools_cata::save_cata $listsources $tabkey $cataxml

   }

}





# Anciennement ::bdi_gui_cata::affiche_cata

proc ::bdi_gui_cata::affiche_cata { } {

   cleanmark

   set err 0
   set err [catch {

      set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
      if {$cataexist == 0} {
         return -code 0 "NOCATA"
      }

      if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"] == "1"} {
         ::bdi_gui_cata::load_cata
      } else {
         return -code 0 "NOCATA"
      }

      if { $::bdi_gui_cata::gui_img      } { affich_rond $::tools_cata::current_listsources IMG       $::bdi_gui_cata::color_img       $::bdi_gui_cata::size_img       }
      if { $::bdi_gui_cata::gui_usnoa2   } { affich_rond $::tools_cata::current_listsources USNOA2    $::bdi_gui_cata::color_usnoa2    $::bdi_gui_cata::size_usnoa2    }
      if { $::bdi_gui_cata::gui_ucac2    } { affich_rond $::tools_cata::current_listsources UCAC2     $::bdi_gui_cata::color_ucac2     $::bdi_gui_cata::size_ucac2     }
      if { $::bdi_gui_cata::gui_ucac3    } { affich_rond $::tools_cata::current_listsources UCAC3     $::bdi_gui_cata::color_ucac3     $::bdi_gui_cata::size_ucac3     }
      if { $::bdi_gui_cata::gui_ucac4    } { affich_rond $::tools_cata::current_listsources UCAC4     $::bdi_gui_cata::color_ucac4     $::bdi_gui_cata::size_ucac4     }
      if { $::bdi_gui_cata::gui_ppmx     } { affich_rond $::tools_cata::current_listsources PPMX      $::bdi_gui_cata::color_ppmx      $::bdi_gui_cata::size_ppmx      }
      if { $::bdi_gui_cata::gui_ppmxl    } { affich_rond $::tools_cata::current_listsources PPMXL     $::bdi_gui_cata::color_ppmxl     $::bdi_gui_cata::size_ppmxl     }
      if { $::bdi_gui_cata::gui_tycho2   } { affich_rond $::tools_cata::current_listsources TYCHO2    $::bdi_gui_cata::color_tycho2    $::bdi_gui_cata::size_tycho2    }
      if { $::bdi_gui_cata::gui_nomad1   } { affich_rond $::tools_cata::current_listsources NOMAD1    $::bdi_gui_cata::color_nomad1    $::bdi_gui_cata::size_nomad1    }
      if { $::bdi_gui_cata::gui_2mass    } { affich_rond $::tools_cata::current_listsources 2MASS     $::bdi_gui_cata::color_2mass     $::bdi_gui_cata::size_2mass     }
      if { $::bdi_gui_cata::gui_wfibc    } { affich_rond $::tools_cata::current_listsources WFIBC     $::bdi_gui_cata::color_wfibc     $::bdi_gui_cata::size_wfibc     }
      if { $::bdi_gui_cata::gui_sdss     } { affich_rond $::tools_cata::current_listsources SDSS      $::bdi_gui_cata::color_sdss      $::bdi_gui_cata::size_sdss      }
      if { $::bdi_gui_cata::gui_panstarrs} { affich_rond $::tools_cata::current_listsources PANSTARRS $::bdi_gui_cata::color_panstarrs $::bdi_gui_cata::size_panstarrs }
      if { $::bdi_gui_cata::gui_gaia1    } { affich_rond $::tools_cata::current_listsources GAIA1     $::bdi_gui_cata::color_gaia1     $::bdi_gui_cata::size_gaia1     }
      if { $::bdi_gui_cata::gui_skybot   } { affich_rond $::tools_cata::current_listsources SKYBOT    $::bdi_gui_cata::color_skybot    $::bdi_gui_cata::size_skybot    }

      # Trace du repere E/N dans l'image
      # TODO ::bdi_gui_cata::affiche_cata est-ce que c'est bon ici ?
      set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
      set cdelt1 [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
      set cdelt2 [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
      ::bdi_gui_cata::trace_repere [list $cdelt1 $cdelt2]

   } msg ]

   if {$err} {
      if {$msg=="NOCATA"} {return}
      ::console::affiche_erreur "ERREUR affiche_cata : $msg\n" 
   }

}




#
# bdi_gui_cata::trace_repere
# Trace le repere E/N dans l'image
# @param scale_factor list of the x and y scale factor of the image
# @param laxis length of axis frame
# @param can0 list of coordinates to center the mark, in canevas coord.
#
proc ::bdi_gui_cata::trace_repere { scale_factors {laxis 30} {can0 {35 35}} {color "green"} {width 1.0} } {

   global audace

   #--- coordonnees du centre de la representation des axes
   set img0_xy [::audace::canvas2Picture $can0]
   set img0_radec [buf$audace(bufNo) xy2radec $img0_xy 2]

   #--- coordonnees du point du segment en alpha
   set img1_radec [list [expr [lindex $img0_radec 0]+$laxis*abs([lindex $scale_factors 0])] [lindex $img0_radec 1]]
   set dir_EW "E"
   if { [expr [lindex $img1_radec 0]-[lindex $img0_radec 0]] < 0 } { set dir_EW "W" }
   set img1_xy [buf$audace(bufNo) radec2xy $img1_radec]
   set can1_xy [::audace::picture2Canvas $img1_xy]

   #--- coordonnees du point du segment en delta
   set img2_radec [list [lindex $img0_radec 0] [expr [lindex $img0_radec 1]+$laxis*abs([lindex $scale_factors 1])]]
   set dir_NS "N"
   if { [expr [lindex $img2_radec 1]-[lindex $img0_radec 1]] < 0 } { set dir_NS "S" }
   set img2_xy [buf$audace(bufNo) radec2xy $img2_radec]
   set can2_xy [::audace::picture2Canvas $img2_xy]

   #--- trace du repere
   $audace(hCanvas) create line [lindex $can0 0] [lindex $can0 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill $color -tags cadres -width $width -arrow last
   $audace(hCanvas) create text [expr [lindex $can1_xy 0]-1] [expr [lindex $can1_xy 1]-10] -text $dir_EW -justify center -fill $color -tags cadres
   $audace(hCanvas) create line [lindex $can0 0] [lindex $can0 1] [lindex $can2_xy 0] [lindex $can2_xy 1]  -fill $color -tags cadres -width $width -arrow last
   $audace(hCanvas) create text [expr [lindex $can2_xy 0]-10] [expr [lindex $can2_xy 1]-1] -text $dir_NS -justify center -fill $color -tags cadres

}


#
# bdi_gui_cata::trace_repere_x
# Trace le repere E/N dans l'image
# @param scale_factors list of the x and y scale factor of the image
# @param laxis length of axis frame
# @param can0 list of coordinates to center the mark, in canevas coord.
#
proc ::bdi_gui_cata::trace_repere_x { scale_factors {laxis 100} {img0 {512 512}} {color "green"} {width 1.0} } {

   global audace

   #--- coordonnees du centre de la representation des axes
   set can0_xy [::audace::picture2Canvas $img0]
   set img0_radec [buf$audace(bufNo) xy2radec $img0 2]
   #--- coordonnees du point du segment en alpha
   set img1_radec [list [expr [lindex $img0_radec 0]+$laxis*abs([lindex $scale_factors 0])] [lindex $img0_radec 1] ]
   set dir_EW "E"
   if { [expr [lindex $img1_radec 0]-[lindex $img0_radec 0]] < 0 } { set dir_EW "W" }
   set img1_xy [buf$audace(bufNo) radec2xy $img1_radec]
   set can1_xy [::audace::picture2Canvas $img1_xy ]

   #--- coordonnees du point du segment en delta
   set img2_radec [ list [lindex $img0_radec 0] [expr [lindex $img0_radec 1]+$laxis*abs([lindex $scale_factors 1])] ]
   set dir_NS "N"
   if { [expr [lindex $img2_radec 1]-[lindex $img0_radec 1]] < 0 } { set dir_NS "S" }
   set img2_xy [buf$audace(bufNo) radec2xy $img2_radec]
   set can2_xy [::audace::picture2Canvas $img2_xy ]

   #--- trace du repere
   $audace(hCanvas) create line [lindex $can0_xy 0] [lindex $can0_xy 1] [lindex $can1_xy 0] [lindex $can1_xy 1] -fill $color -tags cadres -width $width -arrow last
   $audace(hCanvas) create text [expr [lindex $can1_xy 0]-1] [expr [lindex $can1_xy 1]-10] -text $dir_EW -justify center -fill $color -tags cadres
   $audace(hCanvas) create line [lindex $can0_xy 0] [lindex $can0_xy 1] [lindex $can2_xy 0] [lindex $can2_xy 1] -fill $color -tags cadres -width $width -arrow last
   $audace(hCanvas) create text [expr [lindex $can2_xy 0]-10] [expr [lindex $can2_xy 1]-1] -text $dir_NS -justify center -fill $color -tags cadres

}



#
# bdi_gui_cata::trace_repere_x
# Trace le repere E/N dans l'image
# @param scale_factor list of the x and y scale factor of the image
# @param laxis length of axis frame
# @param can0 list of coordinates to center the mark, in canevas coord.
#
proc ::bdi_gui_cata::trace_reticule { {img0 {512 512}} {color "green"} {width 1.0} } {

   global audace

   set naxis1  [lindex [buf$::audace(bufNo) getkwd "NAXIS1" ] 1]
   set naxis2  [lindex [buf$::audace(bufNo) getkwd "NAXIS2" ] 1]

   #--- coordonnees du centre de la representation des axes
   set can0_xy [::audace::picture2Canvas $img0]
   #--- axe x 
   set img1_xy [list [expr [lindex $img0 0] - $naxis1/2.0] [lindex $img0 1]]
   set can1_xy [::audace::picture2Canvas $img1_xy]
   set img2_xy [list [expr [lindex $img0 0] + $naxis1/2.0] [lindex $img0 1]]
   set can2_xy [::audace::picture2Canvas $img2_xy]
   #--- axe y
   set img3_xy [list [lindex $img0 0] [expr [lindex $img0 1] - $naxis2/2.0]]
   set can3_xy [::audace::picture2Canvas $img3_xy]
   set img4_xy [list [lindex $img0 0] [expr [lindex $img0 1] + $naxis2/2.0]]
   set can4_xy [::audace::picture2Canvas $img4_xy]

   #--- trace du reticule
   $audace(hCanvas) create line [lindex $can1_xy 0] [lindex $can1_xy 1] [lindex $can2_xy 0] [lindex $can2_xy 1] -fill $color -tags cadres -width $width
   $audace(hCanvas) create line [lindex $can3_xy 0] [lindex $can3_xy 1] [lindex $can4_xy 0] [lindex $can4_xy 1] -fill $color -tags cadres -width $width

}



proc ::bdi_gui_cata::charge_list { img_list } {

   ::tools_cata::charge_list $img_list

   # Charge l'image 
   buf$::audace(bufNo) load $::tools_cata::file
   # Nettoie les marques
   cleanmark
   # Affiche un rond au centre de l'image
   affich_un_rond_xy $::tools_cata::xcent $::tools_cata::ycent red 2 2
   # Affiche l'image
   ::bdi_gui_cata::affiche_current_image
   ::bdi_gui_cata::affiche_cata
}




proc ::bdi_gui_cata::charge_image { img_list } {

   ::tools_cata::charge_list $img_list

   # Charge l'image
   buf$::audace(bufNo) load $::tools_cata::file
   # Nettoie les marques
   cleanmark
   # Affiche un rond au centre de l'image
   affich_un_rond_xy $::tools_cata::xcent $::tools_cata::ycent red 2 2
   # Affiche l'image
   ::bdi_gui_cata::affiche_current_image
   ::bdi_gui_cata::affiche_cata

}



proc ::bdi_gui_cata::voir_cata { img_list } {

   global audace
   global bddconf

   ::bdi_gui_cata::inittoconf

   set uncosmic_status $::bdi_gui_cata::use_uncosmic
   set ::bdi_gui_cata::use_uncosmic 0
   ::bdi_gui_cata::charge_list $img_list
   set ::bdi_gui_cata::use_uncosmic $uncosmic_status

   # Update nb sources du cata
   set ::tools_cata::nb_img       [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources IMG]
   set ::tools_cata::nb_usnoa2    [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources USNOA2]
   set ::tools_cata::nb_tycho2    [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources TYCHO2]
   set ::tools_cata::nb_ucac2     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC2]
   set ::tools_cata::nb_ucac3     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC3]
   set ::tools_cata::nb_ucac4     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources UCAC4]
   set ::tools_cata::nb_ppmx      [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources PPMX]
   set ::tools_cata::nb_ppmxl     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources PPMXL]
   set ::tools_cata::nb_nomad1    [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources NOMAD1]
   set ::tools_cata::nb_2mass     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources 2MASS]
   set ::tools_cata::nb_wfibc     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources WFIBC]
   set ::tools_cata::nb_sdss      [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources SDSS]
   set ::tools_cata::nb_panstarrs [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources PANSTARRS]
   set ::tools_cata::nb_gaia1     [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources GAIA1]
   set ::tools_cata::nb_skybot    [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources SKYBOT]
   set ::tools_cata::nb_astroid   [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources ASTROID]

   #--- Creation de la fenetre
   set ::bdi_gui_cata::fenv .voircata
   if { [winfo exists $::bdi_gui_cata::fenv] } {
      wm withdraw $::bdi_gui_cata::fenv
      wm deiconify $::bdi_gui_cata::fenv
      focus $::bdi_gui_cata::fenv
      return
   }
   toplevel $::bdi_gui_cata::fenv -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $::bdi_gui_cata::fenv ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $::bdi_gui_cata::fenv ] "+" ] 2 ]
   wm geometry $::bdi_gui_cata::fenv +[ expr $posx_config + 165 ]+[ expr $posy_config + 55 ]
   wm resizable $::bdi_gui_cata::fenv 1 1
   wm title $::bdi_gui_cata::fenv "Voir le CATA"
   wm protocol $::bdi_gui_cata::fenv WM_DELETE_WINDOW "::bdi_gui_cata::fermer_voir_cata"

   set frm $::bdi_gui_cata::fenv.frm_voir_cata
   set ::bdi_gui_cata::current_appli $frm

   #--- Cree un frame general
   frame $frm -borderwidth 0 -cursor arrow -relief groove
   pack $frm -in $::bdi_gui_cata::fenv -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

   set f4 [frame $frm.f4]
   pack $f4 -in $frm

           #--- Cree un frame pour afficher 
     set count [frame $f4.count -borderwidth 0 -cursor arrow -relief groove]
     pack $count -in $f4 -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

        #--- Cree un frame pour afficher 
        set img [frame $count.img -borderwidth 0 -cursor arrow -relief groove]
        pack $img -in $count -anchor w -side top -expand 0 -fill x -padx 10 -pady 5

             #--- Cree un label pour le titre
             checkbutton $img.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_img -state normal \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $img.check -in $img -side left -padx 3 -pady 3 -anchor w 
             label $img.name -text "SOURCES (IMG) :" -width 14 -anchor e
             pack $img.name -in $img -side left -padx 3 -pady 3 -anchor w 
             label $img.val -textvariable ::tools_cata::nb_img -width 4
             pack $img.val -in $img -side left -padx 3 -pady 3
             button $img.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_img -command ""
             pack $img.color -side left -anchor e -expand 0 
             spinbox $img.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_img -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $img.radius -in $img -side left -anchor w
             $img.radius set $::bdi_gui_cata::size_img_sav
             
             
        #--- Cree un frame pour afficher USNOA2
        set usnoa2 [frame $count.usnoa2 -borderwidth 0 -cursor arrow -relief groove]
        pack $usnoa2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $usnoa2.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_usnoa2 -state normal \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $usnoa2.check -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
             label $usnoa2.name -text "USNOA2 :" -width 14 -anchor e
             pack $usnoa2.name -in $usnoa2 -side left -padx 3 -pady 3 -anchor w 
             label $usnoa2.val -textvariable ::tools_cata::nb_usnoa2 -width 4
             pack $usnoa2.val -in $usnoa2 -side left -padx 3 -pady 3
             button $usnoa2.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_usnoa2 -command ""
             pack $usnoa2.color -side left -anchor e -expand 0 
             spinbox $usnoa2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_usnoa2 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $usnoa2.radius -in $usnoa2 -side left -anchor w
             $usnoa2.radius set $::bdi_gui_cata::size_usnoa2_sav

        #--- Cree un frame pour afficher UCAC2
        set ucac2 [frame $count.ucac2 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $ucac2.check -highlightthickness 0  \
                   -variable ::bdi_gui_cata::gui_ucac2 -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $ucac2.check -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
             label $ucac2.name -text "UCAC2 :" -width 14 -anchor e
             pack $ucac2.name -in $ucac2 -side left -padx 3 -pady 3 -anchor w 
             label $ucac2.val -textvariable ::tools_cata::nb_ucac2 -width 4
             pack $ucac2.val -in $ucac2 -side left -padx 3 -pady 3
             button $ucac2.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_ucac2 \
                     -command {set ::bdi_gui_cata::color_ucac2 [tk_chooseColor -initialcolor $::bdi_gui_cata::color_ucac2 -title "Choose color"]; wm withdraw}
             pack $ucac2.color -side left -anchor e -expand 0 
             spinbox $ucac2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac2 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $ucac2.radius -in $ucac2 -side left -anchor w
             $ucac2.radius set $::bdi_gui_cata::size_ucac2_sav

        #--- Cree un frame pour afficher UCAC3
        set ucac3 [frame $count.ucac3 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac3 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $ucac3.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_ucac3 -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $ucac3.check -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
             label $ucac3.name -text "UCAC3 :" -width 14 -anchor e
             pack $ucac3.name -in $ucac3 -side left -padx 3 -pady 3 -anchor w 
             label $ucac3.val -textvariable ::tools_cata::nb_ucac3 -width 4
             pack $ucac3.val -in $ucac3 -side left -padx 3 -pady 3
             button $ucac3.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_ucac3 -command ""
             pack $ucac3.color -side left -anchor e -expand 0 
             spinbox $ucac3.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac3 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $ucac3.radius -in $ucac3 -side left -anchor w
             $ucac3.radius set $::bdi_gui_cata::size_ucac3_sav

        #--- Cree un frame pour afficher UCAC4
        set ucac4 [frame $count.ucac4 -borderwidth 0 -cursor arrow -relief groove]
        pack $ucac4 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $ucac4.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_ucac4 -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $ucac4.check -in $ucac4 -side left -padx 3 -pady 3 -anchor w 
             label $ucac4.name -text "UCAC4 :" -width 14 -anchor e
             pack $ucac4.name -in $ucac4 -side left -padx 3 -pady 3 -anchor w 
             label $ucac4.val -textvariable ::tools_cata::nb_ucac4 -width 4
             pack $ucac4.val -in $ucac4 -side left -padx 3 -pady 3
             button $ucac4.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_ucac4 -command ""
             pack $ucac4.color -side left -anchor e -expand 0 
             spinbox $ucac4.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ucac4 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $ucac4.radius -in $ucac4 -side left -anchor w
             $ucac4.radius set $::bdi_gui_cata::size_ucac4_sav

        #--- Cree un frame pour afficher PPMX
        set ppmx [frame $count.ppmx -borderwidth 0 -cursor arrow -relief groove]
        pack $ppmx -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $ppmx.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_ppmx -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $ppmx.check -in $ppmx -side left -padx 3 -pady 3 -anchor w 
             label $ppmx.name -text "PPMX :" -width 14 -anchor e
             pack $ppmx.name -in $ppmx -side left -padx 3 -pady 3 -anchor w 
             label $ppmx.val -textvariable ::tools_cata::nb_ppmx -width 4
             pack $ppmx.val -in $ppmx -side left -padx 3 -pady 3
             button $ppmx.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_ppmx -command ""
             pack $ppmx.color -side left -anchor e -expand 0 
             spinbox $ppmx.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ppmx -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $ppmx.radius -in $ppmx -side left -anchor w
             $ppmx.radius set $::bdi_gui_cata::size_ppmx_sav

        #--- Cree un frame pour afficher PPMXL
        set ppmxl [frame $count.ppmxl -borderwidth 0 -cursor arrow -relief groove]
        pack $ppmxl -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $ppmxl.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_ppmxl -state normal  \
                   -command "::bdi_gui_cata::affiche_cata" 
             pack $ppmxl.check -in $ppmxl -side left -padx 3 -pady 3 -anchor w 
             label $ppmxl.name -text "PPMXL :" -width 14 -anchor e
             pack $ppmxl.name -in $ppmxl -side left -padx 3 -pady 3 -anchor w 
             label $ppmxl.val -textvariable ::tools_cata::nb_ppmxl -width 4
             pack $ppmxl.val -in $ppmxl -side left -padx 3 -pady 3
             button $ppmxl.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_ppmxl -command ""
             pack $ppmxl.color -side left -anchor e -expand 0 
             spinbox $ppmxl.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_ppmxl -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $ppmxl.radius -in $ppmxl -side left -anchor w
             $ppmxl.radius set $::bdi_gui_cata::size_ppmxl_sav

        #--- Cree un frame pour afficher TYCHO2
        set tycho2 [frame $count.tycho2 -borderwidth 0 -cursor arrow -relief groove]
        pack $tycho2 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $tycho2.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_tycho2 -state normal \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $tycho2.check -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
             label $tycho2.name -text "TYCHO2 :" -width 14 -anchor e
             pack $tycho2.name -in $tycho2 -side left -padx 3 -pady 3 -anchor w 
             label $tycho2.val -textvariable ::tools_cata::nb_tycho2 -width 4
             pack $tycho2.val -in $tycho2 -side left -padx 3 -pady 3
             button $tycho2.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_tycho2 -command ""
             pack $tycho2.color -side left -anchor e -expand 0 
             spinbox $tycho2.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_tycho2 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $tycho2.radius -in $tycho2 -side left -anchor w
             $tycho2.radius set $::bdi_gui_cata::size_tycho2_sav

        #--- Cree un frame pour afficher NOMAD1
        set nomad1 [frame $count.nomad1 -borderwidth 0 -cursor arrow -relief groove]
        pack $nomad1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $nomad1.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_nomad1 -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $nomad1.check -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
             label $nomad1.name -text "NOMAD1 :" -width 14 -anchor e
             pack $nomad1.name -in $nomad1 -side left -padx 3 -pady 3 -anchor w 
             label $nomad1.val -textvariable ::tools_cata::nb_nomad1 -width 4
             pack $nomad1.val -in $nomad1 -side left -padx 3 -pady 3
             button $nomad1.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_nomad1 -command ""
             pack $nomad1.color -side left -anchor e -expand 0 
             spinbox $nomad1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_nomad1 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $nomad1.radius -in $nomad1 -side left -anchor w
             $nomad1.radius set $::bdi_gui_cata::size_nomad1_sav

        #--- Cree un frame pour afficher 2MASS
        set twomass [frame $count.2mass -borderwidth 0 -cursor arrow -relief groove]
        pack $twomass -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $twomass.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_2mass -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $twomass.check -in $twomass -side left -padx 3 -pady 3 -anchor w 
             label $twomass.name -text "2MASS :" -width 14 -anchor e
             pack $twomass.name -in $twomass -side left -padx 3 -pady 3 -anchor w 
             label $twomass.val -textvariable ::tools_cata::nb_2mass -width 4
             pack $twomass.val -in $twomass -side left -padx 3 -pady 3
             button $twomass.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_2mass -command ""
             pack $twomass.color -side left -anchor e -expand 0 
             spinbox $twomass.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_2mass -command "::bdi_gui_cata::affiche_cata" -width 3
             pack $twomass.radius -in $twomass -side left -anchor w
             $twomass.radius set $::bdi_gui_cata::size_2mass_sav

        #--- Cree un frame pour afficher WFIBC
        set wfibc [frame $count.wfibc -borderwidth 0 -cursor arrow -relief groove]
        pack $wfibc -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $wfibc.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_wfibc -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $wfibc.check -in $wfibc -side left -padx 3 -pady 3 -anchor w 
             label $wfibc.name -text "WFIBC :" -width 14 -anchor e
             pack $wfibc.name -in $wfibc -side left -padx 3 -pady 3 -anchor w 
             label $wfibc.val -textvariable ::tools_cata::nb_wfibc -width 4
             pack $wfibc.val -in $wfibc -side left -padx 3 -pady 3
             button $wfibc.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_wfibc -command ""
             pack $wfibc.color -side left -anchor e -expand 0 
             spinbox $wfibc.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_wfibc -command "::bdi_gui_cata::affiche_cata" -width 3
             pack $wfibc.radius -in $wfibc -side left -anchor w
             $wfibc.radius set $::bdi_gui_cata::size_wfibc_sav

        #--- Cree un frame pour afficher SDSS
        set sdss [frame $count.sdss -borderwidth 0 -cursor arrow -relief groove]
        pack $sdss -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $sdss.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_sdss -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $sdss.check -in $sdss -side left -padx 3 -pady 3 -anchor w 
             label $sdss.name -text "SDSS :" -width 14 -anchor e
             pack $sdss.name -in $sdss -side left -padx 3 -pady 3 -anchor w 
             label $sdss.val -textvariable ::tools_cata::nb_sdss -width 4
             pack $sdss.val -in $sdss -side left -padx 3 -pady 3
             button $sdss.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_sdss -command ""
             pack $sdss.color -side left -anchor e -expand 0 
             spinbox $sdss.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_sdss -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $sdss.radius -in $sdss -side left -anchor w
             $sdss.radius set $::bdi_gui_cata::size_sdss_sav

        #--- Cree un frame pour afficher PANSTARRS
        set panstarrs [frame $count.panstarrs -borderwidth 0 -cursor arrow -relief groove]
        pack $panstarrs -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $panstarrs.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_panstarrs -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $panstarrs.check -in $panstarrs -side left -padx 3 -pady 3 -anchor w 
             label $panstarrs.name -text "PANSTARRS :" -width 14 -anchor e
             pack $panstarrs.name -in $panstarrs -side left -padx 3 -pady 3 -anchor w 
             label $panstarrs.val -textvariable ::tools_cata::nb_panstarrs -width 4
             pack $panstarrs.val -in $panstarrs -side left -padx 3 -pady 3
             button $panstarrs.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_panstarrs -command ""
             pack $panstarrs.color -side left -anchor e -expand 0 
             spinbox $panstarrs.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_panstarrs -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $panstarrs.radius -in $panstarrs -side left -anchor w
             $panstarrs.radius set $::bdi_gui_cata::size_panstarrs_sav

        #--- Cree un frame pour afficher GAIA
        set gaia1 [frame $count.gaia1 -borderwidth 0 -cursor arrow -relief groove]
        pack $gaia1 -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $gaia1.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_gaia1 -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $gaia1.check -in $gaia1 -side left -padx 3 -pady 3 -anchor w 
             label $gaia1.name -text "GAIA :" -width 14 -anchor e
             pack $gaia1.name -in $gaia1 -side left -padx 3 -pady 3 -anchor w 
             label $gaia1.val -textvariable ::tools_cata::nb_gaia1 -width 4
             pack $gaia1.val -in $gaia1 -side left -padx 3 -pady 3
             button $gaia1.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_gaia1 -command ""
             pack $gaia1.color -side left -anchor e -expand 0 
             spinbox $gaia1.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_gaia1 -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $gaia1.radius -in $gaia1 -side left -anchor w
             $gaia1.radius set $::bdi_gui_cata::size_gaia1_sav

        #--- Cree un frame pour afficher SKYBOT
        set skybot [frame $count.skybot -borderwidth 0 -cursor arrow -relief groove]
        pack $skybot -in $count -anchor s -side top -expand 0 -fill x -padx 10 -pady 5

             checkbutton $skybot.check -highlightthickness 0 \
                   -variable ::bdi_gui_cata::gui_skybot -state normal  \
                   -command "::bdi_gui_cata::affiche_cata"
             pack $skybot.check -in $skybot -side left -padx 3 -pady 3 -anchor w 
             label $skybot.name -text "SKYBOT :" -width 14 -anchor e
             pack $skybot.name -in $skybot -side left -padx 3 -pady 3 -anchor w 
             label $skybot.val -textvariable ::tools_cata::nb_skybot -width 4
             pack $skybot.val -in $skybot -side left -padx 3 -pady 3
             button $skybot.color -borderwidth 0 -takefocus 1 -bg $::bdi_gui_cata::color_skybot -command ""
             pack $skybot.color -side left -anchor e -expand 0 
             spinbox $skybot.radius -value [ list 1 2 3 4 5 6 7 8 9 10 ] -textvariable ::bdi_gui_cata::size_skybot -command "::bdi_gui_cata::affiche_cata" -width 3
             pack  $skybot.radius -in $skybot -side left -anchor w
             $skybot.radius set $::bdi_gui_cata::size_skybot_sav
             
     #--- Cree un frame pour afficher bouton fermeture
     set boutonpied [frame $frm.boutonpied  -borderwidth 0 -cursor arrow -relief groove]
     pack $boutonpied -in $frm -anchor s -side right -expand 0 -fill x -padx 10 -pady 5

          set ::bdi_gui_cata::gui_refresh [button $boutonpied.refresh -text "Refresh" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata::affiche_cata"]
          pack $boutonpied.refresh -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0

          set ::bdi_gui_cata::gui_fermer [button $boutonpied.fermer -text "Fermer" -borderwidth 2 -takefocus 1 \
             -command "::bdi_gui_cata::fermer_voir_cata"]
          pack $boutonpied.fermer -side left -anchor e \
             -padx 5 -pady 5 -ipadx 5 -ipady 5 -expand 0


   # Application du theme
   ::confColor::applyColor $::bdi_gui_cata::fenv

   $img.color       configure -bg $::bdi_gui_cata::color_img
   $skybot.color    configure -bg $::bdi_gui_cata::color_skybot
   $sdss.color      configure -bg $::bdi_gui_cata::color_sdss
   $panstarrs.color configure -bg $::bdi_gui_cata::color_panstarrs
   $gaia1.color     configure -bg $::bdi_gui_cata::color_gaia1
   $usnoa2.color    configure -bg $::bdi_gui_cata::color_usnoa2
   $tycho2.color    configure -bg $::bdi_gui_cata::color_tycho2
   $ucac2.color     configure -bg $::bdi_gui_cata::color_ucac2
   $ppmx.color      configure -bg $::bdi_gui_cata::color_ppmx
   $nomad1.color    configure -bg $::bdi_gui_cata::color_nomad1
   $wfibc.color     configure -bg $::bdi_gui_cata::color_wfibc
   $ucac3.color     configure -bg $::bdi_gui_cata::color_ucac3
   $ucac4.color     configure -bg $::bdi_gui_cata::color_ucac4
   $ppmxl.color     configure -bg $::bdi_gui_cata::color_ppmxl
   $twomass.color   configure -bg $::bdi_gui_cata::color_2mass

}




proc ::bdi_gui_cata::fermer_voir_cata {  } {

   cleanmark
   ::bdi_gui_cata::closetoconf
   destroy $::bdi_gui_cata::fenv

}



#
# Photometrie: Affiche les sources de reference dans l'image courante
# qui ont ete selectionnees dans la table
# Si l etoile (ou les etoiles) n'apparaissent pas dans l'image courante
# alors on fait appel a la fonction d'affichage de l'image qui contient
# le plus grand nombre de ces sources
#
proc ::bdi_gui_cata::voirobj_photom_ref {  } {

   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark
   array unset tab
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
      set tab($idcata) ""
   }

   
   foreach select [$::bdi_gui_cdl::data_reference curselection] {
      set data [$::bdi_gui_cdl::data_reference get $select]
      set id [lindex $data 0]
      set name [lindex $data 1]
#         gren_info "Id = $id Name = $name\n"
      set date $::tools_cata::current_image_date
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_star_exist($name,$idcata)]} {
            lappend tab($idcata) $name
         }
      }
   }

   set nbvue 0
   set idvue -1
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
      if {[llength $tab($idcata)]>$nbvue} {
         set nbvue [llength $tab($idcata)]
         set idvue $idcata
      }
   }
   
#      gren_info "Idcata = $idvue, Nb star visible = $nbvue\n"
   
   # Chargement de l image 
   if {$idvue != -1} {
      if {$::bdi_gui_cata_gestion::directaccess != $idvue } {
         set ::bdi_gui_cata_gestion::directaccess $idvue
         ::bdi_gui_cata_gestion::charge_image_directaccess
      }
   }
   
   gren_info "Etoiles visible dans l image ($idvue) date = $::tools_cata::current_image_date: \n"
   foreach name $tab($idvue) {
      set ids [::manage_source::name2ids $name ::tools_cata::current_listsources]
      set s [lindex  $::tools_cata::current_listsources 1 $ids] 
      set xy [::bdi_tools_psf::get_xy s]
      gren_info "$name ($ids) : $xy\n"
      set radec [buf$::audace(bufNo) xy2radec [list [lindex $xy 0] [lindex $xy 1] ]]
      
      affich_un_rond [lindex $radec 0] [lindex $radec 1] $color $width
      
   }

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]

}

#
# Photometrie: Affiche une source de reference dans une l'image (de la table srpt)
# ici on affiche l image qui contient le plus d etoiles selectionnees
#
proc ::bdi_gui_cata::voirobj_photom_ref_pas_dans_currentimage {  } {

   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark
   array unset tab
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
      set tab($idcata) ""
   }

   
   foreach select [$::bdi_gui_cdl::data_reference curselection] {
      set data [$::bdi_gui_cdl::data_reference get $select]
      set id [lindex $data 0]
      set name [lindex $data 1]
#         gren_info "Id = $id Name = $name\n"
      set date $::tools_cata::current_image_date
      for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
         if {[info exists ::bdi_tools_cdl::table_star_exist($name,$idcata)]} {
            lappend tab($idcata) $name
         }
      }
   }

   set nbvue 0
   set idvue -1
   for {set idcata 1} {$idcata <= $::tools_cata::nb_img_list} {incr idcata} {
      if {[llength $tab($idcata)]>$nbvue} {
         set nbvue [llength $tab($idcata)]
         set idvue $idcata
      }
   }
   
#      gren_info "Idcata = $idvue, Nb star visible = $nbvue\n"
   
   # Chargement de l image 
   if {$idvue != -1} {
      if {$::bdi_gui_cata_gestion::directaccess != $idvue } {
         set ::bdi_gui_cata_gestion::directaccess $idvue
         ::bdi_gui_cata_gestion::charge_image_directaccess
      }
   }
   
   gren_info "Etoiles visible dans l image ($idvue) date = $::tools_cata::current_image_date: \n"
   foreach name $tab($idvue) {
      set ids $::bdi_tools_cdl::table_star_exist($name,$idvue)
      set s [lindex  $::tools_cata::current_listsources 1 $ids] 
      set xy [::bdi_tools_psf::get_xy s]
      gren_info "$name ($ids) : $xy\n"
      set radec [buf$::audace(bufNo) xy2radec [list [lindex $xy 0] [lindex $xy 1] ]]
      
      affich_un_rond [lindex $radec 0] [lindex $radec 1] $color $width
      
   }


   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]
  
   
}



#
# Astrometrie: Affiche une source de reference dans une l'image (de la table srpt)
#
proc ::bdi_gui_cata::voirobj_srpt {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]

   # Selectionne chaque source
   foreach select [$::bdi_gui_astrometry::srpt curselection] {
      
      set data [$::bdi_gui_astrometry::srpt get $select]
      set name [lindex $data 0]
      set date $::tools_cata::current_image_date

      if {[info exists ::bdi_tools_astrometry::tabval($name,$date)]} {

         set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]

      } else {

         #set r [tk_messageBox -message "L'objet n'est pas present dans l'image. Continer aura pour effet de charger une image où il est present." -type yesno]
         #if {$r=="no"} {return}
         foreach dateok $::bdi_tools_astrometry::listref($name) {
            break
         }
         set id 0
         set idok -1
         foreach current_image $::tools_cata::img_list {
            incr id
            set tabkey [::bddimages_liste::lget $current_image "tabkey"]
            set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
            if { [::bdi_tools::is_isodates_equal $locdate $dateok] } {
               set idok $id
               break
            }
         }

         if {$idok != -1} {
            set ::bdi_gui_cata_gestion::directaccess $idok
            ::bdi_gui_cata_gestion::charge_image_directaccess
            set date $::tools_cata::current_image_date
            if {[info exists ::bdi_tools_astrometry::tabval($name,$date)]} {
               set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
            } else {
               if {[info exists ::bdi_tools_astrometry::tabval($name,$dateok)]} {
                  set id [lindex $::bdi_tools_astrometry::tabval($name,$dateok) 0]
               } else {
                  tk_messageBox -message "Chargement de l'image impossible" -type ok
                  return
               }
            }
         }
      }

      set u 0
      foreach x [$f.frmtable.tbl get 0 end] {
         set idx [lindex $x 0]
         if {$idx == $id} {
            $f.frmtable.tbl selection set $u
            set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
            set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
            affich_un_rond $ra $dec $color $width
         }
         incr u
      }
   }
   # centrer la visu
   ::confVisu::setPos $::audace(visuNo) [ buf$::audace(bufNo) radec2xy [list $ra $dec] ]

}



#
# Astrometrie: supprime une source de reference (de la table srpt) dans toutes les images
#
proc ::bdi_gui_cata::unset_srpt {  } {

   # Affiche l'objet et l'image si besoin
   ::bdi_gui_cata::voirobj_srpt

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]

   # Unset les sources
   ::bdi_gui_cata_gestion::unset_flag $f.frmtable.tbl
   # Propage les sources
   ::bdi_gui_cata_gestion::propagation $f.frmtable.tbl
}



#
# Astrometrie: Affiche une source de reference dans cette l'image (de la table sret)
#
proc ::bdi_gui_cata::voirobj_sret {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Recupere l'image selectionnee dans la table sret
   set select [$::bdi_gui_astrometry::sret curselection]
   set data [$::bdi_gui_astrometry::sret get $select]
   set objid [lindex $data 0]
   set date [lindex $data 1]
   set ra [lindex $data 5]
   set dec [lindex $data 6]

   set id 0
   set idok -1
   foreach current_image $::tools_cata::img_list {
      incr id
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      if { [::bdi_tools::is_isodates_equal $locdate $date] } {
         set idok $id
         break
      }
   }

   if {$idok != -1} {
      set ::bdi_gui_cata_gestion::directaccess $idok
      ::bdi_gui_cata_gestion::charge_image_directaccess
      gren_info "Image $date affichee\n"
      affich_un_rond $ra $dec $color $width
   }

}



#
# Astrometrie: supprime une source de reference (de la table sret) dans l'image selectionnee
#
proc ::bdi_gui_cata::unset_sret {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   set idcata_astroid $tabid(ASTROID)
   $onglets select $onglets.f$idcata_astroid
   set f [$onglets select]

   # Selectionne chaque source
   foreach select [$::bdi_gui_astrometry::sret curselection] {
      
      set data [$::bdi_gui_astrometry::sret get $select]
      set id [lindex $data 0]
      set date [lindex $data 1]

      set u 0
      foreach x [$f.frmtable.tbl get 0 end] {
         set idx [lindex $x 0]
         if {$idx == $id} {
            $f.frmtable.tbl selection set $u
            set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
            set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
            affich_un_rond $ra $dec $color $width
         }
         incr u
      }
      
   }
   
   # Unset les sources
   ::bdi_gui_cata_gestion::unset_flag $f.frmtable.tbl

}



#
# Astrometrie: Affiche une source science dans une l'image (de la table sspt)
#
proc ::bdi_gui_cata::voirobj_sspt {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]

   # Selectionne chaque source
   foreach select [$::bdi_gui_astrometry::sspt curselection] {
      
      set data [$::bdi_gui_astrometry::sspt get $select]
      set name [lindex $data 0]
      set date $::tools_cata::current_image_date

      if {[info exists ::bdi_tools_astrometry::tabval($name,$date)]} {

         set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]

      } else {

         set r [tk_messageBox -message "L'objet n'est pas present dans l'image. Continer aura pour effet de charger une image où il est present." -type yesno]
         if {$r=="no"} {return}
         foreach dateok $::bdi_tools_astrometry::listscience($name) {
            break
         }
         set id 0
         set idok -1
         foreach current_image $::tools_cata::img_list {
            incr id
            set tabkey [::bddimages_liste::lget $current_image "tabkey"]
            set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
            if { [::bdi_tools::is_isodates_equal $locdate $dateok] } {
               set idok $id
               break
            }
         }

         if {$idok != -1} {
            set ::bdi_gui_cata_gestion::directaccess $idok
            ::bdi_gui_cata_gestion::charge_image_directaccess
            set date $::tools_cata::current_image_date
            if {[info exists ::bdi_tools_astrometry::tabval($name,$date)]} {
               set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]
            } else {
               if {[info exists ::bdi_tools_astrometry::tabval($name,$dateok)]} {
                  set id [lindex $::bdi_tools_astrometry::tabval($name,$dateok) 0]
               } else {
                  tk_messageBox -message "Chargement de l'image impossible" -type ok
                  return
               }
            }
         }
      }

      set u 0
      foreach x [$f.frmtable.tbl get 0 end] {
         set idx [lindex $x 0]
         if {$idx == $id} {
            $f.frmtable.tbl selection set $u
            set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
            set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
            affich_un_rond $ra $dec $color $width
         }
         incr u
      }
      
   }
   # centrer la visu
   ::confVisu::setPos $::audace(visuNo) [ buf$::audace(bufNo) radec2xy [list $ra $dec] ]

   

}





#
# Astrometrie: supprime une source science (de la table sspt) dans toutes les images
#
proc ::bdi_gui_cata::unset_sspt {  } {

   # Affiche l'objet et l'image si besoin
   ::bdi_gui_cata::voirobj_sspt

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   $onglets select $onglets.f$tabid(ASTROID)
   set f [$onglets select]

   # Unset les sources
   ::bdi_gui_cata_gestion::unset_flag $f.frmtable.tbl
   # Propage les sources
   ::bdi_gui_cata_gestion::propagation $f.frmtable.tbl
}






#
# Astrometrie: Affiche une source science dans cette l'image (de la table sset)
#
proc ::bdi_gui_cata::voirobj_sset {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Recupere l'image selectionnee dans la table sret
   set select [$::bdi_gui_astrometry::sset curselection]
   set data [$::bdi_gui_astrometry::sset get $select]
   set objid [lindex $data 0]
   set date [lindex $data 1]
   set ra [lindex $data 5]
   set dec [lindex $data 6]

   set id 0
   set idok -1
   foreach current_image $::tools_cata::img_list {
      incr id
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      if { [::bdi_tools::is_isodates_equal $locdate $date] } {
         set idok $id
         break
      }
   }

   if {$idok != -1} {
      set ::bdi_gui_cata_gestion::directaccess $idok
      ::bdi_gui_cata_gestion::charge_image_directaccess
      gren_info "Image $date affichee\n"
      affich_un_rond $ra $dec $color $width
   }

}




#
# Astrometrie: supprime une source science (de la table sset) dans l'image selectionnee
#
proc ::bdi_gui_cata::unset_sset {  } {
   
   set color red

   set width 2
   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Selection de l'onglet du cata ASTROID dans la GUI Gestion du CATA
   set onglets .gestion_cata.appli.onglets.nb
   array set cataname $::bdi_gui_cata::tk_list($::tools_cata::id_current_image,cataname)
   foreach {x y} [array get cataname] {
      set tabid($y) $x
   }
   set idcata_astroid $tabid(ASTROID)
   $onglets select $onglets.f$idcata_astroid
   set f [$onglets select]

   # Selectionne chaque source
   foreach select [$::bdi_gui_astrometry::sset curselection] {
      
      set data [$::bdi_gui_astrometry::sset get $select]
      set id [lindex $data 0]
      set date [lindex $data 1]

      set u 0
      foreach x [$f.frmtable.tbl get 0 end] {
         set idx [lindex $x 0]
         if {$idx == $id} {
            $f.frmtable.tbl selection set $u
            set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
            set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
            affich_un_rond $ra $dec $color $width
         }
         incr u
      }
      
   }
   
   # Unset les sources
   ::bdi_gui_cata_gestion::unset_flag $f.frmtable.tbl

}





#
# Astrometrie: Affiche une image (de la table dspt)
#
proc ::bdi_gui_cata::voirimg_dspt {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Recupere l'image selectionnee dans la table sret
   set select [$::bdi_gui_astrometry::dspt curselection]
   set data [$::bdi_gui_astrometry::dspt get $select]
   set date [lindex $data 0]

   set id 0
   set idok -1
   foreach current_image $::tools_cata::img_list {
      incr id
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      if { [::bdi_tools::is_isodates_equal $locdate $date] } {
         set idok $id
         break
      }
   }

   if {$idok != -1} {
      set ::bdi_gui_cata_gestion::directaccess $idok
      ::bdi_gui_cata_gestion::charge_image_directaccess
      gren_info "Image $date affichee\n"
   }

}



#
# Astrometrie: Affiche une image (de la table dspt)
#
proc ::bdi_gui_cata::voirimg_dwpt {  } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   # Recupere l'image selectionnee dans la table sret
   set select [$::bdi_gui_astrometry::dwpt curselection]
   set data [$::bdi_gui_astrometry::dwpt get $select]
   set date [lindex $data 0]

   set id 0
   set idok -1
   foreach current_image $::tools_cata::img_list {
      incr id
      set tabkey [::bddimages_liste::lget $current_image "tabkey"]
      set locdate [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
      if { [::bdi_tools::is_isodates_equal $locdate $date] } {
         set idok $id
         break
      }
   }

   if {$idok != -1} {
      set ::bdi_gui_cata_gestion::directaccess $idok
      ::bdi_gui_cata_gestion::charge_image_directaccess
      gren_info "Image $date affichee\n"
   }

}



proc ::bdi_gui_cata::voir_sxpt { w } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark

   set onglets [.gestion_cata.appli.onglets.nb tabs]
   set f [.gestion_cata.appli.onglets.nb select]

   foreach select [$w curselection] {
      set data [$w get $select]

      set name [lindex $data 0]
      set date $::tools_cata::current_image_date
      
      if {[info exists ::bdi_tools_astrometry::tabval($name,$date)]} {
         set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]

         set u 0
         foreach x [$f.frmtable.tbl get 0 end] {
            set idx [lindex $x 0]
            if {$idx == $id} {
               #$f.frmtable.tbl selection set $u
               set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
               set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
               affich_un_rond $ra $dec $color $width
            }
            incr u
         }

      }

   }

}



proc ::bdi_gui_cata::voir_dset { w } {
   
   set color red
   set width 2

   if {![winfo exists .gestion_cata.appli.onglets.nb]} {
      tk_messageBox -message "La GUI de gestion du CATA doit etre ouverte" -type ok
      return
   }

   cleanmark
   set onglets [.gestion_cata.appli.onglets.nb tabs]
   set f [.gestion_cata.appli.onglets.nb select]

   foreach select [$w curselection] {
      set data [$w get $select]
      set name [lindex $data 1]
      set date $::tools_cata::current_image_date
      set id [lindex $::bdi_tools_astrometry::tabval($name,$date) 0]

      set u 0
      foreach x [$f.frmtable.tbl get 0 end] {
         set idx [lindex $x 0]
         if {$idx == $id} {
            #$f.frmtable.tbl selection set $u
            set ra  [lindex $x [::bdi_gui_cata::get_pos_col ra]]
            set dec [lindex $x [::bdi_gui_cata::get_pos_col dec]]
            affich_un_rond $ra $dec $color $width
         }
         incr u
      }
      
   }

}



proc ::bdi_gui_cata::get_pos_col { name { idcata 1 } } {

   if {![info exists idcata]} {set idcata 1}
   
   set list_of_columns $::bdi_gui_cata::tklist_list_of_columns($idcata)

   set cpt 0
   foreach { c } $list_of_columns {
      set a [split $c " "]
      set b [lindex $a 1]
      set a [lindex $a 0]
      if {$a==$name} {
         return $cpt
      }
      incr cpt
   }
   return -1
}
