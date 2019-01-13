## @file bddimages_imgcorrection.tcl
#  @brief     Calibration des images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_imgcorrection.tcl]
#  @endcode

# $Id: bddimages_imgcorrection.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bddimages_imgcorrection
# @brief Calibration des images
# @pre Requiert le fichier d'internationalisation \c bddimages_admin.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_imgcorrection {

   global audace
   global bddconf

   variable type 
   variable imgtmplist 
   variable inforesult
   variable erreur_selection

   variable offset_img_list 
   variable soffset_img_list
   variable dark_img_list 
   variable sdark_img_list
   variable flat_img_list 
   variable sflat_img_list
   variable deflat_img_list

   variable progress

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
# { {NAXIS1 1024} {NAXIS2 1024} etc ... }
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


proc ::bddimages_imgcorrection::get_info_img {  } {

   #recupere la liste des idbddimg
   set lid [$::bddimages_recherche::This.frame6.result.tbl curselection ]
   set lid [lsort -decreasing -integer $lid]
   set imgtmplist [::bddimages_liste_gui::new_normallist $lid]
   #::console::affiche_resultat "imgtmplist=$imgtmplist\n"
   return $imgtmplist
}



proc ::bddimages_imgcorrection::verif_all_img {  } {

   global caption

   set img_list ""
   foreach img $::bddimages_imgcorrection::offset_img_list  {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::soffset_img_list {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::dark_img_list    {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::sdark_img_list   {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::flat_img_list    {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::sflat_img_list   {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::deflat_img_list  {lappend img_list $img}
   
   set telescopsav ""
   set bin1sav ""
   set bin2sav ""
   set cpt 0

   foreach img $img_list {
      # A FAIRE
      #set bufno [::buf::create]
      #set bufno 1
      #buf$bufno load $fileimg
      #::bddimagesAdmin::bdi_compatible buf$bufno
      set tabkey   [::bddimages_liste::lget $img "tabkey"]
      set telescop [lindex [::bddimages_liste::lget $tabkey telescop] 1]
      set bin1     [lindex [::bddimages_liste::lget $tabkey bin1    ] 1]
      set bin2     [lindex [::bddimages_liste::lget $tabkey bin2    ] 1]
      if {$cpt==0} {
         set telescopsav $telescop
         set bin1sav     $bin1
         set bin2sav     $bin2
      } else {
         if {$telescopsav != $telescop} {return -code error $caption(bddimages_imgcorrection,pbtelescope)} 
         if {$bin1sav     != $bin1}     {return -code error $caption(bddimages_imgcorrection,pbbinning)} 
         if {$bin2sav     != $bin2}     {return -code error $caption(bddimages_imgcorrection,pbbinning)} 
      }
      incr cpt
   }

   return -code ok ""
}




proc ::bddimages_imgcorrection::verif_filter_img {  } {

   global caption

   set img_list ""
   foreach img $::bddimages_imgcorrection::flat_img_list    {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::sflat_img_list   {lappend img_list $img}
   foreach img $::bddimages_imgcorrection::deflat_img_list  {lappend img_list $img}
   
   set filtersav ""
   set cpt 0

   foreach img $img_list {
      # A FAIRE
      #set bufno [::buf::create]
      #set bufno 1
      #buf$bufno load $fileimg
      #::bddimagesAdmin::bdi_compatible buf$bufno
      set tabkey [::bddimages_liste::lget $img "tabkey"]
      set filter [lindex [::bddimages_liste::lget $tabkey filter] 1]
      if {$cpt==0} {
         set filtersav [string trim $filter]
      } else {
         if {$filtersav != [string trim $filter]} {
            return -code error $caption(bddimages_imgcorrection,pbfiltre)
         } 
      }
      incr cpt
   }

   return -code ok ""
}

#
# Clean space character into string
# @param string chaine a convertir
# @return chunk chaine convertie
proc ::bddimages_imgcorrection::isoDateToString { dateobs } {
   regsub -all {\-} $dateobs {}  dateobs
   regsub -all { }  $dateobs {_}  dateobs
   regsub -all {T}  $dateobs {_}  dateobs
   regsub -all {:}  $dateobs {}  dateobs
   regsub -all {\.} $dateobs {_} dateobs
   return $dateobs
}


#
# Clean space character into string
# @param string chaine a convertir
# @return chunk chaine convertie
proc ::bddimages_imgcorrection::cleanSpace { chunk } {
   regsub -all { } $chunk {-} chunk
   return $chunk
}



#
# Clean special characters into string
# @param string chaine a convertir
# @return chunk chaine convertie
proc ::bddimages_imgcorrection::cleanEntities { chunk } {
   regsub -all { }  $chunk {} chunk
   regsub -all {!}  $chunk {} chunk
   regsub -all {\$} $chunk {} chunk
   regsub -all {\&} $chunk {} chunk
   regsub -all {'}  $chunk {} chunk
   regsub -all {\#} $chunk {} chunk
   regsub -all {\(} $chunk {} chunk
   regsub -all {\)} $chunk {} chunk
   regsub -all {\*} $chunk {} chunk
   regsub -all {\+} $chunk {} chunk
   regsub -all {\-} $chunk {} chunk
   regsub -all {,}  $chunk {} chunk
   regsub -all {=}  $chunk {} chunk
   regsub -all {\?} $chunk {} chunk
   regsub -all {@}  $chunk {} chunk
   regsub -all {\[} $chunk {} chunk
   regsub -all {\]} $chunk {} chunk
   regsub -all {\^} $chunk {} chunk
   regsub -all {`}  $chunk {} chunk
   regsub -all {\{} $chunk {} chunk
   regsub -all {\|} $chunk {} chunk
   regsub -all {\}} $chunk {} chunk
   regsub -all {~}  $chunk {} chunk
   regsub -all {:}  $chunk {} chunk
   regsub -all {/}  $chunk {} chunk
   regsub -all {\.} $chunk {} chunk
   return $chunk
}




#proc ::bddimages_imgcorrection::create_filename_deflat { file } {
#
#   set img_list $::bddimages_imgcorrection::deflat_img_list
#
#   set filename ""
#   foreach img $img_list {
#      set filenametmp [::bddimages_liste::lget $img "filenametmp"]
#      if {$file == $filenametmp} {
#         set tabkey   [::bddimages_liste::lget $img "tabkey"]
#         set telescop [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey telescop] 1] ]
#         set bin1     [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey bin1]     1] ]
#         set bin2     [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey bin2]     1] ]
#         set filter   [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey filter]   1] ]
#         set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
#         set object   [::bddimages_imgcorrection::name_to_stdname [lindex [::bddimages_liste::lget $tabkey "object"] 1] ]
#         set ms       [ string range $dateobs end-2 end ]
#         set date     [ string range $dateobs 0 end-4 ]
#         set date     [ clock format [clock scan $date] -format %Y%m%d_%H%M%S ]
#         set filename "${telescop}_${date}_${ms}_bin${bin1}x${bin2}_F${filter}_${object}"
#         break
#      }
#   }
#
#   return $filename
#}


proc ::bddimages_imgcorrection::create_filename_deflat { file } {

   set img_list $::bddimages_imgcorrection::deflat_img_list

   set filename ""
   foreach img $img_list {
      set filenametmp [::bddimages_liste::lget $img "filenametmp"]
      if {$file == $filenametmp} {
         set tabkey   [::bddimages_liste::lget $img "tabkey"]

         set telescop [string trim [lindex [::bddimages_liste::lget $tabkey "telescop"] 1]]
         set dateobs  [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
         set bin1     [string trim [lindex [::bddimages_liste::lget $tabkey "bin1"] 1]]
         set bin2     [string trim [lindex [::bddimages_liste::lget $tabkey "bin2"] 1]]
         set filter   [string trim [lindex [::bddimages_liste::lget $tabkey "filter"] 1]]
         set object   [string trim [lindex [::bddimages_liste::lget $tabkey "object"] 1]]

         set dateobs [::bddimages_imgcorrection::isoDateToString $dateobs]
         set filename [::bddimages_imgcorrection::cleanEntities "${telescop}_${dateobs}_bin${bin1}x${bin2}_F${filter}_${object}"]
         break
      }
   }

   return $filename
}




proc ::bddimages_imgcorrection::create_filename { type } {

   # Si action = DEFLAT alors retour 
   # car le nommage des fichiers est fait autrement
   if {$type == "deflat"} {
      return ""
   }

   # En fonction de l'action...
   switch $type {
      "offset" { set img_list $::bddimages_imgcorrection::offset_img_list }
      "dark"   { set img_list $::bddimages_imgcorrection::dark_img_list }
      "flat"   { set img_list $::bddimages_imgcorrection::flat_img_list }
      default  { set img_list "" }
   }

   set commundatejjmoy 0
   set cpt 0
   foreach img $img_list {
      set tabkey       [::bddimages_liste::lget $img "tabkey"]
      set telescop     [string trim [lindex [::bddimages_liste::lget $tabkey telescop] 1]]
      set bin1         [string trim [lindex [::bddimages_liste::lget $tabkey bin1] 1]]
      set bin2         [string trim [lindex [::bddimages_liste::lget $tabkey bin2] 1]]
      set filter       [string trim [string trim [lindex [::bddimages_liste::lget $tabkey filter] 1] ]]
      set commundatejj [::bddimages_liste::lget $img commundatejj]
      set commundatejjmoy [expr $commundatejjmoy + $commundatejj]
      incr cpt
   }

   if { $cpt == 0 } {
      return ""
   }

#   set commundatejjmoy  [ expr $commundatejjmoy / $cpt ]
#   set dateobs          [ mc_date2iso8601 $commundatejjmoy ]
#   set ms               [ string range $dateobs end-2 end ]
#   set commundatejjmoy  [ string range $dateobs 0 end-4 ]
#   set commundatejjmoy  [ clock format [clock scan $commundatejjmoy] -format %Y%m%d_%H%M%S ]

   set dateobs [ mc_date2iso8601 [expr $commundatejjmoy/$cpt] ]
   set commundatejjmoy [::bddimages_imgcorrection::isoDateToString $dateobs]

   switch $type {
      "offset" -
      "dark"   { set filename "${telescop}_${commundatejjmoy}_bin${bin1}x${bin2}_${type}" }
      "flat"   { set filename "${telescop}_${commundatejjmoy}_bin${bin1}x${bin2}_F${filter}_${type}" }
      default  { set filename "?" }
   }

   set filename [::bddimages_imgcorrection::cleanSpace $filename]
   return [list $filename $dateobs $bin1 $bin2]
}





proc ::bddimages_imgcorrection::create_image_offset { type inforesult } {

   global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nboffset   [llength $::bddimages_imgcorrection::offset_img_list]
   set k [expr $nboffset - 1]

   set methode 1
   set fileout ${fileout}${methode}

   if {$methode == 1} {
      buf$bufno load "$bddconf(dirtmp)/${type}0$ext"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) offset 0  $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout . . $ext $bddconf(dirtmp) $fileout . $ext STAT bitpix=-32"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd \"MEAN\"]\n"
   }
   if {$methode == 2} {

   }

   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}




proc ::bddimages_imgcorrection::create_image_dark { type inforesult } {

  global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbdark [llength $::bddimages_imgcorrection::dark_img_list]
   set k [expr $nbdark - 1]

   set methode 1
   set fileout ${fileout}${methode}
   
   if {$methode == 1} {
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT bitpix=-32"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd MEAN]\n"
   }
   
   if {$methode == 2} {
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT bitpix=-32"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd MEAN]\n"
   }
   
   if {$methode == 3} {

      set f [file join $bddconf(dirtmp) ${fileout}]

      smedian dark ${fileout} $k
   }
   
   if {$methode == 4} {

      ttscript2 "IMA/STACK  $bddconf(dirtmp) dark 0 $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"
   }

   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   ::console::affiche_resultat "MEAN DARK: [buf$bufno getkwd MEAN]\n"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}



proc ::bddimages_imgcorrection::get_stat { bufno } {

   set stat [buf$bufno stat]
   return "moy=[lindex $stat 4] sig=[lindex $stat 5]"

}




proc ::bddimages_imgcorrection::create_image_flat { type inforesult } {

   global bddconf

   set bufno 1
   set fileout  [lindex $inforesult 0]
   set dateobs  [lindex $inforesult 1]

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
   set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]
   set nbflat    [llength $::bddimages_imgcorrection::flat_img_list]
   set k [expr $nbflat - 1]

   set methode 1
   set fileout ${fileout}${methode}
      
   if {$methode == 1} {

      # Ni Dark Ni Offset -> on normalise les flat
      if {$nbsoffset == 0 && $nbsdark == 0 } {
         for {set x 0} {$x<$nbflat} {incr x} {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=30000 bitpix=-32"
         }
      }

      # Dark + Offset -> soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat 0 $k $ext $bddconf(dirtmp) flats 0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000 bitpix=-32"
         for {set x 0} {$x<$nbflat} {incr x} {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flats $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=30000 bitpix=-32"
         }
      }
      
      # Offset uniquement -> soustraction des Offset
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         gren_info "ICI ***\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat 0 $k $ext $bddconf(dirtmp) flats 0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0 nullpixel=-10000 bitpix=-32"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flats 0 $k $ext $bddconf(dirtmp) flatn 0 $ext NORMGAIN normgain_value=30000 bitpix=-32"
      }
      
      # Dark uniquement -> Soustraction des Dark
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         #loadima [file join $bddconf(dirtmp) "sdark0$ext"]
         set f [file join $bddconf(dirtmp) "sdark0$ext"]
         buf$bufno load $f

         #::console::affiche_resultat "SDARK sdark0$ext\n"
         #::console::affiche_resultat "STAT sdark0$ext [get_stat $bufno]\n"
         #::console::affiche_resultat "ALL [buf$bufno getkwds]\n"
         #::console::affiche_resultat "MEAN [lindex [buf$bufno getkwd MEAN] 1]\n"
         #::console::affiche_resultat "EXPOSURE [buf$bufno getkwd EXPOSURE]\n"

         set meandark [lindex [buf$bufno getkwd MEAN] 1]
         set expodark [expr [lindex [buf$bufno getkwd EXPOSURE] 1] * 1.0]

         #::console::affiche_resultat "SDARK - MEAN : $meandark - EXPOSURE : $expodark\n"

         for {set x 0} {$x<$nbflat} {incr x} {

            #::console::affiche_resultat "FLAT flat${x}${ext}\n"
            buf$bufno load "$bddconf(dirtmp)/flat${x}${ext}"
            #::console::affiche_resultat "STAT flat av [get_stat $bufno]\n"

            set meanflat [lindex [buf$bufno getkwd MEAN] 1]
            set expoflat [expr [lindex [buf$bufno getkwd EXPOSURE] 1]  * 1.0]        

            set fact [expr $expoflat / $expodark]
            ::console::affiche_resultat "FLAT - MEAN : $meanflat - EXPOSURE : $expoflat - FACT : $fact\n"
            
            buf$bufno load "$bddconf(dirtmp)/sdark0${ext}"
            #::console::affiche_resultat "STAT sdark1 av [get_stat $bufno]\n"

            # divise le DARK par un facteur des temps d exposition
            ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 . . $ext $bddconf(dirtmp) sdark1 . $ext MULT constant=$fact bitpix=-32"
            #buf$bufno load "$bddconf(dirtmp)/sdark1${ext}"
            #::console::affiche_resultat "STAT sdark1 ap [get_stat $bufno]\n"
            
            # Soustraction du DARK
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flat $x $x $ext $bddconf(dirtmp) flats $x $ext SUB file=$bddconf(dirtmp)/sdark1$ext offset=0 bitpix=-32"
            #buf$bufno load "$bddconf(dirtmp)/flats${x}${ext}"
            #::console::affiche_resultat "STAT flats [get_stat $bufno]\n"

            # Normalisation du FLAT
            ttscript2 "IMA/SERIES $bddconf(dirtmp) flats $x $x $ext $bddconf(dirtmp) flatn $x $ext NORMGAIN normgain_value=30000 bitpix=-32"
            buf$bufno load "$bddconf(dirtmp)/flatn${x}${ext}"
            ::console::affiche_resultat "STAT flatn [get_stat $bufno]\n"
         }

      }

      # Pile KAPPA SIGMA
      #ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout . $ext KS kappa=3"

      # Pile MEDIANE
      ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"

      # Inscrit les stat dans le header de l image
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT bitpix=-32"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      set mean [buf$bufno getkwd "MEAN"]
      ::console::affiche_resultat "MEAN : $mean\n"
      ::console::affiche_resultat "STAT flat [get_stat $bufno]\n"
      #::console::affiche_resultat "ttscript2 \"IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT\""
   }

   if {$methode == 2} {

      # Soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext exptime=EXPOSURE dexptime=EXPOSURE nullpixel=-10000 bitpix=-32"
      }
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0 bitpix=-32"
      }
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat     0 $k $ext $bddconf(dirtmp) flat     0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0 bitpix=-32"
      }

      # Pile Mediane
      buf$bufno load "$bddconf(dirtmp)/${type}0${ext}"
      ttscript2 "IMA/STACK  $bddconf(dirtmp) flat       0  $k $ext $bddconf(dirtmp) $fileout . $ext MED bitpix=-32"
      ttscript2 "IMA/SERIES $bddconf(dirtmp) $fileout .  .  $ext $bddconf(dirtmp) $fileout . $ext STAT bitpix=-32"
      buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
      ::console::affiche_resultat "MEAN : [buf$bufno getkwd \"MEAN\"]\n"
   }


   if { $methode == 3 } {

      if {$nbsoffset == 0 && $nbsdark == 1 } {
         sub2 flat sdark0 flats 0 $k
         ngain2 flats flatn 20000 $k
         smedian flatn ${fileout} $k
      }


   }

   if { $methode == 4 } {

      if {$nbsoffset == 0 && $nbsdark == 1 } {
      
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flat  0  $k $ext $bddconf(dirtmp) flats    0  $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0 bitpix=-32" 
         ttscript2 "IMA/SERIES $bddconf(dirtmp) flats 0  $k $ext $bddconf(dirtmp) flatn    0  $ext NORMGAIN normgain_value=20000 bitpix=-32"
         ttscript2 "IMA/STACK  $bddconf(dirtmp) flatn 0  $k $ext $bddconf(dirtmp) $fileout .  $ext MED bitpix=-32"
      }


   }

   buf$bufno load "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
   buf$bufno setkwd [list "DATE-OBS" "$dateobs" "string" "DATEISO" ""]
   buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
   buf$bufno clear

   insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}

}




proc ::bddimages_imgcorrection::create_image_deflat {  } {

   global bddconf
      
   set bufno 1

   set ext [buf$bufno extension]
   set gz [buf$bufno compress]
   if {[buf$bufno compress] == "gzip"} {set gz ".gz"} else {set gz ""}

   set nbsoffset [llength $::bddimages_imgcorrection::soffset_img_list]
   set nbsdark   [llength $::bddimages_imgcorrection::sdark_img_list]
   set nbsflat   [llength $::bddimages_imgcorrection::sflat_img_list]
   set nbdeflat  [llength $::bddimages_imgcorrection::deflat_img_list]
   set k [expr $nbdeflat - 1]

   set methode 1
   
   if {$methode == 1} {

      if {$nbsdark == 1 } {
         buf1 load $bddconf(dirtmp)/sdark0$ext
         set meandark [lindex [buf$bufno getkwd MEAN] 1]
      } else {
         if {$nbsoffset == 1 } {
            buf1 load $bddconf(dirtmp)/soffset0$ext
            set meandark [lindex [buf$bufno getkwd MEAN] 1]
         } else {
            set meandark 0
         }
      }
      
      # Soustraction des Dark et Offset
      if {$nbsoffset == 1 && $nbsdark == 1 } {
         ::console::affiche_resultat "Soustraction des Dark et Offset\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUBDARK dark=sdark0$ext bias=soffset0$ext  bitpix=-32"
      }
      # Soustraction des Offset (pas de Dark)
      if {$nbsoffset == 1 && $nbsdark == 0 } {
         ::console::affiche_resultat "Soustraction de l OFFSET\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/soffset0$ext offset=0 bitpix=-32"
      }
      # Soustraction des Dark (pas d'Offset)
      if {$nbsoffset == 0 && $nbsdark == 1 } {
         ::console::affiche_resultat "Soustraction du DARK\n"
         if {1==1} {
            set f [file join $bddconf(dirtmp) "sdark0$ext"]
            buf$bufno load $f
            set meandark [lindex [buf$bufno getkwd MEAN] 1]
            set expodark [expr [lindex [buf$bufno getkwd EXPOSURE] 1] * 1.0]

            for {set x 0} {$x<$nbdeflat} {incr x} {
               buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
               set meandeflat [lindex [buf$bufno getkwd MEAN] 1]
               set expodeflat [expr [lindex [buf$bufno getkwd EXPOSURE] 1]  * 1.0]        
               set fact [expr $expodeflat / $expodark]
               ::console::affiche_resultat "FLAT - MEAN : $meandeflat - EXPOSURE : $expodeflat - FACT : $fact\n"
               ttscript2 "IMA/SERIES $bddconf(dirtmp) sdark0 .  .  $ext $bddconf(dirtmp) sdark1 .  $ext MULT constant=$fact bitpix=-32"
               ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat $x $x $ext $bddconf(dirtmp) deflat $x $ext SUB file=$bddconf(dirtmp)/sdark1$ext offset=0 bitpix=-32"
            }
         } else {
            ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0 bitpix=-32"
         }
      }

      # Division par le Flat
      if { $nbsflat == 1 } {
         set f [file join $bddconf(dirtmp) "sflat0$ext"]
         buf$bufno load $f
         set meanflat [lindex [buf$bufno getkwd MEAN] 1]
         ::console::affiche_resultat "K . E / F -- K = $meanflat\n"

         # Division par le flat
         ::console::affiche_resultat "Division par le flat\n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext DIV file=$bddconf(dirtmp)/sflat0$ext constant=$meanflat nullpixel=-10000 bitpix=-32"

         ::console::affiche_resultat "ajout d une constante : $meandark \n"
         ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext OFFSET offset=$meandark"

         # Change les mots cles
         ::console::affiche_resultat "Modif Header\n"
         for {set x 0} {$x<$nbdeflat} {incr x} {

            buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
            buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
            set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
            buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
            buf$bufno clear
            ::console::affiche_resultat " $x / $k : "
            insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
         }
      }

   }

   if { $methode == 3 } {
      sub2 deflat sdark0 deflat 0 $k
      div2 deflat sflat0 deflat 20000 $k
      for {set x 1} {$x<$nbdeflat} {incr x} {
         buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
         buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
         set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
         buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
         buf$bufno clear
         ::console::affiche_resultat " $x / $k : "
         insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
      }
   }

   if { $methode == 4 } {

      ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext SUB file=$bddconf(dirtmp)/sdark0$ext offset=0 bitpix=-32" 
      ttscript2 "IMA/SERIES $bddconf(dirtmp) deflat 0 $k $ext $bddconf(dirtmp) deflat 0 $ext DIV file=$bddconf(dirtmp)/sflat0$ext constant=20000 nullpixel=-10000 bitpix=-32"
      for {set x 1} {$x<$nbdeflat} {incr x} {
         buf$bufno load "$bddconf(dirtmp)/deflat${x}${ext}"
         buf$bufno setkwd [list "BDDIMAGES STATE" "CORR" "string" "RAW | CORR | CATA | ?" ""]
         set fileout [::bddimages_imgcorrection::create_filename_deflat "deflat${x}${ext}"]
         buf$bufno save "$bddconf(dirtmp)/${fileout}${ext}"
         buf$bufno clear
         ::console::affiche_resultat " $x / $k : "
         insertion_solo $bddconf(dirtmp)/${fileout}${ext}${gz}
      }
   }

}




proc ::bddimages_imgcorrection::create_image { type inforesult} {

  global bddconf

   if {$type=="offset"} {
      ::bddimages_imgcorrection::create_image_offset $type $inforesult
   }
   if {$type=="dark"} {
      ::bddimages_imgcorrection::create_image_dark  $type $inforesult
   }
   if {$type=="flat"} {
      ::bddimages_imgcorrection::create_image_flat $type $inforesult
   }
   if {$type=="deflat"} {
      ::bddimages_imgcorrection::create_image_deflat
   }

}



proc ::bddimages_imgcorrection::delete_to_tmp { type img_list } {

   global bddconf

   set bufno 1
   set ext [buf$bufno extension]
   set nb  [llength $img_list]
   for {set i 0} {$i<$nb} {incr i} {
      file delete -force -- [file join $bddconf(dirtmp) ${type}${i}${ext}]
   }

}





proc ::bddimages_imgcorrection::copy_to_tmp { type img_list } {

   global bddconf
   global audace

   set k 0
   set new_list ""
   set nb [llength $img_list] 

   foreach img $img_list {   
   
      set filename    [string trim [::bddimages_liste::lget $img "filename"] ]
      set dirfilename [string trim [::bddimages_liste::lget $img "dirfilename"] ]
   
      # test filename et dirfilename non null
      set fichier [file join $bddconf(dirbase) $dirfilename $filename]
      
      set f "${type}${k}${bddconf(extension_tmp)}"
      set fc "$bddconf(dirtmp)/$f.gz"
      set fm "$bddconf(dirtmp)/$f"
      set errnum [catch {file copy -force -- $fichier $fc} msg]
      if {$errnum == 0} {
         #::console::affiche_resultat "cp image : $fichier\n"
         #::console::affiche_resultat "gunzip $fc \n"
         if { [file exists $fm] == 1 } {
            set errnum [catch {file delete -force -- $fm} msg]
         }

         lassign [::bdi_tools::gunzip $fc ] errnum msg
         #set errnum [catch {exec gunzip $fc } msg ]
         if {$errnum == 0} {
            #::console::affiche_resultat "dezip image : $f\n"
            lappend img [list filenametmp $f ]
            lappend new_list $img
            incr k
         } else {
            ::console::affiche_erreur "Erreur gunzip : $fm \n"
            ::console::affiche_erreur "errnum : $errnum\n"
            ::console::affiche_erreur "msg    : $msg\n"
         }

      } else {
         ::console::affiche_erreur "Erreur copy_to_tmp : $fichier\n"
         ::console::affiche_erreur "errnum : $errnum\n"
         ::console::affiche_erreur "msg    : $msg\n"
      }
      
   }

   ::console::affiche_resultat "Copie de $k $type\n"

   return $new_list    
}




proc ::bddimages_imgcorrection::correction { type inforesult} {

   global action_label audace bddconf

   set audace(rep_images) $bddconf(dirtmp)
   cd $bddconf(dirtmp)

   set ::bddimages_imgcorrection::offset_img_list  [::bddimages_imgcorrection::copy_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list  ]
   set ::bddimages_imgcorrection::soffset_img_list [::bddimages_imgcorrection::copy_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list] 
   set ::bddimages_imgcorrection::dark_img_list    [::bddimages_imgcorrection::copy_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list   ]  
   set ::bddimages_imgcorrection::sdark_img_list   [::bddimages_imgcorrection::copy_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list  ]  
   set ::bddimages_imgcorrection::flat_img_list    [::bddimages_imgcorrection::copy_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list   ]  
   set ::bddimages_imgcorrection::sflat_img_list   [::bddimages_imgcorrection::copy_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list  ]  
   set ::bddimages_imgcorrection::deflat_img_list  [::bddimages_imgcorrection::copy_to_tmp "deflat"  $::bddimages_imgcorrection::deflat_img_list ]  

   set errnum [catch {create_image $type $inforesult} msg]
   if {$errnum != 0} {
      ::console::affiche_erreur "Erreur sur la creation de $type\n"
      ::console::affiche_erreur "errnum : $errnum\n"
      ::console::affiche_erreur "msg    : $msg\n"
   } else {
      ::bddimages_imgcorrection::delete_to_tmp "offset"  $::bddimages_imgcorrection::offset_img_list
      ::bddimages_imgcorrection::delete_to_tmp "soffset" $::bddimages_imgcorrection::soffset_img_list 
      ::bddimages_imgcorrection::delete_to_tmp "dark"    $::bddimages_imgcorrection::dark_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sdark"   $::bddimages_imgcorrection::sdark_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "flat"    $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "flatn"   $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "flats"   $::bddimages_imgcorrection::flat_img_list    
      ::bddimages_imgcorrection::delete_to_tmp "sflat"   $::bddimages_imgcorrection::sflat_img_list   
      ::bddimages_imgcorrection::delete_to_tmp "deflat"  $::bddimages_imgcorrection::deflat_img_list   
      file delete -force -- [file join $bddconf(dirtmp) tt.log]
   }

   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
   return 0

}




#--------------------------------------------------
# img_list_to_filename_list { img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot cl� : bddimages type
#
#    procedure externe :
#
#    variables en entree :
#        type = mot cl� bddimages type
#        imgtmplist = liste complete d image
#
#    variables en sortie :
#        imgtmplist = liste complete d image de meme mot cl� bddimages type
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::img_list_to_filename_list { img_list typ } {

   global bddconf

   set result_list ""
   foreach img $img_list {
      lappend result_list [::bddimages_imgcorrection::img_to_filename $img $typ]
   }
   return $result_list

}




proc ::bddimages_imgcorrection::img_to_filename { img typ } {

   global bddconf

   set result ""

   set filename    [::bddimages_liste::lget $img filename]
   set dirfilename [::bddimages_liste::lget $img dirfilename]
   set filenametmp [::bddimages_liste::lget $img filenametmp]
   
   if { $typ == "long" } {
      return [file join $bddconf(dirbase) $dirfilename $filename]
   }
   if { $typ == "short" } {
      return $filename
   }
   if { $typ == "tmp" } {
      return $filenametmp
   }
   if { $typ == "longtmp" } {
      return [file join $bddconf(dirtmp) $filenametmp] 
   }
  
   return "-1"
}




#--------------------------------------------------
# select_img_list_by_type { type img_list }
#--------------------------------------------------
#
#    fonction  :
#        Fournit un extrait de la liste imgtmplist
#        correspodant au mot cl� : bddimages_type
#
#    procedure externe :
#
#    variables en entree :
#        bddimages_type = mot cl� bddimages_type
#        bddimages_state = mot cl� bddimages_state
#        img_list = liste complete d image
#
#    variables en sortie :
#        result_list = liste complete d image de meme mot cl� bddimages_type
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::select_img_list_by_type { bddimages_type bddimages_state img_list } {


   #::console::affiche_resultat "img_list $img_list \n"
   set result_list ""


   foreach img $img_list {
      set keep "ok"
      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set bdditype  [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_type"] 1]]
      set bddistate [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_state"] 1]]
      #::console::affiche_resultat "result $bdditype $bddistate\n"

      if {($bddimages_type  == $bdditype)&&($bddimages_state == $bddistate)}  {
         lappend result_list $img
      }
   }

   #::console::affiche_resultat "result_list $bddimages_type $bddimages_state $result_list \n"
   return $result_list
}




proc ::bddimages_imgcorrection::chrono_first_img { img_list } {

   set cpt 0
   foreach img $img_list {
      incr cpt
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      if {$cpt == 1} {
         set datemin $commundatejj
         set result_img $img
         continue
      }
      if { $commundatejj < $datemin} {
         set datemin $commundatejj
         set result_img $img
      }
   }
   return $result_img
}




proc ::bddimages_imgcorrection::chrono_last_img { img_list } {

   set cpt 0
   foreach img $img_list {
      incr cpt
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      if {$cpt == 1} {
         set datemin $commundatejj
         set result_img $img
         continue
      }
      if { $commundatejj > $datemin} {
         set datemin $commundatejj
         set result_img $img
      }
   }
   return $result_img
}




proc ::bddimages_imgcorrection::chrono_sort_img { img_list } {

   set sort_img_list ""
   foreach img $img_list {
      set commundatejj [::bddimages_liste::lget $img "commundatejj"]
      lappend sort_img_list [list $commundatejj $img]
   }

   set sort_img_list [lsort -real -index 0 $sort_img_list]

   set result_img_list ""
   foreach line $sort_img_list {
      lappend result_img_list [lindex $line 1]
   }

   return $result_img_list
}


proc ::bddimages_imgcorrection::mirroirx { img_list } {

   global bddconf
   
   set log 0

   foreach img $img_list {
      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $img "filename"]
      set dirimgfilename [::bddimages_liste::lget $img "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]
     
      set imgfiletmp [string range [file tail $imgfilebase] 0 [expr [string last .gz [file tail $imgfilebase]] -1]]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfiletmp]
      if {$log} {::console::affiche_resultat "imgfilebase = $imgfilebase \n"}
      if {$log} {::console::affiche_resultat "imgfiletmp = $imgfiletmp \n"}

      buf$::audace(bufNo) load $imgfilebase
      buf$::audace(bufNo) mirrorx
      buf$::audace(bufNo) save $imgfiletmp

      set ident [bddimages_image_identification $idbddimg]
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      if {$log} {catch {gren_info "$errnum : $msg : $r"}}
      if {$errnum==0} {}

   }

}




proc ::bddimages_imgcorrection::mirroiry { img_list } {

   global bddconf
   
   set log 0

   foreach img $img_list {
      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $img "filename"]
      set dirimgfilename [::bddimages_liste::lget $img "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]
     
      set imgfiletmp [string range [file tail $imgfilebase] 0 [expr [string last .gz [file tail $imgfilebase]] -1]]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfiletmp]
      if {$log} {::console::affiche_resultat "imgfilebase = $imgfilebase \n"}
      if {$log} {::console::affiche_resultat "imgfiletmp = $imgfiletmp \n"}

      buf$::audace(bufNo) load $imgfilebase
      buf$::audace(bufNo) mirrory
      buf$::audace(bufNo) save $imgfiletmp

      set ident [bddimages_image_identification $idbddimg]
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      if {$log} {catch {gren_info "$errnum : $msg : $r"}}
      if {$errnum==0} {}

   }

}




proc ::bddimages_imgcorrection::rot_plus90 { img_list } {

   global bddconf
   
   set log 0

   foreach img $img_list {
      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $img "filename"]
      set dirimgfilename [::bddimages_liste::lget $img "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
      set xcent       [expr $naxis1/2.0]
      set ycent       [expr $naxis2/2.0]

      set imgfiletmp [string range [file tail $imgfilebase] 0 [expr [string last .gz [file tail $imgfilebase]] -1]]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfiletmp]
      if {$log} {::console::affiche_resultat "imgfilebase = $imgfilebase \n"}
      if {$log} {::console::affiche_resultat "imgfiletmp = $imgfiletmp \n"}

      buf$::audace(bufNo) load $imgfilebase
      buf$::audace(bufNo) rot $xcent $ycent 90.0
      buf$::audace(bufNo) save $imgfiletmp

      set ident [bddimages_image_identification $idbddimg]
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      if {$log} {catch {gren_info "$errnum : $msg : $r"}}
      if {$errnum==0} {}

   }

}




proc ::bddimages_imgcorrection::rot_moins90 { img_list } {

   global bddconf
   
   set log 0

   foreach img $img_list {
      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $img "filename"]
      set dirimgfilename [::bddimages_liste::lget $img "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set naxis1      [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
      set naxis2      [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
      set xcent       [expr $naxis1/2.0]
      set ycent       [expr $naxis2/2.0]

      set imgfiletmp [string range [file tail $imgfilebase] 0 [expr [string last .gz [file tail $imgfilebase]] -1]]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfiletmp]
      if {$log} {::console::affiche_resultat "imgfilebase = $imgfilebase \n"}
      if {$log} {::console::affiche_resultat "imgfiletmp = $imgfiletmp \n"}

      buf$::audace(bufNo) load $imgfilebase
      buf$::audace(bufNo) rot $xcent $ycent -90.0
      buf$::audace(bufNo) save $imgfiletmp

      set ident [bddimages_image_identification $idbddimg]
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      if {$log} {catch {gren_info "$errnum : $msg : $r"}}
      if {$errnum==0} {}

   }

}




proc ::bddimages_imgcorrection::rot_180 { img_list } {

   global bddconf
   
   set log 0

   foreach img $img_list {
      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      set imgfilename    [::bddimages_liste::lget $img "filename"]
      set dirimgfilename [::bddimages_liste::lget $img "dirfilename"]
      set imgfilebase    [file join $bddconf(dirbase) $dirimgfilename $imgfilename]

      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set naxis1    [lindex [::bddimages_liste::lget $tabkey NAXIS1 ] 1]
      set naxis2    [lindex [::bddimages_liste::lget $tabkey NAXIS2 ] 1]
      set xcent     [expr $naxis1/2.0]
      set ycent     [expr $naxis2/2.0]

      set imgfiletmp [string range [file tail $imgfilebase] 0 [expr [string last .gz [file tail $imgfilebase]] -1]]
      set imgfiletmp [file join $bddconf(dirtmp) $imgfiletmp]
      if {$log} {::console::affiche_resultat "imgfilebase = $imgfilebase \n"}
      if {$log} {::console::affiche_resultat "imgfiletmp = $imgfiletmp \n"}

      buf$::audace(bufNo) load $imgfilebase
      buf$::audace(bufNo) rot $xcent $ycent 180.0
      buf$::audace(bufNo) save $imgfiletmp

      set ident [bddimages_image_identification $idbddimg]
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      set errnum [catch {set r [insertion_solo $imgfiletmp]} msg ]
      if {$log} {catch {gren_info "$errnum : $msg : $r"}}
      if {$errnum==0} {}

   }

}




proc ::bddimages_imgcorrection::showReport { {title "Console"} {ltexte "Empty"} {format ""} } {

   variable This
   global audace
   global caption
   global color
   global imgConsole

   set imgConsole $This.report
   if { [ winfo exists $imgConsole ] } {
      destroy $imgConsole
   }

   toplevel $imgConsole -class Toplevel
   wm title $imgConsole "BddImages - Console"
   wm positionfrom $imgConsole user
   wm sizefrom $imgConsole user
   wm resizable $imgConsole 1 1
   wm geometry $imgConsole "400x200"
   wm protocol $imgConsole WM_DELETE_WINDOW { 
      destroy $imgConsole 
   }

   set zonetext $imgConsole.text
   text $zonetext -height 30 -width 80 -yscrollcommand "$zonetext.scroll set"
   pack $zonetext -expand yes -fill both -padx 5 -pady 5
   scrollbar $zonetext.scroll -command "$zonetext yview"
   pack $zonetext.scroll -side right -fill y

   $zonetext tag configure BODY -foreground black -background white
   $zonetext tag configure TITLE -foreground "#808080" -justify center -font [ list {Arial} 12 bold ] 
   $zonetext tag configure H1 -justify left -font [ list {Arial} 10 normal ] -wrap word
   $zonetext tag configure H2 -justify left -font [ list {Arial} 10 normal ] -foreground $color(blue) -wrap word 
   $zonetext tag configure LISTE0 -foreground $color(black) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure LISTE1 -foreground $color(red) -lmargin1 20 -lmargin2 20 -rmargin 10 -wrap word
   $zonetext tag configure GREEN -foreground $color(green) -wrap word
   $zonetext tag configure RED -foreground $color(red) -wrap word

   $zonetext insert end "$title \n\n" TITLE
   foreach t $ltexte { 
      $zonetext insert end "* [lindex $t 0] : [lindex $t 1] \n" $format
   }

}



#--------------------------------------------------
# run_create { this }
#--------------------------------------------------
#
#    fonction  :
#        Creation de la fenetre
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::run_create { this type } {
   
   variable This
   global audace bddconf caption
   global entetelog



   # Type de correction (e.g. flat)
   set ::bddimages_imgcorrection::type $type

   # Recuperation des informations des images selectionnees
   set selection_list [::bddimages_imgcorrection::get_info_img]

   # Initialisations
   set ::bddimages_imgcorrection::offset_img_list  ""
   set ::bddimages_imgcorrection::soffset_img_list ""
   set ::bddimages_imgcorrection::dark_img_list    ""
   set ::bddimages_imgcorrection::sdark_img_list   ""
   set ::bddimages_imgcorrection::flat_img_list    ""
   set ::bddimages_imgcorrection::sflat_img_list   ""
   set ::bddimages_imgcorrection::deflat_img_list  ""
   set ::bddimages_imgcorrection::erreur_selection 0
   set ::bddimages_imgcorrection::progress 0

   set reportMessage ""
   set reportFilename ""

   # Definition des vignettes
   image create photo icon_ok
   icon_ok configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
   image create photo icon_no
   icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
   image create photo icon_warn
   icon_warn configure -file [file join $audace(rep_plugin) tool bddimages icons warn.gif]
   image create photo icon_report
   icon_report configure -file [file join $audace(rep_plugin) tool bddimages icons report.gif]

   # Affichage de la fenetre
   set entetelog "$caption(bddimages_imgcorrection,main_title)"
   set This $this

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   toplevel $This -class Toplevel
   wm title $This $entetelog
   wm positionfrom $This user
   wm sizefrom $This user
   wm resizable $This 0 0

   set framecurrent $This.framename
   frame $framecurrent
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame de titre
   frame $framecurrent.title
   pack configure $framecurrent.title -side top -fill x
   switch $::bddimages_imgcorrection::type {
      offset { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insoffset)] }
      dark   { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insdark)] }
      flat   { set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,insflat)] }
      deflat { set title $caption(bddimages_imgcorrection,correction) }
   }
   label $framecurrent.title.e -font $bddconf(font,arial_10_b) -text $title
   pack configure $framecurrent.title.e -side top -anchor c -padx 3 -pady 3 -fill x 

   # Images d'entree
   frame $framecurrent.input -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.input -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.input.title
      pack configure $framecurrent.input.title -side top -fill x
         label $framecurrent.input.title.t -relief groove -text "$caption(bddimages_imgcorrection,input)" 
         pack $framecurrent.input.title.t -in $framecurrent.input.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set inputFrame $framecurrent.input.tab
      frame $inputFrame
      pack configure $inputFrame -side top -expand 0
         frame $inputFrame.filetype
         pack configure $inputFrame.filetype -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filenb
         pack configure $inputFrame.filenb -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filestatus
         pack configure $inputFrame.filestatus -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filereport
         pack configure $inputFrame.filereport -side left -fill x -padx 2 -pady 1

   # ------------------------------------------------------------------
   #                     Creation d'un OFFSET MAITRE 
   # ------------------------------------------------------------------
   if {$type == "offset"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,inoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "offset" $caption(bddimages_imgcorrection,nooffset)]
         lappend reportFilename [list "offset" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::offset_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.offset -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.offset -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     Creation d'un DARK MAITRE 
   # ------------------------------------------------------------------
   if {$type == "dark"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste DARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,indark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "dark" $caption(bddimages_imgcorrection,nodark)]
         lappend reportFilename [list "dark" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::dark_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.dark -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.dark -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     Creation d'un FLAT MAITRE
   # ------------------------------------------------------------------
   if {$type == "flat"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste SDARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,insdark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master dark" $caption(bddimages_imgcorrection,onedark)]
         lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::sdark_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste FLAT
      set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.flat -text "$caption(bddimages_imgcorrection,inflat)"
      pack $inputFrame.filetype.flat -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.flat -text $nbi
      pack $inputFrame.filenb.flat -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "flat" $caption(bddimages_imgcorrection,noflat)]
         lappend reportFilename [list "flat" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::flat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "flat" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.flat -image $icon
      pack $inputFrame.filestatus.flat -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.flat -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.flat -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # ------------------------------------------------------------------
   #                     DEFLAT images 
   # ------------------------------------------------------------------
   if {$type == "deflat"}  {

      # Chargement de la liste SOFFSET
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.offset -text "$caption(bddimages_imgcorrection,insoffset)"
      pack $inputFrame.filetype.offset -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.offset -text $nbi
      pack $inputFrame.filenb.offset -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master offset" $caption(bddimages_imgcorrection,oneoffset)]
         lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::soffset_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master offset" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master offset" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.offset -image $icon
      pack $inputFrame.filestatus.offset -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w
      
      # Chargement de la liste SDARK
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.dark -text "$caption(bddimages_imgcorrection,insdark)"
      pack $inputFrame.filetype.dark -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.dark -text $nbi
      pack $inputFrame.filenb.dark -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master dark" $caption(bddimages_imgcorrection,onedark)]
         lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
      } else {
         set ::bddimages_imgcorrection::sdark_img_list $img_list
         if {$nbi == 0} {
            set icon "icon_warn"
            lappend reportFilename [list "master dark" $caption(bddimages_imgcorrection,nofile)]
         } else {
            set icon "icon_ok"
            foreach img $img_list {
               lappend reportFilename [ list "master dark" [::bddimages_imgcorrection::img_to_filename $img short] ]
            }
         }
      }
      # Label du statut
      label $inputFrame.filestatus.dark -image $icon
      pack $inputFrame.filestatus.dark -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Chargement de la liste SFLAT
      set img_list [::bddimages_imgcorrection::select_img_list_by_type FLAT CORR $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.flat -text "$caption(bddimages_imgcorrection,insflat)"
      pack $inputFrame.filetype.flat -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.flat -text $nbi
      pack $inputFrame.filenb.flat -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0 || $nbi > 1} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "master flat" $caption(bddimages_imgcorrection,oneflat)]
         lappend reportFilename [list "master flat" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::sflat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "master flat" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.flat -image $icon
      pack $inputFrame.filestatus.flat -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w
      
      # Chargement de la liste IMG
      set img_list [::bddimages_imgcorrection::select_img_list_by_type IMG RAW $selection_list]
      set nbi [llength $img_list]
      # Label type
      label $inputFrame.filetype.img -text "$caption(bddimages_imgcorrection,inimg)"
      pack $inputFrame.filetype.img -in $inputFrame.filetype -side top -padx 3 -pady 1 -anchor w
      # Label nb images du type
      label $inputFrame.filenb.img -text $nbi
      pack $inputFrame.filenb.img -in $inputFrame.filenb -side top -padx 3 -pady 1 -anchor w
      if {$nbi == 0} {
         set ::bddimages_imgcorrection::erreur_selection 1
         set icon "icon_no"
         lappend reportMessage [list "image" $caption(bddimages_imgcorrection,noimg)]
         lappend reportFilename [list "image" $caption(bddimages_imgcorrection,nofile)]
      }  else {
         set ::bddimages_imgcorrection::deflat_img_list $img_list
         set icon "icon_ok"
         foreach img $img_list {
            lappend reportFilename [ list "image" [::bddimages_imgcorrection::img_to_filename $img short] ]
         }
      }
      # Label du statut
      label $inputFrame.filestatus.img -image $icon
      pack $inputFrame.filestatus.img -in $inputFrame.filestatus -side top -padx 3 -pady 1 -anchor w

      # Bouton affiche liste fichiers
      button $inputFrame.filereport.img -image icon_report \
          -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleF) $reportFilename LISTE0]
      pack configure $inputFrame.filereport.img -side top -ipadx 2 -ipady 3 -padx 2 -anchor c

   }

   # Image RESULTAT
   frame $framecurrent.output -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.output -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.output.title
      pack configure $framecurrent.output.title -side top -fill x
         label $framecurrent.output.title.t -relief groove -text "$caption(bddimages_imgcorrection,output)" 
         pack $framecurrent.output.title.t -in $framecurrent.output.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set outputFrame $framecurrent.output.tab
      frame $outputFrame
      pack configure $outputFrame -side top -expand 0 -padx 2 -pady 1

   # Concatenation des listes et verifications
   if {$::bddimages_imgcorrection::erreur_selection == 0} {
      # 
      if {[catch {::bddimages_imgcorrection::verif_all_img} msg]}  {
         set ::bddimages_imgcorrection::erreur_selection 1
         lappend reportMessage [list $::bddimages_imgcorrection::type $msg]
      }
      if {[catch {::bddimages_imgcorrection::verif_filter_img} msg]}  {
         set ::bddimages_imgcorrection::erreur_selection 1
         lappend reportMessage [list $::bddimages_imgcorrection::type $msg]
      }
   }

   # Si les elements selectionnes permettent l'action...
   if {$::bddimages_imgcorrection::erreur_selection == 0} {
      set filename "<generic>"
      set ::bddimages_imgcorrection::inforesult ""
      # Defini un nom d'image dans les cas de creation d'une image MAITRE
      if { [llength $::bddimages_imgcorrection::deflat_img_list] == 0 } {
         set ::bddimages_imgcorrection::inforesult [::bddimages_imgcorrection::create_filename $type]
         set filename [lindex $::bddimages_imgcorrection::inforesult 0]
      }
      label $outputFrame.name -text "$filename"
      pack $outputFrame.name -in $outputFrame -side top -padx 3 -pady 1 -anchor w
      
   } else {
      label $outputFrame.name -text "$caption(bddimages_imgcorrection,noresult)"
      pack $outputFrame.name -in $outputFrame -side left -padx 3 -pady 1 -anchor w
      button $outputFrame.helpme -text ? \
         -command [list ::bddimages_imgcorrection::showReport $caption(bddimages_imgcorrection,consoleE) $reportMessage LISTE1]
      pack configure $outputFrame.helpme -side left
   }
   
   #--- Cree un frame pour y mettre la barre de progression
   frame $framecurrent.frameprogress -borderwidth 0 -cursor arrow
   pack $framecurrent.frameprogress -in $framecurrent -anchor s -side top -expand 0 -fill x

         set pf [ ttk::progressbar $framecurrent.frameprogress.p -variable ::bddimages_imgcorrection::progress -orient horizontal -length 350 -mode determinate]
         pack $pf -in $framecurrent.frameprogress -side top -anchor c

   # Frame boutons Cancel et Ok
   frame $framecurrent.buttons
   pack configure $framecurrent.buttons -side top -fill x -padx 3 -pady 3
      # --- ok
      if {$::bddimages_imgcorrection::erreur_selection == 0} {
        button $framecurrent.buttons.ok -text Ok \
           -command {
              ::bddimages_imgcorrection::correction $::bddimages_imgcorrection::type $::bddimages_imgcorrection::inforesult
              destroy $::bddimages_imgcorrection::This
           }
        pack configure $framecurrent.buttons.ok -side right
      }
      # --- cancel
      button $framecurrent.buttons.cancel -text Cancel \
         -command {destroy $::bddimages_imgcorrection::This}
      pack configure $framecurrent.buttons.cancel -side right

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
   #--- Surcharge la couleur de fond des resultats
   $framecurrent.title.e configure -font $bddconf(font,arial_10_b)

   grab set $This
   tkwait window $This
}









#--------------------------------------------------
# run_auto { this }
#--------------------------------------------------
#
#    fonction  :
#        Recherche automatiquement le travail a faire
#        Puis l execute
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::run_auto { this } {

   variable This
   global audace bddconf caption
   global entetelog

   # Recuperation des informations des images selectionnees
   set selection_list [::bddimages_imgcorrection::get_info_img]

   # Initialisations
   set ::bddimages_imgcorrection::offset_img_list  ""
   set ::bddimages_imgcorrection::soffset_img_list ""
   set ::bddimages_imgcorrection::dark_img_list    ""
   set ::bddimages_imgcorrection::sdark_img_list   ""
   set ::bddimages_imgcorrection::flat_img_list    ""
   set ::bddimages_imgcorrection::sflat_img_list   ""
   set ::bddimages_imgcorrection::deflat_img_list  ""
   set ::bddimages_imgcorrection::erreur_selection 0

   set reportMessage ""
   set reportFilename ""

   # Definition des vignettes
   image create photo icon_ok
   icon_ok configure -file [file join $audace(rep_plugin) tool bddimages icons ok.gif]
   image create photo icon_no
   icon_no configure -file [file join $audace(rep_plugin) tool bddimages icons no.gif]
   image create photo icon_warn
   icon_warn configure -file [file join $audace(rep_plugin) tool bddimages icons warn.gif]
   image create photo icon_report
   icon_report configure -file [file join $audace(rep_plugin) tool bddimages icons report.gif]

   # Affichage de la fenetre
   set entetelog "$caption(bddimages_imgcorrection,main_title)"
   set This $this

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   toplevel $This -class Toplevel
   wm title $This $entetelog
   wm positionfrom $This user
   wm sizefrom $This user
   wm resizable $This 0 0

   set framecurrent $This.framename
   frame $framecurrent
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10

   # Frame de titre
   frame $framecurrent.title
   pack configure $framecurrent.title -side top -fill x
   set title [concat $caption(bddimages_imgcorrection,creation) $caption(bddimages_imgcorrection,inauto)] 
   label $framecurrent.title.e -font $bddconf(font,arial_10_b) -text $title
   pack configure $framecurrent.title.e -side top -anchor c -padx 3 -pady 3 -fill x 

   # Images d'entree
   frame $framecurrent.input -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.input -side top -padx 5 -pady 5 -fill x
      frame $framecurrent.input.title
      pack configure $framecurrent.input.title -side top -fill x
         label $framecurrent.input.title.t -relief groove -text "$caption(bddimages_imgcorrection,input)" 
         pack $framecurrent.input.title.t -in $framecurrent.input.title -side top -padx 3 -pady 3 -anchor w -fill x -expand 1
      set inputFrame $framecurrent.input.tab
      frame $inputFrame
      pack configure $inputFrame -side top -expand 0
         frame $inputFrame.filetype
         pack configure $inputFrame.filetype -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filenb
         pack configure $inputFrame.filenb -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filestatus
         pack configure $inputFrame.filestatus -side left -fill x -padx 2 -pady 1
         frame $inputFrame.filereport
         pack configure $inputFrame.filereport -side left -fill x -padx 2 -pady 1

    # Chargement de la liste SOFFSET
      gren_info "Les Offset \n"
      set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET CORR $selection_list]
      set nbi [llength $img_list]
      if {$nbi>0} {
         gren_info "Super Offset existe. On prend le premier de la liste \n"
      } else {
         set img_list [::bddimages_imgcorrection::select_img_list_by_type OFFSET RAW $selection_list]
         set nbi [llength $img_list]
         if {$nbi>0} {
            gren_info "Offset existe. On cree le super offset \n"
         } else {
            gren_info "Pas d Offset \n"
         }
      }

    # Chargement de la liste DARK
      gren_info "Les Dark \n"
      set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK CORR $selection_list]
      set nbi [llength $img_list]
      if {$nbi>0} {
         gren_info "Super DARK existe. On prend le premier de la liste \n"
      } else {
         set img_list [::bddimages_imgcorrection::select_img_list_by_type DARK RAW $selection_list]
         set nbi [llength $img_list]
         if {$nbi>0} {
            gren_info "DARK existe. On cree le super DARK \n"
         } else {
            gren_info "Pas de DARK \n"
         }
      }

    # Chargement de la liste FLAT

}



#--------------------------------------------------
# Fonction d utilitaires pour le CROP
#--------------------------------------------------

proc ::bddimages_imgcorrection::init_crop {  } {

   set ::bddimages_imgcorrection::progress 0
   set cpt  0
   foreach img $::bddimages_imgcorrection::crop_list {

      set tabkey    [::bddimages_liste::lget $img "tabkey"]
      set naxis  [string trim [lindex [::bddimages_liste::lget $tabkey "naxis" ] 1]]
      set naxis1 [string trim [lindex [::bddimages_liste::lget $tabkey "naxis1"] 1]]
      set naxis2 [string trim [lindex [::bddimages_liste::lget $tabkey "naxis2"] 1]]
      set bdditype  [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_type"] 1]]
      set bddistate [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_state"] 1]]

      if {$cpt == 0} {
         set naxissav $naxis
         set naxis1sav $naxis1
         set naxis2sav $naxis2
      }
      
      if {$naxis != $naxissav || $naxis1 != $naxis1sav || $naxis2 != $naxis2sav || $bddistate != "CORR"} {
         return "no"
      }
      
   }
   set ::bddimages_imgcorrection::xbg 1
   set ::bddimages_imgcorrection::ybg 1
   set ::bddimages_imgcorrection::xhd $naxis1
   set ::bddimages_imgcorrection::yhd $naxis2

   set ::bddimages_imgcorrection::naxis1 $naxis1
   set ::bddimages_imgcorrection::naxis2 $naxis2

   return "yes"      

}



   
proc ::bddimages_imgcorrection::gocrop {  } {

   global bddconf


   gren_info "xbg =$::bddimages_imgcorrection::xbg\n"
   gren_info "ybg =$::bddimages_imgcorrection::ybg\n"
   gren_info "xhd =$::bddimages_imgcorrection::xhd\n"
   gren_info "yhd =$::bddimages_imgcorrection::yhd\n"
   gren_info "naxis1 $::bddimages_imgcorrection::naxis1\n"
   gren_info "naxis2 $::bddimages_imgcorrection::naxis2\n"

   set invalid "Les coordonnees ne sont pas valides."
   if {$::bddimages_imgcorrection::xbg < 1} {return $invalid}
   if {$::bddimages_imgcorrection::ybg < 1} {return $invalid}
   if {$::bddimages_imgcorrection::xhd > $::bddimages_imgcorrection::naxis1} {return $invalid}
   if {$::bddimages_imgcorrection::yhd > $::bddimages_imgcorrection::naxis2} {return $invalid}
   if {$::bddimages_imgcorrection::xbg >= $::bddimages_imgcorrection::xhd} {return $invalid}
   if {$::bddimages_imgcorrection::ybg >= $::bddimages_imgcorrection::yhd} {return $invalid}
   
   if {$::bddimages_imgcorrection::xbg==1 && $::bddimages_imgcorrection::ybg == 1 && $::bddimages_imgcorrection::xhd == $::bddimages_imgcorrection::naxis1 && $::bddimages_imgcorrection::yhd == $::bddimages_imgcorrection::naxis2} {
      return "Il n'y a aucun changement a faire"
   }

   set bufno [::buf::create]
   set nbtotal [llength $::bddimages_imgcorrection::crop_list]
   set cpt  0
   
   foreach img $::bddimages_imgcorrection::crop_list {

      set idbddimg    [::bddimages_liste::lget $img "idbddimg"]
      gren_info "id=$idbddimg\n"
      set change "no"

      # charge l'image
      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]
      #::console::affiche_resultat "Chargement de $ident -> $fileimg \n"
      if {$fileimg == -1} {
         ::console::affiche_resultat "Fichier image inexistant ($idbddimg) \n"
         ::bddimages_define::fermer
         return
      }

      gren_info "fileimg=$fileimg\n"
      gren_info "filecata=$filecata\n"

      buf$bufno load $fileimg
      
      buf$bufno window [list $::bddimages_imgcorrection::xbg $::bddimages_imgcorrection::ybg $::bddimages_imgcorrection::xhd $::bddimages_imgcorrection::yhd ]     
      
      # enregistre les modif dans l image
      set fichtmpunzip [unzipedfilename $fileimg]
      set filetmp   [file join $::bddconf(dirtmp)  [file tail $fichtmpunzip]]
      set filefinal [file join $::bddconf(dirinco) [file tail $fileimg]]

      createdir_ifnot_exist $bddconf(dirtmp)
      buf$bufno save $filetmp
      lassign [::bdi_tools::gzip $filetmp $filefinal] errnum msg
      #set errnum [catch {exec gzip -c $filetmp > $filefinal} msg ]

      # copie l image dans incoming, ainsi que le fichier cata si il existe
      if {$filecata != -1} {
         set errnum [catch {file rename -force -- $filecata $bddconf(dirinco)/.} msg ]
      }

      # efface l image dans la base et le disque
      bddimages_image_delete_fromsql $ident
      bddimages_image_delete_fromdisk $ident

      # insere l image et le cata dans la base
      insertion_solo $filefinal
      if {$filecata!=-1} {
         set filecata [file join $bddconf(dirinco) [file tail $filecata]]
         insertion_solo $filecata
      }

      set errnum [catch {file delete -force $filetmp} msg ]
      incr cpt

      ::bddimages_imgcorrection::set_progress $cpt $nbtotal

   }

   buf$bufno clear
   return "Le fenetrage a ete effectue avec succes"

}



## Defini la barre de progression qui correspond au traitement des images
# \param cur valeur courante 
# \param max valeur maximale
proc ::bddimages_imgcorrection::set_progress { cur max } {

#      pack [ ttk::progressbar $this.p -variable v -orient horizontal -length 200 -mode determinate]
#      for {set v 0} {$v<100} {incr v} { after 100; update }
#      destroy $::acqt1m_offsetdark::frm.p

   set ::bddimages_imgcorrection::progress [format "%0.0f" [expr $cur * 100. /$max ] ]
   update
   #gren_info "Progresse = $::bddimages_recherche::progress\n"
}

   
   
#--------------------------------------------------
# crop { this }
#--------------------------------------------------
#
#    fonction  :
#        Retaille les images selectionnees
#
#    procedure externe :
#
#    variables en entree :
#        this = chemin de la fenetre
#
#    variables en sortie :
#
#--------------------------------------------------
proc ::bddimages_imgcorrection::crop { this } {
   
   variable This
   global audace bddconf caption
   global entetelog

   
   # Initialisation
      set ::bddimages_imgcorrection::crop_list [::bddimages_imgcorrection::get_info_img]

      if {[::bddimages_imgcorrection::init_crop] == "no"} {
         tk_messageBox -message "Veuillez selectionner des images corrigees BDITYPE=CORR dont les NAXIS, NAXIS1 et NAXIS2 sont equivalents" -type ok
         return
      }

   # Affichage de la fenetre
   set This $this

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      return
   }

   toplevel $This -class Toplevel
   wm title $This "Crop"
   wm positionfrom $This user
   wm sizefrom $This user
   wm resizable $This 0 0

   set framecurrent $This.framename
   frame $framecurrent
   pack configure $framecurrent -side top -fill both -expand 1 -padx 10 -pady 10


   # Images d'entree
   frame $framecurrent.input -borderwidth 1 -relief raised -cursor arrow
   pack configure $framecurrent.input -side top -padx 5 -pady 5 -fill x

      frame $framecurrent.input.title
      pack configure $framecurrent.input.title -side top -fill x

         label $framecurrent.input.title.t -relief groove -text "Forme une nouvelle image a partir du rectangle dont les coordonnees sont :" 
         pack $framecurrent.input.title.t -in $framecurrent.input.title -side top -ipadx 15 -ipady 15 -anchor w -fill x -expand 1

      frame $framecurrent.input.basgauche
      pack configure $framecurrent.input.basgauche -side top -fill x -expand 1

         label $framecurrent.input.basgauche.l -text "Position du coin en bas a gauche :"  -borderwidth 0 
         pack $framecurrent.input.basgauche.l -in $framecurrent.input.basgauche -side top -padx 3 -pady 3 -anchor w

         frame $framecurrent.input.basgauche.t -borderwidth 0
         pack configure $framecurrent.input.basgauche.t -side top -fill x

            label $framecurrent.input.basgauche.t.xl -relief groove -text "Xmin :"  -borderwidth 0
            pack $framecurrent.input.basgauche.t.xl -in $framecurrent.input.basgauche.t -side left -padx 3 -pady 3 -anchor w 

            entry $framecurrent.input.basgauche.t.xv -relief sunken -textvariable ::bddimages_imgcorrection::xbg -width 5 \
            -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $framecurrent.input.basgauche.t.xv -in $framecurrent.input.basgauche.t -side left -padx 3 -pady 3 -anchor w

            label $framecurrent.input.basgauche.t.yl -relief groove -text "Ymin :"  -borderwidth 0
            pack $framecurrent.input.basgauche.t.yl -in $framecurrent.input.basgauche.t -side left -padx 3 -pady 3 -anchor w 

            entry $framecurrent.input.basgauche.t.yv -relief sunken -textvariable ::bddimages_imgcorrection::ybg -width 5 \
            -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $framecurrent.input.basgauche.t.yv -in $framecurrent.input.basgauche.t -side left -padx 3 -pady 3 -anchor w

      frame $framecurrent.input.hautdroit -borderwidth 0
      pack configure $framecurrent.input.hautdroit -side top -fill x

         label $framecurrent.input.hautdroit.l -text "Position du coin en haut a droite :"  -borderwidth 0 -font $bddconf(font,arial_10_b)
         pack $framecurrent.input.hautdroit.l -in $framecurrent.input.hautdroit -side top -padx 3 -pady 3 -anchor w

         frame $framecurrent.input.hautdroit.t
         pack configure $framecurrent.input.hautdroit.t -side top -fill x

            label $framecurrent.input.hautdroit.t.xl -relief groove -text "Xmax :"  -borderwidth 0
            pack $framecurrent.input.hautdroit.t.xl -in $framecurrent.input.hautdroit.t -side left -padx 3 -pady 3 -anchor w

            entry $framecurrent.input.hautdroit.t.xv -relief sunken -textvariable ::bddimages_imgcorrection::xhd -width 5 \
            -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $framecurrent.input.hautdroit.t.xv -in $framecurrent.input.hautdroit.t -side left -padx 3 -pady 3 -anchor w

            label $framecurrent.input.hautdroit.t.yl -relief groove -text "Ymax :"  -borderwidth 0
            pack $framecurrent.input.hautdroit.t.yl -in $framecurrent.input.hautdroit.t -side left -padx 3 -pady 3 -anchor w

            entry $framecurrent.input.hautdroit.t.yv -relief sunken -textvariable ::bddimages_imgcorrection::yhd -width 5 \
            -validate all -validatecommand { ::tkutil::validateString %W %V %P %s wordchar1 0 100 }
            pack $framecurrent.input.hautdroit.t.yv -in $framecurrent.input.hautdroit.t -side left -padx 3 -pady 3 -anchor w
   
   #--- Cree un frame pour y mettre la barre de progression
   frame $framecurrent.frameprogress -borderwidth 0 -cursor arrow
   pack $framecurrent.frameprogress -in $framecurrent -anchor s -side top -expand 0 -fill x

         set pf [ ttk::progressbar $framecurrent.frameprogress.p -variable ::bddimages_imgcorrection::progress -orient horizontal -length 350 -mode determinate]
         pack $pf -in $framecurrent.frameprogress -side top -anchor c

   # Frame boutons Cancel et Ok
   frame $framecurrent.buttons
   pack configure $framecurrent.buttons -side top -fill x -padx 3 -pady 3
      # --- ok
      button $framecurrent.buttons.ok -text Crop \
         -command {
            set result [::bddimages_imgcorrection::gocrop]
            tk_messageBox -message $result -type ok
            destroy $::bddimages_imgcorrection::This
         }
      pack configure $framecurrent.buttons.ok -side right
      # --- cancel
      button $framecurrent.buttons.cancel -text Cancel \
         -command {destroy $::bddimages_imgcorrection::This}
      pack configure $framecurrent.buttons.cancel -side right

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
   #--- Surcharge la couleur de fond des resultats
   $framecurrent.input.basgauche.l configure -font $bddconf(font,arial_10_b)
   $framecurrent.input.hautdroit.l configure -font $bddconf(font,arial_10_b)

   grab set $This
   tkwait window $This
}
