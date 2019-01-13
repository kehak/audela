#
# Mise à jour $Id: zeiss.tcl 12081 2015-06-15 00:14:32Z jberthier $
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

   set dateobs [lindex [::bddimages_liste::lget $tabkey "frame"] 1]

   if { [regexp {(\d+)-(\d+)-(\d+)( |T)(\d+):(\d+):(\d+)(\.*\d*)} $dateobs dateiso aa mm jj sep h m s sd] } {

      # Si date ISO Correcte
      set dateiso "${aa}-${mm}-${jj}T${h}:${m}:${s}${sd}"

      set key_dateiso [lreplace [::bddimages_liste::lget $tabkey "date-obs"] 1 1 $dateiso]
      set tabkey [::bddimages_liste::lupdate $tabkey "date-obs" $key_dateiso]

#      set key_foclen [list "FOCLEN" 7.973 "double" "Focal lenght" "m"]
#      set tabkey     [::bddimages_liste::ladd $tabkey "foclen" $key_foclen ]

      set key_bin1 [::bddimages_liste::lget $tabkey "hbin"]
      if {[llength $key_bin1] > 1} {
         set bin1     [lindex $key_bin1 1]
         set key_bin1 [lreplace $key_bin1 0 0 "BIN1"]
         set tabkey   [::bddimages_liste::ladd $tabkey "bin1" $key_bin1 ]

         set pixsize1     [expr $bin1 * 13.5]
         set key_pixsize1 [list "PIXSIZE1" $pixsize1 "double" "Pixel Size" "mum"]
         set tabkey       [::bddimages_liste::ladd $tabkey "pixsize1" $key_pixsize1 ]
      }

      set key_bin2 [::bddimages_liste::lget $tabkey "vbin"]
      if {[llength $key_bin2] > 1} {
         set bin2     [lindex $key_bin2 1]
         set key_bin2 [lreplace $key_bin2 0 0 "BIN2"]
         set tabkey   [::bddimages_liste::ladd $tabkey "bin2" $key_bin2 ]

         set pixsize2     [expr $bin2 * 13.5]
         set key_pixsize2 [list "PIXSIZE2" $pixsize2 "double" "Pixel Size" "mum"]
         set tabkey       [::bddimages_liste::ladd $tabkey "pixsize2" $key_pixsize2 ]
      }

      set key_exposure [::bddimages_liste::lget $tabkey "exposure"]
      if {[llength $key_exposure] > 1} {
         set exposure     [lindex $key_exposure 1]
         set exposure     [regsub {,} $exposure "."]
         set key_exposure [lreplace $key_exposure 1 1 $exposure]
         set tabkey       [::bddimages_liste::lupdate $tabkey "exposure" $key_exposure ]
      }

      set key_exptime  [::bddimages_liste::lget $tabkey "exptime"]
      if {[llength $key_exptime] > 1} {
         set exptime      [lindex $key_exptime 1]
         set exptime      [regsub {,} $exptime "."]
         set key_exptime  [lreplace $key_exptime 1 1 $exptime]
         set tabkey       [::bddimages_liste::lupdate $tabkey "exptime" $key_exptime ]
      }

      set key_uaicode  [list "IAU_CODE" 874 "int" "Observatory uai code" ""]
      set tabkey [ ::bddimages_liste::ladd $tabkey "iau_code" $key_uaicode ]


      #::console::affiche_resultat "RA=$ra ($rah)\n"
      #::console::affiche_resultat "EXPOSURE=$exposure\n"


      return [list 0 $tabkey]

   } else {

      # Sinon
      return [list 1 "-"]

   }

}

proc chg_tabkey_avant_20120101 {tabkey} {

   #     0         1         2
   #       0123456789012345678901
   # date <2006-06-23T20:22:36.08>

   foreach keyval $tabkey {

      set key [lindex $keyval 0]
      set val [lindex [lindex $keyval 1] 1]

      switch $key {
         "DATE" {
            set dateobs $val
         }
         default {
         }
      }
          # fin switch
   }
   # fin foreach

   set annee   [string range $dateobs 0 3]
   set mois    [string range $dateobs 5 6]
   set jour    [string range $dateobs 8 9]
   set heure   [string range $dateobs 11 12]
   set minute  [string range $dateobs 14 15]
   set seconde [string range $dateobs 17 end]

   set dateiso "$annee-$mois-$jour\T$heure:$minute:$seconde"

return [list 0 $dateiso]
}

