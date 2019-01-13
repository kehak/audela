## @file bdi_gui_binast.tcl
#  @brief     GUI d'analyse des observations des satellites d'ast&eacute;ro&iuml;des en optique adaptative
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_binast.tcl]
#  @endcode

# $Id: bdi_gui_binast.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_binast
# @brief GUI d'analyse des observations des satellites d'ast&eacute;ro&iuml;des en optique adaptative
# @pre Requiert \c bdi_tools_binast .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_binast {

}


#------------------------------------------------------------
## 
#  @return void
proc ascii {} {
    set res {}
    for {set i 33} {$i<1024} {incr i} {
        append res "$i :: [format %2.2X:%c $i $i] \n"
        if {$i%16==0} {append res \n}
    }
    set res
}







#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::inittoconf {  } {

   global conf bddconf

   if {![info exists conf(binast,def_author,list)]} {
      set bddconf(binast,def_author,list) ""
   } else {
      set bddconf(binast,def_author,list) $conf(binast,def_author,list)
   }

   if {![info exists conf(binast,def_author,selected)]} {
      set ::bdi_gui_binast::widget(def_author,selected) ""
   } else {
      set ::bdi_gui_binast::widget(def_author,selected) $conf(binast,def_author,selected)
   }

   catch { unset ::bdi_gui_binast::fen                  }
   catch { unset ::bdi_gui_binast::directaccess         }
   catch { unset ::bdi_gui_binast::stateback            }
   catch { unset ::bdi_gui_binast::statenext            }
   catch { unset ::bdi_gui_binast::block                }

   catch { unset ::bdi_gui_binast::check_system         }

   catch { unset ::bdi_tools_binast::nomobj             }
   catch { unset ::bdi_tools_binast::savedir            }
   catch { unset ::bdi_tools_binast::uncosm             }
   catch { unset ::bdi_tools_binast::uncosm_param1      }
   catch { unset ::bdi_tools_binast::uncosm_param2      }
   catch { unset ::bdi_tools_binast::firstmagref        }
   catch { unset ::bdi_tools_binast::current_image_name }
   catch { unset ::bdi_tools_binast::current_image_date }
   catch { unset ::bdi_tools_binast::id_current_image   }
   catch { unset ::bdi_tools_binast::nb_img_list        }
   catch { unset ::bdi_tools_binast::tabsource          }
   catch { unset ::bdi_tools_binast::firstmagref        }
   catch { unset ::bdi_tools_binast::tabphotom          }

   catch { unset ::bdi_tools_binast::nb_obj        }
   catch { unset ::bdi_tools_binast::nb_obj_sav        }

   set ::bdi_gui_binast::enregistrer disabled
   set ::bdi_gui_binast::analyser disabled
   set ::bdi_gui_binast::check_system "-"

   set ::bdi_tools_binast::nb_obj 1
   set ::bdi_tools_binast::nb_obj_sav $::bdi_tools_binast::nb_obj
   set ::bdi_tools_binast::saturation 50000
   set ::bdi_tools_binast::uncosm 50000
   set ::bdi_gui_binast::block 1

   set ::bdi_tools_binast::tabsource(obj1,delta) 15

   # Limite le nombre de ligne dans les tables pour la GUI
   if {![info exists ::bdi_gui_binast::widget(table,compos,list)]} {
      set ::bdi_gui_binast::widget(table,compos,list) ""
   }
   set ::bdi_gui_binast::widget(frame,nbrows) 19

}





#------------------------------------------------------------
## Vide la memoire de l appli
#  
#  @return void
proc ::bdi_gui_binast::free_memory {  } {

   array unset ::bdi_gui_binast::widget
   array unset ::bdi_gui_binast::ephem
   
}





#------------------------------------------------------------
## Bouton de developpement qui relance l application apres 
#  avoir ressource les scripts
#  @return void
proc ::bdi_gui_binast::recharge_appli { x } {

   ::bddimages::ressource
   ::console::clear
   ::bdi_gui_binast::fermer
   
   if {$x == 1} {
      gren_info "widget RAZ\n"
      ::bdi_gui_binast::free_memory
   }
   
   ::bdi_gui_binast::box  $::bdi_gui_binast::img_list
   return
}







#------------------------------------------------------------
## Fermeture de la fenetre de la GUI
#  @return void
proc ::bdi_gui_binast::fermer {  } {
   
   ::bdi_gui_binast::closetoconf
   ::bdi_gui_binast::recup_position

   cleanmark
   catch { destroy $::bdi_gui_binast::widget(fenetre,def_compos) }
   
   destroy $::bdi_gui_binast::fen
   ::bdi_gui_binast::free_memory


   return
}

#----------------------------------------------------------------------------
## Sauvegarde des variables de namespace
# Destruction de toutes les variables de l appli
# @return void
proc ::bdi_gui_binast::closetoconf {  } {

   global conf bddconf

   set conf(binast,def_author,list) $bddconf(binast,def_author,list)
   set conf(binast,def_author,selected) $::bdi_gui_binast::widget(def_author,selected)

   return
}







#------------------------------------------------------------
## Recuperation de la position d'affichage de la GUI
#  @return void
proc ::bdi_gui_binast::recup_position { } {

   global conf bddconf

   set bddconf(binast,geometry) [wm geometry $::bdi_gui_binast::fen]
   set conf(bddimages,binast,geometry) $bddconf(binast,geometry)
   return
}




#------------------------------------------------------------
## Charge toutes les donnees a partir des donnees d entree de l appli
#  les donnees d entree sont composees de la liste des images selectionnees
#  dans la GUI recherche
#
#  @return void
proc ::bdi_gui_binast::charge_list { img_list } {

   global audace
   global bddconf

   gren_info "Chargement...\n"

   catch {
      if { [ info exists $::bdi_tools_binast::img_list ] }           {unset ::bdi_tools_binast::img_list}
      if { [ info exists $::bdi_tools_binast::current_image ] }      {unset ::bdi_tools_binast::current_image}
      if { [ info exists $::bdi_tools_binast::current_image_name ] } {unset ::bdi_tools_binast::current_image_name}
   }
   
   set ::bdi_tools_binast::img_list    [::bddimages_imgcorrection::chrono_sort_img $img_list]
   set ::bdi_tools_binast::img_list    [::bddimages_liste_gui::add_info_cata_list $::bdi_tools_binast::img_list]
   set ::bdi_tools_binast::nb_img_list [llength $::bdi_tools_binast::img_list]

   set object ""
   set cpt 0
   set ::bdi_gui_binast::widget(data,dates) ""
   # Verification des images
   foreach ::bdi_tools_binast::current_image $::bdi_tools_binast::img_list {
      set idbddimg       [::bddimages_liste::lget $::bdi_tools_binast::current_image idbddimg]
      set tabkey         [::bddimages_liste::lget $::bdi_tools_binast::current_image "tabkey"]
      set date           [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1] ]
      set telescop       [string trim [lindex [::bddimages_liste::lget $tabkey "telescop"] 1] ]
      set iau_code       [string trim [lindex [::bddimages_liste::lget $tabkey "iau-code"] 1] ]
      set bddimages_wcs  [string trim [lindex [::bddimages_liste::lget $tabkey "bddimages_wcs"] 1]]
      set timesys        [string trim [lindex [::bddimages_liste::lget $tabkey "timesys"] 1]]
      set satured        [string trim [lindex [::bddimages_liste::lget $tabkey "satured"] 1]]
      set origin         [string trim [lindex [::bddimages_liste::lget $tabkey "origin"] 1]]
      set equinox        [string trim [lindex [::bddimages_liste::lget $tabkey "equinox"] 1]]
      set ctype1         [string trim [lindex [::bddimages_liste::lget $tabkey "ctype1"] 1]]
      set ctype2         [string trim [lindex [::bddimages_liste::lget $tabkey "ctype2"] 1]]
      
      set wcs  [expr [::bddimages_liste::lexist $tabkey "CD1_1"] && \
                     [::bddimages_liste::lexist $tabkey "CD1_2"] && \
                     [::bddimages_liste::lexist $tabkey "CD2_1"] && \
                     [::bddimages_liste::lexist $tabkey "CD2_2"] && \
                     [::bddimages_liste::lexist $tabkey "CDELT1"] && \
                     [::bddimages_liste::lexist $tabkey "CDELT2"] ]
      set bimtype    [string trim [lindex [::bddimages_liste::lget $tabkey "bimtype"] 1] ]
                     
                     
      lappend ::bdi_gui_binast::widget(data,dates) $date
      set ::bdi_gui_binast::widget(data,$date,telescop)  $telescop
      set ::bdi_gui_binast::widget(data,$date,iau_code)  $iau_code
      set ::bdi_gui_binast::widget(data,$date,status)    "Unknown"
      set ::bdi_gui_binast::widget(data,$date,satured)   $satured
      
      # Verif WCS
      if {$wcs != 1} {
         tk_messageBox -message "Toutes les images selectionnees doivent avoir le WCS inscrit dans leur header." -type ok
         return -code 1
      }
      set cdelt1  [string trim [lindex [::bddimages_liste::lget $tabkey "cdelt1"] 1]]
      set cdelt2  [string trim [lindex [::bddimages_liste::lget $tabkey "cdelt2"] 1]]
      set ::bdi_gui_binast::widget(data,$date,xscale) [expr $cdelt1 * 3600000.0]
      set ::bdi_gui_binast::widget(data,$date,yscale) [expr $cdelt2 * 3600000.0]

      # Verif object
      if { $object == ""} {
         set object [string trim [lindex [::bddimages_liste::lget $tabkey "object"]   1] ]
      } else {
         if { $object != [string trim [lindex [::bddimages_liste::lget $tabkey "object"]   1] ]} {
            set msg    "Vous devez selectionner des images pour un seul et meme systeme. "
            append msg "Si vous pensez l avoir fait, c est que le champ OBJECT est different sur certaines images."
            tk_messageBox -message $msg -type ok
            return -code 1
         }
      }

      # Table IMG
      switch $bimtype {
         "IMG"     { 
            set ::bdi_gui_binast::widget(data,listimg,$date,img) "x"
            set ::bdi_gui_binast::widget(data,$date,img,idimg) $cpt
         }
         "CORONO1" { 
            set ::bdi_gui_binast::widget(data,listimg,$date,c1)  "x"
            set ::bdi_gui_binast::widget(data,$date,c1,idimg) $cpt
         }
         "CORONO2" { 
            set ::bdi_gui_binast::widget(data,listimg,$date,c2)  "x"
            set ::bdi_gui_binast::widget(data,$date,c2,idimg) $cpt
         }
         "CORONO3" { 
            set ::bdi_gui_binast::widget(data,listimg,$date,c3)  "x"
            set ::bdi_gui_binast::widget(data,$date,c3,idimg) $cpt
         }
         default {  }
      }

      # Setup Frame
      switch $timesys {
         "UTC" - "TT" { 
            set ::bdi_gui_binast::widget(data,$date,timescale) $timesys
         }
         default {
            tk_messageBox -message "timescale = $timesys non defini, vous devez le renseigner dans la table" -type ok
         }
      }

      switch $origin {
         "KeckII" - "ESO-VLT"  { 
            set ::bdi_gui_binast::widget(data,$date,centerframe) "Topocentric"
         }
         "XXX" { 
            set ::bdi_gui_binast::widget(data,$date,centerframe) "Spacecraft"
         }
         default {
            tk_messageBox -message "centerframe = $origin non defini, vous devez le renseigner dans la table" -type ok
         }
      }

      switch $equinox {
         "2000"  { 
            set ::bdi_gui_binast::widget(data,$date,typeframe) "Astrometrique J2000"
         }
         default {
            tk_messageBox -message "typeframe = $equinox non defini, vous devez le renseigner dans la table" -type ok
         }
      }

      
      set l1 [split $ctype1 "-"]
      set l2 [split $ctype2 "-"]
      set c1 [lindex $l1 end]
      set c2 [lindex $l2 end]
      if {$c1 == "TAN" && $c2 == "TAN"} { 
         set ::bdi_gui_binast::widget(data,$date,coordtype) "Spherical"
      } else {
         tk_messageBox -message "coordtype = $c1,$c2 non defini, vous devez le renseigner dans la table" -type ok
      }
      
      set r1 [lindex $l1 0]
      set r2 [lindex $l2 0]
      if {$r1 == "RA" && $r2 == "DEC"} { 
         set ::bdi_gui_binast::widget(data,$date,refframe) "Equateur"
      } else {
         tk_messageBox -message "refframe = $r1,$r2 non defini, vous devez le renseigner dans la table" -type ok
      }
      
 


      incr cpt
   }
   
   gren_info "Nb d images chargees : $cpt\n"

   # table de donnees
   set ::bdi_gui_binast::widget(data,dates)   [lsort -uniq -increasing $::bdi_gui_binast::widget(data,dates)]
   set ::bdi_gui_binast::widget(data,nbdates) [llength $::bdi_gui_binast::widget(data,dates)]

   # Objet selectionne
   gren_info "object : $object\n"
   set r [split $object "_"]
   set id [lindex $r 0]
   set cpt 0
   foreach s $r {
      incr cpt
      if {$cpt <=1 } {continue}
      if {$cpt ==2 } {
         set name $s
      } else {
         append name "_$s"
      }
   }
   set ::bdi_gui_binast::widget(system,idname) "($id) $name"
   set ::bdi_gui_binast::widget(system,id)     $id
   set ::bdi_gui_binast::widget(system,name)   $name

   # Importation des cata



   # Chargement des variables
   set ::bdi_tools_binast::id_current_image 1
   ::bdi_gui_binast::charge_current_image
   
   
   
   return
}










#------------------------------------------------------------
## Chargement des donnees dans toutes les table MESURES 
#  @return void
proc ::bdi_gui_binast::box_table_charge { } {
   
   
   # On efface les donnees de la table si elles existent
   $::bdi_gui_binast::widget(table,listimg) delete 0 end
   $::bdi_gui_binast::widget(table,listcmp) delete 0 end
   $::bdi_gui_binast::widget(table,listref) delete 0 end
   $::bdi_gui_binast::widget(table,listsfr) delete 0 end
   $::bdi_gui_binast::widget(table,listinf) delete 0 end
   
   foreach date $::bdi_gui_binast::widget(data,dates) {

      # Table Images
      set rowimg [list $date $::bdi_gui_binast::widget(data,$date,telescop) $::bdi_gui_binast::widget(data,$date,status)]
      foreach type [list "img" "c1" "c2" "c3"]  {
         if {! [info exists ::bdi_gui_binast::widget(data,listimg,$date,$type)]} {
            set ::bdi_gui_binast::widget(data,listimg,$date,$type) ""
         }
         lappend rowimg $::bdi_gui_binast::widget(data,listimg,$date,$type)
      }

      # Autres Tables
      set rowcmp [list $date $::bdi_gui_binast::widget(data,$date,telescop)]
      set rowmes [list $date $::bdi_gui_binast::widget(data,$date,telescop)]
      set rowref [list $date $::bdi_gui_binast::widget(data,$date,telescop)]
      set rowsfr [list $date $::bdi_gui_binast::widget(data,$date,telescop)]

      foreach compo $::bdi_gui_binast::widget(table,compos,list)  {

         # Compos
         if {! [info exists ::bdi_gui_binast::widget(data,listcmp,$date,$compo)]} {
            set ::bdi_gui_binast::widget(data,listcmp,$date,$compo) ""
         }
         lappend rowcmp $::bdi_gui_binast::widget(data,listcmp,$date,$compo)

         # References
         if {! [info exists ::bdi_gui_binast::widget(data,listref,$date,$compo)]} {
            set ::bdi_gui_binast::widget(data,listref,$date,$compo) ""
         }
         lappend rowref $::bdi_gui_binast::widget(data,listref,$date,$compo)

      }
      
      # Setup Frame
      foreach field [list "timescale" "centerframe" "typeframe" "coordtype" "refframe" ] {
         if {[ info exists ::bdi_gui_binast::widget(data,$date,$field) ]} {lappend rowsfr $::bdi_gui_binast::widget(data,$date,$field)} else {lappend rowsfr "" }
      }

      # on insere les donnees
      $::bdi_gui_binast::widget(table,listimg) insert end $rowimg
      $::bdi_gui_binast::widget(table,listcmp) insert end $rowcmp
      $::bdi_gui_binast::widget(table,listref) insert end $rowref
      $::bdi_gui_binast::widget(table,listsfr) insert end $rowsfr


      # on insere les donnees de la table info
      foreach compo $::bdi_gui_binast::widget(table,compos,list)  {
         set author  ""
         set when    ""
         set bibitem ""
         set quality ""
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)] } {set quality $::bdi_gui_binast::widget(data,$date,$compo,mesure,quality) }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,author) ] } {set author  $::bdi_gui_binast::widget(data,$date,$compo,mesure,author)  }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,when)   ] } {set when    $::bdi_gui_binast::widget(data,$date,$compo,mesure,when)    }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,bibitem)] } {set bibitem $::bdi_gui_binast::widget(data,$date,$compo,mesure,bibitem) }
         
         set rowinf [list $date $::bdi_gui_binast::widget(data,$date,telescop) $compo $quality $author $when $bibitem]
         $::bdi_gui_binast::widget(table,listinf) insert end $rowinf
      }
   }
   
   return
}

































# Obsolete


proc ::bdi_gui_binast::set_nb_system {  } {

   set ::bdi_tools_binast::nb_obj 2
}





proc ::bdi_gui_binast::change_nbobject { sources } {

   gren_info "nb object = $::bdi_tools_binast::nb_obj \n"
   gren_info "nb save = $::bdi_tools_binast::nb_obj_sav \n"

   if {$::bdi_tools_binast::nb_obj == 1 && $::bdi_tools_binast::nb_obj_sav == 1} {
      set ::bdi_tools_binast::nb_obj $::bdi_tools_binast::nb_obj_sav
      return
   }


   if {$::bdi_tools_binast::nb_obj<$::bdi_tools_binast::nb_obj_sav} {

      set x $::bdi_tools_binast::nb_obj_sav

      destroy $sources.name.obj$x   
      destroy $sources.id.obj$x     
      destroy $sources.ra.obj$x     
      destroy $sources.dec.obj$x    
      destroy $sources.xobs.obj$x    
      destroy $sources.yobs.obj$x    
      destroy $sources.xcalc.obj$x    
      destroy $sources.ycalc.obj$x    
      destroy $sources.xomc.obj$x    
      destroy $sources.yomc.obj$x    
      destroy $sources.mag.obj$x    
      destroy $sources.stdev.obj$x 
      destroy $sources.delta.obj$x  
      destroy $sources.select.obj$x 
      destroy $sources.miriade.obj$x 

   } else {

      set x $::bdi_tools_binast::nb_obj

      label   $sources.name.obj$x -text "Obj$x :"
      entry   $sources.id.obj$x   -relief sunken -width 11
      entry   $sources.ra.obj$x   -relief sunken -width 11
      entry   $sources.dec.obj$x  -relief sunken -width 11
      entry   $sources.xobs.obj$x  -relief sunken -width 11
      entry   $sources.yobs.obj$x  -relief sunken -width 11
      entry   $sources.xcalc.obj$x  -relief sunken -width 11
      entry   $sources.ycalc.obj$x  -relief sunken -width 11
      entry   $sources.xomc.obj$x  -relief sunken -width 11
      entry   $sources.yomc.obj$x  -relief sunken -width 11
      label   $sources.mag.obj$x  -width 9
      label   $sources.stdev.obj$x -width 9 
      spinbox $sources.delta.obj$x -from 1 -to 100 -increment 1 -command "" -width 3 \
                -command "::bdi_gui_binast::mesure_tout $sources" \
                -textvariable ::bdi_tools_binast::tabsource(obj$x,delta)
      button  $sources.select.obj$x -text "Select" -command "::bdi_gui_binast::select_source $sources obj$x"
      button $sources.miriade.obj$x -text "Miriade" -command "::bdi_gui_binast::miriade_obj $sources obj$x"

      pack $sources.name.obj$x    -in $sources.name   -side top -pady 2 -ipady 2
      pack $sources.id.obj$x      -in $sources.id     -side top -pady 2 -ipady 2
      pack $sources.ra.obj$x      -in $sources.ra     -side top -pady 2 -ipady 2
      pack $sources.dec.obj$x     -in $sources.dec    -side top -pady 2 -ipady 2
      pack $sources.xobs.obj$x     -in $sources.xobs    -side top -pady 2 -ipady 2
      pack $sources.yobs.obj$x     -in $sources.yobs    -side top -pady 2 -ipady 2
      pack $sources.xcalc.obj$x     -in $sources.xcalc    -side top -pady 2 -ipady 2
      pack $sources.ycalc.obj$x     -in $sources.ycalc    -side top -pady 2 -ipady 2
      pack $sources.xomc.obj$x     -in $sources.xomc    -side top -pady 2 -ipady 2
      pack $sources.yomc.obj$x     -in $sources.yomc    -side top -pady 2 -ipady 2
      pack $sources.mag.obj$x     -in $sources.mag    -side top -pady 2 -ipady 2
      pack $sources.stdev.obj$x   -in $sources.stdev  -side top -pady 2 -ipady 2
      pack $sources.delta.obj$x   -in $sources.delta  -side top -pady 2 -ipady 2
      pack $sources.select.obj$x  -in $sources.select -side top 
      pack $sources.miriade.obj$x -in $sources.miriade -side top    

      set ::bdi_tools_binast::tabsource(obj$x,delta) 15

      set system [string trim [$sources.id.obj1 get ] ]
      set idobj [expr $::bdi_tools_binast::nb_obj-1]
      $sources.id.obj$x configure 
      $sources.id.obj$x delete 0 end 
      $sources.id.obj$x insert end "${system}/${idobj}"
   }

   set ::bdi_tools_binast::nb_obj_sav $::bdi_tools_binast::nb_obj
   return

}




proc ::bdi_gui_binast::good_sexa { d m s prec } {

   set d [expr int($d)]
   set m [expr int($m)]
   set sa [expr int($s)]
   if {$prec==0} {
      return [format "%02d:%02d:%02d" $d $m $sa]
   }
   set ms [expr int(($s - $sa) * pow(10,$prec))]
   return [format "%02d:%02d:%02d.%0${prec}d" $d $m $sa $ms]
}   





proc ::bdi_gui_binast::miriade_obj { sources obj  } {

   set jd $::bdi_tools_binast::current_image_jjdate
   set ::bdi_tools_binast::observer_pos "@-48"
   set ::bdi_tools_binast::observer_pos "@HST"
   #set ::bdi_tools_binast::observer_pos "500"
   #gren_info "observer_pos=$::bdi_tools_binast::observer_pos\n"

   set miriade_obj [$sources.id.$obj get ]
   #gren_info "miriade_obj=$miriade_obj\n"

   # teph 1 = astromJ2000
   # teph 2 = apparent
   # teph 3 = moyen date
   # teph 3 = moyen J2000
   set teph  1

   # tcoor 
   # 1: spheriques, 2: rectangulaires,                   !
   # 3: locales,    4: horaires,                         !
   # 5: dediees a l'observation,                         !
   # 6: dediees a l'observation AO,                      !
   # 7: dediees au calcul (rep. helio. moyen J2000)      !
   set tcoor  1
   
   # rplane
   # 1: equateur, 2:ecliptique  
   set rplane 1


   set cmd1 "vo_miriade_ephemcc \"$miriade_obj\" \"\" $jd 1 \"1d\" \"UTC\" \"$::bdi_tools_binast::observer_pos\" \"INPOP\" $teph $tcoor $rplane \"text\" \"--jd\" 0"
   #::console::affiche_resultat "CMD MIRIADE=$cmd1\n"
   set textraw1 [vo_miriade_ephemcc "$miriade_obj" "" $jd 1 "1d" "UTC" "$::bdi_tools_binast::observer_pos" "INPOP" $teph $tcoor $rplane "text" "--jd" 0]
   set text1 [split $textraw1 ";"]
   set nbl [llength $text1]
   if {$nbl == 1} {
      set res [tk_messageBox -message "L'appel aux ephemerides a echouer.\nVerifier le nom de l'objet.\nLa commande s'affiche dans la console" -type ok]
      ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
      return      
   }

   # Sauvegarde des fichiers intermediaires
   set file "miriade.1"
   set chan [open $file w]
   foreach line $text1 {
      ::console::affiche_resultat "MIRIADE=$line\n"
      puts $chan $line
   }

   # Recupere la position de l'observateur
   foreach t $text1 {
      if { [regexp {.*(\d+) h +(\d+) m +(\d+)\.(\d+) s (.+?).* (\d+) d +(\d+) ' +(\d+)\.(\d+) " +(.+?).* ([-+]?\d*\.?\d*) m.*} $t str loh lom los loms lowe lad lam las lams lans alt] } {
         # "
         set ::bdi_tools_binast::longitude [format "%s %02d %02d %02d.%03d" $lowe $loh $lom $los $loms ]
         set ::bdi_tools_binast::latitude  [format "%s %02d %02d %02d.%03d" $lans $lad $lam $las $lams ]
         set ::bdi_tools_binast::altitude  $alt
         gren_info "Position=$::bdi_tools_binast::longitude $::bdi_tools_binast::latitude $::bdi_tools_binast::altitude m\n"
      }      
   }

   # Maj du nom de l asteroide      
   set ast [lindex $text1 2]
   if {$ast != ""} {
      gren_info "AST=$ast\n"
   } else {
      set res [tk_messageBox -message "Le nom de l'objet n'est pas reconnu par Miriade.\nLe resultat de la commande s'affiche dans la console" -type ok]
      ::console::affiche_erreur "CMD MIRIADE=$cmd1\n"
      set cpt 0
      foreach line $text1 {
         ::console::affiche_erreur "($cpt)=$line\n"
         incr cpt
      }
      return               
   }

   # Interpretation appel format num 1
   set cpt 0
   foreach line $text1 {
      set char [string index [string trim $line] 0]
      #::console::affiche_resultat "ephemcc 1 ($cpt) ($char)=$line\n"
      if {$char!="#"} { break }
      incr cpt
   }
   #::console::affiche_resultat "cptdata = $cpt\n"
   # on split la la ligne pour retrouver les valeurs
   set line [lindex $text1 $cpt]
   regsub -all -- {[[:space:]]+} $line " " line
   set line [split $line]
   set cpt 0
   foreach s_el $line {
      ::console::affiche_resultat  "($cpt) $s_el\n"
      incr cpt
   }

   # on affecte les varaibles
   set ::bdi_tools_binast::rajapp   [::bdi_gui_binast::good_sexa [lindex $line  2] [lindex $line  3] [lindex $line  4] 2]
   set ::bdi_tools_binast::decapp   [::bdi_gui_binast::good_sexa [lindex $line  5] [lindex $line  6] [lindex $line  7] 2]
   set ::bdi_tools_binast::dist     [format "%.5f" [lindex $line 8]]
   set ::bdi_tools_binast::magv     [lindex $line 9]
   set ::bdi_tools_binast::phase    [lindex $line 10]
   set ::bdi_tools_binast::elong    [lindex $line 11]
   set ::bdi_tools_binast::dracosd  [format "%.5f" [expr [lindex $line 12] * 60. ] ]
   set ::bdi_tools_binast::ddec     [format "%.5f" [expr [lindex $line 13] * 60. ] ]
   set ::bdi_tools_binast::vn       [lindex $line 14]
   set ::bdi_tools_binast::dx       0
   set ::bdi_tools_binast::dy       0

   set ra  [ expr  [mc_angle2deg $::bdi_tools_binast::rajapp ] * 15.0 ]
   set dec [ expr  [mc_angle2deg $::bdi_tools_binast::decapp ] ]
   affich_un_rond  $ra $dec green 3
   #gren_info "affich_un_rond  $ra $dec green 2"


   catch {
      set ::bdi_tools_binast::dx       [lindex $line 15]
      set ::bdi_tools_binast::dy       [lindex $line 16]

      set ra  [ expr $ra  + $::bdi_tools_binast::dx / 3600.0 ]
      set dec [ expr $dec + $::bdi_tools_binast::dy / 3600.0 ]
      affich_un_rond  $ra $dec yellow 2
      #gren_info "affich_un_rond  $ra $dec yellow 2"
   }

   $sources.xcalc.$obj configure 
   $sources.xcalc.$obj delete 0 end 
   $sources.xcalc.$obj insert end [format "%.4f" $::bdi_tools_binast::dx ]
   set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,xcalc) [format "%.4f" $::bdi_tools_binast::dx ]
   $sources.ycalc.$obj configure 
   $sources.ycalc.$obj delete 0 end 
   $sources.ycalc.$obj insert end [format "%.4f" $::bdi_tools_binast::dy ]
   set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,ycalc) [format "%.4f" $::bdi_tools_binast::dy ]

   set xcalc  [$sources.xcalc.$obj get]
   set ycalc  [$sources.ycalc.$obj get]
   set xobs   [$sources.xobs.$obj get]
   set yobs   [$sources.yobs.$obj get]
   gren_info "set  xcalc  $xcalc\n"
   gren_info "set  ycalc  $ycalc\n"
   gren_info "set  xobs   $xobs \n"
   gren_info "set  yobs   $yobs \n"

   if {$xcalc!="" && $ycalc!="" && $xobs!="" && $yobs!="" } {
      gren_info "OK\n"
      set xomc [expr $xobs - $xcalc ]
      $sources.xomc.$obj configure 
      $sources.xomc.$obj delete 0 end 
      $sources.xomc.$obj insert end [format "%.4f" $xomc ]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,xomc) [format "%.4f" $xomc ]
      set yomc [expr $yobs - $ycalc ]
      $sources.yomc.$obj configure 
      $sources.yomc.$obj delete 0 end 
      $sources.yomc.$obj insert end [format "%.4f" $yomc ]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,yomc) [format "%.4f" $yomc ]
   }

   # si tout c est bien passé
   set ::bdi_gui_binast::check_system "Checked"

   # si erreur
   set ::bdi_gui_binast::check_system "Erreur"


   # EN DUR
   set ::bdi_gui_binast::check_system "Checked"

   return ::bdi_tools_binast::nb_obj

}




proc ::bdi_gui_binast::select_source { sources obj } {
  
   gren_info "obj = $obj \n"
   gren_info "delta = $::bdi_tools_binast::tabsource($obj,delta) \n"


   if {[ $sources.select.$obj cget -relief] == "raised"} {

     set err [ catch {set rect  [ ::confVisu::getBox $::audace(visuNo) ]} msg ]
     #buf$::audace(bufNo)
     if {$err>0 || $rect ==""} {
        ::console::affiche_erreur "$msg\n"
        ::console::affiche_erreur "      * * * *\n"
        ::console::affiche_erreur "Selectionnez un cadre dans l'image\n"
        ::console::affiche_erreur "      * * * *\n"
       
        return
     }
     set err [ catch {set valeurs [::tools_cdl::select_obj $rect $::audace(bufNo)]} msg ]
     if {$err>0} {
        ::console::affiche_erreur "$msg\n"
        ::console::affiche_erreur "      * * * *\n"
        ::console::affiche_erreur "Mesure Photometrique impossible\n"
        ::console::affiche_erreur "      * * * *\n"
        return
     }

     
     set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,x) [lindex $valeurs 0]
     set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,y) [lindex $valeurs 1]
     set ::bdi_tools_binast::tabsource($obj,select) true
     #$sources.select.$obj  configure -relief sunken

   } else {
     $sources.select.$obj  configure -relief raised
     set ::bdi_tools_binast::tabsource($obj,select) false
   }

   ::bdi_gui_binast::mesure_tout $sources
    ::bdi_gui_binast::calcul_obs $sources $obj

}










proc ::bdi_gui_binast::calcul_obs { sources obj } {

   set rap  [$sources.ra.obj1 get]
   set decp [$sources.dec.obj1 get]
   set ras  [$sources.ra.$obj get]
   set decs [$sources.dec.$obj get]
   #gren_info "set rap    $rap\n"
   #gren_info "set decp   $decp\n"
   #gren_info "set ras    $ras\n"
   #gren_info "set decs   $decs\n"

   if {$rap!="" && $decp!="" && $ras!="" && $decs!="" } {
      #gren_info "OK\n"
      set dra [expr ([mc_angle2deg $ras ] * 15.0 - [mc_angle2deg $rap ] * 15.0 ) * 3600.0 * cos ( [mc_angle2rad $decp ] )]
      $sources.xobs.$obj configure 
      $sources.xobs.$obj delete 0 end 
      $sources.xobs.$obj insert end [format "%.4f" $dra ]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,xobs) [format "%.4f" $dra ]
      set ddec [expr ([mc_angle2deg $decs ] - [mc_angle2deg $decp ]) * 3600.0]
      $sources.yobs.$obj configure 
      $sources.yobs.$obj delete 0 end 
      $sources.yobs.$obj insert end [format "%.4f" $ddec ]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,yobs) [format "%.4f" $ddec ]
   }
   
   return
}





proc ::bdi_gui_binast::enregistre { sources } {
   
   set id_obj 2
   set miriade_obj [$sources.id.obj$id_obj get ]

   set fileres "obs-$id_obj.xml"
   set filecsv "obs-$id_obj.csv"

   set chan0 [open $fileres w]
   set chan1 [open $filecsv w]

   puts $chan0 "# MIRIADE NAME = $miriade_obj"
   puts $chan1 "# MIRIADE NAME = $miriade_obj"
   
   puts $chan1 "isodate,jjdate,system,xobs,yobs,xcalc,ycalc,xomc,yomc,obsuai"

   for {set i 1} {$i <= $::bdi_tools_binast::nb_img_list} {incr i} {

      if {![info exists ::bdi_tools_binast::tabphotom($i,obj$id_obj,jjdate)]} {
         continue
      }
      if {![info exists ::bdi_tools_binast::tabphotom($i,obj$id_obj,xobs)]} {
         continue
      }

      set jjdate  $::bdi_tools_binast::tabphotom($i,obj$id_obj,jjdate)
      set isodate $::bdi_tools_binast::tabphotom($i,obj$id_obj,isodate)
      set system      [ $sources.id.obj1 get ]
      set xobs    $::bdi_tools_binast::tabphotom($i,obj$id_obj,xobs)
      set yobs    $::bdi_tools_binast::tabphotom($i,obj$id_obj,yobs)
      set xcalc   $::bdi_tools_binast::tabphotom($i,obj$id_obj,xcalc)
      set ycalc   $::bdi_tools_binast::tabphotom($i,obj$id_obj,ycalc)
      set xomc    $::bdi_tools_binast::tabphotom($i,obj$id_obj,xomc)
      set yomc    $::bdi_tools_binast::tabphotom($i,obj$id_obj,yomc)
      set timescale   "UTC"

      # centerframe = icent dans genoide/eproc
      # centerframe 1 = helio
      # centerframe 2 = geo
      # centerframe 3 = topo
      # centerframe 4 = sonde
      set centerframe 4


      # typeframe = iteph dans genoide/eproc
      # typeframe 1 = astromj2000
      # typeframe 2 = apparent
      # typeframe 3 = moyen date
      # typeframe 4 = moyen J2000
      set typeframe   1

      # coordtype = itrep dans genoide/eproc
      # 1: spheriques, 2: rectangulaires,                   !
      # 3: locales,    4: horaires,                         !
      # 5: dediees a l'observation,                         !
      # 6: dediees a l'observation AO,                      !
      # 7: dediees au calcul (rep. helio. moyen J2000)      !
      set coordtype   1

      # refframe =  ipref dans genoide/eproc
      # 1: equateur, 2:ecliptique  
      set refframe    1

      set obsuai      "@HST"


      puts $chan0 "<vot:TR>"
      puts $chan0 "<vot:TD>$jjdate</vot:TD>"
      puts $chan0 "<vot:TD>$isodate</vot:TD>"
      puts $chan0 "<vot:TD>$system</vot:TD>"
      puts $chan0 "<vot:TD>$xobs</vot:TD>"
      puts $chan0 "<vot:TD>$yobs</vot:TD>"
      puts $chan0 "<vot:TD>$xcalc</vot:TD>"
      puts $chan0 "<vot:TD>$ycalc</vot:TD>"
      puts $chan0 "<vot:TD>$xomc</vot:TD>"
      puts $chan0 "<vot:TD>$yomc</vot:TD>"
      puts $chan0 "<vot:TD>$timescale</vot:TD>"
      puts $chan0 "<vot:TD>$centerframe</vot:TD>"
      puts $chan0 "<vot:TD>$typeframe</vot:TD>"
      puts $chan0 "<vot:TD>$coordtype</vot:TD>"
      puts $chan0 "<vot:TD>$refframe</vot:TD>"
      puts $chan0 "<vot:TD>$obsuai</vot:TD>"
      puts $chan0 "</vot:TR>"
      puts $chan0 ""

      puts $chan1 "$isodate,$jjdate,$system,$xobs,$yobs,$xcalc,$ycalc,$xomc,$yomc,$obsuai"


   }
   
   close $chan0
   close $chan1

}



 
proc ::bdi_gui_binast::mesure_tout { sources } {

   cleanmark
   gren_info "ZOOM: [::confVisu::getZoom $::audace(visuNo)] \n "

   for {set x 1} {$x<=$::bdi_tools_binast::nb_obj} {incr x} {
         ::bdi_gui_binast::mesure_une $sources obj$x
   }

   return 0

}
   


   
proc ::bdi_gui_binast::mesure_une { sources obj } {

   set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,err) false
   set err [ catch {set valeurs [::tools_cdl::mesure_obj \
            $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,x) \
            $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,y) \
            $::bdi_tools_binast::tabsource($obj,delta) $::audace(bufNo)]} msg ]
   if {$err} {
      gren_info "PHOTOM ERR $err : $msg \n "
      return
   } else {
      gren_info "PHOTOM $obj : $valeurs \n "
   }
   
   if { $valeurs == -1 } {
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,err) true
      $sources.ra.$obj configure -bg red
      $sources.dec.$obj configure -bg red
      return
   } else {

      $sources.ra.$obj configure -bg "#ffffff"
      $sources.dec.$obj configure -bg "#ffffff"

      set xsm      [lindex $valeurs 0]
      set ysm      [lindex $valeurs 1]

      set a [buf$::audace(bufNo) xy2radec [list $xsm $ysm]]
      set ra_deg  [lindex $a 0]
      set dec_deg [lindex $a 1]
      set ra_hms  [mc_angle2hms $ra_deg 360 zero 3 auto string]
      set dec_dms [mc_angle2dms $dec_deg 90 zero 3 + string]
      set ra_hms  [string map {h : m : s .} $ra_hms]
      set dec_dms [string map {d : m : s .} $dec_dms]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,x)           $xsm
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,y)           $ysm
      
      affich_un_rond_xy  $xsm $ysm blue [expr int($::bdi_tools_binast::tabsource($obj,delta))] 1
      
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,ra_deg)      $ra_deg
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,dec_deg)     $dec_deg
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,ra_hms)      $ra_hms
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,dec_dms)     $dec_dms

      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,fwhmx)       [lindex $valeurs 2]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,fwhmy)       [lindex $valeurs 3]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,fwhm)        [lindex $valeurs 4]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,fluxintegre) [lindex $valeurs 5]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,errflux)     [lindex $valeurs 6]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,pixmax)      [lindex $valeurs 7]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,intensite)   [lindex $valeurs 8]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,sigmafond)   [lindex $valeurs 9]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,snint)       [lindex $valeurs 10]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,snpx)        [lindex $valeurs 11]
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,delta)       [lindex $valeurs 12]
      
      set err [ catch {set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,maginstru)   [expr -log10([lindex $valeurs 5]/20000.)*2.5] } msg ]
      if {$err} {::console::affiche_erreur "Calcul mag_instru $err $msg $obj : $valeurs\n"}
      
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,jjdate)      $::bdi_tools_binast::current_image_jjdate
      set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,isodate)     $::bdi_tools_binast::current_image_date


      if { [lindex $valeurs 7] > $::bdi_tools_binast::saturation} {

         set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,err) true
         set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,saturation) true
         set mesure "bad"

      } else {

         set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,$obj,saturation) false


         $sources.ra.$obj   delete 0 end 
         $sources.ra.$obj   insert end $ra_hms
         $sources.dec.$obj  delete 0 end 
         $sources.dec.$obj  insert end $dec_dms
         $sources.mag.$obj  configure -bg "#ece9d8"

      }

   }

}




proc ::bdi_gui_binast::next { sources } {

      set cpt 0
      
      while {$cpt<$::bdi_gui_binast::block} {
      
         if {$::bdi_tools_binast::id_current_image < $::bdi_tools_binast::nb_img_list} {
            incr ::bdi_tools_binast::id_current_image
            ::bdi_gui_binast::charge_current_image
            
            for {set x 1} {$x<=$::bdi_tools_binast::nb_obj} {incr x} {
               if {![info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,x)]} {
                  set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,x) $::bdi_tools_binast::tabphotom([expr $::bdi_tools_binast::id_current_image -1],obj$x,x)
                  set ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,y) $::bdi_tools_binast::tabphotom([expr $::bdi_tools_binast::id_current_image -1],obj$x,y)
               }
            }
            
            # Mesures des photocentres
            set err [::bdi_gui_binast::mesure_tout $sources]
            if {$err==1 && $::bdi_tools_binast::stoperreur==1} {
               break
            }
            
            # Calcul des Obs differentielles
            for {set x 2} {$x<=$::bdi_tools_binast::nb_obj} {incr x} {
               ::bdi_gui_binast::calcul_obs $sources obj$x
               ::bdi_gui_binast::miriade_obj $sources obj$x
            }
            
            
            
         }
         incr cpt
      }
}
   




proc ::bdi_gui_binast::back { sources } {

      if {$::bdi_tools_binast::id_current_image > 1 } {
         incr ::bdi_tools_binast::id_current_image -1
         ::bdi_gui_binast::charge_current_image
         ::bdi_gui_binast::mesure_tout $sources
      }
}





proc ::bdi_gui_binast::charge_current_image { } {

   global audace
   global bddconf

      gren_info "Charge Image id: $::bdi_tools_binast::id_current_image  \n"

      #ï¿½Charge l image en memoire
      set ::bdi_tools_binast::current_image [lindex $::bdi_tools_binast::img_list [expr $::bdi_tools_binast::id_current_image - 1] ]
      set tabkey      [::bddimages_liste::lget $::bdi_tools_binast::current_image "tabkey"]
      set date        [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"]   1] ]
      set exposure    [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"]   1] ]

      set idbddimg    [::bddimages_liste::lget $::bdi_tools_binast::current_image idbddimg]
      set dirfilename [::bddimages_liste::lget $::bdi_tools_binast::current_image dirfilename]
      set filename    [::bddimages_liste::lget $::bdi_tools_binast::current_image filename   ]
      set file        [file join $bddconf(dirbase) $dirfilename $filename]
      set ::bdi_tools_binast::current_image_name $filename
      set ::bdi_tools_binast::current_image_jjdate [expr [mc_date2jd $date] + $exposure / 86400.0 / 2.0]
      set ::bdi_tools_binast::current_image_date [mc_date2iso8601 $::bdi_tools_binast::current_image_jjdate]

      gren_info "\nCharge Image cur: $date  ($exposure)\n"
      #gren_info "Charge Image cur: $::tools_cdl::current_image_date ($::tools_cdl::current_image_jjdate) \n"
      
      #ï¿½Charge l image
      buf$::audace(bufNo) load $file
      cleanmark
    
      # EFFECTUE UNCOSMIC
      if {$::bdi_tools_binast::uncosm == 1} {
         ::tools_cdl::myuncosmic $::audace(bufNo)
      }
      
      # VIsualisation par Sseuil automatique
      ::audace::autovisu $::audace(visuNo)
       
      catch {
       
         #ï¿½Mise a jour GUI
         $::bdi_gui_binast::fen.frm_cdlwcs.bouton.back configure -state disabled
         $::bdi_gui_binast::fen.frm_cdlwcs.bouton.back configure -state disabled
         $::bdi_gui_binast::fen.frm_cdlwcs.infoimage.nomimage    configure -text $::bdi_tools_binast::current_image_name
         $::bdi_gui_binast::fen.frm_cdlwcs.infoimage.dateimage   configure -text $::bdi_tools_binast::current_image_date
         $::bdi_gui_binast::fen.frm_cdlwcs.infoimage.stimage     configure -text "$::bdi_tools_binast::id_current_image / $::bdi_tools_binast::nb_img_list"

         gren_info " $::bdi_tools_binast::current_image_name \n"

         if {$::bdi_tools_binast::id_current_image == 1 && $::bdi_tools_binast::nb_img_list > 1 } {
            $::bdi_gui_binast::fen.frm_cdlwcs.bouton.back configure -state disabled
         }
         if {$::bdi_tools_binast::id_current_image == $::bdi_tools_binast::nb_img_list && $::bdi_tools_binast::nb_img_list > 1 } {
            $::bdi_gui_binast::fen.frm_cdlwcs.bouton.next configure -state disabled
         }
         if {$::bdi_tools_binast::id_current_image > 1 } {
            $::bdi_gui_binast::fen.frm_cdlwcs.bouton.back configure -state normal
         }
         if {$::bdi_tools_binast::id_current_image < $::bdi_tools_binast::nb_img_list } {
            $::bdi_gui_binast::fen.frm_cdlwcs.bouton.next configure -state normal
         }
      
         set sources $::bdi_gui_binast::fen.frm_cdlwcs.sources
         for {set x 1} {$x<=$::bdi_tools_binast::nb_obj} {incr x} {

            $sources.ra.obj$x delete 0 end 
            $sources.dec.obj$x delete 0 end 
            $sources.xobs.obj$x delete 0 end 
            $sources.yobs.obj$x delete 0 end 
            $sources.xcalc.obj$x delete 0 end 
            $sources.ycalc.obj$x delete 0 end 
            $sources.xomc.obj$x delete 0 end 
            $sources.yomc.obj$x delete 0 end 

            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,ra_hms)]} {
               $sources.ra.obj$x configure 
               $sources.ra.obj$x   delete 0 end 
               $sources.ra.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,ra_hms)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,dec_hms)]} {
               $sources.dec.obj$x configure 
               $sources.dec.obj$x   delete 0 end 
               $sources.dec.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,dec_hms)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xobs)]} {
               $sources.xobs.obj$x configure 
               $sources.xobs.obj$x   delete 0 end 
               $sources.xobs.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xobs)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,yobs)]} {
               $sources.yobs.obj$x configure 
               $sources.yobs.obj$x   delete 0 end 
               $sources.yobs.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,yobs)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xomc)]} {
               $sources.xomc.obj$x configure 
               $sources.xomc.obj$x   delete 0 end 
               $sources.xomc.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xomc)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,yomc)]} {
               $sources.yomc.obj$x configure 
               $sources.yomc.obj$x   delete 0 end 
               $sources.yomc.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,yomc)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xcalc)]} {
               $sources.xcalc.obj$x configure 
               $sources.xcalc.obj$x   delete 0 end 
               $sources.xcalc.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,xcalc)
            }
            if {[info exists ::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,ycalc)]} {
               $sources.ycalc.obj$x configure 
               $sources.ycalc.obj$x   delete 0 end 
               $sources.ycalc.obj$x   insert end $::bdi_tools_binast::tabphotom($::bdi_tools_binast::id_current_image,obj$x,ycalc)
            }

         }
      }
      
      
   
}



proc ::bdi_gui_binast::stat_mag2 { sources } {

   set id_obj 2

   set fileres "obs-moy-$id_obj.xml"
   
   set chan0 [open $fileres w]

   set jjdate  ""
   set xobs    ""
   set yobs    ""

   for {set i 1} {$i <= $::bdi_tools_binast::nb_img_list} {incr i} {

      if {![info exists ::bdi_tools_binast::tabphotom($i,obj$id_obj,jjdate)]} {
         continue
      }
      if {![info exists ::bdi_tools_binast::tabphotom($i,obj$id_obj,xobs)]} {
         continue
      }

      lappend jjdate  $::bdi_tools_binast::tabphotom($i,obj$id_obj,jjdate)
      lappend xobs    $::bdi_tools_binast::tabphotom($i,obj$id_obj,xobs)
      lappend yobs    $::bdi_tools_binast::tabphotom($i,obj$id_obj,yobs)
   }

   set jjdate  [::math::statistics::mean $jjdate]
   set xobs    [::math::statistics::mean $xobs]
   set yobs    [::math::statistics::mean $yobs]

   set system      [ $sources.id.obj1 get ]
   set isodate [mc_date2iso8601 $jjdate]
   set xcalc   0
   set ycalc   0
   set xomc    0
   set yomc    0
   set timescale "UTC"

   # centerframe = icent dans genoide/eproc
   # centerframe 1 = helio
   # centerframe 2 = geo
   # centerframe 3 = topo
   # centerframe 4 = sonde
   set centerframe 4


   # typeframe = iteph dans genoide/eproc
   # typeframe 1 = astromj2000
   # typeframe 2 = apparent
   # typeframe 3 = moyen date
   # typeframe 4 = moyen J2000
   set typeframe   1

   # coordtype = itrep dans genoide/eproc
   # 1: spheriques, 2: rectangulaires,                   !
   # 3: locales,    4: horaires,                         !
   # 5: dediees a l'observation,                         !
   # 6: dediees a l'observation AO,                      !
   # 7: dediees au calcul (rep. helio. moyen J2000)      !
   set coordtype   1

   # refframe =  ipref dans genoide/eproc
   # 1: equateur, 2:ecliptique  
   set refframe    1

   set obsuai      "@HST"


   puts $chan0 "<vot:TR>"
   puts $chan0 "<vot:TD>$jjdate</vot:TD>"
   puts $chan0 "<vot:TD>$isodate</vot:TD>"
   puts $chan0 "<vot:TD>$system</vot:TD>"
   puts $chan0 "<vot:TD>$xobs</vot:TD>"
   puts $chan0 "<vot:TD>$yobs</vot:TD>"
   puts $chan0 "<vot:TD>$xcalc</vot:TD>"
   puts $chan0 "<vot:TD>$ycalc</vot:TD>"
   puts $chan0 "<vot:TD>$xomc</vot:TD>"
   puts $chan0 "<vot:TD>$yomc</vot:TD>"
   puts $chan0 "<vot:TD>$timescale</vot:TD>"
   puts $chan0 "<vot:TD>$centerframe</vot:TD>"
   puts $chan0 "<vot:TD>$typeframe</vot:TD>"
   puts $chan0 "<vot:TD>$coordtype</vot:TD>"
   puts $chan0 "<vot:TD>$refframe</vot:TD>"
   puts $chan0 "<vot:TD>$obsuai</vot:TD>"
   puts $chan0 "</vot:TR>"
   puts $chan0 ""

   close $chan0

}
