# -- Procedure 
proc get_cata { catafile } {

 global bddconf

set test "no"

   set filenametmpzip $bddconf(dirtmp)/ssp_tmp_cata.txt.gz
   set filenametmp $bddconf(dirtmp)/ssp_tmp_cata.txt

   if  {$test == "no"} { 
       # -- liste des sources tag = 1
       set err [catch {file delete -force $filenametmpzip} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4a\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {file delete -force $filenametmp} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4b\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {file copy -force $catafile $filenametmpzip} msg]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4c\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }
       set err [catch {exec chmod g-s $filenametmpzip} msg ]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4d\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }   
       lassign [::bdi_tools::gunzip $filenametmpzip] err msg
       #set err [catch {exec gunzip $filenametmpzip} msg ]
       if {$err} {
          gren_info "solarsystemprocess: ERREUR 4e\n"
          gren_info "solarsystemprocess:        NUM : <$err>\n" 
          gren_info "solarsystemprocess:        MSG : <$msg>\n"
          }   
      }   

gren_info "fichier dezippé\n"

   set linerech "123456789 123456789 123456789 123456789" 

#{ 
# { 
#  { IMG   {list field crossmatch} {list fields}} 
#  { TYC2  {list field crossmatch} {list fields}}
#  { USNO2 {list field crossmatch} {list fields}}
# }
# {                                -> liste des sources
#  {                               -> 1 source
#   { IMG   {crossmatch} {fields}}  -> vue dans l image
#   { TYC2  {crossmatch} {fields}}  -> vue dans le catalogue
#   { USNO2 {crossmatch} {fields}}  -> vue dans le catalogue
#  }
# }
#}

   set cmfields  [list ra dec poserr mag magerr]
   set allfields [list id flag xpos ypos instr_mag err_mag flux_sex err_flux_sex ra dec calib_mag calib_mag_ss1 err_calib_mag_ss1 calib_mag_ss2 err_calib_mag_ss2 nb_neighbours radius background_sex x2_momentum_sex y2_momentum_sex xy_momentum_sex major_axis_sex minor_axis_sex position_angle_sex fwhm_sex flag_sex]

   set list_fields [list [list "IMG" $cmfields $allfields] [list "USNOA2" $cmfields {}]]


   set list_sources {}
   set chan [open $filenametmp r]
   set lineCount 0
   set littab "no"
   while {[gets $chan line] >= 0} {
       if {$littab=="ok"} {
         incr lineCount
         set zlist [split $line " "]
         set xlist {}
         foreach value $zlist {
            if {$value!={}} {
               set xlist [linsert $xlist end $value]
               }
            }
         set row {}
         set cmval [list [lindex $xlist 8] [lindex $xlist 9] 5.0 [lindex $xlist 10] [lindex $xlist 12] ] 
         if {[lindex $xlist 1]==1} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "OVNI" $cmval {} ]
            }
         if {[lindex $xlist 1]==3} {
            lappend row [list "IMG" $cmval $xlist ]
            lappend row [list "USNOA2" $cmval {} ]
            }
         if {[llength $row] > 0} {
            lappend list_sources $row
            }
        
         #if {$lineCount > 215} {  return [list $list_fields $list_sources] }

         } else {
         set a [string first $linerech $line 0]
         if {$a>=0} { set littab "ok" }
         }
      }

   if {[catch {close $chan} err]} {
       gren_info "solarsystemprocess: ERREUR 6  <$err>"
   }


# gren_info " ovni_list2 = $ovni_list2"
# return usno_list2 ?
 return [list $list_fields $list_sources]
 }



