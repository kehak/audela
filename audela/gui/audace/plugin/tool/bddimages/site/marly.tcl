#
# Mise à jour $Id: marly.tcl 7064 2011-04-03 22:07:47Z jberthier $
#

#--------------------------------------------------
#
#  Structure du tabkey
#
# { {TELESCOP { {TELESCOP} {TAROT CHILI} string {Observatory name} } }
#   {NAXIS2   { {NAXIS2}   {1024}        int    {}                 } }
#    etc ...
# }
#
#--------------------------------------------------
#     0         1         2
#       0123456789012345678901
# date <2006-06-23T20:22:36.08>
#--------------------------------------------------

proc chg_tabkey { tabkey } {

   # DATE-OBS
   if {! [::bddimages_liste::lexist $tabkey "date-obs"]} {
      return [list 1 "????-??-??T??:??:??"] 
   }
   set dateobs [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

   } else {

      # Sinon
      set annee   [expr [string range $dateobs 6 9] + 1900]
      set mois    [string range $dateobs 3 4]
      set jour    [string range $dateobs 0 1]
      
      if {! [::bddimages_liste::lexist $tabkey "tu-start"]} {
         return [list 1 "${annee}-${mois}-${jour}T??:??:??"]
      }
      set heurobs [lindex [::bddimages_liste::lget $tabkey "tu-start"] 1]
      set dateiso [format "%04d-%02d-%02dT%s.00" $annee $mois $jour [string trim $heurobs]]

   }
   set l_dateiso [list "date-obs" $dateiso "string" "" ""]
   set tabkey [ ::bddimages_liste::lupdate $tabkey "date-obs" $l_dateiso ]

   # EXPOSURE
   if {! [::bddimages_liste::lexist $tabkey "exposure"]} {
      set line [::bddimages_liste::lget $tabkey "tm-expos"]
      set exposure [lreplace $line 0 0 "EXPOSURE"]
      set tabkey [::bddimages_liste::ladd $tabkey "exposure" $exposure]
   }

   # BIN1
   if {! [::bddimages_liste::lexist $tabkey "bin1"]} {
      set tabkey [::bddimages_liste::ladd $tabkey "bin1" [list "BIN1" "1" "INT" "" ""]]
   }

   # BIN2
   if {! [::bddimages_liste::lexist $tabkey "bin2"]} {
      set tabkey [::bddimages_liste::ladd $tabkey "bin2" [list "BIN2" "1" "INT" "" ""]]
   }

   # FILTER
   if {! [::bddimages_liste::lexist $tabkey "filter"]} {
      set f [::bddimages_liste::lget $tabkey "FILTREF"]
      set tabkey [::bddimages_liste::ladd $tabkey "filter" $f]
   }

   return [list 0 $tabkey]
}

