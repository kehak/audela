#
# @file : main_new.tcl
# @brief : Demonstrateur d'ecriture d'un fichier CATA en VOTable
# @author : jberthier
# Mise à jour $Id: main_new.tcl 6795 2011-02-26 16:05:27Z jberthier $
#
# Usage : source $audace(rep_install)/gui/audace/plugin/tool/bddimages/utils/ssp_votable/main_new.tcl

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   package require votable 1.0
   package require votableUtil 1.0

   set catafile "/work/Observations/bddimages/cata/tarot_chili/2009/11/19/IM_20091119_055755761_230749_54410102_cata.txt.gz"

   gren_info "****************************************************************** \n"
   gren_info "Chargement d'un fichier CATA: $catafile \n"
   gren_info "****************************************************************** \n"

   set listsources [get_cata_txt $catafile]

   gren_info "****************************************************************** \n"
   gren_info "Impressions de 3 sources \n"
   gren_info "****************************************************************** \n"

   ::manage_source::imprim_3_sources $listsources

   gren_info "****************************************************************** \n"
   gren_info "Generation de la VOTable \n"
   gren_info "****************************************************************** \n"

   set votable [::votableUtil::list2votable $listsources]

   set catavotable "/work/Observations/bddimages/cata/tarot_chili/2009/11/19/IM_20091119_055755761_230749_54410102_cata.xml"
   
   gren_info "****************************************************************** \n"
   gren_info "Enregistrement de la VOTable: $catavotable \n"
   gren_info "****************************************************************** \n"


   set fxml [open $catavotable "w"]
   puts $fxml $votable
   close $fxml

   gren_info "*** Done ***\n"
