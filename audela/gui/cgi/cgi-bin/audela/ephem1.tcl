#
# Fichier : ephem_1.tcl
#

# --- entete HTML
cgiaudela_entete
puts "<BODY>"

# --- calcule et affiche la date ---
set d [mc_date2ymdhms now]
puts "Nous sommes le [lindex $d 2]/[lindex $d 1]/[lindex $d 0] "
puts "[lindex $d 3]h[lindex $d 4]min<BR>"

# --- calcule et affiche les ephemerides ---
set liste_ephem [mc_ephem * now {OBJENAME RAH RAM.M DECD DECM.M MAG} ]
set n [expr [llength $liste_ephem]-1]
puts "<PRE>"
puts " PLANET RA         DEC        MAG"
for {set k 0} {$k<$n} {incr k} {
   set ephem   [lindex $liste_ephem $k]
   set planete [format "%7s"    [lindex $ephem 0] ]
   set rah     [format "%02d"   [lindex $ephem 1] ]
   set ram     [format "%05.2f" [lindex $ephem 2] ]
   set decd    [format "%+03d"  [lindex $ephem 3] ]
   set decm    [format "%05.2f" [lindex $ephem 4] ]
   set mag     [format "%+5.1f" [lindex $ephem 5] ]
   puts "${planete} ${rah}h${ram}m ${decd}&deg;${decm}' ${mag}"
}
puts "</PRE>"

# --- fin HTML
puts "</BODY>"
cgiaudela_fin
