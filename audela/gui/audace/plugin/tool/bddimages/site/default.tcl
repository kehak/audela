#
# Mise à jour $Id: default.tcl 7007 2011-03-24 17:28:28Z fredvachier $
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

proc chg_tabkey {tabkey} {

   set dateobs [lindex [::bddimages_liste::lget $tabkey "date-obs"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

      set line [lreplace [::bddimages_liste::lget $tabkey "date-obs"] 1 1 $dateiso]
      set tabkey [::bddimages_liste::lupdate $tabkey "date-obs" $line]
      return [list 0 $tabkey]

   } else {

      # Sinon
      return [list 1 "-"]

   }

}

