

# Mise à jour $Id: spc_ini.tcl 11248 2015-01-19 21:41:46Z bmauclaire $


#----------------------------------------------------------------------------------#
## ***** Chargement de la lib BLT *****
#- realise dans spcaudace.tcl

#--- Version d'SpcAudace :
proc spc_version {} {

   global spcaudace conf
   global caption

   ::console::affiche_resultat "SpcAudACE version $spcaudace(version)\n"
   tk_messageBox -title "Version d'SpcAudACE" -icon error -message "SpcAudACE version $spcaudace(version)"
}


#----------------------------------------------------------------------------------#
proc spc_goodrep {} {
   global audace

   set repdflt [pwd]
   cd $audace(rep_images)
   return $repdflt
}


#----------------------------------------------------------------------------------#
#**** Fonctions de chargement des des plugins *********
proc spc_bessmodule {} {

   global audace spcaudace
   global conf
   global audela

   if { [regexp {1.3.0} $audela(version) match resu ] } {
      source [ file join $spcaudace(rep_spc) plugins bess_module bess_module.tcl ]
   } else {
      source [ file join $spcaudace(rep_spc) plugins bess_module bess_module.tcl ]
      ::bess::Principal ""
   }
}



#--- Amorcage d'initialisation de vecteurs pour la fonction BLT::spline qui bug :
#- 20150119 : les vecteurs sont persistants et doivent etre effaces en fin d'usage. Merci Raymond Z. et Michel P.
proc spc_vectorini {} {
   blt::vector create spc_vx(10) spc_vy(10) spc_vsx(10) spc_vsy(10)
   for {set i 10} {$i>0} {incr i -1} {
      set spc_vx($i-1) [expr $i*$i]
      set spc_vy($i-1) [expr sin($i*$i*$i)]
   }
   spc_vx sort spc_vy
   spc_vx populate spc_vsx 10
   blt::spline natural spc_vx spc_vy spc_vsx spc_vsy
   blt::vector destroy spc_vx spc_vy spc_vsx spc_vsy
}

#spc_vectorini
#*********************************************************#

