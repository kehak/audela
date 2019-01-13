## @file bdi_tools_headers.tcl
#  @brief     Outils de gestion des ent&ecirc;tes des images
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_headers.tcl]
#  @endcode

# $Id: bdi_tools_headers.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_headers
# @brief Outils de gestion des ent&ecirc;tes des images
# @pre Requiert \c bdi_tools_xml .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_headers {

}



# Lancement de la procedure principale
proc ::bdi_tools_headers::go { } {
   
   gren_info "#####################################################"
   gren_info "                     HEADERS                         "
   gren_info " Verification et modification des headers des images "
   gren_info ""
   gren_info "     Auteurs : Fred Vachier, Jerome Berthier         "
   gren_info "#####################################################"

   ::bdi_tools_headers::init
   
   ::bdi_tools_headers::test_chaque_image

   ::bdi_tools_headers::test_build_file_tab
         
   gren_info "\n** Fin du TCL\n"
   return -code $::bdi_tools_headers::final_error
}



# Initialisation
proc ::bdi_tools_headers::init {  } {

   global audace
   global bddconf

   gren_info "*** Init"

   set ::tcl_precision 17
   set ::bdi_tools_headers::final_error 99

   # Config audace
   source [file join $audace(rep_home) audace.ini]

   # Config external
   source [file join $audace(rep_home) headers.ini]

  ::bddimages_sql::mysql_init

   # Fichier de config XML a charger
   set ::bdi_tools_xml::xmlConfigFile [file join $audace(rep_home) bddimages_ini.xml]

   # Chargement et connection a la bdd
   set bddconf(current_config) [::bdi_tools_config::load_config $::bdi_tools_headers::bddname]

   set bddconf(bufno)    $audace(bufNo)
   set bddconf(visuno)   $audace(visuNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]
   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"

   # Phase de test :
   if {$::bdi_tools_headers::repar==1} {
      gren_info "#########################################"
      gren_info "### MODIFICATION DES FICHIERS : ACTIF ###"
      gren_info "#########################################"
   }
   return
}



# Verification que le header est correct
# @return 1 si incorrect 0 si correct
proc ::bdi_tools_headers::verification { bufno } {
   set list_header [buf$bufno getkwds]
   #gren_info "HEADER KWDS : $list_header"
   
   foreach u $::bdi_tools_headers::list_header {
      set action  [lindex $u 0]       
      set bufkey  [lindex $u { 1 0 }] 
      set val     [string trim [lindex $u { 1 1 }] ]
      set type    [string trim [lindex $u { 1 2 }] ]
      set comment [string trim [lindex $u { 1 3 }] ]
      set unit    [string trim [lindex $u { 1 4 }] ]
      if {$action == "DELETE"} {
         if {$bufkey in $list_header} {
            return -code 1 "\[$bufkey\] DELETE"
         } else {
            continue
         }
      }
      if {$action == "IFNOTEXIST"} {
         if {$bufkey in $list_header} {
            #gren_info "$bufkey EXIST IN HEADER : No change"
            continue
         } else {
            #gren_info "$bufkey NOT EXIST IN HEADER : add"
            set action REPLACE
         }
      }
      if {$action == "REPLACE"} {
         set ikey     [buf$bufno getkwd $bufkey]
         set ival     [string trim [lindex $ikey 1] ]
         set itype    [string trim [lindex $ikey 2] ]
         set icomment [string trim [lindex $ikey 3] ]
         set iunit    [string trim [lindex $ikey 4] ]
         if {$val     != "*" && $ival     != $val     } { return -code 1 "\[$bufkey\] VAL ($ival) to ($val)"} 
         if {$type    != "*" && $itype    != $type    } { return -code 1 "\[$bufkey\] TYPE ($itype) to ($type)"} 
         if {$comment != "*" && $icomment != $comment } { return -code 1 "\[$bufkey\] COMMENT ($icomment) to ($comment)"} 
         if {$unit    != "*" && $iunit    != $unit    } { return -code 1 "\[$bufkey\] UNIT ($iunit) to ($unit)"} 
      }
   }
   return
}



# Reparation du header incorrect
proc ::bdi_tools_headers::reparation { bufno } {

   set list_header [buf$bufno getkwds]
   #gren_info "HEADER KWDS : $list_header"

   set cpt 0
   
   foreach u $::bdi_tools_headers::list_header {
      set action  [lindex $u 0]       
      set bufkey  [lindex $u { 1 0 }] 
      set val     [lindex $u { 1 1 }] 
      set type    [lindex $u { 1 2 }] 
      set comment [lindex $u { 1 3 }]
      set unit    [lindex $u { 1 4 }]
      if {$action == "DELETE"} {
         if {$bufkey in $list_header} {
            incr cpt
            buf$bufno delkwd $bufkey
         }
         continue
      }
      if {$action == "IFNOTEXIST"} {
         if {$bufkey in $list_header} {
            #gren_info "$bufkey EXIST IN HEADER : No change"
            continue
         } else {
            #gren_info "$bufkey NOT EXIST IN HEADER : add"
            set action REPLACE
         }
      }
      if {$action == "REPLACE"} {
         set ikey     [buf$bufno getkwd $bufkey]
         set ival     [lindex $ikey 1] 
         set itype    [lindex $ikey 2] 
         set icomment [lindex $ikey 3]
         set iunit    [lindex $ikey 4]
         set change "no"
         if {$val != "*" && $ival != $val } {
            set ival $val
            set change "yes"
         }
         if {$type != "*" && $itype != $type } {
            set itype $type
            set change "yes"
         }
         if {$comment != "*" && $icomment != $comment } {
            set icomment $comment
            set change "yes"
         }
         if {$unit != "*" && $iunit != $unit } {
            set iunit $unit
            set change "yes"
         }
         if {$change == "yes"} {
            incr cpt
            set ikey [ list $bufkey $ival $itype $icomment $iunit]
            #gren_info "$bufkey MODIF TODO  : $ikey"
            buf$bufno setkwd $ikey
            #gren_info "$bufkey MODIF AFTER : [buf$bufno getkwd $bufkey]"
         }
      }
   }
   return $cpt
}



proc ::bdi_tools_headers::test_chaque_image { } {
   global bddconf
   gren_info "** Demarrage Images"

   #gren_info "Lecture de l image"
   #buf$bddconf(bufno) load "/astrodata/Observations/Images/bddimages/bdi_test_auto/tmp/i.fit"

   # recupere la liste des images
   gren_info "\nRecupere la liste des images"
   set sqlcmd "SELECT idbddimg, filename, dirfilename FROM images;"
   #gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images', msg: $msg"
   }
   set nb [llength $data]
   gren_info "nb images = $nb"
   
   set cpt_err      0
   set cpt_to_modif 0
   set cpt_modif    0
   set cpt_ins_img  0
   set cpt_ins_cata 0
   set cpt_img      0
   set cpt_cata     0

   foreach d $data {

      #gren_info "d = $d\n"
      set idbddimg    [lindex $d 0]
      set filename    [lindex $d 1]
      set dirfilename [lindex $d 2]
      set rootfilename [file join $bddconf(dirbase) $dirfilename $filename]
      set img_incoming [file join $bddconf(dirinco) $filename]
      gren_info "+ rootfilename \[$idbddimg\]= $rootfilename"         
      
      # Existance disque
      if {![file exists $rootfilename]} {
         gren_info "   - Le fichier image n existe pas sur le disque"
         incr cpt_err
         continue
      }
      
      # Chargement
      set err [ catch { buf$bddconf(bufno) load $rootfilename } msg ]
      if {$err} {
         gren_erreur "   - Impossible de charger l image : \[$idbddimg\] $rootfilename"
         incr cpt_err
         continue
      }
      gren_info "   + Image chargee"

      # Premiere Verification du buffer
      set err [ catch {::bdi_tools_headers::verification $bddconf(bufno)} msg]
      if {$err==1} {
         gren_info "   - L image doit etre modifiee : $msg"
         incr cpt_to_modif
      } else {
         gren_info "   + L image est correcte"
         continue
      }
      
      if {$::bdi_tools_headers::repar == 0} { continue }
      
      # Modification du buffer
      set err [ catch {::bdi_tools_headers::reparation $bddconf(bufno)} msg]
      if {$err} {
         gren_info "   --- Erreur de modification : ($err) ($msg)"
         incr cpt_err
         continue
      } else {
         gren_info "   + Nb cles du header modifies = $msg"
         incr cpt_modif
      }
      
      # Deuxieme Verification du buffer
      set err [ catch {::bdi_tools_headers::verification $bddconf(bufno)} msg]
      if {$err==1} {
         gren_info "   --- Modification erronee : $msg"
         incr cpt_err
         continue
      } else {
         gren_info "   + Deuxieme Verification du buffer : L image est correcte"
      }
      
      # Existance du cata
      set ident [bddimages_image_identification $idbddimg]
      set fileimg  [lindex $ident 1]
      set filecata [lindex $ident 3]
      if {$fileimg != $rootfilename} {
         gren_info "   --- Indentification incorrecte"
         incr cpt_err
         continue
      }
      if {$filecata != -1} {
         # Existance disque
         if {![file exists $filecata]} {
            gren_info "   - Le fichier cata n existe pas sur le disque : $filecata"
            incr cpt_err
            continue
         }
         gren_info "   + Fichier cata : $filecata"
         set cata_incoming [file join $bddconf(dirinco) [file tail $filecata]]
      }

      # Copie de l image et du cata dans incoming
      set img_incoming [file rootname $img_incoming]
      set err [ catch { buf$bddconf(bufno) save $img_incoming } msg ]
      if {$err} {
         gren_erreur "   - Impossible de sauver l image depuis le buffer : $img_incoming (ERR=$err) (MSG=$msg)"
         incr cpt_err
         continue
      }
      gren_info "   + Sauvegarde du buffer dans le fichier image de incoming"

      if {$filecata != -1} {
         set err [catch {file copy -force -- $filecata $cata_incoming} msg]
         if {$err} {
            gren_info "   --- Copie du fichier vers incoming impossible : $msg"
            incr cpt_err
            continue
         }
         gren_info "   + Copie du fichier cata vers incoming"
      }
      
      # Effacement de l image et du cata dans la base
      set err [catch {bddimages_image_delete_fromsql $ident} msg]
      if {$err} {
         gren_info "   --- Erreur Effacement de l image dans la base (ERR=$err) (MSG=$msg) (IDENT=$ident)\n"
         incr cpt_err
         continue
      }
      set err [catch {bddimages_image_delete_fromdisk $ident} msg]
      if {$err} {
         gren_info "   --- Erreur Effacement de l image dans la base (ERR=$err) (MSG=$msg) (IDENT=$ident)\n"
         incr cpt_err
         continue
      }
      gren_info "   + Effacement de l image et du cata dans la base"
      
      # INSERTION SOLO de l image
      gren_info "   + Insertions..."
      if {![file exists $img_incoming]} {
      }
      set err [catch {set idbddimg [insertion_solo $img_incoming]} msg]
      if {$err} {
         gren_info "   --- Erreur Insertion (ERR=$err) (MSG=$msg) (RESULT=$idbddimg) \n"
         incr cpt_err
         continue
      }
      gren_info "   + Insertion de l image dans la base NEW ID = $idbddimg"

      # INSERTION SOLO du cata
      if {$filecata != -1} {
         set err [catch {set idbddcata [insertion_solo $cata_incoming]} msg]
         if {$err} {
            gren_info "   --- Erreur Insertion (ERR=$err) (MSG=$msg) (RESULT=$idbddcata) \n"
            incr cpt_err
            continue
         }
         gren_info "   + Insertion du cata dans la base NEW ID = $idbddcata"
      }
      
      # Fin de l image
      #break
      continue
   }

   gren_info ""
   gren_info "#########################"
   gren_info "FLAG REPAR  : $::bdi_tools_headers::repar"
   gren_info "NB TO MODIF : $cpt_to_modif"
   gren_info "NB MODIFIED : $cpt_modif"
   gren_info "NB ERREUR   : $cpt_err"
   gren_info "#########################"
   return

}



proc ::bdi_tools_headers::test_build_file_tab { } {
   global bddconf

   gren_info "** Demarrage Header"
   set sqlcmd "SELECT idheader, variable, type, keyname FROM header;"
   #gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images', msg: $msg"
   }
   set nb [llength $data]
   gren_info "nb data = $nb"

   gren_info "Recuperation des donnees de la table sql header"
   set list_var ""
   set list_idheader ""
   array unset tab_type
   foreach d $data {
      #gren_info "d = $d\n"
      set idheader    [lindex $d 0]
      set var         [lindex $d 3]
      set type        [lindex $d 2]
      switch $type {
         "TEXT"   { set tab_type($var,$idheader) T }
         "FLOAT"  { set tab_type($var,$idheader) F }
         "DOUBLE" { set tab_type($var,$idheader) D }
         "INT"    { set tab_type($var,$idheader) I }
      }
      lappend list_var $var
      lappend list_idheader $idheader
   }
   set list_var      [lsort -uniq $list_var]
   set list_idheader [lsort -uniq -integer $list_idheader]
   gren_info "Nb header = [llength $list_idheader]"
   gren_info "Nb cles   = [llength $list_var]"
   
   gren_info "Constrution du fichier table"
   set f [open [file join $bddconf(dirtmp) headers.tab] "w"]
   # entete
   set line [format "%-40s" ""]
   foreach idheader $list_idheader {
      append line [format "%5s" $idheader]
   }
   puts $f $line

   # data
   foreach var $list_var {
      set line [format "%-40s" $var]
      foreach idheader $list_idheader {
         if {[info exists tab_type($var,$idheader)]} {
            append line [format "%5s" $tab_type($var,$idheader)]
         } else {
            append line "     "
         }
         continue
      }
      puts $f $line
      continue
   }
   close $f
   return
}

proc ::bdi_tools_headers::test_bddimages_header_id { } {

   gren_info "** Demarrage appel bddimages_header_id"
   set sqlcmd "SELECT idbddimg, filename, dirfilename, idheader FROM images limit 1;"
   #gren_info "sqlcmd=$sqlcmd\n"
   set err [catch {set data [::bddimages_sql::sql query $sqlcmd]} msg]
   if {$err} {
      return -code 6 "Erreur SQL dans la requete sur la table 'images', msg: $msg"
   }
   set nb [llength $data]
   gren_info "nb images = $nb"


   foreach d $data {
      #gren_info "d = $d\n"
      set idbddimg    [lindex $d 0]
      set filename    [lindex $d 1]
      set dirfilename [lindex $d 2]
      set idheader    [lindex $d 3]
      set rootfilename [file join $bddconf(dirbase) $dirfilename $filename]
      set img_incoming [file join $bddconf(dirinco) $filename]
      gren_info "+ rootfilename \[$idbddimg\]= $rootfilename"         
      
      # Existance disque
      if {![file exists $rootfilename]} {
         gren_info "   - Le fichier image n existe pas sur le disque"
         incr cpt_err
         continue
      }
      
      # Chargement
      set err [ catch { buf$bddconf(bufno) load $rootfilename } msg ]
      if {$err} {
         gren_erreur "   - Impossible de charger l image : \[$idbddimg\] $rootfilename"
         incr cpt_err
         continue
      }
      gren_info "   + Image chargee"
   
      set tabkey [::bdi_tools_image::get_tabkey_from_buffer]
      set liste [bddimages_header_id $tabkey]
      gren_info "   + idheader = $idheader"
      gren_info "   + liste = $liste"
   
   }


   return 
}
