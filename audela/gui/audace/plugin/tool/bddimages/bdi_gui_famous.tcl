## @file bdi_gui_famous.tcl
#  @brief     GUI pour l'analyse en fr&eacute;quence des donn&eacute;es observationnelles
#  @author    Frederic Vachier (fv@imcce.fr)
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_gui_famous.tcl]
#  @endcode

# $Id: bdi_gui_famous.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_gui_famous
# @brief GUI pour l'analyse en fr&eacute;quence des donn&eacute;es observationnelles
# @pre Requiert le programme Famous d&eacute;velopp&eacute; par F. Mignard (OCA)
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_gui_famous {

}



#------------------------------------------------------------
## FAMOUS: Edition du fichier de configuration pour le lancement de Famous
#  @return void
#
proc ::bdi_gui_famous::edit_setup { } {

   global bddconf
   set filename [file join $bddconf(dirtmp) "setting.txt"]
   catch { exec ne $filename }
}



#------------------------------------------------------------
## FAMOUS: Creation du fichier de configuration pour le lancement de Famous
#  @warning les variables suivantes doivent etre definie
#           ::bdi_tools_famous::param(periodic_decomposition)
#           ::bdi_tools_famous::param(idm)
#           bddconf(dirtmp)
#  @return void
#
proc ::bdi_gui_famous::crea_setup { } {

   global bddconf

   if {$::bdi_tools_famous::param(periodic_decomposition) == "Multi"} {
      set decomp ".true. "
   } else {
      set decomp ".false."
   }

   set filename [file join $bddconf(dirtmp) "setting.txt"]
   set f [open $filename "w"]
   puts $f "'famous.dat'    input file with the data"
   puts $f "1               field with time data in input file"
   puts $f "2               field with observation data in input file"
   puts $f "'famous.res'    ouptut file with the frequencies and power"
   puts $f "3               numf : number of lines searched"
   puts $f "$decomp         flmulti : flag for the multi or simply periodic decomposition."
   puts $f ".true.          flauto : flag for the frequency range .true. = automatic .false. : with preset frequencies"
   puts $f "0.01d0          frbeg  : lowest  frequency analysed in the periodograms (disabled if flauto =true)"
   puts $f "0.45d0          frend  : largest frequency analysed in the periodograms (disabled if flauto =true)"
   puts $f ".true.          fltime : flag for the origin of time  :: .true. : automatic  .false. : with preset value"
   puts $f "0.d0            tzero  : your origin of time if fltime = .false. in unit of the time signal read in the input file"
   puts $f "3.0d0           Threshold in S/N to reject non statistically significant lines"
   puts $f ".true.          Flag for the output of the  periodograms and successive residuals (true = output)"
   puts $f "0               iprint in freqsearch : 0 : setting and results, 1 : intermediate results, 2 : extended with correlations"
   puts $f "1               iresid : = 1 residuals are printed. 0 : not printed"
   puts $f ".false.         flagdeg : uniform degree for the mixed term (.true.) or not (.false.)"
   puts $f "0               idm : Value of the degree in terms like a +bt + ... ct^idm (used if flagdeg = .true.)"
   puts $f " 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  ideg(k) k=0..numf  loaded if flagdeg = .false.                           "
   puts $f "                                                                                                                                                                      "
   puts $f " 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30   (just to see the columns numbers to ease the editing of the above array)"
   close $f
}







#------------------------------------------------------------
## FAMOUS: Lance Famous
#  @return void
#
proc ::bdi_gui_famous::launch { } {
   
   global bddconf

   cd $bddconf(dirtmp)
   set err [catch {exec Famous_driver } msg]
   if {$err} {
      gren_info "famous_launch: error #$err: $msg\n" 
      return
   } 
   gren_info "$msg\n"

   # Lit la solution
   set ::bdi_tools_famous::lsolu [::bdi_tools_famous::read_solu_direct]
   array set solu $::bdi_tools_famous::lsolu
   
   # Lecture des residus
   gren_info "Lecture des residus\n"
   set file_res [file join $bddconf(dirtmp) "resid_final.txt"]
   set xo ""
   set yo ""
   set ::bdi_tools_famous::data(residus) ""
   set f [open $file_res "r"]
   while {![eof $f]} {
      set line [gets $f]
      if {[string trim $line] == ""} {break}
      set line [regsub -all \[\s\] $line ,]
      set r [split [string trim $line] ","]
      set x [lindex [lindex $r 0] 0 ] 
      set y [expr [lindex [lindex $r 0] 1 ]]
      lappend xo $x  
      lappend yo $y
      lappend ::bdi_tools_famous::data(residus) $y
      #gren_erreur "xo = [lindex [lindex $r 0] 0 ]   yo = [expr [lindex [lindex $r 0] 1 ]]\n"
       
   }
   close $f
   
   # Calcul du time span
   set time_span [expr [::math::statistics::max $xo] - [::math::statistics::min $xo]]
   set time_span_jd $time_span
   if {$time_span < 1 } {
      set time_span [format "%.2f hours" [expr $time_span * 24.0]]
   } else {
      set time_span [format "%.2f days" [expr $time_span]]
   }

   # Calcul des stats
   switch $::bdi_gui_analysis::column_selected {
      "mag" {
         set residuals_mean [format "%.1f millimag" [ expr [::math::statistics::mean  $yo] *1000.0 ] ]
         set residuals_std  [format "%.1f millimag" [ expr [::math::statistics::stdev $yo] *1000.0 ] ]
      }
      default {
         set residuals_mean [format "%.3f" [::math::statistics::mean  $yo] ]
         set residuals_std  [format "%.3f" [::math::statistics::stdev $yo] ]
      }
   }
   
   set ::bdi_gui_analysis::widget(famous,stats,nb_dates)       [::math::statistics::number $yo]
   set ::bdi_gui_analysis::widget(famous,stats,time_span)      $time_span
   set ::bdi_gui_analysis::widget(famous,stats,time_span_jd)   $time_span_jd
   set ::bdi_gui_analysis::widget(famous,stats,idm)            $::bdi_gui_analysis::idm
   set ::bdi_gui_analysis::widget(famous,stats,residuals_mean) $residuals_mean
   set ::bdi_gui_analysis::widget(famous,stats,residuals_std)  $residuals_std
   set ::bdi_gui_analysis::widget(famous,stats,typeofdata)     $::bdi_gui_analysis::widget(famous,typeofdata)
   gren_info "nbdates : $::bdi_gui_analysis::widget(famous,stats,nb_dates)\n"

   # mise a jour pour les plot

   foreach r $::bdi_gui_analysis::widget(data,tabchrono) {
      set id  [lindex $r 0]
      set tjj  [lindex $r 1]
      set ::bdi_gui_analysis::widget(data,$id,sol) [::bdi_gui_famous::extrapole $tjj]
      set ::bdi_gui_analysis::widget(data,$id,res) [expr $::bdi_gui_analysis::widget(data,$id,raw) - $::bdi_gui_analysis::widget(data,$id,sol)]
   }
   
   # on libere les boutons 
   #$::bdi_gui_analysis::widget(famous,button,view)        configure -state normal
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,res) configure -relief sunken -state normal
   $::bdi_gui_analysis::widget(famous,graph,ordonnee,sol) configure -relief sunken -state normal

   ::bdi_gui_analysis::graph

}

#------------------------------------------------------------
## FAMOUS: Extrapolation depend de la GUI
#  @return void
#
proc ::bdi_gui_famous::extrapole { tjj } {

   array set solu $::bdi_tools_famous::lsolu
   switch $::bdi_gui_analysis::widget(famous,stats,typeofdata) {
      "Raw data" {
         set x [expr $tjj - $::bdi_gui_analysis::widget(data,origin)]
      }

      "Repli obs" - 
      "Repli sol" {
         set x [::bdi_gui_analysis::jd_to_repli $tjj]
      }

   }
   return [::bdi_tools_famous::extrapole $x solu]
}


#------------------------------------------------------------
## FAMOUS: Lit les residus
#  @return void
#
proc ::bdi_gui_famous::residus_read { } {
}
#------------------------------------------------------------
## FAMOUS: Voir les resultats
#  @return void
#
proc ::bdi_gui_famous::view_results { } {
}













proc ::bdi_gui_famous::view_sol { p_solu } {

   upvar $p_solu solu

   for {set k 0} {$k<$solu(nbk)} {incr k} {
         gren_info "k  $k \n"

      for {set exp 0} {$exp<=$solu($k,nbexp)} {incr exp} {
         gren_info "k  $k "
         gren_info "ex $exp)      "
         gren_info "fr $solu($k,$exp,frequency)"
         gren_info "pe $solu($k,$exp,period)   "
         gren_info "co $solu($k,$exp,costerm)  "
         gren_info "si $solu($k,$exp,sineterm) "
         gren_info "si $solu($k,$exp,sigmaf)   "
         gren_info "si $solu($k,$exp,sigmacos) "
         gren_info "si $solu($k,$exp,sigmasin) "
         gren_info "am $solu($k,$exp,amplitude)"
         gren_info "ph $solu($k,$exp,phase)    "
         gren_info "sn $solu($k,$exp,sn)       \n"
      }
   }
}







