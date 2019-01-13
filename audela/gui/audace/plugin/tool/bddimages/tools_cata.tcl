## @file tools_cata.tcl
#  @brief     Outils de cr&eacute;ation / gestion des catas dans les images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages tools_cata.tcl]
#  @endcode

# $Id: tools_cata.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace tools_cata
# @brief Outils de cr&eacute;ation / gestion des catas dans les images
# @warning Outil en d&eacute;veloppement
#
namespace eval ::tools_cata {

   global audace
   global bddconf

   variable id_current_image
   variable current_image
   variable current_cata
   variable current_image_name
   variable current_cata_name
   variable current_image_date
   variable img_list
   variable img_list_sav
   variable nb_img_list
   variable current_listsources

   variable use_skybot
   variable use_gaia1
   variable use_sdss
   variable use_panstarrs
   variable use_usnoa2
   variable use_tycho2
   variable use_ucac2
   variable use_ucac3
   variable use_ucac4
   variable use_ppmx
   variable use_ppmxl
   variable use_nomad1
   variable use_2mass
   variable use_wfibc

   variable catalog_skybot
   variable catalog_gaia1
   variable catalog_sdss
   variable catalog_panstarrs
   variable catalog_usnoa2
   variable catalog_tycho2
   variable catalog_ucac2
   variable catalog_ucac3
   variable catalog_ucac4
   variable catalog_ppmx
   variable catalog_ppmxl
   variable catalog_nomad1
   variable catalog_2mass
   variable catalog_wfibc

   variable keep_radec
   variable create_cata
   variable boucle

   variable ra_save
   variable dec_save

   variable nb_img
   variable nb_ovni
   variable nb_skybot
   variable nb_gaia1
   variable nb_sdss
   variable nb_panstarrs
   variable nb_usnoa2
   variable nb_tycho2
   variable nb_ucac2
   variable nb_ucac3
   variable nb_ucac4
   variable nb_ppmx
   variable nb_ppmxl
   variable nb_nomad1
   variable nb_2mass
   variable nb_wfibc

   variable ra       
   variable dec      
   variable pixsize1 
   variable pixsize2 
   variable foclen   
   variable exposure 

   variable delpv
   variable delimg
   variable deuxpasses
   variable limit_nbstars_accepted
   variable log

   variable threshold_ident_pos_star
   variable threshold_ident_mag_star
   variable threshold_ident_pos_ast
   variable threshold_ident_mag_ast

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

proc ::tools_cata::inittoconf { } {

   global conf

   set ::tools_cata::nb_img       0
   set ::tools_cata::nb_usnoa2    0
   set ::tools_cata::nb_tycho2    0
   set ::tools_cata::nb_ppmx      0
   set ::tools_cata::nb_ppmxl     0
   set ::tools_cata::nb_ucac2     0
   set ::tools_cata::nb_ucac3     0
   set ::tools_cata::nb_ucac4     0
   set ::tools_cata::nb_nomad1    0
   set ::tools_cata::nb_2mass     0
   set ::tools_cata::nb_wfibc     0
   set ::tools_cata::nb_sdss      0
   set ::tools_cata::nb_panstarrs 0
   set ::tools_cata::nb_gaia1     0
   set ::tools_cata::nb_skybot    0
   set ::tools_cata::nb_astroid   0

   # Utilisation des catalogues
   if {! [info exists ::tools_cata::use_cata_if_exist] } {
      set ::tools_cata::use_cata_if_exist 0
   }
   if {! [info exists ::tools_cata::use_usnoa2] } {
      if {[info exists conf(bddimages,cata,use_usnoa2)]} {
         set ::tools_cata::use_usnoa2 $conf(bddimages,cata,use_usnoa2)
      } else {
         set ::tools_cata::use_usnoa2 1
      }
   }
   if {! [info exists ::tools_cata::use_ucac2] } {
      if {[info exists conf(bddimages,cata,use_ucac2)]} {
         set ::tools_cata::use_ucac2 $conf(bddimages,cata,use_ucac2)
      } else {
         set ::tools_cata::use_ucac2 0
      }
   }
   if {! [info exists ::tools_cata::use_ucac3] } {
      if {[info exists conf(bddimages,cata,use_ucac3)]} {
         set ::tools_cata::use_ucac3 $conf(bddimages,cata,use_ucac3)
      } else {
         set ::tools_cata::use_ucac3 0
      }
   }
   if {! [info exists ::tools_cata::use_ucac4] } {
      if {[info exists conf(bddimages,cata,use_ucac4)]} {
         set ::tools_cata::use_ucac4 $conf(bddimages,cata,use_ucac4)
      } else {
         set ::tools_cata::use_ucac4 0
      }
   }
   if {! [info exists ::tools_cata::use_ppmx] } {
      if {[info exists conf(bddimages,cata,use_ppmx)]} {
         set ::tools_cata::use_ppmx $conf(bddimages,cata,use_ppmx)
      } else {
         set ::tools_cata::use_ppmx 0
      }
   }
   if {! [info exists ::tools_cata::use_ppmxl] } {
      if {[info exists conf(bddimages,cata,use_ppmxl)]} {
         set ::tools_cata::use_ppmxl $conf(bddimages,cata,use_ppmxl)
      } else {
         set ::tools_cata::use_ppmxl 0
      }
   }
   if {! [info exists ::tools_cata::use_tycho2] } {
      if {[info exists conf(bddimages,cata,use_tycho2)]} {
         set ::tools_cata::use_tycho2 $conf(bddimages,cata,use_tycho2)
      } else {
         set ::tools_cata::use_tycho2 0
      }
   }
   if {! [info exists ::tools_cata::use_nomad1] } {
      if {[info exists conf(bddimages,cata,use_nomad1)]} {
         set ::tools_cata::use_nomad1 $conf(bddimages,cata,use_nomad1)
      } else {
         set ::tools_cata::use_nomad1 0
      }
   }
   if {! [info exists ::tools_cata::use_2mass] } {
      if {[info exists conf(bddimages,cata,use_2mass)]} {
         set ::tools_cata::use_2mass $conf(bddimages,cata,use_2mass)
      } else {
         set ::tools_cata::use_2mass 0
      }
   }
   if {! [info exists ::tools_cata::use_wfibc] } {
      if {[info exists conf(bddimages,cata,use_wfibc)]} {
         set ::tools_cata::use_wfibc $conf(bddimages,cata,use_wfibc)
      } else {
         set ::tools_cata::use_wfibc 0
      }
   }
   if {! [info exists ::tools_cata::use_sdss] } {
      if {[info exists conf(bddimages,cata,use_sdss)]} {
         set ::tools_cata::use_sdss $conf(bddimages,cata,use_sdss)
      } else {
         set ::tools_cata::use_sdss 0
      }
   }
   if {! [info exists ::tools_cata::use_panstarrs] } {
      if {[info exists conf(bddimages,cata,use_panstarrs)]} {
         set ::tools_cata::use_panstarrs $conf(bddimages,cata,use_panstarrs)
      } else {
         set ::tools_cata::use_panstarrs 0
      }
   }
   if {! [info exists ::tools_cata::use_gaia1] } {
      if {[info exists conf(bddimages,cata,use_gaia1)]} {
         set ::tools_cata::use_gaia1 $conf(bddimages,cata,use_gaia1)
      } else {
         set ::tools_cata::use_gaia1 0
      }
   }
   if {! [info exists ::tools_cata::use_skybot] } {
      if {[info exists conf(bddimages,cata,use_skybot)]} {
         set ::tools_cata::use_skybot $conf(bddimages,cata,use_skybot)
      } else {
         set ::tools_cata::use_skybot 1
      }
   }

   # Repertoires 
   if {! [info exists ::tools_cata::catalog_usnoa2] } {
      if {[info exists conf(bddimages,catfolder,usnoa2)]} {
         set ::tools_cata::catalog_usnoa2 $conf(bddimages,catfolder,usnoa2)
      } else {
         set ::tools_cata::catalog_usnoa2 $conf(rep_userCatalogUsnoa2)
      }
   }
   if {! [info exists ::tools_cata::catalog_ucac2] } {
      if {[info exists conf(bddimages,catfolder,ucac2)]} {
         set ::tools_cata::catalog_ucac2 $conf(bddimages,catfolder,ucac2)
      } else {
         set ::tools_cata::catalog_ucac2 $conf(rep_userCatalogUcac2)
      }
   }
   if {! [info exists ::tools_cata::catalog_ucac3] } {
      if {[info exists conf(bddimages,catfolder,ucac3)]} {
         set ::tools_cata::catalog_ucac3 $conf(bddimages,catfolder,ucac3)
      } else {
         set ::tools_cata::catalog_ucac3 $conf(rep_userCatalogUcac3)
      }
   }
   if {! [info exists ::tools_cata::catalog_ucac4] } {
      if {[info exists conf(bddimages,catfolder,ucac4)]} {
         set ::tools_cata::catalog_ucac4 $conf(bddimages,catfolder,ucac4)
      } else {
         set ::tools_cata::catalog_ucac4 $conf(rep_userCatalogUcac4)
      }
   }
   if {! [info exists ::tools_cata::catalog_ppmx] } {
      if {[info exists conf(bddimages,catfolder,ppmx)]} {
         set ::tools_cata::catalog_ppmx $conf(bddimages,catfolder,ppmx)
      } else {
         set ::tools_cata::catalog_ppmx $conf(rep_userCatalogPpmx)
      }
   }
   if {! [info exists ::tools_cata::catalog_ppmxl] } {
      if {[info exists conf(bddimages,catfolder,ppmxl)]} {
         set ::tools_cata::catalog_ppmxl $conf(bddimages,catfolder,ppmxl)
      } else {
         set ::tools_cata::catalog_ppmxl $conf(rep_userCatalogPpmxl)
      }
   }
   if {! [info exists ::tools_cata::catalog_tycho2] } {
      if {[info exists conf(bddimages,catfolder,tycho2)]} {
         set ::tools_cata::catalog_tycho2 $conf(bddimages,catfolder,tycho2)
      } else {
         set ::tools_cata::catalog_tycho2 $conf(rep_userCatalogTycho2_fast)
      }
   }
   if {! [info exists ::tools_cata::catalog_nomad1] } {
      if {[info exists conf(bddimages,catfolder,nomad1)]} {
         set ::tools_cata::catalog_nomad1 $conf(bddimages,catfolder,nomad1)
      } else {
         set ::tools_cata::catalog_nomad1 $conf(rep_userCatalogNomad1)
      }
   }
   if {! [info exists ::tools_cata::catalog_2mass] } {
      if {[info exists conf(bddimages,catfolder,2mass)]} {
         set ::tools_cata::catalog_2mass $conf(bddimages,catfolder,2mass)
      } else {
         set ::tools_cata::catalog_2mass $conf(rep_userCatalog2mass)
      }
   }
   if {! [info exists ::tools_cata::catalog_wfibc] } {
      if {[info exists conf(bddimages,catfolder,wfibc)]} {
         set ::tools_cata::catalog_wfibc $conf(bddimages,catfolder,wfibc)
      } else {
         set ::tools_cata::catalog_wfibc $conf(rep_userCatalogWFIBC)
      }
   }
   if {! [info exists ::tools_cata::catalog_gaia1]} {
      if {[info exists conf(bddimages,catfolder,gaia1)]} {
         set ::tools_cata::catalog_gaia1 $conf(bddimages,catfolder,gaia1)
      } else {
         set ::tools_cata::catalog_gaia1 $conf(rep_userCatalogGaia1)
      }
   }

   # Services
   if {! [info exists ::tools_cata::catalog_skybot] } {
      if {[info exists conf(bddimages,catfolder,skybot)]} {
         set ::tools_cata::catalog_skybot $conf(bddimages,catfolder,skybot)
      } else {
         set ::tools_cata::catalog_skybot "http://vo.imcce.fr/webservices/skybot/"
      }
   }
   if {! [info exists ::tools_cata::catalog_sdss] } {
      if {[info exists conf(bddimages,catfolder,sdss)]} {
         set ::tools_cata::catalog_sdss $conf(bddimages,catfolder,sdss)
      } else {
         set ::tools_cata::catalog_sdss "http://skyserver.sdss.org/dr9/en/tools/search/x_radial.asp"
      }
   }
   if {! [info exists ::tools_cata::catalog_panstarrs] } {
      if {[info exists conf(bddimages,catfolder,panstarrs)]} {
         set ::tools_cata::catalog_panstarrs $conf(bddimages,catfolder,panstarrs)
      } else {
         set ::tools_cata::catalog_panstarrs "http://archive.stsci.edu/panstarrs/search.php"
      }
   }
   #if {! [info exists ::tools_cata::catalog_tgas] } {
   #   if {[info exists conf(bddimages,catfolder,tgas)]} {
   #      set ::tools_cata::catalog_tgas $conf(bddimages,catfolder,tgas)
   #   } else {
   #      #set ::tools_cata::catalog_tgas "http://gea.esac.esa.int/tap-server/tap"
   #      set ::tools_cata::catalog_tgas "http://gaia.ari.uni-heidelberg.de/tap"
   #   }
   #}

   # Autres utilitaires
   if {! [info exists ::tools_cata::keep_radec] } {
      if {[info exists conf(bddimages,cata,keep_radec)]} {
         set ::tools_cata::keep_radec $conf(bddimages,cata,keep_radec)
      } else {
         set ::tools_cata::keep_radec 1
      }
   }
   if {! [info exists ::tools_cata::create_cata] } {
      if {[info exists conf(bddimages,cata,create_cata)]} {
         set ::tools_cata::create_cata $conf(bddimages,cata,create_cata)
      } else {
         set ::tools_cata::create_cata 1
      }
   }
   if {! [info exists ::tools_cata::delpv] } {
      if {[info exists conf(bddimages,cata,delpv)]} {
         set ::tools_cata::delpv $conf(bddimages,cata,delpv)
      } else {
         set ::tools_cata::delpv 1
      }
   }
   if {! [info exists ::tools_cata::delimg] } {
      if {[info exists conf(bddimages,cata,delimg)]} {
         set ::tools_cata::delimg $conf(bddimages,cata,delimg)
      } else {
         set ::tools_cata::delimg 0
      }
   }
   if {! [info exists ::tools_cata::boucle] } {
      if {[info exists conf(bddimages,cata,boucle)]} {
         set ::tools_cata::boucle $conf(bddimages,cata,boucle)
      } else {
         set ::tools_cata::boucle 0
      }
   }
   if {! [info exists ::tools_cata::deuxpasses] } {
      if {[info exists conf(bddimages,cata,deuxpasses)]} {
         set ::tools_cata::deuxpasses $conf(bddimages,cata,deuxpasses)
      } else {
         set ::tools_cata::deuxpasses 1
      }
   }
   if {! [info exists ::tools_cata::limit_nbstars_accepted] } {
      if {[info exists conf(bddimages,cata,limit_nbstars_accepted)]} {
         set ::tools_cata::limit_nbstars_accepted $conf(bddimages,cata,limit_nbstars_accepted)
      } else {
         set ::tools_cata::limit_nbstars_accepted 5
      }
   }
   if {! [info exists ::tools_cata::log] } {
      if {[info exists conf(bddimages,cata,log)]} {
         set ::tools_cata::log $conf(bddimages,cata,log)
      } else {
         set ::tools_cata::log 0
      }
   }
   if {! [info exists ::tools_cata::threshold_ident_pos_star] } {
      if {[info exists conf(bddimages,cata,threshold_ident_pos_star)]} {
         set ::tools_cata::threshold_ident_pos_star $conf(bddimages,cata,threshold_ident_pos_star)
      } else {
         set ::tools_cata::threshold_ident_pos_star 30.0
      }
   }
   if {! [info exists ::tools_cata::threshold_ident_mag_star] } {
      if {[info exists conf(bddimages,cata,threshold_ident_mag_star)]} {
         set ::tools_cata::threshold_ident_mag_star $conf(bddimages,cata,threshold_ident_mag_star)
      } else {
         set ::tools_cata::threshold_ident_mag_star -30.0
      }
   }
   if {! [info exists ::tools_cata::threshold_ident_pos_ast] } {
      if {[info exists conf(bddimages,cata,threshold_ident_pos_ast)]} {
         set ::tools_cata::threshold_ident_pos_ast $conf(bddimages,cata,threshold_ident_pos_ast)
      } else {
         set ::tools_cata::threshold_ident_pos_ast 10.0
      }
   }
   if {! [info exists ::tools_cata::threshold_ident_mag_ast] } {
      if {[info exists conf(bddimages,cata,threshold_ident_mag_ast)]} {
         set ::tools_cata::threshold_ident_mag_ast $conf(bddimages,cata,threshold_ident_mag_ast)
      } else {
         set ::tools_cata::threshold_ident_mag_ast -100.0
      }
   }

   ::tools_cata::closetoconf

}




proc ::tools_cata::closetoconf { } {

   global conf

   # Repertoires 
   set conf(bddimages,catfolder,usnoa2)              $::tools_cata::catalog_usnoa2 
   set conf(bddimages,catfolder,ucac2)               $::tools_cata::catalog_ucac2  
   set conf(bddimages,catfolder,ucac3)               $::tools_cata::catalog_ucac3  
   set conf(bddimages,catfolder,ucac4)               $::tools_cata::catalog_ucac4  
   set conf(bddimages,catfolder,ppmx)                $::tools_cata::catalog_ppmx  
   set conf(bddimages,catfolder,ppmxl)               $::tools_cata::catalog_ppmxl
   set conf(bddimages,catfolder,tycho2)              $::tools_cata::catalog_tycho2 
   set conf(bddimages,catfolder,nomad1)              $::tools_cata::catalog_nomad1 
   set conf(bddimages,catfolder,2mass)               $::tools_cata::catalog_2mass 
   set conf(bddimages,catfolder,wfibc)               $::tools_cata::catalog_wfibc
   set conf(bddimages,catfolder,sdss)                $::tools_cata::catalog_sdss
   set conf(bddimages,catfolder,panstarrs)           $::tools_cata::catalog_panstarrs
   set conf(bddimages,catfolder,gaia1)               $::tools_cata::catalog_gaia1
   # Utilisation des catalogues
   set conf(bddimages,cata,use_usnoa2)               $::tools_cata::use_usnoa2
   set conf(bddimages,cata,use_ucac2)                $::tools_cata::use_ucac2
   set conf(bddimages,cata,use_ucac3)                $::tools_cata::use_ucac3
   set conf(bddimages,cata,use_ucac4)                $::tools_cata::use_ucac4
   set conf(bddimages,cata,use_ppmx)                 $::tools_cata::use_ppmx
   set conf(bddimages,cata,use_ppmxl)                $::tools_cata::use_ppmxl
   set conf(bddimages,cata,use_tycho2)               $::tools_cata::use_tycho2
   set conf(bddimages,cata,use_nomad1)               $::tools_cata::use_nomad1
   set conf(bddimages,cata,use_2mass)                $::tools_cata::use_2mass
   set conf(bddimages,cata,use_wfibc)                $::tools_cata::use_wfibc
   set conf(bddimages,cata,use_sdss)                 $::tools_cata::use_sdss
   set conf(bddimages,cata,use_panstarrs)            $::tools_cata::use_panstarrs
   set conf(bddimages,cata,use_gaia1)                $::tools_cata::use_gaia1
   set conf(bddimages,cata,use_skybot)               $::tools_cata::use_skybot
   # Autres utilitaires
   set conf(bddimages,cata,keep_radec)               $::tools_cata::keep_radec
   set conf(bddimages,cata,create_cata)              $::tools_cata::create_cata
   set conf(bddimages,cata,delpv)                    $::tools_cata::delpv
   set conf(bddimages,cata,delimg)                   $::tools_cata::delimg
   set conf(bddimages,cata,boucle)                   $::tools_cata::boucle
   set conf(bddimages,cata,deuxpasses)               $::tools_cata::deuxpasses
   set conf(bddimages,cata,limit_nbstars_accepted)   $::tools_cata::limit_nbstars_accepted
   set conf(bddimages,cata,log)                      $::tools_cata::log
   set conf(bddimages,cata,threshold_ident_pos_star) $::tools_cata::threshold_ident_pos_star
   set conf(bddimages,cata,threshold_ident_mag_star) $::tools_cata::threshold_ident_mag_star
   set conf(bddimages,cata,threshold_ident_pos_ast)  $::tools_cata::threshold_ident_pos_ast
   set conf(bddimages,cata,threshold_ident_mag_ast)  $::tools_cata::threshold_ident_mag_ast

}






proc ::tools_cata::charge_list { img_list } {

   global audace
   global bddconf

   catch {
      if { [ info exists $::tools_cata::img_list ] }           {unset ::tools_cata::img_list}
      if { [ info exists $::tools_cata::nb_img_list ] }        {unset ::tools_cata::nb_img_list}
      if { [ info exists $::tools_cata::current_image ] }      {unset ::tools_cata::current_image}
      if { [ info exists $::tools_cata::current_image_name ] } {unset ::tools_cata::current_image_name}
   }
   
   set ::tools_cata::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::tools_cata::img_list    [::bddimages_liste_gui::add_info_cata_list $::tools_cata::img_list]
   set ::tools_cata::nb_img_list [llength $::tools_cata::img_list]

   # Chargement premiere image sans GUI
   set ::tools_cata::id_current_image 1
   set ::tools_cata::current_image [lindex $::tools_cata::img_list 0]

   set tabkey      [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set cataexist   [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]

   set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]

   set ::tools_cata::file [file join $bddconf(dirbase) $dirfilename $filename]
   set ::tools_cata::ra       [lindex [::bddimages_liste::lget $tabkey RA] 1]
   set ::tools_cata::dec      [lindex [::bddimages_liste::lget $tabkey DEC] 1]
   set ::tools_cata::crota1   [lindex [::bddimages_liste::lget $tabkey CROTA1] 1]
   set ::tools_cata::crota2   [lindex [::bddimages_liste::lget $tabkey CROTA2] 1]
   set ::tools_cata::pixsize1 [lindex [::bddimages_liste::lget $tabkey PIXSIZE1] 1]
   set ::tools_cata::pixsize2 [lindex [::bddimages_liste::lget $tabkey PIXSIZE2] 1]
   set ::tools_cata::foclen   [lindex [::bddimages_liste::lget $tabkey FOCLEN] 1]
   set ::tools_cata::exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
   set ::tools_cata::naxis1   [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set ::tools_cata::naxis2   [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set ::tools_cata::xcent    [expr $::tools_cata::naxis1/2.0]
   set ::tools_cata::ycent    [expr $::tools_cata::naxis2/2.0]
   set ::tools_cata::bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1]]
   set ::tools_cata::current_image_name $filename
   set ::tools_cata::current_image_date $date

   gren_info "date = $date \n"
   gren_info "cata file = $::tools_cata::file \n"
   #gren_info "cata wcs = $::tools_cata::bddimages_wcs \n"

   set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
   if {$cataexist == 0} {
       gren_erreur "Le cata n'existe pas\n"
   }
   #if {[::bddimages_liste::lget $::tools_cata::current_image "cataexist"] == "1"} {
   #   gren_info "Le cata existe\n"
   #} else {
   #   gren_erreur "Le cata n'existe pas\n"
   #}
   
}




proc ::tools_cata::get_catafilename { img type } {

   global bddconf

   if {$type == "FILE"} {
      set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
      if {$catafilenameexist==0} {return -code 1 "catafilename n'existe pas dans l'image"}
      set catafilename [::bddimages_liste::lget $img "catafilename"]
      return -code 0 [::bddimages_liste::lget $img "catafilename"]
   }

   if {$type == "BASE"} {
      
   }

   if {$type == "DRIVE"} {
      set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
      if {$catafilenameexist==0} {return -code 1 "catafilename n'existe pas dans l'image"}
      set catafilename [::bddimages_liste::lget $img "catafilename"]

      set catadirfilename [::bddimages_liste::lexist $img "catadirfilename"]
      if {$catafilenameexist==0} {return -code 2 "catadirfilename n'existe pas dans l'image"}
      set catadirfilename [::bddimages_liste::lget $img "catadirfilename"]
   
      return -code 0 [file join $bddconf(dirbase) $catadirfilename $catafilename]
   }

   if {$type == "TMP"} {
      set catafilenameexist [::bddimages_liste::lexist $img "catafilename"]
      if {$catafilenameexist==0} {return -code 1 "catafilename n'existe pas dans l'image"}
      set catafilename [::bddimages_liste::lget $img "catafilename"]

      set catafilename [string range $catafilename 0 [expr [string last .gz $catafilename] -1]]

      return -code 0 [file join $bddconf(dirtmp) $catafilename]
   }

}






proc ::tools_cata::extract_cata_xml { catafile } {

   global bddconf

   if {[file extension $catafile] == ".gz"} {
      set xml [string range $catafile 0 [expr [string last .gz $catafile] -1]]
      set tmpfile [file join $bddconf(dirtmp) [file tail $xml]]
      lassign [::bdi_tools::gunzip $catafile $tmpfile] errnum msgzip
      if {$errnum == 1} {
         file delete -force -- $tmpfile
         return -code 1 "Erreur extraction cata $catafile -> $tmpfile with msg: $msgzip"
      } elseif {$msgzip == 0} {
         return -code 1 "Erreur extraction cata $catafile -> $tmpfile : gunzip n'a rien dezippe!"
      }
   } else {
      set tmpfile [file join $bddconf(dirtmp) [file tail $catafile]]
      if {$tmpfile != $catafile} {
         file copy -force -- "$catafile" "$tmpfile"
      }
   }
   return $tmpfile
}




proc ::tools_cata::get_cata_xml { catafile } {

   global bddconf

   set fields ""
   set fxml [open $catafile "r"]
   set data [read $fxml]
   close $fxml

   set motif  "<vot:TABLE\\s+?name=\"(.+?)\"\\s+?nrows=(.+?)>(?:.*?)</vot:TABLE>"
   set res [regexp -all -inline -- $motif $data]
   set cpt 1
   foreach { table name nrows } $res {
      set res [ ::tools_cata::get_table $name $table ]
      lappend fields [lindex $res 0]
      set asource [lindex $res 1]
      foreach x $asource {
         set idcataspec [lindex $x 0]
         set val [lindex $x 1]
         if {![info exists tsource($idcataspec)]} {
            set tsource($idcataspec) [list [list $name {} $val]]
         } else {
            lappend tsource($idcataspec) [list $name {} $val]
         }
      }
      incr cpt
   }
   
   set tab [array get tsource]
   set lso {}
   set cpt 0
   foreach val $tab {
      if {[expr $cpt%2] == 0 } {
         # indice
      } else {
         lappend lso $val
      }
      incr cpt
   }

   return [list $fields $lso]

}





proc ::tools_cata::get_table { name table } {

   set motif  "<vot:FIELD(?:.*?)name=\"(.+?)\"(?:.*?)</vot:FIELD>"

   set res [regexp -all -inline -- $motif $table ]
   set cpt 1
   set listfield ""
   foreach { x y } $res {
      if {$y != "idcataspec.$name"} { lappend listfield $y }
      incr cpt
   }
   
   set listfield [list $name [list ra dec poserr mag magerr] $listfield]

   set motiftr  "<vot:TR>(.*?)</vot:TR>"
   set motiftd  "<vot:TD>(.*?)</vot:TD>"
   
   set tr [regexp -all -inline -- $motiftr $table ]
   set cpt 1
   set lls ""
   foreach { a x } $tr {
      set x [string map { "<vot:TD/>" "<vot:TD></vot:TD>" } $x]
      set td [regexp -all -inline -- $motiftd $x ]
      set u 0
      set ls ""
      foreach { y z } $td {
         if { $u == 0 } {
            set idcataspec $z
         } else {
            lappend ls $z
         }
         incr u
      }
      lappend lls [list $idcataspec $ls]
      incr cpt
   }
   
   return [list $listfield $lls]
}





proc ::tools_cata::get_cata { {threadId ""} {log 0}} {

   global bddconf
   set saveinfile 0

   if {$log} {set tt0 [clock clicks -milliseconds]}
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem0 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   # Noms du fichier et du repertoire du cata TXT
   set imgfilename [::bddimages_liste::lget $::tools_cata::current_image filename]
   set imgdirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]

   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Analyse de l'image: $imgfilename\n"}

   # Definition du nom du cata XML
   set f [file join $bddconf(dirtmp) [file rootname [file rootname $imgfilename]]]
   set cataxml "${f}_cata.xml"
   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Cata image: $cataxml \n"}

   # Liste des champs du header de l'image
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

   # Liste des sources de l'image
   set listsources $::tools_cata::current_listsources

   # Initialisations
   set ra  $::tools_cata::ra
   set dec $::tools_cata::dec
   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set foclen  [lindex [::bddimages_liste::lget $tabkey FOCLEN] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   set crota1  [lindex [::bddimages_liste::lget $tabkey CROTA1] 1]
   set crota2  [lindex [::bddimages_liste::lget $tabkey CROTA2] 1]
   set mscale  [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
   set radius  [format "%0.0f" [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]]

   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: radius = $radius scale_x=$scale_x scale_y=$scale_y naxis1=$naxis1 naxis2=$naxis2 \n"}
   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: ::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale \n"}

   # Magnitude limite de recherche
   set mag_limit $::bdi_tools_appariement::calibwcs_param(maglimit)
   if {[string length  $mag_limit] < 1} {
      set mag_limit 18.0
   }
   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      Mag Limit = $mag_limit \n"}
   
   # parfois on a des sources en dehors de l image, alors on les jette
   if {$saveinfile} {
      set f [open [file join $bddconf(dirtmp) "listsources.tcl"] "a"]
      puts $f "set listsources \[list $listsources \]"
      close $f
   }
   set listsources [::manage_source::clean_out_sources $listsources $naxis1 $naxis2]

   if {1==0} {
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: get_wcs: --------------------------------\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: naxis1  = $naxis1\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: naxis2  = $naxis2\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: mscale  = $mscale\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: scale_x = $scale_x\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: scale_y = $scale_y\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: ra      = $ra\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: dec     = $dec\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: radius  = $radius\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: crota1  = $crota1\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: crota2  = $crota2\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: foclen  = $foclen\n"
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: get_wcs: --------------------------------\n"
   }

   if {$log} {set tt_prepa [clock clicks -milliseconds]}
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_prepa [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: IMG NB sources: [llength [lindex $listsources 1]] \n"}

   if {$::tools_cata::use_usnoa2} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius $mag_limit\n"}
      #gren_info "*** CMD: csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius\n"
      set usnoa2 [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $usnoa2]\n"
      set usnoa2 [::manage_source::set_common_fields $usnoa2 USNOA2 { magR 0.5 }]
      #::manage_source::imprim_3_sources $usnoa2
      #gren_info "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB USNOA2 [::manage_source::get_nb_sources $usnoa2]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $usnoa2 USNOA2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set listsources [ ::manage_source::delete_catalog $listsources USNOA2CALIB ]
      set ::tools_cata::nb_usnoa2 [::manage_source::get_nb_sources_by_cata $listsources USNOA2]
   }

   if {$::tools_cata::use_tycho2} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius\n"
      set tycho2 [cstycho2_fast $::tools_cata::catalog_tycho2 $ra $dec $radius $mag_limit]
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "tycho2.$threadId.txt"] "a"]
         puts $f "1:$imgfilename: $tycho2"
         close $f
      }
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $tycho2]\n"
      set tycho2 [::manage_source::set_common_fields $tycho2 TYCHO2 { VT e_VT }]
      #::manage_source::imprim_3_sources $tycho2
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB TYCHO2 [::manage_source::get_nb_sources $tycho2]\n"}
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "cmd.$threadId.txt"] "a"]
         puts $f "load libcatalog_tcl.so"
         puts $f "load libcatalog.so"
         puts $f "set tycho2 \[cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius\]"
         puts $f "identification \$listsources IMG \$nomad1 NOMAD1 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} 0 $threadId"
         close $f
         set f [open [file join $bddconf(dirtmp) "tycho2.$threadId.txt"] "a"]
         puts $f "set tycho2 $tycho2"
         close $f
         set f [open [file join $bddconf(dirtmp) "listsources.$threadId.txt"] "a"]
         puts $f "set listsources $listsources"
         close $f
      }
      set clog 0
      set listsources [ identification $listsources IMG $tycho2 TYCHO2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_tycho2 [::manage_source::get_nb_sources_by_cata $listsources TYCHO2]
   }

   if {$::tools_cata::use_ucac2} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csucac2 $::tools_cata::catalog_ucac2 $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csucac2 $::tools_cata::catalog_ucac2 $ra $dec $radius\n"
      set ucac2 [csucac2 $::tools_cata::catalog_ucac2 $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac2]\n"
      set ucac2 [::manage_source::set_common_fields $ucac2 UCAC2 { U2Rmag_mag 0.5 }]
      #::manage_source::imprim_3_sources $ucac2
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB UCAC2 [::manage_source::get_nb_sources $ucac2]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $ucac2 UCAC2 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_ucac2 [::manage_source::get_nb_sources_by_cata $listsources UCAC2]
   }

   if {$::tools_cata::use_ucac3} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius\n"
      set ucac3 [csucac3 $::tools_cata::catalog_ucac3 $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac3]\n"
      set ucac3 [::manage_source::set_common_fields $ucac3 UCAC3 { im2_mag sigmag_mag }]
      #::manage_source::imprim_3_sources $ucac3
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB UCAC3 [::manage_source::get_nb_sources $ucac3]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $ucac3 UCAC3 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_ucac3 [::manage_source::get_nb_sources_by_cata $listsources UCAC3]
   }

   if {$::tools_cata::use_ucac4} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius\n"
      set ucac4 [csucac4 $::tools_cata::catalog_ucac4 $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ucac4]\n"
      set ucac4 [::manage_source::set_common_fields $ucac4 UCAC4 { im2_mag sigmag_mag }]
      #::manage_source::imprim_3_sources $ucac4
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB UCAC4 [::manage_source::get_nb_sources $ucac4]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $ucac4 UCAC4 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_ucac4 [::manage_source::get_nb_sources_by_cata $listsources UCAC4]
   }

   if {$::tools_cata::use_ppmx} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csppmx $::tools_cata::catalog_ppmx $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csppmx $::tools_cata::catalog_ppmx $ra $dec $radius\n"
      set ppmx [csppmx $::tools_cata::catalog_ppmx $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ppmx]\n"
      set ppmx [::manage_source::set_common_fields $ppmx PPMX { Vmag ErrVmag }]
      #::manage_source::imprim_3_sources $ppmx
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB PPMX [::manage_source::get_nb_sources $ppmx]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $ppmx PPMX $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_ppmx [::manage_source::get_nb_sources_by_cata $listsources PPMX]
   }

   if {$::tools_cata::use_ppmxl} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csppmxl $::tools_cata::catalog_ppmxl $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csppmxl $::tools_cata::catalog_ppmxl $ra $dec $radius\n"
      set ppmxl [csppmxl $::tools_cata::catalog_ppmxl $ra $dec $radius $mag_limit]
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $ppmxl]\n"
      set ppmxl [::manage_source::set_common_fields $ppmxl PPMXL { magR1 0.5 }]
      #::manage_source::imprim_3_sources $ppmxl
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB PPMXL [::manage_source::get_nb_sources $ppmxl]\n"}
      set clog 0
      set listsources [ identification $listsources IMG $ppmxl PPMXL $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_ppmxl [::manage_source::get_nb_sources_by_cata $listsources PPMXL]
   }

   if {$::tools_cata::use_nomad1} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius\n"
      set nomad1 [csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius $mag_limit]
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "nomad1.$threadId.txt"] "a"]
         puts $f "1:$imgfilename: $nomad1"
         close $f
      }
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $nomad1]\n"
      set nomad1 [::manage_source::set_common_fields $nomad1 NOMAD1 { magV 0.5 }]
      #::manage_source::imprim_3_sources $nomad1
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB NOMAD1 [::manage_source::get_nb_sources $nomad1]\n"}
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "nomad1.$threadId.txt"] "a"]
         puts $f "2:$imgfilename: $nomad1"
         close $f
      }
      set clog 0
      set listsources [ identification $listsources IMG $nomad1 NOMAD1 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_nomad1 [::manage_source::get_nb_sources_by_cata $listsources NOMAD1]
   }

   if {$::tools_cata::use_2mass} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: cs2mass $::tools_cata::catalog_2mass $ra $dec $radius $mag_limit\n"}
      #gren_info "CMD: cs2mass $::tools_cata::catalog_2mass $ra $dec $radius\n"
      set twomass [cs2mass $::tools_cata::catalog_2mass $ra $dec $radius $mag_limit]
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "2mass1.$threadId.txt"] "a"]
         puts $f "1:$imgfilename: $twomass"
         close $f
      }
      #gren_info "rollup = [::manage_source::get_nb_sources_rollup $twomass]\n"
      set twomass [::manage_source::set_common_fields $twomass 2MASS { jMag jMagError }]
      #::manage_source::imprim_3_sources $twomass
      #gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB 2MASS [::manage_source::get_nb_sources $twomass]\n"}
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "2mass1.$threadId.txt"] "a"]
         puts $f "2:$imgfilename: $twomass"
         close $f
      }
      set clog 0
      set listsources [ identification $listsources IMG $twomass 2MASS $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_2mass [::manage_source::get_nb_sources_by_cata $listsources 2MASS]
   }

   if {$::tools_cata::use_wfibc} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: CMD: cswfibc $::tools_cata::catalog_wfibc $ra $dec $radius $mag_limit\n"}
      # gren_info "CMD: cswfibc $::tools_cata::catalog_wfibc $ra $dec $radius\n"
      set wfibc [cswfibc $::tools_cata::catalog_wfibc $ra $dec $radius $mag_limit]
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "wfibc.$threadId.txt"] "a"]
         puts $f "1:$imgfilename: $wfibc"
         close $f
      }
      # gren_info "rollup = [::manage_source::get_nb_sources_rollup $wfibc]\n"
      set wfibc [::manage_source::set_common_fields $wfibc WFIBC { magR error_magR } ]
      #::manage_source::imprim_3_sources $wfibc
      # gren_info  "[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S -timezone :UTC]: Identification\n"
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB WFIBC [::manage_source::get_nb_sources $wfibc]\n"}
      if {$saveinfile} {
         set f [open [file join $bddconf(dirtmp) "wfibc.$threadId.txt"] "a"]
         puts $f "2:$imgfilename: $wfibc"
         close $f
      }
      set clog 0
      set listsources [ identification $listsources IMG $wfibc WFIBC $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog $threadId ]
      set ::tools_cata::nb_wfibc [::manage_source::get_nb_sources_by_cata $listsources WFIBC]
   }

   if {$::tools_cata::use_sdss} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: SDSS ($::tools_cata::catalog_sdss)\n"}
      set radius [format "%0.0f" $radius]
      set err [catch {get_sdss $ra $dec $radius -topnum 10000 -mag_limit_min 0 -mag_limit_max $mag_limit} sdss]
      set sdss [::manage_source::set_common_fields $sdss SDSS { r Err_r } ]
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB SDSS [::manage_source::get_nb_sources $sdss]\n"}
      set clog 0; # log=2 pour activer ulog dans identification
      set listsources [identification $listsources "IMG" $sdss "SDSS" $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog  $threadId]
      set ::tools_cata::nb_sdss [::manage_source::get_nb_sources_by_cata $listsources SDSS]
   }

   if {$::tools_cata::use_panstarrs} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: PANSTARRS ($::tools_cata::catalog_panstarrs)\n"}
      set radius [format "%0.0f" $radius]
      set err [catch {get_panstarrs $ra $dec $radius -topnum 10000 -mag_limit_min 0 -mag_limit_max $mag_limit} panstarrs]
      set panstarrs [::manage_source::set_common_fields $panstarrs PANSTARRS { gmeanapmag gmeanapmagerr } ]
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB PANSTARRS [::manage_source::get_nb_sources $panstarrs]\n"}
      set clog 0; # log=2 pour activer ulog dans identification
      set listsources [identification $listsources "IMG" $panstarrs "PANSTARRS" $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog  $threadId]
      set ::tools_cata::nb_panstarrs [::manage_source::get_nb_sources_by_cata $listsources PANSTARRS]
   }

   if {$::tools_cata::use_gaia1} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: GAIA1 ($::tools_cata::catalog_gaia1)\n"}
      set gaia1 [csgaia1 $::tools_cata::catalog_gaia1 $ra $dec $radius $mag_limit]
      set gaia1 [::manage_source::set_common_fields $gaia1 GAIA1 { phot_g_mean_mag 0.5 } ]
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB GAIA1 [::manage_source::get_nb_sources $gaia1]\n"}
      set clog 0; # log=2 pour activer ulog dans identification
      set listsources [identification $listsources "IMG" $gaia1 GAIA1 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog  $threadId]
      set ::tools_cata::nb_gaia1 [::manage_source::get_nb_sources_by_cata $listsources GAIA1]
   }

#   if {$::tools_cata::use_tgas} {
#      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: GAIA WWW ($::tools_cata::catalog_gaia)\n"}
#      set radius [format "%0.0f" $radius]
#      set err [catch {get_gaia $ra $dec $radius -topnum 10000 -mag_limit_min 0 -mag_limit_max $mag_limit} gaia]
#      set gaia [::manage_source::set_common_fields $gaia GAIA1 { phot_g_mean_mag 0.5 } ]
#      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB GAIA [::manage_source::get_nb_sources $gaia]\n"}
#      set clog 0; # log=2 pour activer ulog dans identification
#      set listsources [::manage_source::delete_catalog $listsources GAIA1]
#      set listsources [identification $listsources "IMG" $gaia GAIA1 $::tools_cata::threshold_ident_pos_star $::tools_cata::threshold_ident_mag_star {} $clog  $threadId]
#      set ::tools_cata::nb_gaia [::manage_source::get_nb_sources_by_cata $listsources GAIA1]
#   }

   if {$::tools_cata::use_skybot} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Skybot \n"}
      set dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
      set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
      set datejd   [ mc_date2jd $dateobs ]
      set datejd   [ expr $datejd + $exposure/86400.0/2.0 ]
      set dateiso  [ mc_date2iso8601 $datejd ]
      set radius   [format "%0.0f" [expr $radius*60.0] ]
      set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]
      #gren_info "get_skybot $dateiso $ra $dec $radius $iau_code \n"
      set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} skybot ]
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: NB SKYBOT [::manage_source::get_nb_sources $skybot]\n"}
      set clog 0; # log=2 pour activer ulog dans identification
      set listsources [ identification $listsources "IMG" $skybot "SKYBOT" $::tools_cata::threshold_ident_pos_ast $::tools_cata::threshold_ident_mag_ast {} $clog  $threadId ] 
      set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
   }

   if {$log} {set tt_cm [clock clicks -milliseconds]}
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_cm [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}


   # Verification des identifications
   set msg [::tools_verifcata::verif_in_get_cata listsources]
   if {$log} {
      gren_info "[gren_date] SLAVE \[$threadId\]:      $msg \n"
   }

   if {$saveinfile} {
      set f [open [file join $bddconf(dirtmp) "listsources.tcl"] "a"]
      puts $f "set listsources \[list $listsources \]"
      close $f
   }


   # Effacement du catalogue IMG
   if {$::tools_cata::delimg} {
      set listsources [::manage_source::delete_catalog $listsources "IMG"]
   }
   
   if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      ROLLUP = [::manage_source::get_nb_sources_rollup $listsources]\n"}

   if {[::manage_source::get_nb_sources $listsources] == 0} {
      return -code 99 "No sources matched"
   }

   # Mesure des photocentres IMG
   if {$::bdi_tools_psf::use_psf} {
      ::bdi_tools_psf::get_psf_listsources listsources
      set ::tools_cata::nb_astroid [::manage_source::get_nb_sources_by_cata $listsources ASTROID]
   }

   if {$log} {set tt_psf [clock clicks -milliseconds]}
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_psf [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   # Sauvegarde du cata XML
   if {$::tools_cata::create_cata == 1} {
      if {$log} {gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Enregistrement du cata XML: $cataxml\n"}
      ::tools_cata::save_cata $listsources $tabkey $cataxml
   }
   
   set ::tools_cata::current_listsources $listsources

   #gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"

   catch  {
      unset imgfilename
      unset imgdirfilename
      unset f
      unset cataxml
      unset tabkey
      unset listsources
      unset ra
      unset dec
      unset naxis1 
      unset naxis2 
      unset scale_x
      unset scale_y
      unset mscale
      unset radius
      unset usnoa2
      unset tycho2
      unset ucac2
      unset ucac3
      unset ucac4
      unset ppmx
      unset ppmxl
      unset nomad1
      unset twomass
      unset wfibc
      unset sdss
      unset panstarrs
      unset gaia1
      unset skybot
      unset dateobs  
      unset exposure 
      unset datejd   
      unset dateiso  
      unset radius   
      unset iau_code 
      unset err
   }
   
   if {$log} {
      set tt_fin   [clock clicks -milliseconds]
      set tt_total [format "%4.1f" [expr ($tt_fin-$tt0)/1000.0]]
      set tt_fin   [format "%4.1f" [expr ($tt_fin-$tt_psf)/1000.0]]
      set tt_psf   [format "%4.1f" [expr ($tt_psf-$tt_cm)/1000.0]]
      set tt_cm    [format "%4.1f" [expr ($tt_cm-$tt_prepa)/1000.0]]
      set tt_prepa [format "%4.1f" [expr ($tt_prepa-$tt0)/1000.0]]
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Timing (s)  : total : $tt_total (prepa : $tt_prepa, cm : $tt_cm, psf : $tt_psf, final : $tt_fin)\n"
   }
   
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_fin [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   if {$log} {
      set mem_total [format "%4.1f" [expr $mem_fin-$mem0]]
      set mem_fin   [format "%4.1f" [expr $mem_fin-$mem_psf]]
      set mem_psf   [format "%4.1f" [expr $mem_psf-$mem_cm]]
      set mem_cm    [format "%4.1f" [expr $mem_cm-$mem_prepa]]
      set mem_prepa [format "%4.1f" [expr $mem_prepa-$mem0]]
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_cata: Memory (Mo) : total : $mem_total (prepa : $mem_prepa, cm : $mem_cm, psf : $mem_psf, final : $mem_fin)\n"
   }
   
   if {[::manage_source::get_nb_sources $::tools_cata::current_listsources]==0} {
      return -code 99 "No sources matched"
   } 

   catch {
      unset info
      unset log
      unset tt0
      unset tt_fin  
      unset tt_total
      unset tt_psf  
      unset tt_cm   
      unset tt_prepa

      unset mem0
      unset mem_fin
      unset mem_total 
      unset mem_psf   
      unset mem_cm    
      unset mem_prepa 
   }
   return true

#::manage_source::imprim_3_sources $::tools_cata::current_listsources
#gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $::tools_cata::current_listsources]\n"
#set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
#set votable [::votableUtil::list2votable $::tools_cata::current_listsources $tabkey]
#set fxml [open $cataxml "w"]
#puts $fxml $votable
#close $fxml

}




#
# Sauvegarde du cata XML et insertion dans la bdd si demande (insertcata=1)
#   listsources liste des sources des cata
#   tabkey      liste des tabkey
#   cataxml     nom du fichier du cata xml
#   insertcata  1|0 pour inserer ou non le cata xml dans la bdd
#
proc ::tools_cata::save_cata { listsources tabkey cataxml } {

   global bddconf

   set dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS   ] 1]
   #gren_info "date = $dateobs\n"
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   # Creation de la VOTable en memoire
   set votable [::votableUtil::list2votable $listsources $tabkey]
   
   # Sauvegarde du cata XML
   set fxml [open $cataxml "w"]
   puts $fxml $votable
   close $fxml
   
   # Insertion du cata dans bdi
   set err [ catch { insertion_solo $cataxml } msg ]
   gren_info "** INSERTION_SOLO = $err $msg\n"
   set cataexist [::bddimages_liste::lexist $::tools_cata::current_image "cataexist"]
   if {$cataexist == 0} {
      set ::tools_cata::current_image [::bddimages_liste::ladd $::tools_cata::current_image "cataexist" 1]
   } else {
      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image "cataexist" 1]
   }

}


#
# Sauvegarde du cata XML et insertion dans la bdd si demande (insertcata=1)
#   listsources liste des sources des cata
#   tabkey      liste des tabkey
#   cataxml     nom du fichier du cata xml
#   insertcata  1|0 pour inserer ou non le cata xml dans la bdd
#
proc ::tools_cata::save_cata_to_tmp { listsources tabkey cataxml } {

   global bddconf

   set dateobs [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
   #gren_info "date = $dateobs\n"
   #gren_info "rollup = [::manage_source::get_nb_sources_rollup $listsources]\n"

   # Creation de la VOTable en memoire
   set votable [::votableUtil::list2votable $listsources $tabkey]
   
   # Sauvegarde du cata XML
   set fxml [open $cataxml "w"]
   puts $fxml $votable
   close $fxml
   
}






#::tools_cata::test_ident_skybot 50 50 2

proc ::tools_cata::test_ident_skybot { x y l } {

   cleanmark

   set ra  $::tools_cata::ra
   set dec $::tools_cata::dec
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set listsources $::tools_cata::current_listsources

   gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"
   set listsources [ ::manage_source::delete_catalog $listsources "SKYBOT" ]
   gren_info "rollup listsources = [::manage_source::get_nb_sources_rollup $listsources]\n"

   set dateobs  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
   set exposure [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]
   set datejd   [expr [mc_date2jd $dateobs] + $exposure/86400.0/2.0]
   set dateiso  [mc_date2iso8601 $datejd]
   set radius   [format "%0.0f" [expr 10.*60.0] ]
   set iau_code [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]

   gren_info "get_skybot $dateiso $ra $dec $radius $iau_code\n"
   if {![info exists ::tools_cata::skybot]} {
      set err [ catch {get_skybot $dateiso $ra $dec $radius $iau_code} ::tools_cata::skybot ]
      if {$err} {
         gren_info "err = $err\n"
         gren_info "msg = $::tools_cata::skybot\n"
         return
      }
   }
   gren_info "skybot = $::tools_cata::skybot\n"

   #set listsources [::bdi_tools_sources::set_common_fields_skybot $listsources]
   set listsources [ identification $listsources "IMG" $::tools_cata::skybot "SKYBOT" $x $y {} $l] 
   set ::tools_cata::nb_skybot [::manage_source::get_nb_sources_by_cata $listsources SKYBOT]
   gren_info "nb_skybot = $::tools_cata::nb_skybot\n"
   #gren_info "[::manage_source::extract_sources_by_catalog $listsources SKYBOT]\n"
   #cleanmark
   affich_rond $listsources "SKYBOT" "magenta" 4

# {1647 0} {1689 0} {1700 0} {1712 0} {3058 0} {3069 0} {3073 0}

# {1678 0} {1738 0} {1752 0} {3420 0} {3463 0} {3465 0} {3488 0} 
# {1678 0} {1738 0} {1752 0} {3420 0} {3463 0} {3465 0} {3488 0} 

#{1299 0} {1334 0} {1342 0} {2737 0} {2779 0} {2781 0} {2802 0} 
#{1299 0} {1334 0} {1342 0} {2737 0} {2779 0} {2781 0} {2802 0} 
}

# ::tools_cata::get_maglimit 
proc ::tools_cata::get_maglimit { } {

   set tt0 [clock clicks -milliseconds]

   # tabkey
   set tabkey [::bdi_tools_image::get_tabkey_from_buffer]

   # recupere les caracteristiques de l image
   set ra      [lindex [::bddimages_liste::lget $tabkey RA] 1]
   set dec     [lindex [::bddimages_liste::lget $tabkey DEC] 1]
   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   set mscale  [::math::statistics::max [list [expr abs($scale_x)] [expr abs($scale_y)]]]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $mscale $mscale]

   # calcul de la maglimit
   set nb 0
   set ::tools_cata::mag_limit 0
   gren_info "nb_img  = $::tools_cata::nb_img\n"
   gren_info "refcata = $::bdi_tools_appariement::calibwcs_param(refcata)\n"
   gren_info "cmd     : csucac4 $::tools_cata::catalog_ucac4  $ra $dec $radius\n"

   while { $nb < $::tools_cata::nb_img } {
      incr ::tools_cata::mag_limit
      switch $::bdi_tools_appariement::calibwcs_param(refcata) {
         "USNOA2" { set l [csusnoa2 $::tools_cata::catalog_usnoa2 $ra $dec $radius $::tools_cata::mag_limit]}
         "TYCHO2" { set l [cstycho2 $::tools_cata::catalog_tycho2 $ra $dec $radius $::tools_cata::mag_limit]}
         "UCAC2"  { set l [csucac2  $::tools_cata::catalog_ucac2  $ra $dec $radius $::tools_cata::mag_limit]}
         "UCAC3"  { set l [csucac3  $::tools_cata::catalog_ucac3  $ra $dec $radius $::tools_cata::mag_limit]}
         "UCAC4"  { set l [csucac4  $::tools_cata::catalog_ucac4  $ra $dec $radius $::tools_cata::mag_limit]}
         "PPMX"   { set l [csppmx   $::tools_cata::catalog_ppmx   $ra $dec $radius $::tools_cata::mag_limit]}
         "PPMXL"  { set l [csppmxl  $::tools_cata::catalog_ppmxl  $ra $dec $radius $::tools_cata::mag_limit]}
         "NOMAD1" { set l [csnomad1 $::tools_cata::catalog_nomad1 $ra $dec $radius $::tools_cata::mag_limit]}
         "2MASS"  { set l [cs2mass  $::tools_cata::catalog_2mass  $ra $dec $radius $::tools_cata::mag_limit]}
         "WFIBC"  { set l [cswfibc  $::tools_cata::catalog_wfibc  $ra $dec $radius $::tools_cata::mag_limit]}
      }
      set nb [llength [lindex $l 1]]
      gren_info "mag limit = $::tools_cata::mag_limit / nb = $nb\n"
   }
   set ::tools_cata::mag_limit [expr $::tools_cata::mag_limit + 1]
   set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
   gren_erreur "mag_limit = $::tools_cata::mag_limit in $tt_total sec\n"
    
}

proc ::tools_cata::get_maglimit2 { } {

   set tt0 [clock clicks -milliseconds]

   set sources [lindex $::tools_cata::current_listsources 1]
   set ::tools_cata::mag_limit 0
   foreach s $sources { 
      foreach cata $s {
         if { [string toupper [lindex $cata 0]] == "IMG" } {
            set mag [lindex $cata 1 3]
            gren_info "mag = $mag / max = $::tools_cata::mag_limit\n"
            if {$mag > $::tools_cata::mag_limit} {
               set ::tools_cata::mag_limit $mag
            }
         }
      }
   }

   set ::tools_cata::mag_limit [expr $::tools_cata::mag_limit + 1]
   set tt_total [format "%4.1f" [expr ([clock clicks -milliseconds]-$tt0)/1000.0]]
   gren_erreur "mag_limit2 = $::tools_cata::mag_limit in $tt_total sec\n"
}


proc ::tools_cata::get_wcs { {threadId "0"}  {log 0}} {

   global audace
   global bddconf

   set mem_calib1 0
   set mem_calib2 0
   set mem_calib3 0
   set mem_calib4 0

   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem0 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}

   set img $::tools_cata::current_image

   set wcs_ok false

   # Infos sur l'image a traiter
   set tabkey [::bddimages_liste::lget $img "tabkey"]

   if {$::tools_cata::ra == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::ra_save]} {
      set ra $::tools_cata::ra_save
   } else {
      set ra $::tools_cata::ra
   }
   if {$::tools_cata::dec == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::dec_save]} {
      set dec $::tools_cata::dec_save
   } else {
      set dec $::tools_cata::dec
   }
   if {$::tools_cata::pixsize1 == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::pixsize1_save]} {
      gren_erreur "PIXSIZE1 not exist. affect save value = $::tools_cata::pixsize1_save\n"
      set pixsize1 $::tools_cata::pixsize1_save
      set ::tools_cata::pixsize1 $::tools_cata::pixsize1_save
   } else {
      set pixsize1 $::tools_cata::pixsize1
   }
   if {$::tools_cata::pixsize2 == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::pixsize2_save]} {
      gren_erreur "PIXSIZE2 not exist. affect save value = $::tools_cata::pixsize2_save\n"
      set pixsize2 $::tools_cata::pixsize2_save
      set ::tools_cata::pixsize2 $::tools_cata::pixsize2_save
   } else {
      set pixsize2 $::tools_cata::pixsize2
   }
   if {$::tools_cata::foclen == "" && $::tools_cata::keep_radec == 1 && [info exists ::tools_cata::foclen_save]} {
      gren_erreur "FOCLEN not exist. affect save value = $::tools_cata::foclen_save\n"
      set foclen $::tools_cata::foclen_save
      set ::tools_cata::foclen $::tools_cata::foclen_save
   } else {
      set foclen $::tools_cata::foclen
   }
   set exposure  $::tools_cata::exposure 

   set dateobs     [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]
   set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set filename    [::bddimages_liste::lget $img filename]
   set dirfilename [::bddimages_liste::lget $img dirfilename]
   set idbddimg    [::bddimages_liste::lget $img idbddimg]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]

   set xcent [expr $naxis1/2.0]
   set ycent [expr $naxis2/2.0]

   # Commande calibwcs a exectuer fourni par la methode d'appariement
   set ::bdi_tools_appariement::calibwcs_args "$ra $dec $pixsize1 $pixsize2 $foclen"
   set erreur [catch {set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"} msg]
   if {$::tools_cata::log} { gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: PASS1: $calibwcs_cmd\n" }
   if {$erreur} {
      return -code 1 "ERR = $erreur ($msg)"
   }

   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_avcalib1 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
   set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
   if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_apcalib1 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
   if {$log} {set mem_calib1 [format "%0.1f" [expr $mem_apcalib1 - $mem_avcalib1]]}

   if {$erreur} {

      if {  [info exists ::tools_cata::ra_save] \
         && [info exists ::tools_cata::dec_save] \
         && [info exists ::tools_cata::pixsize1_save] \
         && [info exists ::tools_cata::pixsize2_save] \
         && [info exists ::tools_cata::foclen_save] \
         } {
         set ra       $::tools_cata::ra_save
         set dec      $::tools_cata::dec_save
         set pixsize1 $::tools_cata::pixsize1_save
         set pixsize2 $::tools_cata::pixsize2_save
         set foclen   $::tools_cata::foclen_save
   
         set ::bdi_tools_appariement::calibwcs_args "$ra $dec $pixsize1 $pixsize2 $foclen"
         set erreur [catch {set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"} msg]
         if {$::tools_cata::log} { gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: PASS1_bis: $calibwcs_cmd\n" }
         if {$erreur} {
            return -code 1 "ERR = $erreur ($msg)"
         }

         if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_avcalib1 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
         set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
         if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_apcalib1 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
         if {$log} {set mem_calib1 [format "%0.1f" [expr $mem_apcalib1 - $mem_avcalib1]]}

      } else {

         # Log du developpeur
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: --------------------------------\n"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: - PERTE calibwcs : $mem_calib1\n"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: - calibwcs: $calibwcs_cmd\n"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: - erreur  : $erreur\n"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: - msg  : $msg\n"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: - file  : $file\n"
      
      }

      if {$erreur} {
         if {[info exists nbstars]} {
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: existe\n"
            if {[string is integer -strict $nbstars]} {
               return -code 10 "ERR NBSTARS = $nbstars ($msg)"
            } else {
               return -code 11 "ERR = $erreur ($msg)"
            }
         } else {
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: ERR-12 interne de calibwcs, voir le log de la libtt\n"
            return -code 12 "ERR = $erreur ($msg)"
         }
      }
   }

   set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
   set ra  [lindex $a 0]
   set dec [lindex $a 1]
   if {$::tools_cata::log} {
      gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
   }

   if {$::tools_cata::deuxpasses} {
      set ::bdi_tools_appariement::calibwcs_args "$ra $dec * * *"
      set erreur [catch {set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"} msg]
      if {$::tools_cata::log} { gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: PASS2: $calibwcs_cmd\n" }
      if {$erreur} {
         return -code 20 "ERR = $erreur ($msg)"
      }

      if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_avcalib2 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
      set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
      if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_apcalib2 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
      if {$log} {set mem_calib2 [format "%0.1f" [expr $mem_apcalib2 - $mem_avcalib2]]}

      if {$erreur} {
         return -code 21 "ERR NBSTARS = $nbstars ($msg)"
      }

      set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
      set ra  [lindex $a 0]
      set dec [lindex $a 1]
      if {$::tools_cata::log} {
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
      }
   }

   gren_debug "[gren_date] SLAVE \[$threadId\]:      get_wcs: nbstars/limit  = $nbstars / $::tools_cata::limit_nbstars_accepted \n"

   if { $::tools_cata::keep_radec==1 && $nbstars<$::tools_cata::limit_nbstars_accepted && [info exists ::tools_cata::ra_save] && [info exists ::tools_cata::dec_save] } {
      set ra  $::tools_cata::ra_save
      set dec $::tools_cata::dec_save
      set ::bdi_tools_appariement::calibwcs_args "$ra $dec * * *"

      
      set erreur [catch {set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"} msg]
      if {$::tools_cata::log} { gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: PASS3: $calibwcs_cmd\n" }
      if {$erreur} {
         return -code 30 "ERR = $erreur ($msg)"
      }
      if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_avcalib3 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
      set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
      if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_apcalib3 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
      if {$log} {set mem_calib3 [format "%0.1f" [expr $mem_apcalib3 - $mem_avcalib3]]}


      if {$erreur} {
         return -code 31 "ERR NBSTARS = $nbstars ($msg)"
      }
      set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
      set ra  [lindex $a 0]
      set dec [lindex $a 1]
      if {$::tools_cata::log} {
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: nbstars ra dec : $nbstars [mc_angle2hms $ra 360 zero 1 auto string] [mc_angle2dms $dec 90 zero 1 + string]\n"
      }

      if {$::tools_cata::deuxpasses} {
         set ::bdi_tools_appariement::calibwcs_args "$ra $dec * * *"
         set erreur [catch {set calibwcs_cmd "[::bdi_tools_appariement::get_calibwcs_cmde] -tmp_dir $bddconf(dirtmp)"} msg]
         if {$::tools_cata::log} { gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: PASS4: $calibwcs_cmd\n" }
         if {$erreur} {
            return -code 40 "ERR = $erreur ($msg)"
         }

         if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_avcalib4 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
         set erreur [catch {set nbstars [eval $calibwcs_cmd]} msg]
         if {$log} {set info [exec cat /proc/[pid]/status ] ; set mem_apcalib4 [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]}
         if {$log} {set mem_calib4 [format "%0.1f" [expr $mem_apcalib4 - $mem_avcalib4]]}

         if {$erreur} {
            return -code 41 "ERR NBSTARS = $nbstars ($msg)"
         }
         set a [buf$::audace(bufNo) xy2radec [list $xcent $ycent]]
         set ra  [lindex $a 0]
         set dec [lindex $a 1]
         if {$::tools_cata::log} {
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: RETRY nbstars : $nbstars | ra : [mc_angle2hms $ra 360 zero 1 auto string] | dec : [mc_angle2dms $dec 90 zero 1 + string]\n"
         }
      }

   }

   set ::tools_cata::current_listsources [::bdi_tools_appariement::get_cata]
   set ::tools_cata::nb_img  [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources IMG]
   set ::tools_cata::nb_ovni [::manage_source::get_nb_sources_by_cata $::tools_cata::current_listsources OVNI]
   set nb_wcs_ident [::manage_source::get_nb_sources $::tools_cata::current_listsources]

   if {$nbstars > $::tools_cata::limit_nbstars_accepted} {
      set wcs_ok true
   }

   if {$wcs_ok} {

      # Recherche de la mag limit
      
            # Pour l instant peu concluant

            #::tools_cata::get_maglimit
            #::tools_cata::get_maglimit2
            set ::tools_cata::mag_limit 30

            #::tools_cata::get_maglimit  -> 16
            #::tools_cata::get_maglimit2 -> 14
            # au final il faut 19
            # maglimit 17  ROLLUP = SKYBOT 1 UCAC4 371 USNOA2  724 TYCHO2 3 IMG 1423 2MASS 1377 UCAC2 185 TOTAL 1423
            # maglimit 18  ROLLUP = SKYBOT 1 UCAC4 371 USNOA2 1252 TYCHO2 3 IMG 1423 2MASS 1377 UCAC2 185 TOTAL 1423
            # maglimit 19  ROLLUP = SKYBOT 1 UCAC4 371 USNOA2 1355 TYCHO2 3 IMG 1423 2MASS 1377 UCAC2 185 TOTAL 1423
            # maglimit 30  ROLLUP = SKYBOT 1 UCAC4 375 USNOA2 1355 TYCHO2 3          2MASS 1377 UCAC2 185 TOTAL 1405
      
      # On garde les valeurs pour init prochaine image
      set ::tools_cata::ra_save       [lindex [buf$::audace(bufNo) getkwd RA] 1]
      set ::tools_cata::dec_save      [lindex [buf$::audace(bufNo) getkwd DEC] 1]
      set ::tools_cata::pixsize1_save [lindex [buf$::audace(bufNo) getkwd PIXSIZE1] 1]
      set ::tools_cata::pixsize2_save [lindex [buf$::audace(bufNo) getkwd PIXSIZE2] 1]
      set ::tools_cata::foclen_save   [lindex [buf$::audace(bufNo) getkwd FOCLEN] 1]

      # Efface les cles PV1_0 et PV2_0 car pas bon
      if {$::tools_cata::delpv} {
         set err [catch {buf$::audace(bufNo) delkwd PV1_0} msg]
         set err [catch {buf$::audace(bufNo) delkwd PV2_0} msg]
      }

      # Modifie le champs BDI
      set key [list "BDDIMAGES WCS" "Y" "string" "WCS performed: Y|N|?" ""]
      buf$::audace(bufNo) delkwd "BDDIMAGES WCS"
      buf$::audace(bufNo) setkwd $key

      # Modifie le champs BDI
      set key [list "BDDIMAGES ASTROID" "W" "string" "Astroid performed" ""]
      buf$::audace(bufNo) delkwd "BDDIMAGES ASTROID"
      buf$::audace(bufNo) setkwd $key


      # Si on est en mode NOGUI pour Astroid automatique alors on sort
      # TODO : cela devra a terme etre toujours le cas pour inserer
      # seulement a la fin le cata et l image avec les infos dans le header 
      # qui correspondent a l analyse de l image et de creation du cata
      if {[info exists ::bddimages::nogui]} {
         if {$::bddimages::nogui} {
            
            catch {
               unset img
               unset wcs_ok
               unset tabkey
               unset ra
               unset dec
               unset pixsize1
               unset pixsize2
               unset foclen
               unset exposure
               unset dateobs     
               unset naxis1      
               unset naxis2      
               unset filename    
               unset dirfilename 
               unset idbddimg    
               unset file        
               unset xcent
               unset ycent
               unset erreur
               unset a
               unset err
               unset key
            }

            # recupere le tabkey du buffer
            set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
            # redefini l'image courante
            set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image tabkey $tabkey]

            # log
            if {$log} {
               set info [exec cat /proc/[pid]/status ] ; set mem_fin [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
               set mem_calib [format "%0.1f" [expr $mem_calib1+$mem_calib2+$mem_calib3+$mem_calib4]]
               set mem_total [format "%0.1f" [expr $mem_fin-$mem0]]
               set mem_autre [format "%0.1f" [expr $mem_total-$mem_calib]]
               gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: Memoire (Mo) : total : $mem_total (autre: $mem_autre, calib : $mem_calib (1:$mem_calib1, 2:$mem_calib2, 3:$mem_calib3, 4:$mem_calib4))\n"
            }
            return -code 0 "WCS OK"
         }

      }

      # Avec GUI on continu

      set err [catch { ::tools_cata::save_current_image_from_buffer_to_base $idbddimg} new_idbddimg ]
      
      if {$err} {

         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: save_current_image_from_buffer_to_base: err = $err"
         gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: save_current_image_from_buffer_to_base: idbddimg = $new_idbddimg"
         return -code $err "WCS ERROR FILE INSERTION : ($new_idbddimg)"

      } else { 

         catch {
            unset img
            unset wcs_ok
            unset tabkey
            unset ra
            unset dec
            unset pixsize1
            unset pixsize2
            unset foclen
            unset exposure
            unset dateobs     
            unset naxis1      
            unset naxis2      
            unset filename    
            unset dirfilename 
            unset idbddimg    
            unset file        
            unset xcent
            unset ycent
            unset erreur
            unset a
            unset err
            unset key
         }

         if {$log} {
            set info [exec cat /proc/[pid]/status ] ; set mem_fin [format "%0.1f" [expr [::bdi_tools_cdl::get_mem info "VmSize:"] / 1024.0 ] ]
            set mem_calib [format "%0.1f" [expr $mem_calib1+$mem_calib2+$mem_calib3+$mem_calib4]]
            set mem_total [format "%0.1f" [expr $mem_fin-$mem0]]
            set mem_autre [format "%0.1f" [expr $mem_total-$mem_calib]]
            gren_info "[gren_date] SLAVE \[$threadId\]:      get_wcs: Memoire (Mo) : total : $mem_total (autre: $mem_autre, calib : $mem_calib (1:$mem_calib1, 2:$mem_calib2, 3:$mem_calib3, 4:$mem_calib4))\n"
         }
         return -code 0 "WCS OK"
      }

   }
   return -code 10 "Sources non identifiees ($nbstars)"
}




proc ::tools_cata::save_current_image_from_buffer_to_tmp { idbddimg { threadId "0" } } {

   global bddconf

   gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : On recup les infos du fichier"
   set ident [bddimages_image_identification $idbddimg]
   set fileimg  [lindex $ident 1]
   set filecata [lindex $ident 3]
   if {$fileimg == -1} {
      gren_erreur "[gren_date] SLAVE \[$threadId\]: ------------------------"
      gren_erreur "[gren_date] SLAVE \[$threadId\]:  idbddimg = $idbddimg"
      gren_erreur "[gren_date] SLAVE \[$threadId\]:  ident    = $ident"
      gren_erreur "[gren_date] SLAVE \[$threadId\]: ------------------------"
      return -code 5 "Fichier image inexistant ($idbddimg) \n"
   }

   set fichtmpunzip [unzipedfilename $fileimg]
   set filetmp      [file join $bddconf(dirtmp) [file tail $fichtmpunzip]]
   set filefinal    [file join $bddconf(dirtmp) [file tail $fileimg]]

   # On sauve le buffer 
   createdir_ifnot_exist $bddconf(dirtmp)
   gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : On sauve le buffer "
   buf$::audace(bufNo) save $filetmp

#gren_info "** get_cata : PID:[pid] : re-wait 60 sec\n"
#after 20000
#gren_info "** get_cata : PID:[pid] : go\n"

   # On zip l image
   gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : On zip l image"
   lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg

#gren_info "** get_cata : PID:[pid] : re-wait 60 sec\n"
#after 20000
#gren_info "** get_cata : PID:[pid] : continue\n"

   if {$errnum != 0} {
      set msg "[gren_date] SLAVE \[$threadId\]:      Appel gzip: $filetmp -> $filefinal\n  size filetmp = [file size $filetmp]\n   => err=$errnum avec msg: $msg\n"
      gren_info $msg
      return -code 8 $msg
   }

   gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_tmp : On sort"
   return -code 0 $filefinal

}






proc ::tools_cata::save_current_image_from_buffer_to_inco { idbddimg { threadId "0" } } {

   global bddconf

   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_inco : On recup les infos du fichier"
   set ident [bddimages_image_identification $idbddimg]
   set fileimg  [lindex $ident 1]
   set filecata [lindex $ident 3]
   if {$fileimg == -1} {
      gren_erreur "[gren_date] SLAVE \[$threadId\]: ------------------------"
      gren_erreur "[gren_date] SLAVE \[$threadId\]:  idbddimg = $idbddimg"
      gren_erreur "[gren_date] SLAVE \[$threadId\]:  ident    = $ident"
      gren_erreur "[gren_date] SLAVE \[$threadId\]: ------------------------"
      return -code 5 "Fichier image inexistant ($idbddimg) \n"
   }

   set fichtmpunzip [unzipedfilename $fileimg]
   set filetmp      [file join $bddconf(dirinco) [file tail $fichtmpunzip]]
   set filefinal    [file join $bddconf(dirinco) [file tail $fileimg]]

   # On sauve le buffer 
   createdir_ifnot_exist $bddconf(dirinco)
   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_inco : On sauve le buffer "
   buf$::audace(bufNo) save $filetmp

#gren_info "** get_cata : PID:[pid] : re-wait 60 sec\n"
#after 20000
#gren_info "** get_cata : PID:[pid] : go\n"

   # On zip l image
   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_inco : On zip l image"
   lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg

#gren_info "** get_cata : PID:[pid] : re-wait 60 sec\n"
#after 20000
#gren_info "** get_cata : PID:[pid] : continue\n"

   if {$errnum != 0} {
      set msg "[gren_date] SLAVE \[$threadId\]:      Appel gzip: $filetmp -> $filefinal\n  size filetmp = [file size $filetmp]\n   => err=$errnum avec msg: $msg\n"
      gren_info $msg
      return -code 8 $msg
   }

   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_inco : On sort"
   return -code 0 $filefinal

}






proc ::tools_cata::save_current_image_from_buffer_to_base { idbddimg { threadId "0" } } {

   global bddconf

   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_base : On recup les infos du fichier"
   set ident [bddimages_image_identification $idbddimg]
   set fileimg  [lindex $ident 1]
   set filecata [lindex $ident 3]
   if {$fileimg == -1} {
      if {$erreur} {
         return -code 5 "Fichier image inexistant ($idbddimg) \n"
      }
   }

   set fichtmpunzip [unzipedfilename $fileimg]
   set filetmp      [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
   set filefinal    [file join $::bddconf(dirinco) [file tail $fileimg]]

   # On sauve le buffer 
   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_base : On sauve le buffer "
   createdir_ifnot_exist $bddconf(dirtmp)
   buf$::audace(bufNo) save $filetmp

   # On zip l image
   #gren_info "[gren_date] SLAVE \[$threadId\]:      save_current_image_from_buffer_to_base : On zip l image"
   lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg

   if {$errnum != 0} {
      gren_info "Appel gzip: $filetmp -> $filefinal\n"
      gren_info "  size filetmp = [file size $filetmp]\n" 
      gren_info "   => err=$errnum avec msg: $msg\n"
   }

   # efface l image dans la base et le disque
   bddimages_image_delete_fromsql $ident
   bddimages_image_delete_fromdisk $ident

   # insere l image et le cata dans la base filecata
   set errnum [catch {set r [insertion_solo $filefinal]} msg ]
   if {$errnum == 0} {
      set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image idbddimg $r]
   }

   # efface le fichier tmp
   set errnum [catch {file delete -force $filetmp} msg]

   # recupere le tabkey du buffer
   set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
   # refefini l'image courante
   set ::tools_cata::current_image [::bddimages_liste::lupdate $::tools_cata::current_image tabkey $tabkey]
   # recupe l'id bddimage de l'image courante
   set idbddimg [::bddimages_liste::lget $::tools_cata::current_image "idbddimg"]

   return -code 0 $idbddimg

}




#
# Calcul le rayon (arcmin) du FOV de l'image
#
proc ::tools_cata::get_radius { naxis1 naxis2 scale_x scale_y } {

   #--- Calcul de la dimension du FOV: naxis*scale
   set taille_champ_x [expr abs($scale_x)*$naxis1*60.0]
   set taille_champ_y [expr abs($scale_y)*$naxis2*60.0]

   set radius [expr sqrt(pow($taille_champ_x,2) + pow($taille_champ_y,2)) ]
   return $radius

}





proc ::tools_cata::get_id_astrometric { tag sent_current_listsources} {
   
   upvar $sent_current_listsources listsources
   
   set result ""
   set sources [lindex $listsources 1]
   set cpt 0
   foreach s $sources {
      set x  [lsearch -index 0 $s "ASTROID"]
      if {$x>=0} {
         set othf  [lindex [lindex $s $x] 2]           
         set ar [::bdi_tools_psf::get_val othf "flagastrom"]
         set ac [::bdi_tools_psf::get_val othf "cataastrom"]
         if {$ar==$tag} {
            set name [::manage_source::naming $s $ac]
            lappend result [list $cpt $x $ar $ac $name]
         }
      }
      incr cpt
   }
   
   return $result
}



# Anciennement ::bdi_gui_cata::get_img_null
# return une ligne de champ nul pour la creation d'une entree IMG dans le catalogue
proc ::tools_cata::get_img_fields { } {
   return [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]

}

proc ::tools_cata::get_img_null { } {
 
   return [list "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" ]
}


# Anciennement ::bdi_gui_cata::is_astrometric_catalog
# renvoit le nom d'un catalogue consideré comme astrometrique
proc ::tools_cata::is_astrometric_catalog { c } {

   return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2 WFIBC GAIA1] $c] + 1]
}


# Anciennement ::bdi_gui_cata::is_photometric_catalog 
# renvoit le nom d'un catalogue consideré comme photometrique
proc ::tools_cata::is_photometric_catalog { c } {

   return [expr [lsearch -exact [list USNOA2 UCAC2 UCAC3 UCAC4 TYCHO2 SDSS PANSTARRS GAIA1] $c] + 1]
}





# Anciennement ::bdi_gui_cata::push_img_list

proc ::tools_cata::push_img_list {  } {

   set ::tools_cata::img_list_sav         $::tools_cata::img_list
   set ::tools_cata::current_image_sav    $::tools_cata::current_image
   set ::tools_cata::id_current_image_sav $::tools_cata::id_current_image
   set ::tools_cata::create_cata_sav      $::tools_cata::create_cata

   array unset ::tools_cata::cata_list_sav
   if {[info exists ::bdi_gui_cata::cata_list]} {
      array set ::tools_cata::cata_list_sav  [array get ::bdi_gui_cata::cata_list]
   }

}









# Anciennement ::bdi_gui_cata::pop_img_list

proc ::tools_cata::pop_img_list {  } {

   set ::tools_cata::img_list         $::tools_cata::img_list_sav
   set ::tools_cata::current_image    $::tools_cata::current_image_sav
   set ::tools_cata::id_current_image $::tools_cata::id_current_image_sav
   set ::tools_cata::create_cata      $::tools_cata::create_cata_sav

   array unset ::bdi_gui_cata::cata_list
   if {[info exists ::tools_cata::cata_list_sav]} {
      array set ::bdi_gui_cata::cata_list  [array get ::tools_cata::cata_list_sav]
   } 

}







# Anciennement ::bdi_gui_cata::current_listsources_to_tklist



proc ::tools_cata::current_listsources_to_tklist { } {

   set listsources $::tools_cata::current_listsources
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   #gren_erreur "sources current_listsources_to_tklist=[lindex $sources {1 9 2 0}]\n"

   set nbcata  [llength $fields]

   array unset ::bdi_gui_cata::tklist
   array unset ::bdi_gui_cata::tklist_list_of_columns
   array unset ::bdi_gui_cata::cataname

   catch {
      unset ::bdi_gui_cata::cataname
      unset ::bdi_gui_cata::cataid
   }

   set commonfields {ra dec poserr mag magerr}
   set idcata 0
   set list_id ""
   foreach f $fields {
      incr idcata
      set c [lindex $f 0]
      set ::bdi_gui_cata::cataname($idcata) $c
      set ::bdi_gui_cata::cataid($c) $idcata
      if {$c=="ASTROID"} {
         set idcata_astroid $idcata
         set list_id [linsert $list_id 0 $idcata]
      } else {
         set list_id [linsert $list_id end $idcata]
      }
   }
   
   foreach idcata $list_id {

      set ::bdi_gui_cata::tklist($idcata) ""
      set ::bdi_gui_cata::tklist_list_of_columns($idcata) [list  \
                                 [list "bdi_idc_lock"      "Id"] \
                                 [list "astrom_reference"  "AR"] \
                                 [list "astrom_catalog"    "AC"] \
                                 [list "photom_reference"  "PR"] \
                                 [list "photom_catalog"    "PC"] \
                                 ]
      foreach cc $commonfields {
         lappend ::bdi_gui_cata::tklist_list_of_columns($idcata) [list $cc $cc]
      }

      set otherfields ""
      foreach f $fields {
         if {[lindex $f 0]==$::bdi_gui_cata::cataname($idcata)} {
            foreach cc [lindex $f 2] {
               lappend ::bdi_gui_cata::tklist_list_of_columns($idcata) [list $cc $cc]
               lappend otherfields $cc
            }
         }
      }
   }
      
   #gren_info "m list_of_columns = $list_of_columns \n"
   #gren_info "$::bdi_gui_cata::cataname($idcata) => fields : $otherfields\n"

   set cpts 0

   foreach s $sources {

      incr cpts

      set ar ""
      set ac ""
      set pr ""
      set pc ""

      set x  [lsearch -index 0 $s "ASTROID"]
      if {$x>=0} {
         set othf [lindex [lindex $s $x] 2]           
         set ar [::bdi_tools_psf::get_val othf "flagastrom"]
         set ac [::bdi_tools_psf::get_val othf "cataastrom"]
         set pr [::bdi_tools_psf::get_val othf "flagphotom"]
         set pc [::bdi_tools_psf::get_val othf "cataphotom"]
         #gren_info "AR = $ar $ac $pr $pc\n"
      }

      foreach cata $s {
         #set a [lindex $cata 0]
         #if {$a == "ASTROID"} { gren_info "cata = $a\n" }
         if {![info exists ::bdi_gui_cata::cataid([lindex $cata 0])]} { continue }
         set idcata $::bdi_gui_cata::cataid([lindex $cata 0])
         set line ""
         # ID
         lappend line $cpts
         # valeur des Flag ASTROID
         lappend line $ar
         lappend line $ac
         lappend line $pr
         lappend line $pc
         # valeur des common
         foreach field [lindex $cata 1] {
            lappend line $field
         }
         # valeur des other field
         foreach field [lindex $cata 2] {
            lappend line $field
         }
         lappend ::bdi_gui_cata::tklist($idcata) $line
         #if {$a == "ASTROID"} { gren_info "line = $line\n" }
         #if {$a == "ASTROID"} { return }
         
      }

   }


}





# Anciennement ::bdi_gui_cata::setCenterFromRADEC

proc ::tools_cata::setCenterFromRADEC { } {

   set rd [regexp -inline -all -- {\S+} $::tools_cata::coord]
   set ra [lindex $rd 0]
   set dec [lindex $rd 1]
   set ::tools_cata::ra  $ra
   set ::tools_cata::dec $dec
   gren_info "SET CENTER FROM RA,DEC: $::tools_cata::ra $::tools_cata::dec\n"

}



# Anciennement ::bdi_gui_cata::sendImageAndTable

proc ::tools_cata::broadcastImageAndTable { } {

   global bddconf

   set idbddimg    [::bddimages_liste::lget $::tools_cata::current_image idbddimg]
   set dirfilename [::bddimages_liste::lget $::tools_cata::current_image dirfilename]
   set filename    [::bddimages_liste::lget $::tools_cata::current_image filename   ]
   set file        [file join $bddconf(dirbase) $dirfilename $filename]
   
   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]
   set ::tools_cata::ra        [lindex [::bddimages_liste::lget $tabkey ra      ] 1]
   set ::tools_cata::dec       [lindex [::bddimages_liste::lget $tabkey dec     ] 1]
   set ::tools_cata::pixsize1  [lindex [::bddimages_liste::lget $tabkey pixsize1] 1]
   set ::tools_cata::pixsize2  [lindex [::bddimages_liste::lget $tabkey pixsize2] 1]
   set ::tools_cata::foclen    [lindex [::bddimages_liste::lget $tabkey foclen  ] 1]
   set ::tools_cata::exposure  [lindex [::bddimages_liste::lget $tabkey EXPOSURE] 1]

   set ::tools_cata::bddimages_wcs [string trim [lindex [::bddimages_liste::lget $tabkey bddimages_wcs] 1]]

   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   set radius  [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

   # Envoie de l'image dans Aladin via Samp
   ::SampTools::broadcastImage
   
   set cataexist [::bddimages_liste::lget $::tools_cata::current_image "cataexist"]
   set catafile [::bddimages_liste::lget $::tools_cata::current_image "catafilename"]
   set catafilename [string range $catafile 0 [expr [string last .gz $catafile] -1]]
   set catadir [::bddimages_liste::lget $::tools_cata::current_image "catadirfilename"]
   set cata [file join $bddconf(dirbase) $bddconf(dirtmp) $catafilename]

   set ::tools_cata::current_image [::bddimages_liste_gui::add_info_cata $::tools_cata::current_image]

   # Envoie du CATA dans Aladin via Samp
   if {$cataexist} {
      set ::votableUtil::votBuf(file) $cata
      ::SampTools::broadcastTable
   } else {
      gren_erreur "Cata does not exist. Broadcast to VO tools aborted."
   }

}


# Anciennement ::bdi_gui_cata::set_aladin_script_params

proc ::tools_cata::set_aladin_script_params { } {

   set tabkey [::bddimages_liste::lget $::tools_cata::current_image "tabkey"]

   set ::tools_cata::uaicode [string trim [lindex [::bddimages_liste::lget $tabkey IAU_CODE] 1]]

   set ra  [lindex [::bddimages_liste::lget $tabkey ra] 1]
   set dec [lindex [::bddimages_liste::lget $tabkey dec] 1]
   if {$dec > 0} { set dec "+$dec" }
   set ::tools_cata::coord "$ra $dec"

   set naxis1  [lindex [::bddimages_liste::lget $tabkey NAXIS1] 1]
   set naxis2  [lindex [::bddimages_liste::lget $tabkey NAXIS2] 1]
   set scale_x [lindex [::bddimages_liste::lget $tabkey CDELT1] 1]
   set scale_y [lindex [::bddimages_liste::lget $tabkey CDELT2] 1]
   set ::tools_cata::radius [::tools_cata::get_radius $naxis1 $naxis2 $scale_x $scale_y]

}


# Anciennement ::bdi_gui_cata::sendAladinScript

proc ::tools_cata::broadcastAladinScript { } {

   # Get parameters
   set coord $::tools_cata::coord
   set radius_arcmin "${::tools_cata::radius}arcmin"
   set radius_arcsec [concat [expr $::tools_cata::radius * 60.0] "arcsec"]
   set date $::tools_cata::current_image_date
   set uaicode [string trim $::tools_cata::uaicode]

   # Request Skybot cone-search
   set skybotQuery "get SkyBoT.IMCCE($date,$uaicode,'Asteroids and Planets','$radius_arcsec')"

   # Draw a circle to mark the fov center
   set lcoord [split $coord " "]
   set drawFovCenter "draw phot([lindex $lcoord 0],[lindex $lcoord 1],20.00arcsec)"
   # Draw USNO stars as triangles
   set shapeUSNO "set USNO2 shape=triangle"

   # Aladin Script
   set script "get Aladin(DSS2) ${coord} $radius_arcmin; get VizieR(USNO2); sync; $shapeUSNO; $drawFovCenter; $skybotQuery;"
   # Broadcast script
   ::SampTools::broadcastAladinScript $script

}




proc ::tools_cata::skybotResolver { } {

   set name $::tools_cata::target
   set date $::tools_cata::current_image_date
   set uaicode [string trim $::tools_cata::uaicode]

   set erreur [ catch { vo_skybotresolver $date $name text basic $uaicode } skybot ]
   if { $erreur == "0" } {
      if { [ lindex $skybot 0 ] == "no" } {
         tk_messageBox -message "skybotResolver error: the solar system object '$name' was not resolved by SkyBoT" -type ok
      } else {
         set resp [split $skybot ";"]
         set respdata [split [lindex $resp 1] "|"]
         set ra [expr [lindex $respdata 2] * 15.0]
         set dec [lindex $respdata 3]
         if {$dec > 0} { set dec "+[string trim $dec]" }
         set ::tools_cata::coord "$ra $dec"
      }
   } else {
      tk_messageBox -message "skybotResolver error: $erreur : $skybot" -type ok
   }

}



proc ::tools_cata::date2idcata { date } {
   
   set id_current_image 0
   foreach current_image $::tools_cata::img_list {
      incr id_current_image
      set tabkey  [::bddimages_liste::lget $current_image "tabkey"]
      set dateiso [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      if {[::bdi_tools::is_isodates_equal $dateiso $date]} {
         return $id_current_image
      }
   }
   return -1
}
