#--------------------------------------------------
# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/priam/priam.tcl
#--------------------------------------------------
#
# Fichier        : priam.tcl
# Description    : Utilisation de Priam pour faire l astrometrie
# Auteur         : Frederic Vachier
# Mise à jour $Id: priam.tcl 6795 2011-02-26 16:05:27Z fredvachier $
#

namespace eval ::priam {




# Lance le programme Priam
   proc ::priam::launch_priam {  } {
       
      global bddconf
      
      #set err [catch {exec pwd} msg]
      #gren_info "launch_priam:  PWD : <$msg>\n"
      set err [catch {exec sh ./cmd.priam} msg]
      
      if {$err} {
         gren_info "launch_priam ERREUR d\n"
         gren_info "launch_priam:  NUM : <$err>\n" 
      }   
      #gren_info "launch_priam:  MSG : <$msg>\n"
      
      set tab [split $msg "\0"]
      set pass "no"
      foreach l $tab {
         #gren_info "ligne=$l n"
         set exs [string first "writing results in the file:" $l]
         if {$exs>=0} {
            set r [string last "writing results in the file:" $l ]
            #gren_info "r=$r ***\n"
            set file [string trim [string range $l [expr 29+$r] end] ]
            #gren_info "file=$file\n"
            set pass "yes"
         }

      }
    
      if {$pass=="yes"} {
        #gren_info "PRIAMRESULT: =$file\n"
        return -code 0 $file
      } else {
        return -code -1 $msg
      }

   }
   






# ** Exemple du fichier science.mes

# #? Centroid measures formatted for Priam
# #?   Source: Tasp/idl - mai 2004
# #? Object: 1446 Sillanpaa 
# #
# #> orientation: wn
# #
# #! Frame: /observ/ohp/T120/2009/test/n1/p68484f1.fits
# 2454908.5137460064   20.00 1013.500  35.0   0.57000
# S 2.618036E+02 6.804010E-02 6.224708E+02 8.501132E-02 4.471942E+00 3.288280E+00 1.769230E+01 NewObj
# R 6.797814E+02 3.830099E-03 8.745620E+02 4.537117E-03 3.725335E+00 4.525925E+00 1.185362E+01 Star_1

# ** Exemple fichier local.cat

#     NOM *                 ______RA_______ _____DEC_______ RPMA RPMD __EPOCH___  _RSA_ _RSD_  RSPMA  RSPMD  _MAG_   TS  PARALE VIT_RAD
# 2MASS_12585626+0052218    12 58 56.261520 +00 52 21.87840 0.00 0.00 2451545.50  100.0 100.0  0.000  0.000  16.083  ?    0.00    0.0
#
# Avec: 
#   Epoch = Epoque de reference de la position catalogue (J2000 par defaut)
#   RPMA = mvt propre en RA en s/year
#   RPMD = mvt propre en DEC en "/year
#   RSA = Erreur position RA en mas
#   RSD = Erreur position DEC en mas
#   RSPMA = Erreur mvt propre RA en mas/year
#   RSPMD = Erreur mvt propre DEC en mas/year
#   ParalE = parallaxe trigonometrique de l'etoile en mas
#   VitRad = vit. radiale en km/s
#   TS = Type spectral de l'etoile
#
# Exemple:
#   UCAC2_34392837   01 37 48.442248 +07 58 42.43728  0.001820 -0.03410 2451545.00  15.0  15.0   3.5   3.3 12.360 ?       0.00 0.0


# ** Exemple fichier cnd.obs

# #
# # Conditions observationnelles
# # 
# # objet : astrometrie de 2008 FU6 au T1m Pic du midi
# # date  : 11 avril 2011
# #
#   code           : 586
# lieu           : Pic du midi
# station        : 0.0 0.0 0.0
# observateurs   : F. Vachier
# reduction      : F. Vachier & J. Berthier
# #
# # Instrumentation
# #
#   type           : T1m
# focale         : 12.5
# diametre       : 1.0
# echelle        : 0.44
# orientation    : 0.00 
# taille CCD     : 1024 1024
# #

# {IMG {105.94394 4.34557 5 +14.0326 0.036} 
#      {4133 3 1455.26 1236.98 +12.432 0.036 2483.4 81.3 105.94394 4.34557 +14.0326 +13.8275 0.3848 +13.8527 0.3839 221 150 994.2 +0.63 -0.08 -0.16 +1.29 +0.94 -12.1 3.26 0}} 
#      {USNOA2 {105.94394 4.34557 5.0 +14.0326 0.3848} {}} 
#      {ASTROID {} {1455.214748 1237.066546 2.946869 2.521896 2.7343825 1467.000000 0 1239.000000 227.0 38.759163 37.8491145436 5.85667961922 3.26 0.0976624473377}}
   

# nb = Nombre d image pour analyse
# tag = new ou add pour savoir si c est la premiere image ou pas. 
# listsources = la liste des sources
# science = le nom du catalogue scientifique (a mesurer)
# stars = le nom du catalogue de reference


# Constante a modifier dans le futur bandwith 0.57000

   proc ::priam::create_file_oldformat { tag nb sent_img sent_list_source } {

      
   
      upvar $sent_img img
      upvar $sent_list_source listsources
   
      global bddconf 
   
      set imagefilename [::bddimages_liste::lget $img "filename"]
   
      set tabkey [::bddimages_liste::lget $img "tabkey"]
   
      # Constantes provisoires
      set bandwith 0.57000
   
      # Conditions d observation
   
      set imagefilename [::bddimages_liste::lget $img "filename"]
      set dateobsjd [::bddimages_liste::lget $img "commundatejj"]
   
      if {[::bddimages_liste::lexist $tabkey "TEMPAIR" ]==0} {
         set temperature 20.00
      } else {
         set temperature [lindex [::bddimages_liste::lget $tabkey "TEMPAIR"] 1] 
      }
   
      if {[::bddimages_liste::lexist $tabkey "HYDRO" ]==0} {
         set humidity 35.0
      } else {
         set humidity [lindex [::bddimages_liste::lget $tabkey "HYDRO"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "AIRPRESS" ]==0} {
         set pression 1013.500
      } else {
         set pression [lindex [::bddimages_liste::lget $tabkey "AIRPRESS"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "OBS-LAT" ]==0} {
         set obslat 0.0
      } else {
         set obslat [lindex [::bddimages_liste::lget $tabkey "OBS-LAT"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "OBS-LONG" ]==0} {
         set obslong 0.0
      } else {
         set obslong [lindex [::bddimages_liste::lget $tabkey "OBS-LONG"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "OBS-ELEV" ]==0} {
         set obselev 0.0
      } else {
         set obselev [lindex [::bddimages_liste::lget $tabkey "OBS-ELEV"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "TELESCOP" ]==0} {
         set telescop 0.0
      } else {
         set telescop [lindex [::bddimages_liste::lget $tabkey "TELESCOP"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "FOCLEN" ]==0} {
         set foclen 1.0
      } else {
         set foclen [lindex [::bddimages_liste::lget $tabkey "FOCLEN"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "NAXIS1" ]==0} {
         set naxis1 1024
      } else {
         set naxis1 [lindex [::bddimages_liste::lget $tabkey "NAXIS1"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "NAXIS2" ]==0} {
         set naxis2 1024
      } else {
         set naxis2 [lindex [::bddimages_liste::lget $tabkey "NAXIS2"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "CROTA2" ]==0} {
         set crota2 1024
      } else {
         set crota2 [lindex [::bddimages_liste::lget $tabkey "CROTA2"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "CDELT1" ]==0} {
         set cdelt1 1.0
      } else {
         set cdelt1 [lindex [::bddimages_liste::lget $tabkey "CDELT1"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "CDELT2" ]==0} {
         set cdelt2 1.0
      } else {
         set cdelt2 [lindex [::bddimages_liste::lget $tabkey "CDELT2"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "PIXSIZE1" ]==0} {
         set pixsize1 0.0
      } else {
         set pixsize1 [lindex [::bddimages_liste::lget $tabkey "PIXSIZE1"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "PIXSIZE2" ]==0} {
         set pixsize2 0.0
      } else {
         set pixsize2 [lindex [::bddimages_liste::lget $tabkey "PIXSIZE2"] 1 ]
      }
   
      set echelle [expr sqrt((pow($cdelt1,2)+pow($cdelt2,2))/2.0)*3600.0]
   
      if {[::bddimages_liste::lexist $tabkey "SITENAME" ]==0} {
         set sitename ""
      } else {
         set sitename [lindex [::bddimages_liste::lget $tabkey "SITENAME"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "OBSERVER" ]==0} {
         set observer ""
      } else {
         set observer [lindex [::bddimages_liste::lget $tabkey "OBSERVER"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "IAU_CODE" ]==0} {
         set iau_code ""
      } else {
         set iau_code [lindex [::bddimages_liste::lget $tabkey "IAU_CODE"] 1 ]
      }
   
      if {[::bddimages_liste::lexist $tabkey "OBJECT" ]==0} {
         set object ""
      } else {
         set object [lindex [::bddimages_liste::lget $tabkey "OBJECT"] 1 ]
      }
      if {[::bddimages_liste::lexist $tabkey "DATE-OBS" ]==0} {
         set dateobs ""
      } else {
         set dateobs [lindex [::bddimages_liste::lget $tabkey "DATE-OBS"] 1 ]
      }
      # Creation des fichiers
   
      if {$tag=="new"} {
   
         # creation du fichier de conditions initiales (cnd.obs)
         set filecnd [ file join $bddconf(dirtmp) cnd.obs ]
         set chan0 [open $filecnd w]
         puts $chan0 "#? Centroid measures formatted for Priam"
         puts $chan0 "# Conditions observationnelles"
         puts $chan0 "# objet : astrometrie de $object au $telescop $sitename"
         puts $chan0 "# date  : $dateobs"
         puts $chan0 "#"
         puts $chan0 "code           : $iau_code"
         puts $chan0 "lieu           : $sitename"
         puts $chan0 "station        : $obslat $obslong $obselev"
         puts $chan0 "observateurs   : $observer"
         puts $chan0 "reduction      : F. Vachier & J. Berthier"
         puts $chan0 "#"
         puts $chan0 "# Instrumentation"
         puts $chan0 "#"
         puts $chan0 "type           : $telescop"
         puts $chan0 "focale         : $foclen"
         puts $chan0 "diametre       : 1.0"
         puts $chan0 "echelle        : $echelle"
         puts $chan0 "orientation    : $crota2"
         puts $chan0 "taille CCD     : $naxis1 $naxis2"
         puts $chan0 "pixsize        : $pixsize1 $pixsize2"
         close $chan0
      }
   
      if {$tag=="new"} {
         # creation du fichier d'exec de priam (cmd.priam)
         set filepriam [ file join $bddconf(dirtmp) cmd.priam ]
         gren_info "filepriam = $bddconf(dirtmp)\n"
         gren_info "filepriam = $filepriam\n"
         
         set chan0 [open $filepriam w]
         puts $chan0 "#!/bin/sh"
         puts $chan0 "LD_LIBRARY_PATH=$::bdi_tools_astrometry::locallib:$::bdi_tools_astrometry::ifortlib"
         puts $chan0 "export LD_LIBRARY_PATH"
         puts $chan0 "priam -lang en -format priam -m $nb -deg 0 -fc cnd.obs -fm science.mes -r ./ -fcat local.cat -rcat ./ -s fichier:bddimages -te 1"
         close $chan0
      }
   
      # creation du fichier de mesures
      set filemes [ file join $bddconf(dirtmp) science.mes ]
      
      if {$tag=="new"} { 
         set chan0 [open $filemes w] 
         puts $chan0 "#? Centroid measures formatted for Priam"
         puts $chan0 "#?   Source: Astroid - jan. 2013"
         puts $chan0 "#? Object: science"
         puts $chan0 "#"
         puts $chan0 "#> orientation: $::bdi_tools_astrometry::orient"
         puts $chan0 "#"
         puts $chan0 "!$imagefilename"
         puts $chan0 "$dateobsjd $temperature $pression  $humidity $bandwith"
      }
      if {$tag=="add"} { 
         set chan0 [open $filemes a+] 
         puts $chan0 "!$imagefilename"
         puts $chan0 "$dateobsjd $temperature $pression  $humidity $bandwith"
      }
       
      # creation du fichier stellaire
      set filelocal [ file join $bddconf(dirtmp) local.cat ]
   
      if {$tag=="new"} { set chan1 [open $filelocal w] }
      if {$tag=="add"} { set chan1 [open $filelocal a+] }
   
      
      
      foreach s [lindex $listsources 1] {
   
         set x  [lsearch -index 0 $s "ASTROID"]
         if {$x>=0} {
            set othf  [lindex [lindex $s $x] 2]
            set ar [::bdi_tools_psf::get_val othf "flagastrom"]
            set ac [::bdi_tools_psf::get_val othf "cataastrom"]
            #gren_info "ASTROID $b\n"
            #gren_info "ASTROID $ar $ac\n"
            
            # cas d une reference ou d une science
            if  {$ar=="R" || $ar=="S"} {
               #gren_info "yop\n"
               set name    [::manage_source::naming $s $ac]
               set xsm     [::bdi_tools_psf::get_val othf "xsm"]
               set ysm     [::bdi_tools_psf::get_val othf "ysm"]
               set err_xsm [::bdi_tools_psf::get_val othf "err_xsm"]
               set err_ysm [::bdi_tools_psf::get_val othf "err_ysm"]
               set fwhmx   [::bdi_tools_psf::get_val othf "fwhmx"]
               set fwhmy   [::bdi_tools_psf::get_val othf "fwhmy"]
               set flux    [::bdi_tools_psf::get_val othf "flux"]
               #gren_info "insert science.mes $ar $xsm $ysm\n"
               puts $chan0 "$ar $xsm $err_xsm $ysm $err_ysm $fwhmx $fwhmy $flux $name"
            } else {
               #gren_info "not ($ar)\n"
            
            }
            
            # cas particulier d une reference -> local.cat
            if  {$ar=="R"} {
               set x [lsearch -index 0 $s $ac]
               if {$x>=0} {
                  set b  [lindex [lindex $s $x] 1]           
                  set ra  [mc_angle2hms [lindex $b 0]]
                  set dec [mc_angle2dms [lindex $b 1] 90]
                  set mag [lindex $b 3]
                  set ra_pm 0
                  set dec_pm 0
                  set ra_err 100
                  set dec_err 100
                  set ra_pm_err  0
                  set dec_pm_err 0
                  set typeS "?"
                  set paral 0
                  set vitrad 0
   
                  set otherfields  [lindex [lindex $s $x] 2]
   
                  if {  $ac == "UCAC2" } {
                     # 4 = e_RAm_deg, 5 = e_DEm_deg
                     set ra_err  [expr [lindex $otherfields 4] * 3600000]
                     set dec_err [expr [lindex $otherfields 5] * 3600000]
                     # 12 = pmRA_masperyear, 13 = pmDEC_masperyear
                     set ra_pm  [expr [lindex $otherfields 12] / 15000.0]
                     set dec_pm [expr [lindex $otherfields 13] / 1000.0]
                     # 14 = e_pmRA_masperyear, 15 = e_pmDE_masperyear
                     set ra_pm_err  [lindex $otherfields 14]
                     set dec_pm_err [lindex $otherfields 15]
                  }
   
                  if {  $ac == "UCAC3" } {
                     # 8 = sigra_deg, 9 = sigdc_deg
                     set ra_err  [expr [lindex $otherfields 8] * 3600000]
                     set dec_err [expr [lindex $otherfields 9] * 3600000]
                     # 16 = pmrac_masperyear, 17 = pmdc_masperyear
                     set ra_pm  [expr [lindex $otherfields 16] / 15000.0]
                     set dec_pm [expr [lindex $otherfields 17] / 1000.0]
                     # 18 = sigpmr_masperyear, 19 = sigpmd_masperyear
                     set ra_pm_err  [lindex $otherfields 18]
                     set dec_pm_err [lindex $otherfields 19]
                  }
   
                  if {  $ac == "UCAC4" } {
                     # 8 = sigra_deg, 9 = sigdc_deg
                     set ra_err  [expr [lindex $otherfields 8] * 3600000]
                     set dec_err [expr [lindex $otherfields 9] * 3600000]
                     # 15 = pmrac_masperyear, 16 = pmdc_masperyear
                     set ra_pm  [expr [lindex $otherfields 15] / 15000.0]
                     set dec_pm [expr [lindex $otherfields 16] / 1000.0]
                     # 17 = sigpmr_masperyear, 18 = sigpmd_masperyear
                     set ra_pm_err  [lindex $otherfields 17]
                     set dec_pm_err [lindex $otherfields 18]
                  }
   
                  if {  $ac == "TYCHO2" } {
                     # 9 = e_mRA, 10 = e_mDE
                     set ra_err  [lindex $otherfields 9]
                     set dec_err [lindex $otherfields 10]
                     # 7 = pmRA, 8 = pmDE
                     set ra_pm  [expr [lindex $otherfields 7] / 15000.0]
                     set dec_pm [expr [lindex $otherfields 8] / 1000.0]
                     # 11 = e_pmRA, 12 = e_pmDE
                     set ra_pm_err  [lindex $otherfields 11]
                     set dec_pm_err [lindex $otherfields 12]
                  }
   
                  if {  $ac == "2MASS" } {
                     # 3 = err_ra, 4 = err_de
                     set ra_err  [expr [lindex $otherfields 3] * 1000]
                     set dec_err [expr [lindex $otherfields 4] * 1000]
                  }
   
                  if {  $ac == "USNOA2" } {
                     set ra_err  500
                     set dec_err 500
                  }
                  
                  # Ecriture du local.cat 
                  puts $chan1 "$name $ra $dec $ra_pm $dec_pm 2451545.50  $ra_err $dec_err  $ra_pm_err  $dec_pm_err  $mag $typeS $paral $vitrad"
               } else {
                  ::console::affiche_erreur "ERREUR DE REFERENCE\n"
               }
            }
            
         }
         
      }
   
      close $chan0
      close $chan1
   }


}
