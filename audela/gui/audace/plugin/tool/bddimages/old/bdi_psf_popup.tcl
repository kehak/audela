#--------------------------------------------------
# source [ file join $audace(rep_plugin) tool bddimages bdi_psf_popup.tcl ]
#--------------------------------------------------
#
# Fichier        : bdi_psf_popup.tcl
# Description    : Traitement des psf des images par un popup depuis la gestion
# Auteur         : Frederic Vachier
# Mise à jour $Id: bdi_psf_popup.tcl 6858 2011-03-06 14:19:15Z fredvachier $
#
#--------------------------------------------------
#
# - namespace psf_tools
#
#--------------------------------------------------


namespace eval psf_popup {


# Anciennement ::gui_cata::psf_popup
# Ouvre une boite de dialogue depuis la gestion des cata pour faire 
# l analyse des psf en mode manuel

   proc ::psf_popup::go { tbl } {

      set cataselect [lindex [split [$onglets.nb tab [expr [string index [lindex [split $tbl .] 5] 1] -1] -text] ")"] 1]
      set idcata [string index [lindex [split $tbl .] 5] 1]
      if {[string compare -nocase $cataselect "ASTROID"] == 0} {

         set propalist ""
         foreach select [$tbl curselection] {

            set id   [lindex [$tbl get $select] [::gui_cata::get_pos_col bdi_idc_lock $idcata]]
            set ar   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_reference $idcata]]
            set ac   [lindex [$tbl get $select] [::gui_cata::get_pos_col astrom_catalog $idcata]]
            set pr   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_reference $idcata]]
            set pc   [lindex [$tbl get $select] [::gui_cata::get_pos_col photom_catalog $idcata]]
            set name [lindex [$tbl get $select] [::gui_cata::get_pos_col name $idcata]]

            ::psf_gui::gestion_mode_manuel
         }

      }

   }



#- Fin du namespace -------------------------------------------------
}
