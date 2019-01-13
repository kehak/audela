## @file bdi_gui_binast_ihm.tcl
#  @brief     Fonctions d&eacute;di&eacute;es &agrave; la GUI d'analyse des observations des satellites d'ast&eacute;ro&iuml;des en optique adaptative
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_binast_ihm.tcl]
#  @endcode

# $Id: bdi_gui_binast_ihm.tcl 13117 2016-05-21 02:00:00Z jberthier $

# Camilla
# S2001-107-1
# S2016-107-1

#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_cmdButton_clear_mark {  } {

   set visuNo $::audace(visuNo)

   ::audace::psf_clean_mark $visuNo
      
   set hcanvas [::confVisu::getCanvas $visuNo]
   catch {$hcanvas delete tag_cible_visu}


   return
}



#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::save_exit {  } {
   
   ::bdi_gui_binast::box_cmdButton_clear_mark

   ::bdi_gui_binast::export

   ::bdi_gui_binast::insert

   # Rechargement des listes
   ::bddimages_recherche::get_intellist $::bddimages_recherche::current_list_id
   ::bddimages_recherche::Affiche_Results $::bddimages_recherche::current_list_id [array get action_label]
   
   ::bdi_gui_binast::fermer

   return
}

#------------------------------------------------------------
## Clic pour voir les positions des ephemerides
#  @return void
proc ::bdi_gui_binast::voir_ephem {  } {
   
   gren_info "TODO save_exit\n"  
   #::bdi_gui_binast::export
   #::bdi_gui_binast::insert
   #::bdi_gui_binast::fermer
   
   return
}
#------------------------------------------------------------
## Aide au remplissage des flag qualite
# A+ : tous les satellites sont bien identifiés (tous visibles dans cette image), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
# A : le satellite est bien identifié (tous les satellites ne sont pas visible dans l image mais on estime par photométrie relative ou éphéméride que c est le bon), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
# B: le satellite est bien identifié, le satellite est bien mesuré, saturation du primaire
# C: le satellite est douteux, le primaire et le satellite sont bien mesurés, saturation ou non du primaire
# D: le satellite est douteux, le primaire et/ou le satellite sont mal mesurés, mesure a la louche
#  @return void
proc ::bdi_gui_binast::aide_quality {  } {

      set txt ""
      append txt "A+ : (Special Asteroides Multiples)\ntous les satellites sont bien identifiés (tous visibles dans cette image), le primaire et le satellite sont bien mesurés, pas de saturation du primaire"
      append txt "\n"
      append txt "\n"
      append txt "A : \nle satellite est bien identifié (tous les satellites ne sont pas visible dans l image mais on estime par photométrie relative ou éphéméride que c est le bon), le primaire et le satellite sont bien mesurés, pas de saturation du primaire"
      append txt "\n"
      append txt "\n"
      append txt "B: \nle satellite est bien identifié, le satellite est bien mesuré, saturation du primaire"
      append txt "\n"
      append txt "\n"
      append txt "C: \nle satellite est douteux, le primaire et le satellite sont bien mesurés, saturation ou non du primaire"
      append txt "\n"
      append txt "\n"
      append txt "D: \nle satellite est douteux, le primaire et/ou le satellite sont mal mesurés, mesure a la louche"
      append txt "\n"
      
      gren_info "$txt"
      set res [tk_messageBox -message $txt -type ok]

   return
}

#------------------------------------------------------------
## Aide au remplissage des flag qualite
# A+ : tous les satellites sont bien identifiés (tous visibles dans cette image), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
# A : le satellite est bien identifié (tous les satellites ne sont pas visible dans l image mais on estime par photométrie relative ou éphéméride que c est le bon), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
# B: le satellite est bien identifié, le satellite est bien mesuré, saturation du primaire
# C: le satellite est douteux, le primaire et le satellite sont bien mesurés, saturation ou non du primaire
# D: le satellite est douteux, le primaire et/ou le satellite sont mal mesurés, mesure a la louche
#  @return void
proc ::bdi_gui_binast::aide_setup_frame {  } {

      set txt ""
      append txt "Timescale :\n UTC TT"
      append txt "\n\n"
      append txt "Centerframe :\n 1: Heliocentric, 2: Geocentric, 3: Topocentric, 4: Spacecraft"
      append txt "\n\n"
      append txt "Typeframe :\n 1: Astrometrique J2000, 2: Apparente, 3: Moyenne de la date, 4: Moyenne J2000"
      append txt "\n\n"
      append txt "Coordtype :\n 1: Spherical, 2: Rectangular, 3: Local, 4: Horizontal, 5: For observers, 6: For AO observers, 7: For computation (mean heliocentric J2000 frame) 8: For ESO Phase II Observing Blocks"
      append txt "\n\n"
      append txt "Refframe :\n 1: Equateur 2:Ecliptic"
      
      gren_info "$txt"
      set res [tk_messageBox -message $txt -type ok]

   return
}

#------------------------------------------------------------
## Procedure selectionnant toute la table 
#  @return void
proc ::bdi_gui_binast::box_cmdselectall { table } {

   $table selection 0, end
   return
}







#------------------------------------------------------------
## Procedure activant le simple click dans une des tables de donnees.
#  @return void
proc ::bdi_gui_binast::box_cmdButton1Click { table } {

   gren_info "box_cmdButton1Click \n"

   set curselection [$table curselection]
   set nbselection  [llength $curselection]
   #gren_info "table = $table, nbsel = $nbselection, curselection = $curselection\n"

   # Aucune selection on sort
   if {$nbselection==0} {
      return
   }

   # plusieurs selections : Actions par lot
   if {$nbselection>1} {
      return
   }
   
   # une seule selection on visualise l image
   if {$nbselection==1} {

      # on recupere la selection
      set select [lindex $curselection 0]
      #gren_info "select = $select\n"

      # obtention de la date et du telescope
      set date [$table cellcget $select,date -text]
      set telescope [$table cellcget $select,telescope -text]
      #gren_info "date = $date\n"
      #gren_info "telescope = $telescope\n"
      
      # obtention du type d image deja selectionne dans la GUI
      set predeftype ""
      foreach type [list "img" "c1" "c2" "c3"] {
         #gren_info "relief = $type :: [$::bdi_gui_binast::widget(current,button,$type) cget -relief]\n"
         if {[$::bdi_gui_binast::widget(current,button,$type) cget -relief]=="sunken"} {
            #gren_info "type = $type\n"
            set predeftype $type
            break
         }
      }
      
      # Mise a  jour de la GUI activant les boutons suivant l existance des types d images
      foreach type [list "img" "c1" "c2" "c3"] {
         if {$::bdi_gui_binast::widget(data,listimg,$date,$type) == "x"} {
            $::bdi_gui_binast::widget(current,button,$type) configure -state normal
         } else {
            if {$predeftype==$type} {set predeftype ""}
            $::bdi_gui_binast::widget(current,button,$type) configure -relief "raised"
            $::bdi_gui_binast::widget(current,button,$type) configure -state disabled
         }
      }
      
      # On visualise l image
      if {$predeftype!=""} {
         #gren_info "ICI:\n"
         ::bdi_gui_binast::box_cmdButton_view $predeftype $date
      } else {
         #gren_info "LA:\n"
         set ::bdi_gui_binast::widget(current,date)     ""
         set ::bdi_gui_binast::widget(current,telescop) ""
         set ::bdi_gui_binast::widget(current,camera)   ""
         set ::bdi_gui_binast::widget(current,exposure) ""    
      }

      # Donnees de mesure sur la compo preselectionnee
      ::bdi_gui_binast::box_update
      
      return
   }

}


#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_listref_update_popup {  } {
   $::bdi_gui_binast::widget(table,listref).popupTbl delete 0 end
   
   foreach compo $::bdi_gui_binast::widget(table,compos,list) {
       $::bdi_gui_binast::widget(table,listref).popupTbl add command -label "Select Reference to [lindex $compo 0]" \
                     -command "::bdi_gui_binast::box_table_listref_select_reference [lindex $compo 0]"
   }
   
   return
}

#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_listref_select_reference { compo } {

   set curselection [$::bdi_gui_binast::widget(table,listref) curselection]
   foreach select $curselection {
      gren_info "select = $select\n"
      set date [$::bdi_gui_binast::widget(table,listref) cellcget $select,date -text]
      gren_info "date = $date\n"
      foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
         set ::bdi_gui_binast::widget(data,listref,$date,$cpo) ""
      }
      set ::bdi_gui_binast::widget(data,listref,$date,$compo) "x"
   }
   ::bdi_gui_binast::box_table_charge
   return
}





#------------------------------------------------------------
## Mise a jour de la GUI dans la partie Mesure
#  @return void
proc ::bdi_gui_binast::box_update {  } {

   gren_info "box_update \n"
   
   ::bdi_gui_binast::box_update_mesure

   ::bdi_gui_binast::box_update_visu_value

   ::bdi_gui_binast::box_update_data_saved
   
   return
}



#------------------------------------------------------------
## Mise a jour de la GUI dans la partie Mesure
#  @return void
proc ::bdi_gui_binast::box_update_mesure {  } {

   gren_info "box_update_mesure \n"
   
   set date $::bdi_gui_binast::widget(current,date)
   if {$date == ""} return

   set compo $::bdi_gui_binast::widget(mesure,compo)
   if {$compo == ""} {return}

   set ::bdi_gui_binast::widget(mesure,xsm)       ""
   set ::bdi_gui_binast::widget(mesure,ysm)       ""
   set ::bdi_gui_binast::widget(mesure,err_xsm)   ""
   set ::bdi_gui_binast::widget(mesure,err_ysm)   ""
   set ::bdi_gui_binast::widget(mesure,dx)        ""
   set ::bdi_gui_binast::widget(mesure,dy)        ""
   set ::bdi_gui_binast::widget(mesure,err_dx)    ""
   set ::bdi_gui_binast::widget(mesure,err_dy)    ""

   set ::bdi_gui_binast::widget(mesure,rho)       ""
   set ::bdi_gui_binast::widget(mesure,err_rho)   ""
   set ::bdi_gui_binast::widget(mesure,mag)       ""
   set ::bdi_gui_binast::widget(mesure,err_mag)   ""
   set ::bdi_gui_binast::widget(mesure,dmag)      ""
   set ::bdi_gui_binast::widget(mesure,err_dmag)  ""
   set ::bdi_gui_binast::widget(mesure,dynamique) ""


   if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)]} {
      set ::bdi_gui_binast::widget(mesure,xsm)      $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)     
      set ::bdi_gui_binast::widget(mesure,ysm)      $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)     
      set ::bdi_gui_binast::widget(mesure,err_xsm)  $::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm) 
      set ::bdi_gui_binast::widget(mesure,err_ysm)  $::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm) 
   }

   ::bdi_gui_binast::box_mesure_differentielle $date $compo "data"

   ::bdi_gui_binast::box_mag $date
   set ::bdi_gui_binast::widget(mesure,mag)      $::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)      
   set ::bdi_gui_binast::widget(mesure,err_mag)  $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)  
   set ::bdi_gui_binast::widget(mesure,dmag)     $::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)     
   set ::bdi_gui_binast::widget(mesure,err_dmag) $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag) 
   
   if {$::bdi_gui_binast::widget(data,$date,satured) == 1} {
      set ::bdi_gui_binast::widget(mesure,dynamique) "Saturated"
   } else {
      set ::bdi_gui_binast::widget(mesure,dynamique) "Good"
   }
   
   ::bdi_gui_binast::box_ephem $date $compo "data"

   
   return
}







# ::bdi_gui_binast::update_box_data_saved $date $compo
proc ::bdi_gui_binast::box_update_data_saved {  } {
   
   set date  $::bdi_gui_binast::widget(current,date)
   set compo $::bdi_gui_binast::widget(mesure,compo)
   
   gren_info "box_data_saved : $date $compo \n"
   
   set ::bdi_gui_binast::widget(cata,omc,x)     ""
   set ::bdi_gui_binast::widget(cata,omc,y)     ""
   set ::bdi_gui_binast::widget(cata,omc,err_x) ""
   set ::bdi_gui_binast::widget(cata,omc,err_y) ""
   set ::bdi_gui_binast::widget(cata,author)    ""
   set ::bdi_gui_binast::widget(cata,quality)   ""
   
   if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x,cata) ]} {
      set ::bdi_gui_binast::widget(cata,omc,x)     $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x,cata)    
      set ::bdi_gui_binast::widget(cata,omc,y)     $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y,cata) 
      set ::bdi_gui_binast::widget(cata,omc,err_x) $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x,cata) 
      set ::bdi_gui_binast::widget(cata,omc,err_y) $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y,cata)
      set ::bdi_gui_binast::widget(cata,author)    $::bdi_gui_binast::widget(data,$date,$compo,mesure,author,cata)
      set ::bdi_gui_binast::widget(cata,quality)   $::bdi_gui_binast::widget(data,$date,$compo,mesure,quality,cata)
   }
   
   return 

}


proc ::bdi_gui_binast::visu_value { type } {
   
   gren_info "visu_value : $type \n"

   # Nettoyage
   if {$type == "clean"} {
      ::bdi_gui_binast::box_cmdButton_clear_mark
      return
   }
   
   # Gestion des boutons   
   if {$type == "allcompos"} {

      if {[$::bdi_gui_binast::widget(frame,visu,buttons).all cget -relief ] == "sunken" } { 
         $::bdi_gui_binast::widget(frame,visu,buttons).all   configure -relief "raised"
      } else {
         $::bdi_gui_binast::widget(frame,visu,buttons).all   configure -relief "sunken"
      }

   } else {

      $::bdi_gui_binast::widget(frame,visu,buttons).mes   configure -relief "raised"
      $::bdi_gui_binast::widget(frame,visu,buttons).ephem configure -relief "raised"
      $::bdi_gui_binast::widget(frame,visu,buttons).cata  configure -relief "raised"

      switch $type {
         "mesure"     { 
            $::bdi_gui_binast::widget(frame,visu,buttons).mes    configure -relief "sunken"
         }
         "ephem" { 
            $::bdi_gui_binast::widget(frame,visu,buttons).ephem  configure -relief "sunken"
         }
         "cata" { 
            $::bdi_gui_binast::widget(frame,visu,buttons).cata   configure -relief "sunken"
         }
         default {  
            $::bdi_gui_binast::widget(frame,visu,buttons).all   configure -relief "raised"
            return
         }
      }

   }

   ::bdi_gui_binast::box_update_visu_value
   
   return 

}



proc ::bdi_gui_binast::box_update_visu_value_by_compo { type compo } {

   gren_info "box_update_visu_value_by_compo : $compo \n"

   set visuNo $::audace(visuNo)
   set canvas [::confVisu::getCanvas $visuNo]
   set bufNo  [::confVisu::getBufNo  $visuNo]

   set date $::bdi_gui_binast::widget(current,date)
   if {$date == ""} return

   set pi [::pi]

   switch $type {

      "mesure"     {

         # Verification de l existance des variables
         if {![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)] || 
             ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)] } { return } 

         # Calcul des coordonnees pixel
         set x $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)
         set y $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)
         gren_info "Position mesuree pix = $x $y \n"

         # Affichage de la position
         ::bdi_gui_binast::tag_circle $x $y red "Mesure de $compo"

      }

      "ephem" { 

         # Determination de la reference
         set compo_ref ""
         foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
            if {$::bdi_gui_binast::widget(data,listref,$date,$cpo)=="x"} {
               set compo_ref $cpo
               break
            }
         }

         # Verification de l existance des variables
         if {![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)] || 
             ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)] ||
             ![info exists ::bdi_gui_binast::ephem($date,$compo,dx)]                ||
             ![info exists ::bdi_gui_binast::ephem($date,$compo,dy)]                ||
             ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dx)]            ||
             ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dy)] 
             } { set pass "no" } else { set pass "yes" }
         
         # Cas ou la composante de reference est mesuree dans l image
         if { $pass == "yes" } {

            if {$compo_ref == ""} { return } 

            # Calcul des coordonnees pixel
            set x_ref_pix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)
            set y_ref_pix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)
            gren_info "Position mesuree ref pix = $x_ref_pix $y_ref_pix \n"

            set dx [expr ($::bdi_gui_binast::ephem($date,$compo,dx) + $::bdi_gui_binast::ephem($date,$compo_ref,dx) ) ]
            set dy [expr ($::bdi_gui_binast::ephem($date,$compo,dy) + $::bdi_gui_binast::ephem($date,$compo_ref,dy) ) ]

            set adr [buf$bufNo xy2radec [list $x_ref_pix $y_ref_pix] ]
            lassign $adr ar dr
            set ac [expr $dx/cos($dr*$pi/180.0)/3600000.0+$ar]
            set dc [expr $dy/3600000.0+$dr]
            set xy [buf$bufNo radec2xy [list $ac $dc] ]
            lassign $xy x y
            gren_info "Position ephem pix = $x $y \n"

            # Affichage de la position
            ::bdi_gui_binast::tag_circle $x $y cyan "Ephem de $compo"
         }
         
         # Cas ou la composante de reference n est pas mesuree dans l image
         if { $pass == "no" } {
            # Verification de l existance des variables
            if {![info exists ::bdi_gui_binast::ephem($date,$compo,dx)]                ||
                ![info exists ::bdi_gui_binast::ephem($date,$compo,dy)] 
                } { return }
            
            # Calcul des coordonnees pixel
            set x_ref_pix 128
            set y_ref_pix 128
            gren_info "Position mesuree ref pix = $x_ref_pix $y_ref_pix \n"

            set dx $::bdi_gui_binast::ephem($date,$compo,dx)
            set dy $::bdi_gui_binast::ephem($date,$compo,dy)

            set adr [buf$bufNo xy2radec [list $x_ref_pix $y_ref_pix] ]
            lassign $adr ar dr
            set ac [expr $dx/cos($dr*$pi/180.0)/3600000.0+$ar]
            set dc [expr $dy/3600000.0+$dr]
            set xy [buf$bufNo radec2xy [list $ac $dc] ]
            lassign $xy x y
            gren_erreur "Position ephem pix = $x $y \n"

            # Affichage de la position
            ::bdi_gui_binast::tag_circle $x $y "olive drab" "Ephem de $compo"
         }
         
         
      }

      "cata" { 
         
         # Verification de l existance des variables
         if {![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm,cata)] || 
             ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm,cata)] } { return } 

         # Calcul des coordonnees pixel
         set x $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm,cata)
         set y $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm,cata)
         gren_info "Position cata pix = $x $y \n"

         # Affichage de la position
         ::bdi_gui_binast::tag_circle $x $y magenta "Cata de $compo"

      }
      default {  
         return
      }
   }


}



proc ::bdi_gui_binast::box_update_visu_value {  } {

   gren_info "box_update_visu_value :  \n"

   ::bdi_gui_binast::box_cmdButton_clear_mark

   set all  "no" 
   set type ""
   if {[$::bdi_gui_binast::widget(frame,visu,buttons).mes   cget -relief ] == "sunken" } { set type "mesure"    }
   if {[$::bdi_gui_binast::widget(frame,visu,buttons).ephem cget -relief ] == "sunken" } { set type "ephem"     }
   if {[$::bdi_gui_binast::widget(frame,visu,buttons).cata  cget -relief ] == "sunken" } { set type "cata"      }
   if {[$::bdi_gui_binast::widget(frame,visu,buttons).all   cget -relief ] == "sunken" } { set all  "yes" }
   
   if {$type == ""} { return }
   
   gren_info "box_update_visu_value : $type all=$all\n"

   if {$all == "no"} { 
      set compo $::bdi_gui_binast::widget(mesure,compo)
      if {$compo == ""} return
      ::bdi_gui_binast::box_update_visu_value_by_compo $type $compo 
   } else {
      set date $::bdi_gui_binast::widget(current,date)
      if {$date == ""} return
      foreach  compo $::bdi_gui_binast::widget(table,compos,list)  {
         ::bdi_gui_binast::box_update_visu_value_by_compo $type $compo 
      }
   }
   
   return 

}



   proc ::bdi_gui_binast::tag_circle { xpic ypic color name } {

      set visuNo  $::audace(visuNo)
      set hcanvas [::confVisu::getCanvas $visuNo]
      set bufNo   [::confVisu::getBufNo  $visuNo]

      set err [catch {set coord [::confVisu::picture2Canvas $visuNo [list $xpic $ypic]]} msg]
      if {![info exists coord]} {
         gren_erreur "ERREUR Not exist : $xpic $ypic :: $err $msg\n"
         return
      }
      if {$err!=0} {
         gren_erreur "ERREUR : $xpic $ypic :: $err $msg\n"
         return
      }
      set x  [lindex $coord 0]
      set y  [lindex $coord 1]
      gren_info "Position mesuree can = $x $y \n"

      set tag tag_cible_visu
  
      set w 1
      set r 20
      set t 20
  
      #$hcanvas create oval [expr $x]       [expr $y]       [expr $x]       [expr $y]       -outline $color -tag $tag -width 1
      $hcanvas create oval [expr $x-$r]    [expr $y-$r]    [expr $x+$r]    [expr $y+$r]    -outline $color -tag $tag -width $w
      $hcanvas create text [expr $x+$t]    [expr $y-$t]                                    -fill    $color -tag $tag -text  $name -justify left -anchor nw
  
      return 

   }







proc ::bdi_gui_binast::tag_square { hcanvas visuNo xpic ypic color name } {

         set err [catch {set coord [::confVisu::picture2Canvas $visuNo $img0_xy]} msg]
         if {![info exists coord]} {
            gren_erreur "ERREUR Not exist : $xpic $ypic :: $err $msg\n"
            return
         }
         if {$err!=0} {
            gren_erreur "ERREUR : $xpic $ypic :: $err $msg\n"
            return
         }
         set x  [lindex $coord 0]
         set y  [lindex $coord 1]
   return 

}








#------------------------------------------------------------
## Procedure activant le simple click dans une des tables de donnees.
#  @return void
proc ::bdi_gui_binast::box_cmdButton_current { type } {
   
   gren_info "box_cmdButton_current : $type \n"
   if {[$::bdi_gui_binast::widget(current,button,$type) cget -relief]=="sunken"} {
      return
   }
   $::bdi_gui_binast::widget(current,button,$type) configure -relief "sunken"
   foreach t [list "img" "c1" "c2" "c3"] {
      if {$t==$type} continue
      $::bdi_gui_binast::widget(current,button,$t) configure -relief "raised"
   }
   ::bdi_gui_binast::box_cmdButton_view $type $::bdi_gui_binast::widget(current,date)
}








#------------------------------------------------------------
## Procedure de visualisation d une image
#  @return void
proc ::bdi_gui_binast::box_cmdButton_view { type date } {

   gren_info "box_cmdButton_view : $type $date\n"

   if {$date == ""} {
      tk_messageBox -message "Il faut choisir une date dans la table de droite" -type ok
      return
   }
   
   set ::bdi_tools_binast::current_image [lindex $::bdi_tools_binast::img_list $::bdi_gui_binast::widget(data,$date,$type,idimg)]
   set idbddimg    [::bddimages_liste::lget $::bdi_tools_binast::current_image idbddimg]
   set filename    [::bddimages_liste::lget $::bdi_tools_binast::current_image filename]
   set dirfilename [::bddimages_liste::lget $::bdi_tools_binast::current_image dirfilename]
   set tabkey      [::bddimages_liste::lget $::bdi_tools_binast::current_image "tabkey"]
   set telescop    [string trim [lindex [::bddimages_liste::lget $tabkey "telescop"] 1]]
   set camera      [string trim [lindex [::bddimages_liste::lget $tabkey "camera"] 1]]
   set exposure    [string trim [lindex [::bddimages_liste::lget $tabkey "exposure"] 1]]
   set cdelt1      [string trim [lindex [::bddimages_liste::lget $tabkey "cdelt1"] 1]]
   set cdelt2      [string trim [lindex [::bddimages_liste::lget $tabkey "cdelt2"] 1]]

   set ::bdi_gui_binast::widget(current,date)      $date
   set ::bdi_gui_binast::widget(current,telescop)  $telescop
   set ::bdi_gui_binast::widget(current,camera)    $camera
   set ::bdi_gui_binast::widget(current,exposure)  $exposure
   set ::bdi_gui_binast::widget(current,xscale)    [format "%0.3f" [expr abs($cdelt1)*3600000.0 ] ] 
   set ::bdi_gui_binast::widget(current,yscale)    [format "%0.3f" [expr abs($cdelt2)*3600000.0 ] ] 

   set fp [file join $::bddconf(dirbase) $dirfilename $filename ]
   charge $fp
   
   return
}





#------------------------------------------------------------
## Procedure lance la mesure du photocentre
#  @return void
proc ::bdi_gui_binast::box_cmdButton_mesure {  } {
   
   global private

   set visuNo $::audace(visuNo)

   # Lancement de psf tool box si la fenetre n existe pas
   set base [ ::confVisu::getBase $visuNo ]
   set frm "$base.psfimcce$visuNo"
   if {! [ winfo exists $frm ]} {
      ::audace::psf_toolbox $visuNo
   }

   set date $::bdi_gui_binast::widget(current,date)
   if {$date == ""} return
   

   set ::bdi_gui_binast::widget(mesure,xsm)     ""
   set ::bdi_gui_binast::widget(mesure,ysm)     ""
   set ::bdi_gui_binast::widget(mesure,err_xsm) ""
   set ::bdi_gui_binast::widget(mesure,err_ysm) ""

   set ::bdi_gui_binast::widget(mesure,dx)     ""
   set ::bdi_gui_binast::widget(mesure,dy)     ""
   set ::bdi_gui_binast::widget(mesure,err_dx) ""
   set ::bdi_gui_binast::widget(mesure,err_dy) ""

   set ::bdi_gui_binast::widget(mesure,rho)       ""
   set ::bdi_gui_binast::widget(mesure,err_rho)   ""
   set ::bdi_gui_binast::widget(mesure,mag)       ""
   set ::bdi_gui_binast::widget(mesure,err_mag)   ""
   set ::bdi_gui_binast::widget(mesure,dmag)      ""
   set ::bdi_gui_binast::widget(mesure,err_dmag)  ""
   set ::bdi_gui_binast::widget(mesure,dynamique) ""

   ::audace::refreshPSF $visuNo

   if { $private(psf_toolbox,$visuNo,psf,err_psf) != "-"} return
   gren_info "PSF = OK\n"
   
   set ::bdi_gui_binast::widget(mesure,xsm)      $private(psf_toolbox,$visuNo,psf,xsm)
   set ::bdi_gui_binast::widget(mesure,ysm)      $private(psf_toolbox,$visuNo,psf,ysm)
   set ::bdi_gui_binast::widget(mesure,err_xsm)  $private(psf_toolbox,$visuNo,psf,err_xsm)
   set ::bdi_gui_binast::widget(mesure,err_ysm)  $private(psf_toolbox,$visuNo,psf,err_ysm)
   set ::bdi_gui_binast::widget(mesure,flux)     $private(psf_toolbox,$visuNo,psf,flux)
   set ::bdi_gui_binast::widget(mesure,err_flux) $private(psf_toolbox,$visuNo,psf,err_flux)

   set compo $::bdi_gui_binast::widget(mesure,compo)
   ::bdi_gui_binast::box_mesure_differentielle $date $compo "mesure"

   set r [::bdi_gui_binast::box_mag_compo $date $compo]
   lassign $r ::bdi_gui_binast::widget(mesure,mag)  ::bdi_gui_binast::widget(mesure,err_mag) \
              ::bdi_gui_binast::widget(mesure,dmag) ::bdi_gui_binast::widget(mesure,err_dmag)
   gren_info "r = $r\n"

}







#------------------------------------------------------------
## Procedure de validation de la mesure du photocentre
#  @return void
proc ::bdi_gui_binast::box_cmdButton_valid {  } {
   
   global private
   
   set visuNo $::audace(visuNo)
   
   set compo $::bdi_gui_binast::widget(mesure,compo)
   set date  $::bdi_gui_binast::widget(current,date)
   gren_info "Compo : $compo \n"
   gren_info "Date  : $date  \n"
   
   set ::bdi_gui_binast::widget(data,listcmp,$date,$compo) "x"
   
   # PSF Resultats
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)                      $private(psf_toolbox,$visuNo,psf,xsm)      
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)                  $private(psf_toolbox,$visuNo,psf,err_xsm)  
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)                      $private(psf_toolbox,$visuNo,psf,ysm)      
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)                  $private(psf_toolbox,$visuNo,psf,err_ysm)  
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmx)                    $private(psf_toolbox,$visuNo,psf,fwhmx)    
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmy)                    $private(psf_toolbox,$visuNo,psf,fwhmy)    
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhm)                     $private(psf_toolbox,$visuNo,psf,fwhm)     
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,flux)                     $private(psf_toolbox,$visuNo,psf,flux)     
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux)                 $private(psf_toolbox,$visuNo,psf,err_flux) 
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,pixmax)                   $private(psf_toolbox,$visuNo,psf,pixmax)   
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,intensity)                $private(psf_toolbox,$visuNo,psf,intensity)
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,sky)                      $private(psf_toolbox,$visuNo,psf,sky)      
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,err_sky)                  $private(psf_toolbox,$visuNo,psf,err_sky)  
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,snint)                    $private(psf_toolbox,$visuNo,psf,snint)    
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,radius)                   $private(psf_toolbox,$visuNo,psf,radius)   
   set ::bdi_gui_binast::widget(data,$date,$compo,psf,err_psf)                  $private(psf_toolbox,$visuNo,psf,err_psf)  

   # PSF Resultats derives : TODO
   #set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dynamic)               $::bdi_gui_binast::widget(mesure,dynamic)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dynamic)               ""
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)                   $::bdi_gui_binast::widget(mesure,mag) 
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)               $::bdi_gui_binast::widget(mesure,err_mag) 
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)                  $::bdi_gui_binast::widget(mesure,dmag)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag)              $::bdi_gui_binast::widget(mesure,err_dmag)

   # Positions & Erreurs ephemerides

   # Positions & Erreurs derivees
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dx)                    $::bdi_gui_binast::widget(mesure,dx)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dx)                $::bdi_gui_binast::widget(mesure,err_dx)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,dy)                    $::bdi_gui_binast::widget(mesure,dy)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dy)                $::bdi_gui_binast::widget(mesure,err_dy)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,rho)                   $::bdi_gui_binast::widget(mesure,rho)
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_rho)               $::bdi_gui_binast::widget(mesure,err_rho)
   
   # PSF Methode utilisee
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,radius)               $private(psf_toolbox,$visuNo,radius)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,min)           $private(psf_toolbox,$visuNo,radius,min)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,max)           $private(psf_toolbox,$visuNo,radius,max)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,min)          $private(psf_toolbox,$visuNo,globale,min)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,max)          $private(psf_toolbox,$visuNo,globale,max)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,confidence)   $private(psf_toolbox,$visuNo,globale,confidence)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,saturation)           $private(psf_toolbox,$visuNo,saturation)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,threshold)            $private(psf_toolbox,$visuNo,threshold)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale)              $private(psf_toolbox,$visuNo,globale)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,ecretage)             $private(psf_toolbox,$visuNo,ecretage)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,methode)              $private(psf_toolbox,$visuNo,methode)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,precision)            $private(psf_toolbox,$visuNo,precision)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r1)            $private(psf_toolbox,$visuNo,photom,r1)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r2)            $private(psf_toolbox,$visuNo,photom,r2)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r3)            $private(psf_toolbox,$visuNo,photom,r3)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,marks,cercle)         $private(psf_toolbox,$visuNo,marks,cercle)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,arret)        $private(psf_toolbox,$visuNo,globale,arret)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,nberror)      $private(psf_toolbox,$visuNo,globale,nberror)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,gaussian_statistics)  $private(psf_toolbox,$visuNo,gaussian_statistics)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,read_out_noise)       $private(psf_toolbox,$visuNo,read_out_noise)
   set ::bdi_gui_binast::widget(data,$date,$compo,methode,beta)                 $private(psf_toolbox,$visuNo,beta)

   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,author)                $::bdi_gui_binast::widget(def_author,selected)
#   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,when)                  [string range [mc_date2iso8601 now] 0 9]
   set ::bdi_gui_binast::widget(data,$date,$compo,mesure,when)                  [clock format [clock scan now] -format "%Y-%m-%d %H:%M:%S"]


   set ::bdi_gui_binast::widget(data,$date,status) "Modified"

   ::bdi_gui_binast::box_table_charge
}






#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_create_all {  } {

   ::bdi_gui_binast::box_table_create_listimg
   ::bdi_gui_binast::box_table_create_listcmp
   ::bdi_gui_binast::box_table_create_listref
   ::bdi_gui_binast::box_table_create_listsfr
   ::bdi_gui_binast::box_table_create_listinf

   ::bdi_gui_binast::box_table_charge

   return
}









#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_create_listimg {  } {


         # On restreint la table a N enregistrements. question d esthetisme
         if  {$::bdi_gui_binast::widget(data,nbdates) > $::bdi_gui_binast::widget(frame,nbrows)} {
            set height $::bdi_gui_binast::widget(frame,nbrows)
         } else {
            set height 0
         }

         # Colonnes
         set cols [list 0 "Date"      left   \
                        0 "Telescope" left   \
                        0 "Status"    center \
                        0 "IMG"       center \
                        0 "C1"        center \
                        0 "C2"        center \
                        0 "C3"        center \
                  ]

         # Table
         #catch {gren_erreur "winfo exists \$ => [winfo exists $::bdi_gui_binast::widget(frame,listimg).table]\n"}
         #catch {gren_erreur "winfo exists  => [winfo exists ::bdi_gui_binast::widget(frame,listimg).table]\n"}
         
         if {![winfo exists $::bdi_gui_binast::widget(frame,listimg).table]} {
            set ::bdi_gui_binast::widget(table,listimg) $::bdi_gui_binast::widget(frame,listimg).table
            tablelist::tablelist $::bdi_gui_binast::widget(table,listimg) \
              -columns $cols \
              -labelcommand "" \
              -yscrollcommand [ list $::bdi_gui_binast::widget(frame,listimg).vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -height $height -width 0 \
              -state normal \
              -showseparators 1

            # Config
            $::bdi_gui_binast::widget(table,listimg) columnconfigure 0 -name date -editable no 
            $::bdi_gui_binast::widget(table,listimg) columnconfigure 1 -name telescope -editable no 

            # Scrollbar
            scrollbar $::bdi_gui_binast::widget(frame,listimg).vsb -orient vertical -command [list $::bdi_gui_binast::widget(table,listimg) yview]
            if {$height!=0} {
               pack $::bdi_gui_binast::widget(frame,listimg).vsb -in $::bdi_gui_binast::widget(frame,listimg) -side right -fill y
            }

            # Popup
            set popupTbl $::bdi_gui_binast::widget(table,listimg).popupTbl
            menu $popupTbl -title "Image"
               $popupTbl add command -label "Enlever images de la liste"   -command "" -state disabled
               $popupTbl add command -label "Revenir a la version du cata" -command "" -state disabled

            # Binding
            bind [$::bdi_gui_binast::widget(table,listimg) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            bind [$::bdi_gui_binast::widget(table,listimg) bodypath] <Control-Key-a> [ list $::bdi_gui_binast::widget(table,listimg) selection set 0 end ]
            bind $::bdi_gui_binast::widget(table,listimg) <<ListboxSelect>> [ list ::bdi_gui_binast::box_cmdButton1Click %W ]

            # Pack
            pack $::bdi_gui_binast::widget(table,listimg) -in $::bdi_gui_binast::widget(frame,listimg) -expand yes -fill both
         } else {
            $::bdi_gui_binast::widget(table,listimg) configure -columns $cols
         }

         
   return
}



#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_create_listcmp {  } {


         # On restreint la table a N enregistrements. question d esthetisme
         if  {$::bdi_gui_binast::widget(data,nbdates) > $::bdi_gui_binast::widget(frame,nbrows)} {
            set height $::bdi_gui_binast::widget(frame,nbrows)
         } else {
            set height 0
         }

         # Colonnes
         set cols [list 0 "Date" left \
                        0 "Telescope" left \
                  ]

         foreach compo $::bdi_gui_binast::widget(table,compos,list) {
             lappend cols 0
             lappend cols [lindex $compo 0]
             lappend cols "center"
         }

         # Table
         if {![winfo exists $::bdi_gui_binast::widget(frame,listcmp).table]} {
            set ::bdi_gui_binast::widget(table,listcmp) $::bdi_gui_binast::widget(frame,listcmp).table
            tablelist::tablelist $::bdi_gui_binast::widget(table,listcmp) \
              -columns $cols \
              -labelcommand "" \
              -yscrollcommand [ list $::bdi_gui_binast::widget(frame,listcmp).vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -height $height -width 0 \
              -state normal \
              -showseparators 1

            # Config
            $::bdi_gui_binast::widget(table,listcmp) columnconfigure 0 -name date -editable no 
            $::bdi_gui_binast::widget(table,listcmp) columnconfigure 1 -name telescope -editable no 

            # Scrollbar
            scrollbar $::bdi_gui_binast::widget(frame,listcmp).vsb -orient vertical -command [list $::bdi_gui_binast::widget(table,listcmp) yview]
            if {$height!=0} {
               pack $::bdi_gui_binast::widget(frame,listcmp).vsb -in $::bdi_gui_binast::widget(frame,listcmp) -side right -fill y
            }

            # Popup
            set popupTbl $::bdi_gui_binast::widget(table,listcmp).popupTbl
            menu $popupTbl -title "Compos"
               $popupTbl add command -label "Efface mesures"   -command ""  -state disabled

            # Binding
            bind [$::bdi_gui_binast::widget(table,listcmp) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            bind $::bdi_gui_binast::widget(table,listcmp) <<ListboxSelect>> [ list ::bdi_gui_binast::box_cmdButton1Click %W ]
            bind [$::bdi_gui_binast::widget(table,listcmp) bodypath] <Control-Key-a> [ list $::bdi_gui_binast::widget(table,listcmp) selection set 0 end ]

            # Pack
            pack $::bdi_gui_binast::widget(table,listcmp) -in $::bdi_gui_binast::widget(frame,listcmp) -expand yes -fill both
         } else {
            $::bdi_gui_binast::widget(table,listcmp) configure -columns $cols
         }

         
   return
}

#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::box_table_create_listref {  } {


         # On restreint la table a N enregistrements. question d esthetisme
         if  {$::bdi_gui_binast::widget(data,nbdates) > $::bdi_gui_binast::widget(frame,nbrows)} {
            set height $::bdi_gui_binast::widget(frame,nbrows)
         } else {
            set height 0
         }

         # Colonnes
         set cols [list 0 "Date" left \
                        0 "Telescope" left \
                  ]

         foreach compo $::bdi_gui_binast::widget(table,compos,list) {
             lappend cols 0
             lappend cols [lindex $compo 0]
             lappend cols "center"
         }

         # Table
         if {![winfo exists $::bdi_gui_binast::widget(frame,listref).table]} {
            set ::bdi_gui_binast::widget(table,listref) $::bdi_gui_binast::widget(frame,listref).table
            tablelist::tablelist $::bdi_gui_binast::widget(table,listref) \
              -columns $cols \
              -labelcommand "" \
              -yscrollcommand [ list $::bdi_gui_binast::widget(frame,listref).vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -height $height -width 0 \
              -state normal \
              -showseparators 1

            # Config
            $::bdi_gui_binast::widget(table,listref) columnconfigure 0 -name date -editable no 
            $::bdi_gui_binast::widget(table,listref) columnconfigure 1 -name telescope -editable no 

            # Scrollbar
            scrollbar $::bdi_gui_binast::widget(frame,listref).vsb -orient vertical -command [list $::bdi_gui_binast::widget(table,listref) yview]
            if {$height!=0} {
               pack $::bdi_gui_binast::widget(frame,listref).vsb -in $::bdi_gui_binast::widget(frame,listref) -side right -fill y
            }

            # Popup
            set popupTbl $::bdi_gui_binast::widget(table,listref).popupTbl
            menu $popupTbl -title "Reference"

            # Binding
            bind [$::bdi_gui_binast::widget(table,listref) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            bind $::bdi_gui_binast::widget(table,listref) <<ListboxSelect>> [ list ::bdi_gui_binast::box_cmdButton1Click %W ]
            bind [$::bdi_gui_binast::widget(table,listref) bodypath] <Control-Key-a> [ list $::bdi_gui_binast::widget(table,listref) selection set 0 end ]

            # Pack
            pack $::bdi_gui_binast::widget(table,listref) -in $::bdi_gui_binast::widget(frame,listref) -expand yes -fill both
         } else {
            $::bdi_gui_binast::widget(table,listref) configure -columns $cols
         }

   return
}






#------------------------------------------------------------
## 
#  @return void
# timescale   : UTC TT
# centerframe : 1:heliocentric, 2:geocentric, 3:topocentric, 4:spacecraft
# typeframe   : 1:astrometrique J2000, 2:apparente, 3:moyenne de la date, 4:moyenne J2000
# coordtype   : 1: Spherical, 2: Rectangular, 3: Local, 4: Horizontal, 5: For observers, 6: For AO observers, 7: For computation (mean heliocentric J2000 frame) 8: For ESO Phase II Observing Blocks
# refframe    : 1: Equateur 2:Ecliptic
proc ::bdi_gui_binast::box_table_create_listsfr {  } {

         # On restreint la table a N enregistrements. question d esthetisme
         if  {$::bdi_gui_binast::widget(data,nbdates) > $::bdi_gui_binast::widget(frame,nbrows)} {
            set height $::bdi_gui_binast::widget(frame,nbrows)
         } else {
            set height 0
         }

         # Colonnes
         set cols [list 0 "Date"         left \
                        0 "Telescope"    left \
                        0 "Timescale"    left \
                        0 "Centerframe"  left \
                        0 "Typeframe"    left \
                        0 "Coordtype"    left \
                        0 "Refframe"     left \
                  ]

         # Table
         if {![winfo exists $::bdi_gui_binast::widget(frame,listsfr).table]} {
            set ::bdi_gui_binast::widget(table,listsfr) $::bdi_gui_binast::widget(frame,listsfr).table
            tablelist::tablelist $::bdi_gui_binast::widget(table,listsfr) \
              -columns $cols \
              -labelcommand "" \
              -yscrollcommand [ list $::bdi_gui_binast::widget(frame,listsfr).vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -height $height -width 0 \
              -state normal \
              -showseparators 1

            # Config
            $::bdi_gui_binast::widget(table,listsfr) columnconfigure 0 -name date -editable no 
            $::bdi_gui_binast::widget(table,listsfr) columnconfigure 1 -name telescope -editable no 

            # Scrollbar
            scrollbar $::bdi_gui_binast::widget(frame,listsfr).vsb -orient vertical -command [list $::bdi_gui_binast::widget(table,listsfr) yview]
            if {$height!=0} {
               pack $::bdi_gui_binast::widget(frame,listsfr).vsb -in $::bdi_gui_binast::widget(frame,listsfr) -side right -fill y
            }

            # Popup
            set popupTbl $::bdi_gui_binast::widget(table,listsfr).popupTbl
            menu $popupTbl -title "Setup Frame"


               menu $popupTbl.timsecale -tearoff 0
               $popupTbl add cascade -label "Timescale"   -menu $popupTbl.timsecale

                  $popupTbl.timsecale add command -label "UTC" \
                     -command {::bdi_gui_binast::setup_frame_set "UTC"}
                  $popupTbl.timsecale add command -label "TT"  \
                     -command {::bdi_gui_binast::setup_frame_set "TT"}

               menu $popupTbl.centerframe -tearoff 0
               $popupTbl add cascade -label "Centerframe" -menu $popupTbl.centerframe

                  $popupTbl.centerframe add command -label "Heliocentric"  \
                     -command {::bdi_gui_binast::setup_frame_set "Heliocentric"}
                  $popupTbl.centerframe add command -label "Geocentric"  \
                     -command {::bdi_gui_binast::setup_frame_set "Geocentric"}
                  $popupTbl.centerframe add command -label "Topocentric"  \
                     -command {::bdi_gui_binast::setup_frame_set "Topocentric"}
                  $popupTbl.centerframe add command -label "Spacecraft"  \
                     -command {::bdi_gui_binast::setup_frame_set "Spacecraft"}

               menu $popupTbl.typeframe -tearoff 0
               $popupTbl add cascade -label "Typeframe"   -menu $popupTbl.typeframe

                  $popupTbl.typeframe add command -label "Astrometrique J2000"  \
                     -command {::bdi_gui_binast::setup_frame_set "Astrometrique J2000"}
                  $popupTbl.typeframe add command -label "Apparente"  \
                     -command {::bdi_gui_binast::setup_frame_set "Apparente"}
                  $popupTbl.typeframe add command -label "Moyenne de la date"  \
                     -command {::bdi_gui_binast::setup_frame_set "Moyenne de la date"}
                  $popupTbl.typeframe add command -label "Moyenne J2000"  \
                     -command {::bdi_gui_binast::setup_frame_set "Moyenne J2000"}

               menu $popupTbl.coordtype -tearoff 0
               $popupTbl add cascade -label "Coordtype"   -menu $popupTbl.coordtype

                  $popupTbl.coordtype add command -label "Spherical"  \
                     -command {::bdi_gui_binast::setup_frame_set "Spherical"}
                  $popupTbl.coordtype add command -label "Rectangular"  \
                     -command {::bdi_gui_binast::setup_frame_set "Rectangular"}
                  $popupTbl.coordtype add command -label "Local"  \
                     -command {::bdi_gui_binast::setup_frame_set "Local"}
                  $popupTbl.coordtype add command -label "Horizontal"  \
                     -command {::bdi_gui_binast::setup_frame_set "Horizontal"}
                  $popupTbl.coordtype add command -label "For observers"  \
                     -command {::bdi_gui_binast::setup_frame_set "For observers"}
                  $popupTbl.coordtype add command -label "For AO observers"  \
                     -command {::bdi_gui_binast::setup_frame_set "For AO observers"}
                  $popupTbl.coordtype add command -label "For computation (mean heliocentric J2000 frame)"  \
                     -command {::bdi_gui_binast::setup_frame_set "For computation (mean heliocentric J2000 frame)"}
                  $popupTbl.coordtype add command -label "For ESO Phase II Observing Blocks"  \
                     -command {::bdi_gui_binast::setup_frame_set "For ESO Phase II Observing Blocks"}

               menu $popupTbl.refframe -tearoff 0
               $popupTbl add cascade -label "Refframe"    -menu $popupTbl.refframe

                  $popupTbl.refframe add command -label "Equateur"  \
                     -command {::bdi_gui_binast::setup_frame_set "Equateur"}
                  $popupTbl.refframe add command -label "Ecliptic"  \
                     -command {::bdi_gui_binast::setup_frame_set "Ecliptic"}

               $popupTbl add separator
               $popupTbl add command -label "Auto"  -command "::bdi_gui_binast::setup_frame_set_auto" 
               $popupTbl add separator
               $popupTbl add command -label "Aide"  -command "::bdi_gui_binast::aide_setup_frame"

            # Binding
            bind [$::bdi_gui_binast::widget(table,listsfr) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            #bind $::bdi_gui_binast::widget(table,listsfr) <<ListboxSelect>> [ list ::bdi_gui_binast::box_cmdButton1Click %W ]
            #bind [$::bdi_gui_binast::widget(table,listsfr) bodypath] <Control-Key-a> [ list $::bdi_gui_binast::widget(table,listsfr) selection set 0 end ]

            # Pack
            pack $::bdi_gui_binast::widget(table,listsfr) -in $::bdi_gui_binast::widget(frame,listsfr) -expand yes -fill both
         } else {
            $::bdi_gui_binast::widget(table,listsfr) configure -columns $cols
         }

   return
}

#------------------------------------------------------------
## 
#  @return void
# author
# when
# bibitem 

proc ::bdi_gui_binast::box_table_create_listinf {  } {

         # On restreint la table a N enregistrements. question d esthetisme
         if  {$::bdi_gui_binast::widget(data,nbdates) > $::bdi_gui_binast::widget(frame,nbrows)} {
            set height $::bdi_gui_binast::widget(frame,nbrows)
         } else {
            set height 0
         }

         # Colonnes
         set cols [list 0 "Date"         left \
                        0 "Telescope"    left \
                        0 "Compo"        left \
                        0 "Qualite"      left \
                        0 "Auteur"       left \
                        0 "When"         left \
                        0 "Bibitem"      left \
                  ]

         # Table
         if {![winfo exists $::bdi_gui_binast::widget(frame,listinf).table]} {
            set ::bdi_gui_binast::widget(table,listinf) $::bdi_gui_binast::widget(frame,listinf).table
            tablelist::tablelist $::bdi_gui_binast::widget(table,listinf) \
              -columns $cols \
              -labelcommand "" \
              -yscrollcommand [ list $::bdi_gui_binast::widget(frame,listinf).vsb set ] \
              -selectmode extended \
              -activestyle none \
              -stripebackground "#e0e8f0" \
              -height $height -width 0 \
              -state normal \
              -showseparators 1

            # Config
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 0 -name date      -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 1 -name telescope -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 2 -name compo     -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 3 -name quality   -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 4 -name auteur    -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 5 -name when      -editable no 
            $::bdi_gui_binast::widget(table,listinf) columnconfigure 6 -name bibitem   -editable no 

            # Scrollbar
            scrollbar $::bdi_gui_binast::widget(frame,listinf).vsb -orient vertical -command [list $::bdi_gui_binast::widget(table,listinf) yview]
            if {$height!=0} {
               pack $::bdi_gui_binast::widget(frame,listinf).vsb -in $::bdi_gui_binast::widget(frame,listinf) -side right -fill y
            }

            # Popup
            set popupTbl $::bdi_gui_binast::widget(table,listinf).popupTbl
            menu $popupTbl -title "Selection"

               menu $popupTbl.quality -tearoff 0
               $popupTbl add cascade -label "Qualite" -menu $popupTbl.quality


                  #A+ : tous les satellites sont bien identifiés (tous visibles dans cette image), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
                  #A : le satellite est bien identifié (tous les satellites ne sont pas visible dans l image mais on estime par photométrie relative ou éphéméride que c est le bon), le primaire et le satellite sont bien mesurés, pas de saturation du primaire
                  #B: le satellite est bien identifié, le satellite est bien mesuré, saturation du primaire
                  #C: le satellite est douteux, le primaire et le satellite sont bien mesurés, saturation ou non du primaire
                  #D: le satellite est douteux, le primaire et/ou le satellite sont mal mesurés, mesure a la louche
                  $popupTbl.quality add command -label "A+" -command "::bdi_gui_binast::quality_set A+"
                  $popupTbl.quality add command -label "A"  -command "::bdi_gui_binast::quality_set A"
                  $popupTbl.quality add command -label "B"  -command "::bdi_gui_binast::quality_set B"
                  $popupTbl.quality add command -label "C"  -command "::bdi_gui_binast::quality_set C"
                  $popupTbl.quality add command -label "D"  -command "::bdi_gui_binast::quality_set D"
                  $popupTbl.quality add command -label "E"  -command "::bdi_gui_binast::quality_set E"
                  $popupTbl.quality add separator
                  $popupTbl.quality add command -label "Aide"  -command "::bdi_gui_binast::aide_quality"

               $popupTbl add separator
               $popupTbl add command -label "Modifier Bibitem" -command "" -state disabled
               $popupTbl add separator
               $popupTbl add command -label "Aide"  -command "" -state disabled

            # Binding
            bind [$::bdi_gui_binast::widget(table,listinf) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
            #bind $::bdi_gui_binast::widget(table,listinf) <<ListboxSelect>> [ list ::bdi_gui_binast::box_cmdButton1Click %W ]
            #bind [$::bdi_gui_binast::widget(table,listinf) bodypath] <Control-Key-a> [ list $::bdi_gui_binast::widget(table,listinf) selection set 0 end ]

            # Pack
            pack $::bdi_gui_binast::widget(table,listinf) -in $::bdi_gui_binast::widget(frame,listinf) -expand yes -fill both
         } else {
            $::bdi_gui_binast::widget(table,listinf) configure -columns $cols
         }

   return
}






proc ::bdi_gui_binast::quality_set { quality } {
   
   set curselection [$::bdi_gui_binast::widget(table,listinf) curselection]
   set nb [llength $curselection]
   if {$nb==0} return
   foreach select $curselection {
      set date  [$::bdi_gui_binast::widget(table,listinf) cellcget $select,date -text]
      set compo [$::bdi_gui_binast::widget(table,listinf) cellcget $select,compo -text]
      gren_info "set date  $date \n"
      gren_info "set compo $compo\n"
      gren_info "set quality $quality\n"
      gren_info "set select [list $select]\n"
      #if {$::bdi_gui_binast::widget(data,$date,status) == "Unknown"} {continue}
      
      $::bdi_gui_binast::widget(table,listinf) cellconfigure $select,quality -text $quality
      set ::bdi_gui_binast::widget(data,$date,$compo,mesure,quality) $quality
      gren_info "set quality : $date $compo -> $::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)\n"
   }
   
   return
}







proc ::bdi_gui_binast::setup_frame_set { value } {

   set curselection [$::bdi_gui_binast::widget(table,listsfr) curselection]
   set nb [llength $curselection]
   if {$nb==0} return
   foreach select $curselection {

      set date [$::bdi_gui_binast::widget(table,listsfr) cellcget $select,date -text]
      if {$::bdi_gui_binast::widget(data,$date,status) == "Unknown"} {continue}

      switch $value {
         "UTC" - "TT" { 
            $::bdi_gui_binast::widget(table,listsfr) cellconfigure $select,2 -text $value
            set ::bdi_gui_binast::widget(data,$date,timescale) $value
            gren_info "set Timescale : $date -> $value\n"
         }
         "Heliocentric" - "Geocentric" - "Topocentric" - "Spacecraft" {
            $::bdi_gui_binast::widget(table,listsfr) cellconfigure $select,3 -text $value
            set ::bdi_gui_binast::widget(data,$date,centerframe) $value
            gren_info "set Centerframe : $date -> $value\n"
         }
         "Astrometrique J2000" - "Apparente" - "Moyenne de la date" - "Moyenne J2000" {
            $::bdi_gui_binast::widget(table,listsfr) cellconfigure $select,4 -text $value
            set ::bdi_gui_binast::widget(data,$date,typeframe) $value
            gren_info "set Typeframe : $date -> $value\n"
         }
         "Spherical" - "Rectangular" - "Local" - "Horizontal" - "For observers" -
         "For AO observers" - "For computation (mean heliocentric J2000 frame)" -
         "For ESO Phase II Observing Blocks" {
            $::bdi_gui_binast::widget(table,listsfr) cellconfigure $select,5 -text $value
            set ::bdi_gui_binast::widget(data,$date,coordtype) $value
            gren_info "set Coordtype : $date -> $value\n"
         }
         "Equateur" - "Ecliptic" {
            $::bdi_gui_binast::widget(table,listsfr) cellconfigure $select,6 -text $value
            set ::bdi_gui_binast::widget(data,$date,refframe) $value
            gren_info "set Refframe : $date -> $value\n"
         }
         default {  }
      }

   }

   return
}


proc ::bdi_gui_binast::setup_frame_set_auto {  } {

   set curselection [$::bdi_gui_binast::widget(table,listsfr) curselection]
   set nb [llength $curselection]
   if {$nb==0} return
   foreach select $curselection {

      set date [$::bdi_gui_binast::widget(table,listsfr) cellcget $select,date -text]
      if {$::bdi_gui_binast::widget(data,$date,status) == "Unknown"} {continue}
      gren_info "setup fram auto : $date -> TODO\n"

   }

   return
}




#------------------------------------------------------------
## Fermeture de l application : gestion des compos
#  @return void
proc ::bdi_gui_binast::box_create_menubutton_compo {  } {
    set ::bdi_gui_binast::widget(mesure,compo) ""
    $::bdi_gui_binast::widget(mesure,menuconfig) delete 0 end
    foreach  compo $::bdi_gui_binast::widget(table,compos,list)  {
       if {$::bdi_gui_binast::widget(mesure,compo) == ""} {set ::bdi_gui_binast::widget(mesure,compo) $compo}
       $::bdi_gui_binast::widget(mesure,menuconfig) add radiobutton -label $compo -value $compo \
          -variable ::bdi_gui_binast::widget(mesure,compo) -command "::bdi_gui_binast::box_update"
    }
    return
}








#------------------------------------------------------------
## GUI generale de l outil de mesure des satellites d asteroides
#  @return void
#------------------------------------------------------------
# globale dynamic
# ra dec poserr \
# quality author when bibitem 
# timescale centerframe typeframe coordtype refframe 



proc ::bdi_gui_binast::box { img_list } {

   global audace
   global conf bddconf

   # Initialisation des variables
   set ::bdi_gui_binast::img_list $img_list
   gren_info "Nb images selectionnees : [llength $::bdi_gui_binast::img_list]\n"
   ::bdi_gui_binast::inittoconf

   # Chargement des donnees
   set err [ catch {::bdi_gui_binast::charge_list $::bdi_gui_binast::img_list} msg ]
   if {$err != 0} {
      gren_erreur "erreur $err : $msg\n"
      return
   }
      
   #--- Creation de la fenetre
   if { ! [ info exists conf(bddimages,binast,geometry) ] } { set conf(bddimages,binast,geometry) "+300+55" }
   set bddconf(binast,geometry) $conf(bddimages,binast,geometry)

   set ::bdi_gui_binast::fen .bdi_binast
   if { [winfo exists $::bdi_gui_binast::fen] } {
      wm withdraw $::bdi_gui_binast::fen
      wm deiconify $::bdi_gui_binast::fen
      focus $::bdi_gui_binast::fen
      return
   }
   toplevel $::bdi_gui_binast::fen -class Toplevel
   wm geometry $::bdi_gui_binast::fen $bddconf(binast,geometry)
   wm resizable $::bdi_gui_binast::fen 1 1
   wm title $::bdi_gui_binast::fen "Binast Box"
   wm protocol $::bdi_gui_binast::fen WM_DELETE_WINDOW "::bdi_gui_binast::fermer"

   #--- Cree un menu pour le panneau
   set frmmenu [frame $::bdi_gui_binast::fen.frame0 -borderwidth 1 -relief raised -pady 1]
   grid $frmmenu -in $::bdi_gui_binast::fen -sticky news

     #--- menu Fichier
     menubutton $frmmenu.file -text "Fichier" -underline 0 -menu $frmmenu.file.menu
     menu $frmmenu.file.menu
       $frmmenu.file.menu add command -label "Export Cata" -command "::bdi_gui_binast::export"
       $frmmenu.file.menu add command -label "Import Cata" -command "::bdi_gui_binast::import"
       $frmmenu.file.menu add separator
       $frmmenu.file.menu add command -label "Insert Cata" -command "::bdi_gui_binast::insert"
       $frmmenu.file.menu add separator
       $frmmenu.file.menu add command -label "Save & Exit" -command "::bdi_gui_binast::save_exit"
       $frmmenu.file.menu add command -label "Quitter" -command "::bdi_gui_binast::fermer"
        
     #--- menu Compos
     menubutton $frmmenu.comp -text "Compos" -underline 0 -menu $frmmenu.comp.menu
     menu $frmmenu.comp.menu
       $frmmenu.comp.menu add command -label "Gestion" -command "::bdi_gui_binast::def_compos"
        
     #--- menu Ephemerides
     menubutton $frmmenu.ephem -text "Ephemerides" -underline 0 -menu $frmmenu.ephem.menu
     set ::bdi_gui_binast::widget(ephem,menu) $frmmenu.ephem.menu
        
     menu $frmmenu.ephem.menu
     $frmmenu.ephem.menu add command -label "Get solution" -command "::bdi_gui_binast::get_ephem"
     $frmmenu.ephem.menu add separator

     #--- menu Auteur
     menubutton $frmmenu.auth -text "Auteur" -underline 0 -menu $frmmenu.auth.menu
     set ::bdi_gui_binast::widget(def_author,menu) $frmmenu.auth.menu

     menu $frmmenu.auth.menu
       $frmmenu.auth.menu add command -label "Gestion" -command "::bdi_gui_binast::def_author"
       $frmmenu.auth.menu add separator
        
     #--- menu dev
     menubutton $frmmenu.dev -text "Dev" -underline 0 -menu $frmmenu.dev.menu
     menu $frmmenu.dev.menu
       $frmmenu.dev.menu add command -label "Ressource" -command "::bddimages::ressource ; ::console::clear"
       $frmmenu.dev.menu add separator
       $frmmenu.dev.menu add command -label "Recharge" -command "::bdi_gui_binast::recharge_appli 0"
       $frmmenu.dev.menu add separator
       $frmmenu.dev.menu add command -label "Recharge & Clean" -command "::bdi_gui_binast::recharge_appli 1"

     #--- menu aide
     menubutton $frmmenu.aide -text "Aide" -underline 0 -menu $frmmenu.aide.menu
     menu $frmmenu.aide.menu
       $frmmenu.aide.menu add command -label "Aide" -command ""
       $frmmenu.aide.menu add command -label "Credits" -command ""

     pack $frmmenu.file  -side left
     pack $frmmenu.comp  -side left
     pack $frmmenu.ephem -side left
     pack $frmmenu.auth  -side left
     pack $frmmenu.aide  -side right
     pack $frmmenu.dev   -side right

   #--- Cree un frame general
   set frm [frame $::bdi_gui_binast::fen.frmgen -borderwidth 0 -cursor arrow -relief groove]
   grid $frm -in $::bdi_gui_binast::fen -sticky news

      set left [frame $frm.left ]
      set right [frame $frm.right ]

      grid $left       -in $frm -sticky nw  -row 1 -column 0
      grid $right      -in $frm -sticky ne  -row 1 -column 1

      #--- Cree un frame pour afficher les informations sur le systeme
      set system [TitleFrame $left.system -borderwidth 2 -text "Systeme"]
      grid $system -in $left -sticky news

         label   $system.lab1  -text "Name :"
         label   $system.lab2  -textvariable ::bdi_gui_binast::widget(system,idname)
         grid $system.lab1 $system.lab2  -in [$system getframe] -sticky nes

      #--- Cree un frame pour afficher les informations courantes
      set img [TitleFrame $left.img -borderwidth 2 -text "Image courante"]
      grid $img -in $left -sticky news
   
         set top [frame $img.top ]
         grid $top -in [$img getframe] -sticky new

            label   $top.labd1  -text "Date :"
            label   $top.labd2  -textvariable ::bdi_gui_binast::widget(current,date)
            label   $top.labt1  -text "Telescop :"
            label   $top.labt2  -textvariable ::bdi_gui_binast::widget(current,telescop)
            label   $top.labc1  -text "Camera :"
            label   $top.labc2  -textvariable ::bdi_gui_binast::widget(current,camera)
            label   $top.labe1  -text "Exposure (s) :"
            label   $top.labe2  -textvariable ::bdi_gui_binast::widget(current,exposure)
            label   $top.labx1  -text "Xscale (mas/pix) :"
            label   $top.labx2  -textvariable ::bdi_gui_binast::widget(current,xscale)
            label   $top.laby1  -text "Yscale (mas/pix) :"
            label   $top.laby2  -textvariable ::bdi_gui_binast::widget(current,yscale)
            grid $top.labd1 $top.labd2 -in $top -sticky ne
            grid $top.labt1 $top.labt2 -in $top -sticky ne
            grid $top.labc1 $top.labc2 -in $top -sticky ne
            grid $top.labe1 $top.labe2 -in $top -sticky ne
            grid $top.labx1 $top.labx2 -in $top -sticky ne
            grid $top.laby1 $top.laby2 -in $top -sticky ne

         set bottom [frame $img.bottom -pady 3 ]
         grid $bottom -in [$img getframe] -sticky sew

            set ::bdi_gui_binast::widget(current,button,img) [button $bottom.img -text "IMG" -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_current img"]
            set ::bdi_gui_binast::widget(current,button,c1)  [button $bottom.c1  -text "C1"  -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_current c1"]
            set ::bdi_gui_binast::widget(current,button,c2)  [button $bottom.c2  -text "C2"  -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_current c2"]
            set ::bdi_gui_binast::widget(current,button,c3)  [button $bottom.c3  -text "C3"  -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_current c3"]
            grid $bottom.img $bottom.c1 $bottom.c2 $bottom.c3 -in $bottom -sticky ne

      #--- Cree un frame pour afficher les mesures
      set mes [TitleFrame $left.mes -borderwidth 2 -text "Mesure"]
      grid $mes -in $left -sticky news
   
         set top [frame $mes.top ]
         grid $top -in [$mes getframe] -sticky new

            label   $top.lab1  -text "Select compo :"
            set ::bdi_gui_binast::widget(mesure,menucompo) [menubutton $top.selco -textvariable ::bdi_gui_binast::widget(mesure,compo) \
                     -borderwidth 1 -relief raised -underline 0 -menu $top.selco.menu]
            set ::bdi_gui_binast::widget(mesure,menuconfig) [menu $top.selco.menu -tearoff 1]
                     
            grid $top.lab1 $top.selco -in $top -sticky new

         set middle [frame $mes.middle ]
         grid $middle -in [$mes getframe] -sticky new

            # X pixel
            label   $middle.labx1  -text "X pix :"
            label   $middle.labx2  -textvariable ::bdi_gui_binast::widget(mesure,xsm)
            label   $middle.labx3  -text "1-[format %c 963] err :"
            label   $middle.labx4  -textvariable ::bdi_gui_binast::widget(mesure,err_xsm)
            grid $middle.labx1 $middle.labx2 $middle.labx3 $middle.labx4 -in $middle -sticky ne
            # Y pixel
            label   $middle.laby1  -text "Y pix :"
            label   $middle.laby2  -textvariable ::bdi_gui_binast::widget(mesure,ysm)
            label   $middle.laby3  -text "1-[format %c 963] err :"
            label   $middle.laby4  -textvariable ::bdi_gui_binast::widget(mesure,err_ysm)
            grid $middle.laby1 $middle.laby2 $middle.laby3 $middle.laby4 -in $middle -sticky ne
            # DX mas
            label   $middle.labdx1  -text "[format %c 916]X mas :"
            label   $middle.labdx2  -textvariable ::bdi_gui_binast::widget(mesure,dx)
            label   $middle.labdx3  -text "1-[format %c 963] err :"
            label   $middle.labdx4  -textvariable ::bdi_gui_binast::widget(mesure,err_dx)
            grid $middle.labdx1 $middle.labdx2 $middle.labdx3 $middle.labdx4 -in $middle -sticky ne
            # DY mas
            label   $middle.labdy1  -text "[format %c 916]Y mas :"
            label   $middle.labdy2  -textvariable ::bdi_gui_binast::widget(mesure,dy)
            label   $middle.labdy3  -text "1-[format %c 963] err :"
            label   $middle.labdy4  -textvariable ::bdi_gui_binast::widget(mesure,err_dy)
            grid $middle.labdy1 $middle.labdy2 $middle.labdy3 $middle.labdy4 -in $middle -sticky ne
            # DRho mas : separation
            label   $middle.labrh1  -text "[format %c 916]\u3c1 mas :"
            label   $middle.labrh2  -textvariable ::bdi_gui_binast::widget(mesure,rho)
            label   $middle.labrh3  -text "1-[format %c 963] err :"
            label   $middle.labrh4  -textvariable ::bdi_gui_binast::widget(mesure,err_rho)
            grid $middle.labrh1 $middle.labrh2 $middle.labrh3 $middle.labrh4 -in $middle -sticky ne
            # Flux
            label   $middle.labma1  -text "Mag :"
            label   $middle.labma2  -textvariable ::bdi_gui_binast::widget(mesure,mag)
            label   $middle.labma3  -text "1-[format %c 963] err :"
            label   $middle.labma4  -textvariable ::bdi_gui_binast::widget(mesure,err_mag)
            grid $middle.labma1 $middle.labma2 $middle.labma3 $middle.labma4 -in $middle -sticky ne
            # Delta Mag
            label   $middle.labdm1  -text "[format %c 916]Mag :"
            label   $middle.labdm2  -textvariable ::bdi_gui_binast::widget(mesure,dmag)
            label   $middle.labdm3  -text "1-[format %c 963] err :"
            label   $middle.labdm4  -textvariable ::bdi_gui_binast::widget(mesure,err_dmag)
            grid $middle.labdm1 $middle.labdm2 $middle.labdm3 $middle.labdm4 -in $middle -sticky ne

         set middle2 [frame $mes.middle2 -pady 3]
         grid $middle2 -in [$mes getframe] -sticky new

            # Dynamic
            label   $middle2.labdm1  -text "Dynamique :"
            label   $middle2.labdm2  -textvariable ::bdi_gui_binast::widget(mesure,dynamique)
            grid $middle2.labdm1 $middle2.labdm2 -in $middle2 -sticky ne

         set bottom [frame $mes.bottom -pady 3]
         grid $bottom -in [$mes getframe] -sticky new

            button $bottom.mes  -text "1. Mesure" -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_mesure"
            button $bottom.val  -text "2. Valid"  -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::box_cmdButton_valid"
            grid $bottom.mes $bottom.val -in $bottom -sticky ne

      #--- Cree un frame pour afficher les informations sur les ephemerides
      set ephem [TitleFrame $left.ephem -borderwidth 2 -text "Ephemerides"]
      grid $ephem -in $left -sticky news

         set top [frame $ephem.top ]
         grid $top -in [$ephem getframe] -sticky new

            # X (O-C) mas
            label   $top.labxo1  -text "X (O-C) mas :"
            label   $top.labxo2  -textvariable ::bdi_gui_binast::widget(ephem,omc,x)
            label   $top.labxo3  -text "1-[format %c 963] err :"
            label   $top.labxo4  -textvariable ::bdi_gui_binast::widget(ephem,x,omc,err_x)
            grid $top.labxo1 $top.labxo2 $top.labxo3 $top.labxo4 -in $top -sticky ne
            # Y (O-C) mas
            label   $top.labyo1  -text "Y (O-C) mas :"
            label   $top.labyo2  -textvariable ::bdi_gui_binast::widget(ephem,omc,y)
            label   $top.labyo3  -text "1-[format %c 963] err :"
            label   $top.labyo4  -textvariable ::bdi_gui_binast::widget(ephem,omc,err_y)
            grid $top.labyo1 $top.labyo2 $top.labyo3 $top.labyo4 -in $top -sticky ne
 
      #--- Cree un frame pour afficher les informations sur les donnees enregistrees
      set cata [TitleFrame $left.cata -borderwidth 2 -text "Donnees enregistrees"]
      grid $cata -in $left -sticky news

         set top [frame $cata.top ]
         grid $top -in [$cata getframe] -sticky new

            # X (O-C) mas
            label   $top.labxo1  -text "X (O-C) mas :"
            label   $top.labxo2  -textvariable ::bdi_gui_binast::widget(cata,omc,x)
            label   $top.labxo3  -text "1-[format %c 963] err :"
            label   $top.labxo4  -textvariable ::bdi_gui_binast::widget(cata,omc,err_x)
            grid $top.labxo1 $top.labxo2 $top.labxo3 $top.labxo4 -in $top -sticky ne
            # Y (O-C) mas
            label   $top.labyo1  -text "Y (O-C) mas :"
            label   $top.labyo2  -textvariable ::bdi_gui_binast::widget(cata,omc,y)
            label   $top.labyo3  -text "1-[format %c 963] err :"
            label   $top.labyo4  -textvariable ::bdi_gui_binast::widget(cata,omc,err_y)
            grid $top.labyo1 $top.labyo2 $top.labyo3 $top.labyo4 -in $top -sticky ne
 
         set bottom [frame $cata.bottom -pady 3 ]
         grid $bottom -in [$cata getframe] -sticky sew

            label   $bottom.labmes1  -text "Auteur :"
            label   $bottom.labmes2  -textvariable ::bdi_gui_binast::widget(cata,author)
            grid $bottom.labmes1 $bottom.labmes2 -in $bottom -sticky nes

            label   $bottom.labflag1  -text "Qualite :"
            label   $bottom.labflag2  -textvariable ::bdi_gui_binast::widget(cata,quality)
            grid $bottom.labflag1 $bottom.labflag2 -in $bottom -sticky nws

      #--- Cree un frame pour afficher les informations sur les ephemerides
      set view [TitleFrame $left.view -borderwidth 2 -text "Visu"]
      grid $view -in $left -sticky news

         set top [frame $view.top ]
         grid $top -in [$view getframe] -sticky new

            set ::bdi_gui_binast::widget(frame,visu,buttons) $top

            button $top.mes   -text "Mesure"     -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::visu_value mesure"
            button $top.ephem -text "Ephem"      -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::visu_value ephem"
            button $top.cata  -text "Cata"       -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::visu_value cata"
            button $top.all   -text "All Compos" -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::visu_value allcompos"
            button $top.clean -text "Clean"      -borderwidth 2 -takefocus 1 -relief "raised" -command "::bdi_gui_binast::visu_value clean"
            grid $top.mes $top.ephem $top.cata -in $top -sticky news
            grid $top.all $top.clean -in $top -sticky news
 

      #--- Cree un frame pour afficher les tables de donnees 
      set top [frame $right.top ]
      grid $top -in $right -sticky new

         set onglets $top.onglets
         set ::bdi_gui_binast::widget(frame,onglets) $onglets
         grid [ttk::notebook $onglets] -row 0 -column 0

            set f_img [frame $onglets.f_img]
            set f_cmp [frame $onglets.f_cmp]
            set f_ref [frame $onglets.f_ref]
            set f_qua [frame $onglets.f_qua]
            set f_sfr [frame $onglets.f_sfr]
            set f_inf [frame $onglets.f_inf]

            $onglets add $f_img -text "Img"         -underline 0
            $onglets add $f_cmp -text "Compo"       -underline 0
            $onglets add $f_ref -text "Ref"         -underline 0
            $onglets add $f_sfr -text "Setup Frame" -underline 0
            $onglets add $f_inf -text "Info"        -underline 0

            $onglets select $f_img
            ttk::notebook::enableTraversal $onglets

               set ::bdi_gui_binast::widget(frame,listimg) [frame $f_img.tab -borderwidth 0 -cursor arrow -relief groove]
               grid $::bdi_gui_binast::widget(frame,listimg) -in $f_img -sticky news

               set ::bdi_gui_binast::widget(frame,listcmp) [frame $f_cmp.tab -borderwidth 0 -cursor arrow -relief groove]
               grid $::bdi_gui_binast::widget(frame,listcmp) -in $f_cmp -sticky news

               set ::bdi_gui_binast::widget(frame,listref) [frame $f_ref.tab -borderwidth 0 -cursor arrow -relief groove]
               grid $::bdi_gui_binast::widget(frame,listref) -in $f_ref -sticky news

               set ::bdi_gui_binast::widget(frame,listsfr) [frame $f_sfr.tab -borderwidth 0 -cursor arrow -relief groove]
               grid $::bdi_gui_binast::widget(frame,listsfr) -in $f_sfr -sticky news
   
               set ::bdi_gui_binast::widget(frame,listinf) [frame $f_inf.tab -borderwidth 0 -cursor arrow -relief groove]
               grid $::bdi_gui_binast::widget(frame,listinf) -in $f_inf -sticky news

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_binast::fen

   # Chargement des donnees si elles existents

   set cpt 0
   foreach x $::bdi_tools_binast::img_list {
      set idbddimg  [::bddimages_liste::lget $x idbddimg]
      set cataexist [::bddimages_liste::lget $x cataexist]
      gren_info "$idbddimg => $cataexist \n"
      incr cpt $cataexist
   }
   gren_info "Nb CATA present : $cpt\n"


   if {$::bdi_gui_binast::widget(table,compos,list) == ""} {
      
      if { $cpt > 0} {
         set msg "Des fichiers CATA sont presents voulez vous les charger ?"
         set res [tk_messageBox -message $msg -type yesno]
         if {$res == "yes"} {
            ::bdi_gui_binast::box_create_menubutton_compo
            ::bdi_gui_binast::box_table_create_all
            ::bdi_gui_binast::import
         }    
      }
      
      if {$::bdi_gui_binast::widget(table,compos,list) == ""} {
         set res [tk_messageBox -message "Aucune composante n'a ete trouvee, vous devez commencer par les definir" -type ok]
         ::bdi_gui_binast::def_compos
      }

   } else {
      gren_erreur "Defaut\n"
      ::bdi_gui_binast::box_create_menubutton_compo
      ::bdi_gui_binast::box_table_create_all

      $::bdi_gui_binast::widget(table,listimg) selection set 0 0
      $::bdi_gui_binast::widget(current,button,img) configure -relief "sunken"
      ::bdi_gui_binast::box_cmdButton1Click $::bdi_gui_binast::widget(table,listimg)
      ::bdi_gui_binast::box_cmdButton_current "img"
   }

   ::bdi_gui_binast::def_author_update_menu
   ::bdi_gui_binast::ephem_update_menu   

   return

}














#------------------------------------------------------------
## Fermeture de l application : gestion des compos
#  @return void
proc ::bdi_gui_binast::def_compos_close {  } {
   global bddconf

   set geom [split [wm geometry $::bdi_gui_binast::widget(fenetre,def_compos)] "+"]
   set bddconf(binast,def_compos,geometry) "[lindex $geom 0]+[lindex $geom 1]+[lindex $geom 2]"
   destroy $::bdi_gui_binast::widget(fenetre,def_compos)

   return
}








#------------------------------------------------------------
## Charge la liste des compos dans l appli
#  @return void
proc ::bdi_gui_binast::def_compos_charge {  } {

   if {![info exists ::bdi_gui_binast::widget(table,compos,list)]} {
      set ::bdi_gui_binast::widget(table,compos,list) ""
      return
   }

   foreach compo $::bdi_gui_binast::widget(table,compos,list) {
      $::bdi_gui_binast::widget(table,compos) insert end $compo
   }

   return
}







#------------------------------------------------------------
## Ajoute une compo a la liste des compos
#  @return void
proc ::bdi_gui_binast::def_compos_ajout {  } {

   set ::bdi_gui_binast::widget(def_compos,newentry) [string trim $::bdi_gui_binast::widget(def_compos,newentry)]
   if {$::bdi_gui_binast::widget(def_compos,newentry)==""} {return}

   set pass "yes"
   foreach l [$::bdi_gui_binast::widget(table,compos) get 0 end] {
      if {[lindex $l 0] == $::bdi_gui_binast::widget(def_compos,newentry)} {set pass "no"}
   }

   if {$pass!="yes"} {
      tk_messageBox -message "La compo existe deja !" -type ok
      return
   }
   
   lappend ::bdi_gui_binast::widget(table,compos,list) $::bdi_gui_binast::widget(def_compos,newentry)
   $::bdi_gui_binast::widget(table,compos) insert end [list $::bdi_gui_binast::widget(def_compos,newentry)]
   set ::bdi_gui_binast::widget(def_compos,newentry) ""

   ::bdi_gui_binast::box_table_create_all   
   ::bdi_gui_binast::box_create_menubutton_compo
   ::bdi_gui_binast::box_table_listref_update_popup

   return
}







#------------------------------------------------------------
## Efface une compo a la liste des compos
#  @return void
proc ::bdi_gui_binast::def_compos_delete {  } {

   set curselection [$::bdi_gui_binast::widget(table,compos) curselection]
   set nb [llength $curselection]
   if {$nb==0} return
   if {$nb!=1} {
      set ::bdi_gui_binast::widget(def_compos,newentry) ""
      tk_messageBox -message "Un seul objet doit etre selectionné pour pouvoir etre supprimé" -type ok
      return
   }
   set select [lindex $curselection 0 ]
   set name [$::bdi_gui_binast::widget(table,compos) cellcget $select,name -text]
   $::bdi_gui_binast::widget(table,compos) delete $select $select
   set ::bdi_gui_binast::widget(def_compos,newentry) ""
   
   set cpt 0
   foreach compo $::bdi_gui_binast::widget(table,compos,list) {
      if {$name == $compo} {
         break
      }
      incr cpt
   }
   gren_info "Suppression de la compo : $name\n"
   set ::bdi_gui_binast::widget(table,compos,list) [lreplace $::bdi_gui_binast::widget(table,compos,list) $cpt $cpt]

   ::bdi_gui_binast::box_table_create_all   
   ::bdi_gui_binast::box_create_menubutton_compo
   ::bdi_gui_binast::box_table_listref_update_popup
   
   return
}









#------------------------------------------------------------
## Clic sur une compo
#  @return void
proc ::bdi_gui_binast::def_compos_cmdButton1Click { w } {

   set curselection [$::bdi_gui_binast::widget(table,compos) curselection]
   set nb [llength $curselection]
   if {$nb!=1} {
      set ::bdi_gui_binast::widget(def_compos,newentry) ""
      return
   }
   
   set select [lindex $curselection 0 ]
   set ::bdi_gui_binast::widget(def_compos,newentry) [$::bdi_gui_binast::widget(table,compos) cellcget $select,name -text]
   return
}







#------------------------------------------------------------
## GUI de gestion des compos
#  @return void
proc ::bdi_gui_binast::def_compos {  } {

   global bddconf

   set ::bdi_gui_binast::widget(def_compos,newentry) ""
   
   #--- Creation de la fenetre
   set ::bdi_gui_binast::widget(fenetre,def_compos) .def_compos
   if { [winfo exists ::bdi_gui_binast::widget(fenetre,def_compos)] } {
      ::bdi_gui_binast::def_compos_close
   }
   toplevel $::bdi_gui_binast::widget(fenetre,def_compos) -class Toplevel
   if {[ info exists bddconf(binast,def_compos,geometry)]} {
      gren_info "$bddconf(binast,def_compos,geometry)\n"
      wm geometry $::bdi_gui_binast::widget(fenetre,def_compos) $bddconf(binast,def_compos,geometry)
   }
   wm resizable $::bdi_gui_binast::widget(fenetre,def_compos) 0 1
   wm title $::bdi_gui_binast::widget(fenetre,def_compos) "Compos"
   wm protocol $::bdi_gui_binast::widget(fenetre,def_compos) WM_DELETE_WINDOW "::bdi_gui_binast::def_compos_close"

   #--- Cree un frame general
   set frm [frame $::bdi_gui_binast::widget(fenetre,def_compos).frmgen -borderwidth 0 -cursor arrow -relief groove]

      label $frm.label -text "Definir le nom des compos"
      #--- Cree un frame pour afficher la table des compos
      set frmcomp [frame $frm.frmcomp  -borderwidth 0 -cursor arrow -relief groove]
         # Colonnes
         set cols [list 0 "Name" left ]
         # Table
         set ::bdi_gui_binast::widget(table,compos) $frmcomp.table
         tablelist::tablelist $::bdi_gui_binast::widget(table,compos) \
           -columns $cols \
           -labelcommand "" \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -height 0 -width 0 \
           -state normal \
           -showseparators 1
         $::bdi_gui_binast::widget(table,compos) columnconfigure  0 -name name -editable no 
         # Popup
         set popupTbl $::bdi_gui_binast::widget(table,compos).popupTbl
         menu $popupTbl -title "Selection"
           $popupTbl add command -label "Delete" -command "::bdi_gui_binast::def_compos_delete"
         # Binding
         bind [$::bdi_gui_binast::widget(table,compos) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
         bind $::bdi_gui_binast::widget(table,compos) <<ListboxSelect>> [ list ::bdi_gui_binast::def_compos_cmdButton1Click %W ]
         # Pack
         pack $::bdi_gui_binast::widget(table,compos) -in $frmcomp -expand yes -fill both

      #--- Cree les widgets entree et boutons
      entry  $frm.name  -textvariable ::bdi_gui_binast::widget(def_compos,newentry) -width 25 -justify center
      button $frm.ajout -text "Ajouter" -borderwidth 2 -takefocus 1 -relief "raised" \
                  -command "::bdi_gui_binast::def_compos_ajout"
      button $frm.ferme -text "Fermer" -borderwidth 2 -takefocus 1 -relief "raised" \
                  -command "::bdi_gui_binast::def_compos_close"

      button $frm.import -text "Importer" -borderwidth 2 -takefocus 1 -relief "raised" \
                  -command "::bdi_gui_binast::import ; ::bdi_gui_binast::def_compos_close"

   #--- Agencement des widgets
   grid $frm -in $::bdi_gui_binast::widget(fenetre,def_compos) -sticky nsew
      grid $frm.label -column 0 -row 0 -columnspan 2 -pady 3
      grid $frmcomp -in $frm -column 0 -row 1 -columnspan 2 -pady 5
      grid $frm.name -column 0 -row 2 -columnspan 2 -padx 5 -pady 3 -sticky ew
      grid $frm.ferme -column 0 -row 3 -pady 3
      grid $frm.ajout -column 1 -row 3 -pady 3
      grid $frm.import -column 0 -row 4 -columnspan 2 -pady 3

   #--- Bind return pour creer une compo
   bind $frm.name <Return> { ::bdi_gui_binast::def_compos_ajout }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_binast::widget(fenetre,def_compos)
   #--- Focus
   focus $::bdi_gui_binast::widget(fenetre,def_compos)
   #--- Chargement des donnees
   ::bdi_gui_binast::def_compos_charge

   return

}













#------------------------------------------------------------
## Fermeture de l application : gestion des compos
#  @return void
proc ::bdi_gui_binast::def_author_close {  } {

   global bddconf

   set geom [split [wm geometry $::bdi_gui_binast::widget(fenetre,def_author)] "+"]
   set bddconf(binast,def_author,geometry) "[lindex $geom 0]+[lindex $geom 1]+[lindex $geom 2]"
   destroy $::bdi_gui_binast::widget(fenetre,def_author)

   return
}








#------------------------------------------------------------
## Charge la liste des compos dans l appli
#  @return void
#  @code ::bddimages::ressource ; ::console::clear ; ::bdi_gui_binast::def_author_charge
proc ::bdi_gui_binast::def_author_charge {  } {

   global bddconf

   $::bdi_gui_binast::widget(table,author) delete 0 end

   if {![info exists bddconf(binast,def_author,list)]} {
      set bddconf(binast,def_author,list) ""
      return
   }

   foreach author $bddconf(binast,def_author,list) {
      $::bdi_gui_binast::widget(table,author) insert end $author
   }

   return
}







#------------------------------------------------------------
## Ajoute une compo a la liste des compos
#  @return void
proc ::bdi_gui_binast::def_author_ajout {  } {

   global bddconf

   set ::bdi_gui_binast::widget(def_author,newentry) [string trim $::bdi_gui_binast::widget(def_author,newentry)]
   if {$::bdi_gui_binast::widget(def_author,newentry)==""} {return}

   set pass "yes"
   foreach author [$::bdi_gui_binast::widget(table,author) get 0 end] {
      if {$author == $::bdi_gui_binast::widget(def_author,newentry)} {set pass "no"}
   }

   if {$pass!="yes"} {
      tk_messageBox -message "L'auteur existe deja !" -type ok
      return
   }
   
   lappend bddconf(binast,def_author,list)            [list $::bdi_gui_binast::widget(def_author,newentry)]
   $::bdi_gui_binast::widget(table,author) insert end [list $::bdi_gui_binast::widget(def_author,newentry)]
   set ::bdi_gui_binast::widget(def_author,newentry) ""

   # MAJ GUI
   ::bdi_gui_binast::def_author_update_menu

   return
}





#------------------------------------------------------------
## Efface une compo a la liste des compos
#  @return void
proc ::bdi_gui_binast::def_author_delete {  } {

   global bddconf

   set curselection [$::bdi_gui_binast::widget(table,author) curselection]
   set nb [llength $curselection]
   if {$nb==0} return
   if {$nb!=1} {
      set ::bdi_gui_binast::widget(def_author,newentry) ""
      tk_messageBox -message "Un seul auteur doit etre selectionné pour pouvoir etre supprimé" -type ok
      return
   }
   set select [lindex $curselection 0]
   set author_to_del [$::bdi_gui_binast::widget(table,author) cellcget $select,name -text]
   $::bdi_gui_binast::widget(table,author) delete $select $select
   set ::bdi_gui_binast::widget(def_author,newentry) ""
   
   set nl ""
   foreach author $bddconf(binast,def_author,list) {
      if {$author != $author_to_del} {
         lappend nl $author
      }
   }
   set bddconf(binast,def_author,list) $nl

   # MAJ GUI
   ::bdi_gui_binast::def_author_update_menu   

   return
}





#------------------------------------------------------------
## Maj la fenetre principale avec la nouvelle liste des auteurs
#  @return void
proc ::bdi_gui_binast::def_author_update_menu {  } {

   global bddconf

   $::bdi_gui_binast::widget(def_author,menu) delete 0 end

   $::bdi_gui_binast::widget(def_author,menu) add command -label "Gestion" -command "::bdi_gui_binast::def_author"
   $::bdi_gui_binast::widget(def_author,menu) add separator
   
   foreach author $bddconf(binast,def_author,list) {
      $::bdi_gui_binast::widget(def_author,menu) add radiobutton -label [lindex $author 0] -variable ::bdi_gui_binast::widget(def_author,selected)
   }
   
   return
}





#------------------------------------------------------------
## Clic sur une compo
#  @return void
proc ::bdi_gui_binast::def_author_cmdButton1Click { w } {

   set curselection [$::bdi_gui_binast::widget(table,author) curselection]
   set nb [llength $curselection]
   if {$nb!=1} {
      set ::bdi_gui_binast::widget(def_author,newentry) ""
      return
   }
   
   set select [lindex $curselection 0]
   set ::bdi_gui_binast::widget(def_author,newentry) [$::bdi_gui_binast::widget(table,author) cellcget $select,name -text]
   return
}









#------------------------------------------------------------
## GUI de gestion des auteurs
#  @return void
proc ::bdi_gui_binast::def_author {  } {

   global bddconf

   set ::bdi_gui_binast::widget(def_author,newentry) ""
   
   #--- Creation de la fenetre
   set ::bdi_gui_binast::widget(fenetre,def_author) .def_author
   if { [winfo exists $::bdi_gui_binast::widget(fenetre,def_author)] } {
      ::bdi_gui_binast::def_author_close
   }
   toplevel $::bdi_gui_binast::widget(fenetre,def_author) -class Toplevel
   if {[ info exists bddconf(binast,def_author,geometry)]} {
      gren_info "$bddconf(binast,def_author,geometry)\n"
      wm geometry $::bdi_gui_binast::widget(fenetre,def_author) $bddconf(binast,def_author,geometry)
   }
   wm resizable $::bdi_gui_binast::widget(fenetre,def_author) 0 1
   wm title $::bdi_gui_binast::widget(fenetre,def_author) "Gestion des auteurs"
   wm protocol $::bdi_gui_binast::widget(fenetre,def_author) WM_DELETE_WINDOW "::bdi_gui_binast::def_author_close"

   #--- Cree un frame general
   set frm [frame $::bdi_gui_binast::widget(fenetre,def_author).frmgen -borderwidth 0 -cursor arrow -relief groove]

      label $frm.label -text "Definir le nom des auteurs"
      #--- Cree un frame pour afficher la table des auteurs
      set frmauth [frame $frm.frmauth  -borderwidth 0 -cursor arrow -relief groove]
         # Colonnes
         set cols [list 0 "Name" left ]
         # Table
         set ::bdi_gui_binast::widget(table,author) $frmauth.table
         tablelist::tablelist $::bdi_gui_binast::widget(table,author) \
           -columns $cols \
           -labelcommand "" \
           -selectmode extended \
           -activestyle none \
           -stripebackground "#e0e8f0" \
           -height 0 -width 0 \
           -state normal \
           -showseparators 1
         $::bdi_gui_binast::widget(table,author) columnconfigure  0 -name name -editable no 
         # Popup
         set popupTbl $::bdi_gui_binast::widget(table,author).popupTbl
         menu $popupTbl -title "Selection"
           $popupTbl add command -label "Delete" -command "::bdi_gui_binast::def_author_delete"
         # Binding
         bind [$::bdi_gui_binast::widget(table,author) bodypath] <ButtonPress-3> [ list tk_popup $popupTbl %X %Y ]
         bind $::bdi_gui_binast::widget(table,author) <<ListboxSelect>> [ list ::bdi_gui_binast::def_author_cmdButton1Click %W ]
         # Pack
         pack $::bdi_gui_binast::widget(table,author) -in $frmauth -expand yes -fill both

      #--- Cree les widgets entree et boutons
      entry  $frm.name  -textvariable ::bdi_gui_binast::widget(def_author,newentry) -width 25 -justify center
      button $frm.ajout -text "Ajouter" -borderwidth 2 -takefocus 1 -relief "raised" \
                  -command "::bdi_gui_binast::def_author_ajout"
      button $frm.ferme -text "Fermer" -borderwidth 2 -takefocus 1 -relief "raised" \
                  -command "::bdi_gui_binast::def_author_close"

   #--- Agencement des widgets
   grid $frm -in $::bdi_gui_binast::widget(fenetre,def_author) -sticky nsew
      grid $frm.label -column 0 -row 0 -columnspan 2 -pady 3
      grid $frmauth -in $frm -column 0 -row 1 -columnspan 2 -pady 5
      grid $frm.name -column 0 -row 2 -columnspan 2 -padx 5 -pady 3 -sticky ew
      grid $frm.ajout -column 0 -row 3 -pady 3
      grid $frm.ferme -column 1 -row 3 -pady 3

   #--- Bind return pour creer un auteur
   bind $frm.name <Return> { ::bdi_gui_binast::def_author_ajout }
   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $::bdi_gui_binast::widget(fenetre,def_author)
   #--- Focus
   focus $::bdi_gui_binast::widget(fenetre,def_author)
   #--- Chargement des donnees
   ::bdi_gui_binast::def_author_charge

   return

}

