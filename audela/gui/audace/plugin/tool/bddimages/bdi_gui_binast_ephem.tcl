# compo = Camilla [Camilla]
# compo = S2001-107-1 [Camilla]
# compo = S2016-107-1 [Camilla]


#------------------------------------------------------------
## Maj la fenetre principale avec la nouvelle liste des auteurs
#  @return void
proc ::bdi_gui_binast::ephem_update_menu {  } {

   global bddconf

   catch { $::bdi_gui_binast::widget(ephem,menu) delete 0 end}

   $::bdi_gui_binast::widget(ephem,menu) add command -label "Get solution" -command "::bdi_gui_binast::get_ephem"
   $::bdi_gui_binast::widget(ephem,menu) add separator
   
   if {! [info exists ::bdi_gui_binast::widget(ephem,solution,list)] } { return }

   foreach ephem $::bdi_gui_binast::widget(ephem,solution,list) {
      $::bdi_gui_binast::widget(ephem,menu) add radiobutton -label $ephem -variable ::bdi_gui_binast::widget(ephem,selected)
   }
   return
}



#------------------------------------------------------------
## Maj la fenetre principale avec la nouvelle liste des auteurs
#  @return void
proc ::bdi_gui_binast::get_ephem {  } {

   set ::bdi_gui_binast::widget(ephem,solution,list) ""
   set ::bdi_gui_binast::widget(ephem,selected)      ""
   
   array unset ::bdi_gui_binast::ephem
   set ::bdi_gui_binast::ephem(gensol,list) ""
   set ::bdi_gui_binast::ephem(compo,list) ""


   foreach date $::bdi_gui_binast::widget(data,dates) {
      
      set system   $::bdi_gui_binast::widget(system,name)

      gren_info "vo_miriade_ephemsys a:$system $date 1 1d UTC 0 votable\n"   

      ::bdi_gui_binast::read_xml_ephem [vo_miriade_ephemsys "a:$system" $date 1 "1d" "UTC" 0 "votable"] $date
      #set date "2018-11-16T01:21:00"
      # ::bdi_gui_binast::read_xml_ephem [vo_miriade_ephemsys "a:kalliope" "2018-11-16T01:21:00" 1 "1d" "UTC" 0 "votable"] $date
      # ::bdi_gui_binast::read_xml_ephem [vo_miriade_ephemsys "a:$::bdi_gui_binast::widget(system,name)" $date 1 "1d" "UTC" 0 "votable"] $date

      #::bdi_gui_binast::ephem_update_menu   

      gren_info "gensol list : $::bdi_gui_binast::ephem(gensol,list)\n"   
   }
   
   # Verif
   set msg ""
   foreach compo $::bdi_gui_binast::ephem(compo,list) {
      if {$compo ni $::bdi_gui_binast::widget(table,compos,list)} {
         append msg "WARNING : $compo n est pas dans la liste des Compos\n" 
      }
   }
   foreach compo $::bdi_gui_binast::widget(table,compos,list) {
      if {$compo ni $::bdi_gui_binast::ephem(compo,list)} {
         append msg "WARNING : $compo n est pas dans la liste des ephemerides\n" 
      }
   }
   if {$msg != "" } {
      set msg "Verifier les points suivants :\n\n$msg"
      tk_messageBox -message $msg -type ok
   }

   # GUI
   set ::bdi_gui_binast::widget(ephem,solution,list) $::bdi_gui_binast::ephem(gensol,list)
   set ::bdi_gui_binast::widget(ephem,selected) [lindex $::bdi_gui_binast::ephem(gensol,list) 0]
   ::bdi_gui_binast::ephem_update_menu
   
   return
}




proc ::bdi_gui_binast::read_xml_ephem { xmldoc date } {

   global bddconf

   gren_info "read_ephem :: begin\n"
   
   
   set fxml [open [file join $bddconf(dirtmp) "req_miriade.xml"] "w"]
   puts $fxml $xmldoc
   close $fxml
   gren_info "file save  :: [file join $bddconf(dirtmp) "req_miriade.xml"]\n"


   set xml [::dom::parse $xmldoc]
   
   foreach resource [::dom::selectNode $xml {descendant::RESOURCE}] {

      set gensol     ""
      set namesystem "" 
 
      if { [catch {::dom::node stringValue [::dom::selectNode $resource {attribute::ID}]} val] == 0 } {
         set gensol $val
      }
      if { [catch {::dom::node stringValue [::dom::selectNode $resource {attribute::name}]} val] == 0 } {
         set namesystem $val
      }
      
      gren_info "gensol     = $gensol\n"
      gren_info "namesystem = $namesystem\n"
      
      set ::bdi_gui_binast::ephem($gensol,solution,date)   ""
      set ::bdi_gui_binast::ephem($gensol,solution,id)     ""
      set ::bdi_gui_binast::ephem($gensol,solution,method) ""
      set ::bdi_gui_binast::ephem($gensol,solution,fomc)   ""
      set ::bdi_gui_binast::ephem($gensol,solution,proba)  ""
      

      foreach param [::dom::selectNode $resource {descendant::PARAM}] {
         if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::name}]} val] == 0 } {
  
            switch $val {
               "GenoideSolutionDate" {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set ::bdi_gui_binast::ephem($gensol,solution,date) $val
                  }
               }
               "GenoideSolutionId" {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set ::bdi_gui_binast::ephem($gensol,solution,id) $val
                  }
               }
               "GenoideMethod" {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set ::bdi_gui_binast::ephem($gensol,solution,method) $val
                  }
               }
               "GenoideFomc" {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set ::bdi_gui_binast::ephem($gensol,solution,fomc) $val
                  }
               }
               "GenoideProba" {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set ::bdi_gui_binast::ephem($gensol,solution,proba) $val
                  }
               }
            }
         }
      }
      
      # Construction de la ligne affichable de la solution 
      set    solution "$::bdi_gui_binast::ephem($gensol,solution,id): $::bdi_gui_binast::ephem($gensol,solution,method) "
      append solution " $::bdi_gui_binast::ephem($gensol,solution,fomc)\" $::bdi_gui_binast::ephem($gensol,solution,proba) % "
      append solution " \[$::bdi_gui_binast::ephem($gensol,solution,date)\]"
 
      if { $solution ni $::bdi_gui_binast::ephem(gensol,list) } {
         set ::bdi_gui_binast::ephem(solution,$solution) $gensol
         set ::bdi_gui_binast::ephem(gensol,$gensol)     $solution
         lappend ::bdi_gui_binast::ephem(gensol,list)    $solution
      }

      gren_info "   gensol date      = $::bdi_gui_binast::ephem($gensol,solution,date)\n"
      gren_info "   gensol id        = $::bdi_gui_binast::ephem($gensol,solution,id)\n"
      gren_info "   gensol method    = $::bdi_gui_binast::ephem($gensol,solution,method)\n"
      gren_info "   gensol fomc      = $::bdi_gui_binast::ephem($gensol,solution,fomc)\n"
      gren_info "   gensol proba     = $::bdi_gui_binast::ephem($gensol,solution,proba)\n"
      gren_info "   gensol solution  = $::bdi_gui_binast::ephem(gensol,$gensol)\n"

      foreach table [::dom::selectNode $resource {descendant::TABLE}] {
         
         # selection de la table
         set idtable "" 
         if { [catch {::dom::node stringValue [::dom::selectNode $table {attribute::ID}]} val] == 0 } {
            set idtable $val
         }
         gren_info "idtable = $idtable\n"
         
         # Recupere le nom de la compo
         set compo ""
         foreach param [::dom::selectNode $table {descendant::PARAM}] {
            if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::name}]} val] == 0 } {
               #gren_info "param name = $val\n"
               if {$val == "ComponentName" } {
                  if { [catch {::dom::node stringValue [::dom::selectNode $param {attribute::value}]} val] == 0 } {
                     set compo $val
                  }
               }
            }
         }
         if { $compo == "" } { continue }
         gren_info "compo = $compo\n"
         if { $compo ni $::bdi_gui_binast::ephem(compo,list) } {
            lappend ::bdi_gui_binast::ephem(compo,list) $compo
         }
         
         # Recupere les donnees
         set l ""
         foreach td [::dom::selectNode $table {descendant::TD/text()}] {
            set tdv "" 
            if { [catch {::dom::node stringValue $td} val] == 0 } {
               set tdv $val
            }
            #gren_info "td = $tdv\n"
            lappend l $tdv
         }

         set ::bdi_gui_binast::ephem($date,$compo,dx)                [lindex $l 1]
         set ::bdi_gui_binast::ephem($date,$compo,dy)                [lindex $l 2]
         set ::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma) [lindex $l 3]
         set ::bdi_gui_binast::ephem($date,$compo,dy_min_err_1sigma) [lindex $l 4]
         set ::bdi_gui_binast::ephem($date,$compo,dx_max_err_1sigma) [lindex $l 5]
         set ::bdi_gui_binast::ephem($date,$compo,dy_max_err_1sigma) [lindex $l 6]
         set ::bdi_gui_binast::ephem($date,$compo,dx_min_err_2sigma) [lindex $l 7]
         set ::bdi_gui_binast::ephem($date,$compo,dy_min_err_2sigma) [lindex $l 8]
         set ::bdi_gui_binast::ephem($date,$compo,dx_max_err_2sigma) [lindex $l 9]
         set ::bdi_gui_binast::ephem($date,$compo,dy_max_err_2sigma) [lindex $l 10]
         set ::bdi_gui_binast::ephem($date,$compo,dx_min_err_3sigma) [lindex $l 11]
         set ::bdi_gui_binast::ephem($date,$compo,dy_min_err_3sigma) [lindex $l 12]
         set ::bdi_gui_binast::ephem($date,$compo,dx_max_err_3sigma) [lindex $l 13]
         set ::bdi_gui_binast::ephem($date,$compo,dy_max_err_3sigma) [lindex $l 14]

         gren_info "ephem($date,$compo,dx)  = $::bdi_gui_binast::ephem($date,$compo,dx)\n"
         gren_info "ephem($date,$compo,dy)  = $::bdi_gui_binast::ephem($date,$compo,dy)\n"

         gren_info "ephem($date,$compo,dx_min_err_1sigma)  = $::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma)\n"
         
      }
      
   }


   gren_info "read_ephem :: end\n"
   return 

}











   
   
#  ::bddimages::ressource ;  ::bdi_gui_binast::box_ephem $date $compo "data"

proc ::bdi_gui_binast::box_ephem { date compo orig } {

   set pi [::pi]
   gren_info "box_ephem : $date $compo $orig\n"
   
   # Init
   set ::bdi_gui_binast::widget(ephem,omc,x) ""
   set ::bdi_gui_binast::widget(ephem,omc,y) "" 
   set ::bdi_gui_binast::widget(ephem,omc,err_x) ""
   set ::bdi_gui_binast::widget(ephem,omc,err_y) "" 

   # Verifie si la compo n est pas une reference
   if {$::bdi_gui_binast::widget(data,listref,$date,$compo)!=""} return

   # Determination de la reference
   set compo_ref ""
   foreach  cpo $::bdi_gui_binast::widget(table,compos,list)  {
      if {$::bdi_gui_binast::widget(data,listref,$date,$cpo)=="x"} {
         set compo_ref $cpo
         break
      }
   }

   gren_info "set date $date\n"
   gren_info "set orig $orig\n"
   gren_info "set compo $compo\n"
   gren_info "set compo_ref $compo_ref\n"

   # Verification qu on a bien une reference
   #if {$compo_ref == ""} return

   # Verification que la reference a bien ete mesuree
   if {![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_xsm)] || 
       ![info exists ::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_ysm)] } return
   set xrpix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,xsm)
   set yrpix $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,ysm)
   set xrerr $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_xsm)
   set yrerr $::bdi_gui_binast::widget(data,$date,$compo_ref,psf,err_ysm)
   if {$xrpix == "" || $yrpix == "" || $xrerr == "" || $yrerr == "" } return
   gren_info "Verification que la reference a bien ete mesuree\n"

   # Verification que la compo a bien ete mesuree
   set xcpix ""
   set ycpix ""
   set xcerr ""
   set ycerr ""
   if {$orig=="mesure"} {
      if {![info exists ::bdi_gui_binast::widget(mesure,xsm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,ysm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,err_xsm)] || 
          ![info exists ::bdi_gui_binast::widget(mesure,err_ysm)] } return
      set xcpix $::bdi_gui_binast::widget(mesure,xsm)
      set ycpix $::bdi_gui_binast::widget(mesure,ysm)
      set xcerr $::bdi_gui_binast::widget(mesure,err_xsm)
      set ycerr $::bdi_gui_binast::widget(mesure,err_ysm)
   }
   if {$orig=="data"} {
      if {![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)] || 
          ![info exists ::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)] } return
      set xcpix $::bdi_gui_binast::widget(data,$date,$compo,psf,xsm)
      set ycpix $::bdi_gui_binast::widget(data,$date,$compo,psf,ysm)
      set xcerr $::bdi_gui_binast::widget(data,$date,$compo,psf,err_xsm)
      set ycerr $::bdi_gui_binast::widget(data,$date,$compo,psf,err_ysm)
   }
   if {$xcpix == "" || $ycpix == "" || $xcerr == "" || $ycerr == "" } return
   gren_info "Verification que la compo a bien ete mesuree\n"

   # Ephem : Verification et calcul de la reference
   set x_omc ""
   set y_omc ""
   if {![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dx)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dy)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dx)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dy)] } return
   set x_omc [expr $::bdi_gui_binast::widget(mesure,dx) - ($::bdi_gui_binast::ephem($date,$compo,dx) + $::bdi_gui_binast::ephem($date,$compo_ref,dx) ) ]
   set y_omc [expr $::bdi_gui_binast::widget(mesure,dy) - ($::bdi_gui_binast::ephem($date,$compo,dy) + $::bdi_gui_binast::ephem($date,$compo_ref,dy) ) ]
   if {$x_omc == "" || $y_omc == ""} return
   gren_info "Ephem : Verification et calcul de la reference\n"


   # OMC
   set ::bdi_gui_binast::widget(ephem,omc,x) [format "%.1f" $x_omc]
   set ::bdi_gui_binast::widget(ephem,omc,y) [format "%.1f" $y_omc]

   set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,x) $::bdi_gui_binast::widget(ephem,omc,x)
   set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,y) $::bdi_gui_binast::widget(ephem,omc,y)

   # Erreurs
   set x_omc_err ""
   set y_omc_err ""

   if {![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dx_min_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dy_min_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dx_max_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo_ref,dy_max_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dy_min_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dx_max_err_1sigma)] || 
       ![info exists ::bdi_gui_binast::ephem($date,$compo,dy_max_err_1sigma)] } return
   gren_info "Ephem 1\n"
   if {$::bdi_gui_binast::ephem($date,$compo_ref,dx_min_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo_ref,dy_min_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo_ref,dx_max_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo_ref,dy_max_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo,dy_min_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo,dx_max_err_1sigma) == "" || 
       $::bdi_gui_binast::ephem($date,$compo,dy_max_err_1sigma) == "" } return
   gren_info "Ephem 2\n"

   gren_info "dx_min_err_1sigma = $::bdi_gui_binast::ephem($date,$compo_ref,dx_min_err_1sigma)\n"
   gren_info "dy_min_err_1sigma = $::bdi_gui_binast::ephem($date,$compo_ref,dy_min_err_1sigma)\n"
   gren_info "dx_max_err_1sigma = $::bdi_gui_binast::ephem($date,$compo_ref,dx_max_err_1sigma)\n"
   gren_info "dy_max_err_1sigma = $::bdi_gui_binast::ephem($date,$compo_ref,dy_max_err_1sigma)\n"
   gren_info "dx_min_err_1sigma = $::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma)    \n"
   gren_info "dy_min_err_1sigma = $::bdi_gui_binast::ephem($date,$compo,dy_min_err_1sigma)    \n"
   gren_info "dx_max_err_1sigma = $::bdi_gui_binast::ephem($date,$compo,dx_max_err_1sigma)    \n"
   gren_info "dy_max_err_1sigma = $::bdi_gui_binast::ephem($date,$compo,dy_max_err_1sigma)    \n"
       
       
   set x_omc_err [expr $::bdi_gui_binast::ephem($date,$compo_ref,dx_max_err_1sigma) - $::bdi_gui_binast::ephem($date,$compo_ref,dx_min_err_1sigma) \
                     + $::bdi_gui_binast::ephem($date,$compo,dx_max_err_1sigma)     - $::bdi_gui_binast::ephem($date,$compo,dx_min_err_1sigma)]
   set y_omc_err [expr $::bdi_gui_binast::ephem($date,$compo_ref,dy_max_err_1sigma) - $::bdi_gui_binast::ephem($date,$compo_ref,dy_min_err_1sigma) \
                     + $::bdi_gui_binast::ephem($date,$compo,dy_max_err_1sigma)     - $::bdi_gui_binast::ephem($date,$compo,dy_min_err_1sigma)]
   if {$x_omc_err == "" || $y_omc_errr == ""} return


   set ::bdi_gui_binast::widget(ephem,omc,err_x) [format "%.1f" $x_omc_err ]
   set ::bdi_gui_binast::widget(ephem,omc,err_y) [format "%.1f" $y_omc_errr]
   
   gren_info "OMC de $compo % par rapport a $compo_ref\n"
   gren_info "DX = $::bdi_gui_binast::widget(ephem,omc,x) +- $::bdi_gui_binast::widget(ephem,omc,err_x) \n"
   gren_info "DY = $::bdi_gui_binast::widget(ephem,omc,y) +- $::bdi_gui_binast::widget(ephem,omc,err_y) \n"


   set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_x) $::bdi_gui_binast::widget(ephem,omc,err_x)
   set ::bdi_gui_binast::widget(data,$date,$compo,ephem,omc,err_y) $::bdi_gui_binast::widget(ephem,omc,err_y)
   

   
   
   
   
   # Calculs

   gren_info "box_ephem :: end\n"
   return 

}


