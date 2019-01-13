## @file bddimages_astroid.tcl
#  @brief     Fonctions de manipulation des sources Astroid
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_astroid.tcl]
#  @endcode

# $Id: bddimages_astroid.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bddimages_astroid
# @brief Fonctions de manipulation des sources Astroid
# @pre Requiert le fichier d'internationalisation \c bddimages_admin.cap .
# @pre Requiert le paquetage \c math::constants .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages_astroid {

   global audace
   global bddconf

   package require math::constants

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

proc ::bddimages_astroid::run_astroid {  } {

   global bddconf

   ::confVisu::addZoomListener $::audace(visuNo) "efface_rond"
   ::confVisu::addMirrorListener $::audace(visuNo) "efface_rond"
   ::confVisu::addFileNameListener $::audace(visuNo) "efface_rond"

   ::console::affiche_resultat "cata head = [lindex $::bdi_gui_cata::current_cata 0] \n"
   ::console::affiche_resultat "cata s1   = [lindex [lindex $::bdi_gui_cata::current_cata 1] 0]\n"
   set med  [expr [llength [lindex $::bdi_gui_cata::current_cata 1] ] / 2]
   ::console::affiche_resultat "cata s2  $med = [lindex [lindex $::bdi_gui_cata::current_cata 1] $med]\n"

   # Affichage centre champ de l image
   set centre [list [list "CENTRE" {ra dec} {}] [list [list [list "CENTRE" [list $::bdi_gui_cata::current_image(ra) $::bdi_gui_cata::current_image(dec)] {}]]]]
   ::console::affiche_resultat "centre = $centre\n"
   ::bddimages_astroid::affich_rond $centre "CENTRE" "red" 7
   ::console::affiche_resultat "ROND ROUGE: centre du champ provenant du header fits\n"

   # Recupere le catalog astrometrique
    set astrometric_list [get_astrometric_catalog $::bdi_gui_cata::current_image(ra) $::bdi_gui_cata::current_image(dec) $::bdi_gui_cata::current_image(radius)]
    ::console::affiche_resultat "astroid astrometric nbsource =  [llength [lindex $astrometric_list 1]]\n"
   ::console::affiche_resultat "astrometric head = [lindex $astrometric_list 0] \n"
   ::console::affiche_resultat "astrometric s1   = [lindex [lindex $astrometric_list 1] 0]\n"
   ::console::affiche_resultat "astrometric s2   = [lindex [lindex $astrometric_list 1] 1]\n"

   # Affichage le catalogue astrometrique
   ::bddimages_astroid::affich_rond $astrometric_list "UCAC2" "blue" 2
   ::console::affiche_resultat "ROND BLEU: Etoiles astrometric\n"

   set star_ident [ identification $::bdi_gui_cata::current_cata "USNOA2" $astrometric_list "UCAC2" 30.0 10.0 10.0 ]
   # Affichage des sources identifiees
   ::bddimages_astroid::affich_rond $star_ident "UCAC2" "green" 2

   ###################################################
   ###################################################

   # Ecrire au format cata.xml la liste star_ident
   ::console::affiche_resultat "set star_ident $star_ident \n"

   ###################################################
   ###################################################

}



proc ::bddimages_astroid::get_identified { sra sdec serrpos srmag srmagerr ira idec ierrpos irmag irmagerr scoreposlimit scoremvlimit scorelimit } {

   set dtr $::math::constants::degtorad
   set score NULL
   set deltapos [expr sqrt(pow(($sra-$ira)*cos($sdec*$dtr),2) + pow($sdec-$idec,2))]
   set deltaposdiv [expr ($serrpos + $ierrpos) / 3600.0]
   set scorepos [expr (1.0 - $deltapos / $deltaposdiv) * 100.0]
   if {$deltapos > $deltaposdiv } { set scorepos 0.0 }
   set deltamag [expr abs($irmag - $srmag)]
   set deltamagdiv [expr $srmagerr+$irmagerr]
   set scoremv [expr (1.0 - $deltamag / $deltamagdiv) * 100.0]
   if { $deltamag > $deltamagdiv } { set scoremv 0.0 }
   set score $scorepos
   if { $scoremv < $score } { set score $scoremv }
   if { $scorepos >= $scoreposlimit && $scoremv >= $scoremvlimit && $score >= $scorelimit } {
      return true
   }
   return false

}




# -- Procedure 
proc ::bddimages_astroid::identification { catalist1 catalog1 catalist2 catalog2 scoreposlimit scoremvlimit scorelimit } {

   set resultlist {}
   
   set fields1  [lindex $catalist1 0]
   set sources1 [lindex $catalist1 1]
   set fields2  [lindex $catalist2 0]
   set sources2 [lindex $catalist2 1]
   
   set nb 0
   
   foreach s1 $sources1 {
      set cm "?"
      set completesource {}
      foreach cata $s1 {
         lappend completesource $cata
         if { [lindex $cata 0]==$catalog1 } {
            set cm1 [lindex $cata 1]
            set cm "ok"
         }
      }
      if { $cm == "ok"} {
         set key 0
         foreach s2 $sources2 {
            set tmpsource {}
            foreach cata $s2 {
               lappend tmpsource $cata
               if { [lindex $cata 0]==$catalog2 } {
                  set cm2 [lindex $cata 1]
               }
            }
            set accepted [::bddimages_astroid::get_identified [lindex $cm1 0] [lindex $cm1 1] [lindex $cm1 2] [lindex $cm1 3] [lindex $cm1 4] [lindex $cm2 0] [lindex $cm2 1] [lindex $cm2 2] [lindex $cm2 3] [lindex $cm2 4] $scoreposlimit $scoremvlimit $scorelimit ]
            if { $accepted } {
               set sources2 [lreplace $sources2 $key $key ]
               incr nb
               gren_info "[lindex $cm1 0] [lindex $cm1 1] [lindex $cm2 0] [lindex $cm2 1] accepted $nb [llength $sources2]\n"
               set completesource [concat $completesource $tmpsource]
               break
            }
            incr key
         }
      }
   
      lappend resultlist $completesource
   }

   return [list [concat $fields1 $fields2] $resultlist]
}



proc ::bddimages_astroid::get_astrometric_catalog { ra dec radius} {

   set astrometric_catalog UCAC2
   
   ::console::affiche_resultat "::bddimages_astroid::vo_cds_query $astrometric_catalog $ra $dec $radius\n"
   set star_list [::bddimages_astroid::vo_cds_query $astrometric_catalog $ra $dec $radius]
   #set star_list [vo_vizier_query $ra $dec $radius arcmin I/289/out]
   
   #::console::affiche_resultat "set star_list {$star_list}\n"
   
   set fsav ""
   set cpt 0
   set list_sources ""
   foreach t $star_list {
      set tt [lindex $t 0]
      set c  [lindex $tt 0]
      set f  [lindex $tt 1]
      set v  [lindex $tt 2]
      if {$cpt!=0} {
         if {$f!=$fsav} {
            ::console::affiche_erreur "ENTETE NON IDENTIQUE\n"
         }
      } else {
         ::console::affiche_resultat "premier passage\n"
         
         set i 0
         foreach x $f {
           ::console::affiche_resultat "($i) $x = [lindex $v $i]\n"
           incr i
         }
   
      }
      #::console::affiche_resultat "ucac2 = [lindex $v 1]\n"
   
      set cmval [list [lindex $v 2] [lindex $v 3] .2 [lindex $v 7] 0.2 ]
      lappend list_sources [list [list $c $cmval $v]]
      #::console::affiche_resultat "cmval $cmval\n"
      set fsav $f
      incr cpt
   }
   
   set cmfields  [list ra dec poserr mag magerr]
   set list_fields [list [list $astrometric_catalog $cmfields $fsav] ]
   
   return [list $list_fields $list_sources]

}




#
# catalog : I/289/out for UCAC2
# catalog : I/315/out for UCAC3
# catalog : I/239/hip_main for HIPPARCOS
# ra : 
# dec : signe obligatoire
# r : rayon
proc ::bddimages_astroid::vo_cds_query { catalogname ra dec r } {

   package require xml
   package require dom
   package require http
   
   if {$catalogname == "UCAC3"}  then { set catalog "I/315/out" }
   if {$catalogname == "UCAC2"}  then { set catalog "I/289/out" }
   if {$catalogname == "UCAC2A"} then { set catalog "I/294A/ucac2bss" }
   if {$catalogname == "HIP"}    then { set catalog "I/239/hip_main" }
   if {$catalogname == "2MASS"}  then { set catalog "II/246/out" }
   if {$catalogname == "TYCHO"}  then { set catalog "I/239/tyc_main" }
   
   
   #http://vizier.u-strasbg.fr/viz-bin/votable?-out.max=10000&-c=0+%2B0&-c.eq=J2000&-oc.form=dec&-c.r=+10&-c.u=arcmin&-c.geom=r&-source=I%2F289%2Fout&-out.all=1
   
   set url "http://vizier.u-strasbg.fr/viz-bin/votable"
   set catalog [::http::formatQuery $catalog ]
   set ra [::http::formatQuery $ra]
   set dec [::http::formatQuery $dec]
   set r [::http::formatQuery $r]
   set query "-out.max=10000&-c=$ra+$dec&-c.eq=J2000&-oc.form=dec&-c.r=+$r&-c.u=arcmin&-c.geom=r&-source=$catalog%2Fout&-out.all=1"
   
   
   set token [ ::http::geturl $url -query $query ]
   set votable [::dom::parse [::http::data $token]]
   set fields {}
   foreach n [::dom::selectNode $votable {descendant::FIELD/attribute::name}] {
   lappend fields "[::dom::node stringValue $n]"
   }
   
   set rows {}
   foreach tr [::dom::selectNode $votable {descendant::TR}] {
   set row {}
   foreach td [::dom::selectNode $tr {descendant::TD/text()}] {
      lappend row [::dom::node stringValue $td]
      }
      lappend rows [list [list $catalogname $fields $row] ]
   }
   
   return $rows
}



proc ::bddimages_astroid::extract_sun_star { starlist } {

   set commonfields [list ra dec poserr mag magerr]
   set rows {}
   foreach star $starlist {
   set insert "no"
   foreach cata $star {
      set fields   [lindex $cata 1]
      set idmagbmv [lsearch $fields "B-V"]
      set magbnv   [lindex [lindex $cata 2] $idmagbmv]
      if {$magbnv > 0.5 && $magbnv < 0.9}  then {
         #gren_info " B-V = $magbnv"         
         set insert "yes"
         set ra      [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "RAhms"] ]
         set ra      [mc_angle2deg $ra]
         set ra      [expr $ra * 15.0]
         set dec     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "DEdms"] ]
         set dec     [mc_angle2deg $dec]
         set e_RAdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_RAdeg"] ]
         set e_DEdeg [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "e_DEdeg"] ]
         set mag     [lindex [lindex $cata 2] [lsearch [lindex $cata 1] "Vmag"] ]
         set magerr  0.3
         #gren_info " field = [lindex $cata 1] "
         #gren_info " value = [lindex $cata 2] "
         #gren_info " tag =$ra $dec $e_RAdeg $e_DEdeg $mag $magerr"
         set poserr  0.3
         #gren_info " tag =$ra $dec $poserr $mag $magerr"
         }
      }
   if {$insert == "yes"} {
      lappend star [list "common" $commonfields [list $ra $dec $poserr $mag $magerr] ]
      lappend rows $star 
      }
   }
   #gren_info "rows = $rows"
   return $rows

}



proc ::bddimages_astroid::affich_image { fitsfile } {
   global bddconf
   global audace
   set bufno $::bddconf(bufno)
   set errnum [catch {buf$bufno load $fitsfile} msg ]
   set nbvisu [::visu::create $bufno 1]
   #visu$nbvisu zoom 0.5
   #visu$nbvisu clear
   #visu$nbvisu disp
   #$audace(hCanvas) delete cadres
}



proc ::bddimages_astroid::affich_rond { listsources catalog color width } {

   ::console::affiche_resultat "AFFICH_CATALOG=($catalog, $color, $width) NB=[llength [lindex $listsources 1]]\n"
      
   set fields  [lindex $listsources 0]
   set sources [lindex $listsources 1]
   foreach s $sources { 
      #gren_info "s =  $s \n"
      foreach cata $s {
         #gren_info "cata =  $cata \n"
         if { [lindex $cata 0]==$catalog } {
            set cm [lindex $cata 1]
            #gren_info "cm =  $cm \n"
            affich_un_rond [lindex $cm 0] [lindex $cm 1] $color $width
         }
      }
   }

}


proc ::bddimages_astroid::affich_un_rond { ra dec color width } {

   global audace
   global bddconf
   set bufno $::bddconf(bufno)
   #gren_info "DD =  $ra $dec \n"
   # Affiche un rond vert
   set img_xy [ buf$bufno radec2xy [ list $ra $dec ] ]
   #--- Transformation des coordonnees image en coordonnees canvas
   set can_xy [ ::audace::picture2Canvas $img_xy ]
   set x [lindex $can_xy 0]
   set y [lindex $can_xy 1]
   # gren_info "XY =  $x $y \n"
   set radius 5           
   #--- Dessine l'objet selectionne en vert dans l'image
   $audace(hCanvas) create oval [ expr $x - $radius ] [ expr $y - $radius ] [ expr $x + $radius ] [ expr $y + $radius ] \
       -outline $color -tags cadres -width $width

}


proc ::bddimages_astroid::efface_rond { args } {
   global audace conf bddconf

   #--- Efface les reperes des objets
   $audace(hCanvas) delete cadres
}
