
proc vision { p_tvargs } { 
    
    upvar $p_tvargs tvargs
    
    set out [exec vision-cli -c $tvargs(iaucode)  \
                             -d $tvargs(date)     \
                             -n $tvargs(nb)       \
                             -o $tvargs(filename) \
                             -p $tvargs(step)     \
                             -t $tvargs(targets)  \
                             -m none
            ]
    return 0

}


proc can_we_observe { jd p_data_struct } {
   
   upvar $p_data_struct data_struct

   if {$jd >= data_struct(sun,$i,evetwi,2) && $jd <= data_struct(sun,$i,mortwi,2)} {
      return 0
   } else {
      return 1
   }

}


proc is_observable { cible jd p_data_struct } {
   
   upvar $p_data_struct data_struct



   return 1

}




proc read_ephevision { filename p_data_struct } {

   upvar $p_data_struct data_struct

   set text ""
   set chan [open $filename r]
   while {![eof $chan]} {
      lappend text [gets $chan]
   }
   close $chan

   # Code UAI
   set idx 0
   set data_struct(iaucode) [lindex $text $idx]

   # Coordonnees geographiques long(deg) lat(deg) alt(m)
   set idx 1
   set a [regexp -inline -all -- {\S+} [lindex $text $idx]]
   lassign $a data_struct(long) data_struct(lat) data_struct(alt)

   # Nom du lieu
   set idx 2
   set data_struct(nomlieu) [lindex $text $idx]

   # Epoques de calcul
   set idx 3
   set a [regexp -inline -all -- {\S+} [lindex $text $idx]]
   lassign $a data_struct(nbdatesvision) data_struct(nbdatesparjour) data_struct(pasint)

   # Nb cibles
   set idx 4
   set data_struct(nbcibles) [lindex $text $idx]

   # Donnees du Soleil
   set idx 4
   for {set i 1} {$i <= $data_struct(nbdatesvision)} {incr i} {
      set a [regexp -inline -all -- {\S+} [lindex $text [expr $i + $idx]]]
      lassign $a id \
                 data_struct(sun,$i,jd) \
                 data_struct(sun,$i,sunset) \
                 data_struct(sun,$i,evetwi,1) data_struct(sun,$i,evetwi,2) data_struct(sun,$i,evetwi,3) \
                 data_struct(sun,$i,mortwi,1) data_struct(sun,$i,mortwi,2) data_struct(sun,$i,mortwi,3) \
                 data_struct(sun,$i,sunrise)
   }

   # Cibles
   set idx [expr $data_struct(nbdatesvision) + 5]
   array unset cible
   for {set i 1} {$i <= $data_struct(nbcibles)} {incr i} {

      # Info cible
      if { ! [regexp {(.*), (.*), (.*), (.*), (.*)} [lindex $text $idx] u data_struct(cible,$i,type) data_struct(cible,$i,name) data_struct(cible,$i,num) data_struct(cible,$i,rotperiod) data_struct(cible,$i,alias)] } {
         return 1
      }
      incr idx

      # Data cible
      for {set j 1} {$j <= $data_struct(nbdatesvision)} {incr j} {
         for {set k 1} {$k <= $data_struct(nbdatesparjour)} {incr k} {
            set a [regexp -inline -all -- {\S+} [lindex $text $idx]]
            lassign $a id \
                       data_struct(cible,$i,$j,$k,jd) \
                       data_struct(cible,$i,$j,$k,vmag) \
                       data_struct(cible,$i,$j,$k,ra) \
                       data_struct(cible,$i,$j,$k,dec) \
                       data_struct(cible,$i,$j,$k,appmotion) \
                       data_struct(cible,$i,$j,$k,dobserver) \
                       data_struct(cible,$i,$j,$k,dhelio) \
                       data_struct(cible,$i,$j,$k,phaseangle) \
                       data_struct(cible,$i,$j,$k,sunelong) \
                       data_struct(cible,$i,$j,$k,moonelong) \
                       data_struct(cible,$i,$j,$k,appdiam) \
                       data_struct(cible,$i,$j,$k,azimuth) \
                       data_struct(cible,$i,$j,$k,hauteur)                        
            incr idx
         }
      }
   }

   return 0
}