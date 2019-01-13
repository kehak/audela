#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::export {  } {

   global bddconf

   set l [$::bdi_gui_binast::widget(table,listimg) get 0 end]
   set cpt 0
   foreach x $l {

      lassign $x date telescope img c1 c2 c3
      gren_info "Export BINAST cata de l'image courante : $date $telescope $img $c1 $c2 $c3\n"
 
      if {$::bdi_gui_binast::widget(data,$date,status) != "Modified"} {continue}

      # Recuperation du TABKEY de l'image courante
      set pass "no"
      foreach ::bdi_tools_binast::current_image $::bdi_tools_binast::img_list {
         set tabkey [::bddimages_liste::lget $::bdi_tools_binast::current_image "tabkey"]
         set bimtype [string trim [lindex [::bddimages_liste::lget $tabkey "bimtype"] 1]]
         if {$bimtype != "IMG"} { continue  }
         set d [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
         if {$d == $date} {
            set pass "yes"
            break
         }
      }
      if {$pass == "no"} {
         tk_messageBox -message "Erreur: l'image n'est pas dans la liste" -type ok
         return
      }

      # Nom de l'image courante
      set filename [::bddimages_liste::lget $::bdi_tools_binast::current_image filename]

      # Construction du listsources
      # -- fields
      set img_fields [list system_id system_name target_name compo_ref \
                           tjj tiso dx err_dx dy err_dy rho err_rho \
                           xsm err_xsm ysm err_ysm fwhmx fwhmy fwhm flux err_flux pixmax intensity sky err_sky snint radius err_psf \
                           dynamic mag err_mag dmag err_dmag \
                           x_omc y_omc err_x_omc err_y_omc \
                           input_radius radius_min radius_max globale_min globale_max globale_confidence saturation threshold \
                           globale ecretage methode precision photom_r1 photom_r2 photom_r3 marks_cercle globale_arret \
                           globale_nberror gaussian_statistics read_out_noise beta quality \
                           author when bibitem]

      set fields [list [list BINAST [list ra dec poserr mag magerr] $img_fields]]

      # Reference
      set compo_ref ""
      foreach compo $::bdi_gui_binast::widget(table,compos,list) {
         if { $::bdi_gui_binast::widget(data,listref,$date,$compo) == "x"} {
            set compo_ref $compo
         }
      }
      if {$compo_ref == ""} {
         set msg "Vous devez selectionner une reference pour cette image : $date"
         tk_messageBox -message $msg -type ok
      }
      
      # Calcul des magnitudes
      ::bdi_gui_binast::box_mag $date
      
      # -- sources
      set sources {}
      foreach compo $::bdi_gui_binast::widget(table,compos,list) {
      
         # Dates
         set tjj [mc_date2jd $date]
         set tiso $date

         # PSF Resultats
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)                     ]} {set xsm                 $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)                     } else { set xsm                 "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)                 ]} {set err_xsm             $::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)                 } else { set err_xsm             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)                     ]} {set ysm                 $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)                     } else { set ysm                 "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)                 ]} {set err_ysm             $::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)                 } else { set err_ysm             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmx)                   ]} {set fwhmx               $::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmx)                   } else { set fwhmx               "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmy)                   ]} {set fwhmy               $::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmy)                   } else { set fwhmy               "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhm)                    ]} {set fwhm                $::bdi_gui_binast::widget(data,$date,$compo,psf,fwhm)                    } else { set fwhm                "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,flux)                    ]} {set flux                $::bdi_gui_binast::widget(data,$date,$compo,psf,flux)                    } else { set flux                "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux)                ]} {set err_flux            $::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux)                } else { set err_flux            "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,pixmax)                  ]} {set pixmax              $::bdi_gui_binast::widget(data,$date,$compo,psf,pixmax)                  } else { set pixmax              "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,intensity)               ]} {set intensity           $::bdi_gui_binast::widget(data,$date,$compo,psf,intensity)               } else { set intensity           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,sky)                     ]} {set sky                 $::bdi_gui_binast::widget(data,$date,$compo,psf,sky)                     } else { set sky                 "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_sky)                 ]} {set err_sky             $::bdi_gui_binast::widget(data,$date,$compo,psf,err_sky)                 } else { set err_sky             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,snint)                   ]} {set snint               $::bdi_gui_binast::widget(data,$date,$compo,psf,snint)                   } else { set snint               "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,radius)                  ]} {set radius              $::bdi_gui_binast::widget(data,$date,$compo,psf,radius)                  } else { set radius              "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_psf)                 ]} {set err_psf             $::bdi_gui_binast::widget(data,$date,$compo,psf,err_psf)                 } else { set err_psf             "" }

         # PSF Resultats derives
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,dynamic)              ]} {set dynamic             $::bdi_gui_binast::widget(data,$date,$compo,mesure,dynamic)              } else { set dynamic             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)                  ]} {set mag                 $::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)                  } else { set mag                 "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)              ]} {set err_mag             $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)              } else { set err_mag             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)                 ]} {set dmag                $::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)                 } else { set dmag                "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag)             ]} {set err_dmag            $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag)             } else { set err_dmag            "" }

         # Positions & Erreurs ephemerides
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x)                 ]} {set x_omc               $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x)                 } else { set x_omc               "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y)                 ]} {set y_omc               $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y)                 } else { set y_omc               "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x)             ]} {set err_x_omc           $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x)             } else { set err_x_omc           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y)             ]} {set err_y_omc           $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y)             } else { set err_y_omc           "" }

         # Positions & Erreurs derivees
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,dx)                   ]} {set dx                  $::bdi_gui_binast::widget(data,$date,$compo,mesure,dx)                   } else { set dx                  "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dx)               ]} {set err_dx              $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dx)               } else { set err_dx              "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,dy)                   ]} {set dy                  $::bdi_gui_binast::widget(data,$date,$compo,mesure,dy)                   } else { set dy                  "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dy)               ]} {set err_dy              $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dy)               } else { set err_dy              "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,rho)                  ]} {set rho                 $::bdi_gui_binast::widget(data,$date,$compo,mesure,rho)                  } else { set rho                 "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_rho)              ]} {set err_rho             $::bdi_gui_binast::widget(data,$date,$compo,mesure,err_rho)              } else { set err_rho             "" }
 
         # PSF Methode utilisee
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,radius)              ]} {set input_radius        $::bdi_gui_binast::widget(data,$date,$compo,methode,radius)              } else { set input_radius        "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,min)          ]} {set radius_min          $::bdi_gui_binast::widget(data,$date,$compo,methode,radius,min)          } else { set radius_min          "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,max)          ]} {set radius_max          $::bdi_gui_binast::widget(data,$date,$compo,methode,radius,max)          } else { set radius_max          "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,min)         ]} {set globale_min         $::bdi_gui_binast::widget(data,$date,$compo,methode,globale,min)         } else { set globale_min         "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,max)         ]} {set globale_max         $::bdi_gui_binast::widget(data,$date,$compo,methode,globale,max)         } else { set globale_max         "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,confidence)  ]} {set globale_confidence  $::bdi_gui_binast::widget(data,$date,$compo,methode,globale,confidence)  } else { set globale_confidence  "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,saturation)          ]} {set saturation          $::bdi_gui_binast::widget(data,$date,$compo,methode,saturation)          } else { set saturation          "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,threshold)           ]} {set threshold           $::bdi_gui_binast::widget(data,$date,$compo,methode,threshold)           } else { set threshold           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale)             ]} {set globale             $::bdi_gui_binast::widget(data,$date,$compo,methode,globale)             } else { set globale             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,ecretage)            ]} {set ecretage            $::bdi_gui_binast::widget(data,$date,$compo,methode,ecretage)            } else { set ecretage            "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,methode)             ]} {set methode             $::bdi_gui_binast::widget(data,$date,$compo,methode,methode)             } else { set methode             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,precision)           ]} {set precision           $::bdi_gui_binast::widget(data,$date,$compo,methode,precision)           } else { set precision           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r1)           ]} {set photom_r1           $::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r1)           } else { set photom_r1           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r2)           ]} {set photom_r2           $::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r2)           } else { set photom_r2           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r3)           ]} {set photom_r3           $::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r3)           } else { set photom_r3           "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,marks,cercle)        ]} {set marks_cercle        $::bdi_gui_binast::widget(data,$date,$compo,methode,marks,cercle)        } else { set marks_cercle        "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,arret)       ]} {set globale_arret       $::bdi_gui_binast::widget(data,$date,$compo,methode,globale,arret)       } else { set globale_arret       "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,nberror)     ]} {set globale_nberror     $::bdi_gui_binast::widget(data,$date,$compo,methode,globale,nberror)     } else { set globale_nberror     "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,gaussian_statistics) ]} {set gaussian_statistics $::bdi_gui_binast::widget(data,$date,$compo,methode,gaussian_statistics) } else { set gaussian_statistics "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,read_out_noise)      ]} {set read_out_noise      $::bdi_gui_binast::widget(data,$date,$compo,methode,read_out_noise)      } else { set read_out_noise      "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,methode,beta)                ]} {set beta                $::bdi_gui_binast::widget(data,$date,$compo,methode,beta)                } else { set beta                "" }

         # Frame
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)              ]} {set quality             $::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)              } else { set quality             "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,author)               ]} {set author              $::bdi_gui_binast::widget(data,$date,$compo,mesure,author)               } else { set author              "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,when)                 ]} {set when                $::bdi_gui_binast::widget(data,$date,$compo,mesure,when)                 } else { set when                "" }
         if {[info exists ::bdi_gui_binast::widget(data,$date,$compo,mesure,bibitem)              ]} {set bibitem             $::bdi_gui_binast::widget(data,$date,$compo,mesure,bibitem)              } else { set bibitem             "" }

         # Build the Fucking Data Line
         set l ""

         # Designations
         lappend l $::bdi_gui_binast::widget(system,id)
         lappend l $::bdi_gui_binast::widget(system,name) 
         lappend l $compo 
         lappend l $compo_ref 

         # Dates
         lappend l $tjj 
         lappend l $tiso 

         # PSF Resultats
         lappend l $xsm     
         lappend l $err_xsm 
         lappend l $ysm     
         lappend l $err_ysm 
         lappend l $fwhmx 
         lappend l $fwhmy 
         lappend l $fwhm 
         lappend l $flux 
         lappend l $err_flux
         lappend l $pixmax 
         lappend l $intensity 
         lappend l $sky 
         lappend l $err_sky 
         lappend l $snint 
         lappend l $radius 
         lappend l $err_psf 

         # PSF Resultats derives
         lappend l $dynamic 
         lappend l $mag 
         lappend l $err_mag 
         lappend l $dmag 
         lappend l $err_dmag 

         # Positions & Erreurs ephemerides
         lappend l $x_omc    
         lappend l $y_omc    
         lappend l $err_x_omc
         lappend l $err_y_omc 

         # Positions & Erreurs derivees
         lappend l $dx     
         lappend l $err_dx 
         lappend l $dy     
         lappend l $err_dy 
         lappend l $rho    
         lappend l $err_rho

         # PSF Methode utilisee
         lappend l $input_radius       
         lappend l $radius_min         
         lappend l $radius_max         
         lappend l $globale_min        
         lappend l $globale_max        
         lappend l $globale_confidence 
         lappend l $saturation         
         lappend l $threshold          
         lappend l $globale            
         lappend l $ecretage           
         lappend l $methode            
         lappend l $precision          
         lappend l $photom_r1          
         lappend l $photom_r2          
         lappend l $photom_r3          
         lappend l $marks_cercle       
         lappend l $globale_arret      
         lappend l $globale_nberror    
         lappend l $gaussian_statistics
         lappend l $read_out_noise     
         lappend l $beta               

         # Frame
         lappend l $quality 
         lappend l $author 
         lappend l $when 
         lappend l $bibitem

         lappend sources [list [list "BINAST" {} $l]]
      }

      # -- listsources
      set current_listsources [list $fields $sources]

      # Sauvegarde du cata XML
      set f [file join $bddconf(dirtmp) $filename]
      set result [bddimages_formatfichier $f]
      set racinefich [lindex $result 1]
      set cataxml "${racinefich}_cata.xml"
      gren_info " -> Enregistrement du cata XML: $cataxml\n"
      set votable [::votableUtil::list2votable $current_listsources $tabkey]
      set fxml [open $cataxml "w"]
      puts $fxml $votable
      close $fxml
      incr cpt

   }

   gren_info "Nombre de fichiers exportes : $cpt\n"
   gren_info "Export termine"
   
   return
}











#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::import {  } {

   global bddconf

   gren_info "+ Import\n"

   set list_target ""

   foreach x $::bdi_gui_binast::img_list {

      #gren_info "Import BINAST cata : $x\n"

      set idbddimg [::bddimages_liste::lget $x idbddimg]
      set tabkey [::bddimages_liste::lget $x "tabkey"]
      set bimtype [string trim [lindex [::bddimages_liste::lget $tabkey "bimtype"]   1] ]
      if {$bimtype != "IMG"} { continue }
      
      # Date
      set date  [lindex [::bddimages_liste::lget $tabkey DATE-OBS] 1]

      # Nom complet de l'image
      set fi [::bddimages_liste::lget $x filename]
      set di [::bddimages_liste::lget $x dirfilename]
      set imgfilename [file join $bddconf(dirbase) $di $fi]
      # Nom complet du cata
      set cataexist       [::bddimages_liste::lget $x cataexist]
      set catadatemodif   [::bddimages_liste::lget $x catadatemodif]
      set catafilename    [::bddimages_liste::lget $x catafilename]
      set catadirfilename [::bddimages_liste::lget $x catadirfilename]
      set fcata [file join $bddconf(dirbase) $catadirfilename $catafilename]
      #gren_info "fcata => ($cataexist) ($catadatemodif) $fcata\n"

#set catafilename "/observ/bddimages/bdi_OA/tmp/sylvia-keck-2002-03-07-01-Image.fits.gz_cata.xml"

      #gren_info "=> : $idbddimg :: $imgfilename :: $fcata\n"
      # Test d'existence physique du fichier cata
      if { ! [file isfile $fcata] } {
         gren_erreur "Warning: aucun cata trouve pour l'image $fi\n" 
         continue
      }

      gren_info "Chargement de $fcata\n"

      # Recupere le cata xml
      set errnum [catch {set catafile [::tools_cata::extract_cata_xml $fcata]} msg ]
      if {$errnum} {
         return -code $errnum $msg
      }

      # Charge la liste des sources depuis les cata (les common sont vides)
      set listsources [::tools_cata::get_cata_xml $catafile]

      #gren_info "CATA: $listsources\n\n"

      set sources [lindex $listsources 1]
      foreach s $sources {
         foreach cata $s {
            if {[string toupper [lindex $cata 0]] == "BINAST"} {
               set othf [lindex $cata 2]
               
               set idsys   [lindex $othf 0]
               set namesys [lindex $othf 1]
               if {$idsys != $::bdi_gui_binast::widget(system,id)} {
                  gren_erreur "idsys lu : $idsys\n"
                  gren_erreur "idsys definit : $::bdi_gui_binast::widget(system,id)\n"
                  set msg    "L'id systeme est different detail dans la console"
                  tk_messageBox -message $msg -type ok
                  return
               }
               if {$namesys != $::bdi_gui_binast::widget(system,name)} {
                  gren_erreur "namesys lu : $namesys\n"
                  gren_erreur "namesys definit : $::bdi_gui_binast::widget(system,name)\n"
                  set msg    "Le nom du systeme est different detail dans la console"
                  return
               }
               #gren_info "othf = $othf\n"
               set compo [lindex $othf 2]
               set date  [lindex $othf 5]
               #gren_info "++$compo $date\n"
               lassign $othf idsys namesys \
                             compo \
                             compo_ref \
                             tjj \
                             tiso \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)                        \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)                        \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmx)                      \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhmy)                      \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,fwhm)                       \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,flux)                       \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,err_flux)                   \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,pixmax)                     \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,intensity)                  \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,sky)                        \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,err_sky)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,snint)                      \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,radius)                     \
                             ::bdi_gui_binast::widget(data,$date,$compo,psf,err_psf)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,dynamic)                 \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,mag)                     \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_mag)                 \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,dmag)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dmag)                \
                             ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x)                \
                             ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y)                \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,dx)                      \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dx)                  \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,dy)                      \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_dy)                  \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,rho)                     \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,err_rho)                 \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,radius)                 \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,min)             \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,radius,max)             \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,min)            \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,max)            \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,confidence)     \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,saturation)             \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,threshold)              \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale)                \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,ecretage)               \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,methode)                \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,precision)              \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r1)              \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r2)              \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,photom,r3)              \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,marks,cercle)           \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,arret)          \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,globale,nberror)        \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,gaussian_statistics)    \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,read_out_noise)         \
                             ::bdi_gui_binast::widget(data,$date,$compo,methode,beta)                   \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)                 \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,author)                  \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,when)                    \
                             ::bdi_gui_binast::widget(data,$date,$compo,mesure,bibitem)
                                                                                        
               #gren_info "compo = $compo \[$compo_ref\]\n"
               if {$compo == $compo_ref} {
                  set ::bdi_gui_binast::widget(data,listref,$date,$compo) "x"
               } else {
                  set ::bdi_gui_binast::widget(data,listref,$date,$compo) ""
               }
               
               set exist "no"
               if {$compo ni $::bdi_gui_binast::widget(table,compos,list)} {
                  lappend ::bdi_gui_binast::widget(table,compos,list) $compo
               }
               
               if {$::bdi_gui_binast::widget(data,$date,$compo,psf,xsm) !="" && $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm) !=""} {
                  set ::bdi_gui_binast::widget(data,listcmp,$date,$compo) "x"
               } else {
                  set ::bdi_gui_binast::widget(data,listcmp,$date,$compo) ""
               }
               
               set ::bdi_gui_binast::widget(data,$date,status) "Saved"

               set ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm,cata)     $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)     
               set ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm,cata)     $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)     

               set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x,cata)     $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x)     
               set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y,cata)     $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y)     
               set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x,cata) $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x) 
               set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y,cata) $::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y) 
               set ::bdi_gui_binast::widget(data,$date,$compo,mesure,quality,cata)  $::bdi_gui_binast::widget(data,$date,$compo,mesure,quality)
               set ::bdi_gui_binast::widget(data,$date,$compo,mesure,author,cata)   $::bdi_gui_binast::widget(data,$date,$compo,mesure,author)
               
            }
         }
      }
   }

   # on recree les tables de la GUI
   ::bdi_gui_binast::box_table_create_all   
   ::bdi_gui_binast::box_create_menubutton_compo
   ::bdi_gui_binast::box_table_listref_update_popup

   # on definit la date courante
   set date [lindex [$::bdi_gui_binast::widget(table,listimg) get 0] 0]
   set ::bdi_gui_binast::widget(current,date) $date
   # Decoche tous les boutons de type d image
   foreach type [list "img" "c1" "c2" "c3"] {
      $::bdi_gui_binast::widget(current,button,$type) configure -relief "raised"
   }
   # Coche le bouton de type IMG
   $::bdi_gui_binast::widget(current,button,img) configure -relief "sunken"
   # Selection de la premiere image dans la table
   $::bdi_gui_binast::widget(table,listimg) selection set 0 0
   # on clique dans la table image
   ::bdi_gui_binast::box_cmdButton1Click $::bdi_gui_binast::widget(table,listimg)
   # on appuie sur le bouton IMG
   ::bdi_gui_binast::box_cmdButton_current "img"
   # on cale l onglet sur la table image
   $::bdi_gui_binast::widget(frame,onglets) select $::bdi_gui_binast::widget(frame,onglets).f_img
   
   gren_info "Import termine\n"

   return
}


#------------------------------------------------------------
## 
#  @return void
proc ::bdi_gui_binast::insert {  } {

   global bddconf

   set l [$::bdi_gui_binast::widget(table,listimg) get 0 end]
   set cpt 0
   foreach x $l {

      lassign $x date telescope img c1 c2 c3
      gren_info "Export BINAST cata de l'image courante : $date $telescope $img $c1 $c2 $c3\n"
      
      if {$::bdi_gui_binast::widget(data,$date,status) != "Modified"} {continue}
      
      # Recuperation du TABKEY de l'image courante
      set pass "no"
      foreach ::bdi_tools_binast::current_image $::bdi_tools_binast::img_list {
         set tabkey [::bddimages_liste::lget $::bdi_tools_binast::current_image "tabkey"]
         set bimtype [string trim [lindex [::bddimages_liste::lget $tabkey "bimtype"] 1]]
         if {$bimtype != "IMG"} { continue  }
         set d [string trim [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]]
         if {$d == $date} {
            set pass "yes"
            break
         }
      }
      if {$pass == "no"} {
         tk_messageBox -message "Erreur: l'image n'est pas dans la liste" -type ok
         return
      }

      # Id de l'image courante
      set idbddimg [::bddimages_liste::lget $::bdi_tools_binast::current_image idbddimg]
      set filename [::bddimages_liste::lget $::bdi_tools_binast::current_image filename]
      gren_info "filename -> $filename\n"

      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]

      gren_info "ident -> [lindex $ident 0] :: $fileimg :: [lindex $ident 2] :: $filecata\n"

      set err ""
      set pass "yes"

      set f [file join $bddconf(dirtmp) $filename]
      set result [bddimages_formatfichier $f]
      set racinefich [lindex $result 1]
      set cataxml "${racinefich}_cata.xml"
      gren_info "cataxml -> $cataxml\n"
      # Verifications avant insertion
      if {$fileimg == -1} {
         set err "Fichier image inexistant ($idbddimg)  \n"
         continue
      }
      
      set err [ catch { insertion_solo $cataxml } msg ]
      if {$err} { gren_info "$err : Fichier cata $cataxml echec insertion\n" }
      
      set ::bdi_gui_binast::widget(data,$date,status) "Saved"
      incr cpt
      continue
      #gren_info "TO_INSERT pop : [file tail $fileimg] : PASS=$pass : ERR=$err"

      # Copier $fileimg vers $tmpimg

      # Modifier le header de l'image -> cata existe

      # efface l image dans la base et le disqueMASTER TO_INSERT 
      #gren_info "[gren_date] MASTER                    bddimages_image_delete_fromsql"
      bddimages_image_delete_fromsql $ident
      #gren_info "[gren_date] MASTER                    bddimages_image_delete_fromdisk"
      bddimages_image_delete_fromdisk $ident
      # insere l image dans la base
      #gren_info "[gren_date] MASTER                    insertion_solo $tmpimg"
      set err [catch {insertion_solo $tmpimg} idbddimg]
      #if {$err==0} { gren_info "TO_INSERT image inseree " }
      # Insertion du cata dans la base
      #gren_info "[gren_date] MASTER                    insertion_solo $tmpcata"
      set err [ catch { insertion_solo $tmpcata } msg ]
      if {$err} { set err "$err : Fichier cata $tmpcata echec insertion\n" }

   }
   
   
   gren_info "Nombre de fichiers inseres : $cpt\n"
   gren_info "Insertion terminee"
   
   
   return

}
