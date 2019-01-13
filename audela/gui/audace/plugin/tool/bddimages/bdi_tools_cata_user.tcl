## @file bdi_tools_cata_user.tcl
#  @brief     Outils de gestion du catalogue USER des sources identifi&eacute;es personnellement
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_cata_user.tcl]
#  @endcode

# $Id: bdi_tools_cata_user.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_cata_user
# @brief Outils de gestion du catalogue USER des sources identifi&eacute;es personnellement
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_cata_user {

}


#------------------------------------------------------------
## Cette fonction renvoit un cata USER
# pret a etre associé a une source
# @return un cata USER
#
proc ::bdi_tools_cata_user::new { mobil name} {

   return [list "USER" {} [list $mobil $name]]
}

#------------------------------------------------------------
## Cette fonction renvoit les noms des champs d'une source
# USER sous la forme des other field
# c est la liste de tous les parametres que l'on peut
# en obtenir
# @return liste des champs d'une source USER
#
proc ::bdi_tools_cata_user::get_otherfields { } {

   return [list "mobile" "name" ]
}

#------------------------------------------------------------
## Cette fonction renvoit les noms des champs d'une source
# USER compatible avec la forme listesource.
# c est l'entete d'un cata USER
# @return cata fields d'une source USER
#
proc ::bdi_tools_cata_user::get_fields_sources { } {

   return [list "USER" [list "ra" "dec" "poserr" "mag" "magerr"] \
                          [::bdi_tools_cata_user::get_otherfields] ]

}

#------------------------------------------------------------
## modifier la cle d'une liste USER (other fields)
# @param p_othf pointeur de la liste qui va etre modifiee.
# @param key cle qui fait reference de la valeur a modifiee
# @param val nouvelle valeur a modifier
# @return void
#
proc ::bdi_tools_cata_user::set_by_key { p_othf key val } {

   upvar $p_othf othf

   set p [::bdi_tools_cata_user::get_otherfields]
   set pos [lsearch $p $key]
   if {$pos != -1} {
      set othf [lreplace $othf $pos $pos $val]
   }
   return
}

#------------------------------------------------------------
## Affiche la liste otherfield  d'une liste USER dans la console
# @param p_othf pointeur de la liste qui va etre affichee
# @return void
#
proc ::bdi_tools_cata_user::gren_user {  p_othf } {

   upvar $p_othf othf

      gren_info "-- USER ---\n"
      set p [::bdi_tools_cata_user::get_otherfields_user]
      foreach key $p {
         set pos [lsearch $p $key]
         gren_info "$key = [lindex $othf $pos]\n"
      }
}


#------------------------------------------------------------
## retourne la valeur d'un element de la liste otherfield
# en fournissant le nom de sa cle
# @param p_othf pointeur de la liste qui va etre lue
# @param key  nom de la cle
# @return valeur de la cle
#
proc ::bdi_tools_cata_user::get_val { p_othf key } {

   upvar $p_othf othf

      set p [::bdi_tools_cata_user::get_otherfields_user]
      set pos [lsearch $p $key]
      return [lindex $othf $pos]
}



proc ::bdi_tools_cata_user::set_common_fields_on_source { p_s } {

   upvar $p_s s

      set posu [lsearch -index 0 $s "USER"]
      if {$posu == -1 } {
         return -1
      }

      set othf [::bdi_tools_psf::get_astroid_othf_from_source $s]

      set ra  [::bdi_tools_psf::get_val othf "ra"]
      set dec [::bdi_tools_psf::get_val othf "dec"]
      set res_ra  [::bdi_tools_psf::get_val othf "res_ra"]
      set res_dec [::bdi_tools_psf::get_val othf "res_dec"]
      set mag  [::bdi_tools_psf::get_val othf "mag"]
      set err_mag [::bdi_tools_psf::get_val othf "err_mag"]

      if {$res_ra ==""||$res_dec ==""} {
         set poserr 3
      } else {
         set poserr [ expr sqrt ( ( pow($res_ra * cos($dec*[pi]),2) + pow($res_dec,2) ) / 2.0 ) ]
      }

      set user [lindex $s $posu]
      set user [lreplace $user 1 1 [list $ra $dec $poserr $mag $err_mag] ]
      set s [lreplace $s $posu $posu $user]

      return
}

proc ::bdi_tools_cata_user::set_common_fields_on_listsources { p_listsources } {

   upvar $p_listsources listsources

   set lf [lindex $listsources 0]
   set ls [lindex $listsources 1]
   set i 0
   foreach s $ls {
      if {[::bdi_tools_cata_user::exist s]} {
         ::bdi_tools_cata_user::set_common_fields_on_source s
         set ls [lreplace $ls $i $i $s]
      }
      incr i
   }
   set listsources [list $lf $ls]
   return
}


proc ::bdi_tools_cata_user::exist { p_s } {

   upvar $p_s s
   set pos [lsearch -index 0 $s "USER"]
   if {$pos == -1 } {
      return 0
   } else {
      return 1
   }
}

#------------------------------------------------------------
## Fonction qui retourne les champs otherfield d ASTROID
# pour une source donnee. Si la source ne comporte pas de
# cata ASTROID alors une entree vide
# @param s source qui se verra modifiee
# @return void
#
proc ::bdi_tools_cata_user::get_user_othf_from_source { s } {

   set posastr [lsearch -index 0 $s "USER"]
   if {$posastr == -1} {
      return -1
   } else {
      set othf [lindex [lindex $s $posastr] 2]
   }
   return $othf
}
#------------------------------------------------------------
## Fonction qui retourne les champs otherfield d ASTROID
# pour une source donnee. Si la source ne comporte pas de
# cata ASTROID alors une entree vide
# @param s source qui se verra modifiee
# @return void
#
proc ::bdi_tools_cata_user::get_user_from_source { s } {

   set posastr [lsearch -index 0 $s "USER"]
   if {$posastr == -1} {
      return -1
   } else {
      return [lindex $s $posastr]
   }
   return
}


#------------------------------------------------------------
## Cette fonction ajoute les champs USER a la liste Fields
# qui nomme chaque champs d'un catalogue USER dans une
# listsources
# @param p_listsources pointeur de variable de type listsources
# @return void
#
proc ::bdi_tools_cata_user::set_fields { p_listsources } {

   upvar $p_listsources listsources

   set fields [lindex $listsources 0]
   set pos [lsearch -index 0 $fields "USER"]
   if {$pos == -1 } {
      lappend fields [::bdi_tools_cata_user::get_fields_sources]
   } else {
      set fields [lreplace $fields $pos $pos [::bdi_tools_cata_user::get_fields_sources] ]
   }
   set listsources [lreplace $listsources 0 0 $fields]
   return
}
