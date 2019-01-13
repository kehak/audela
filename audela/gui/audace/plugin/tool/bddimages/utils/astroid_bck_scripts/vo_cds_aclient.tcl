
# ./aclient 130.79.129.161 1660 ucac2 -sr -c 0.0 0.0 -r 1

# http://cdsarc.u-strasbg.fr/cgi-bin/Cat?I/289
proc vo_aclient_parse_ucac2 { line } {
 set fields { 2UCAC RAdeg DEdeg e_RAdeg e_DEdeg ePos UCmag No Nc cfl EpRA EpDE pmRA pmDE e_pmRA e_pmDE qpmRA qpmDE 2Mkey Jmag Hmag Kmag phf ccf }
 set l {}
 lappend l [ string range $line 0 7 ]
 lappend l [ string range $line 9 19 ]
 lappend l [ string range $line 20 30 ]
 lappend l [ string range $line 32 34 ]
 lappend l [ string range $line 36 38 ]
 lappend l [ string range $line 40 42 ]
 lappend l [ string range $line 44 48 ]
 lappend l [ string range $line 50 51 ]
 lappend l [ string range $line 53 54 ]
 lappend l [ string range $line 57 58 ]
 lappend l [ string range $line 60 67 ]
 lappend l [ string range $line 69 76 ]
 lappend l [ string range $line 78 85 ]
 lappend l [ string range $line 87 94 ]
 lappend l [ string range $line 96 99 ]
 lappend l [ string range $line 101 104 ]
 lappend l [ string range $line 106 110 ]
 lappend l [ string range $line 112 116 ]
 lappend l [ string range $line 118 127 ]
 lappend l [ string range $line 129 134 ]
 lappend l [ string range $line 136 141 ]
 lappend l [ string range $line 143 148 ]
 lappend l [ string range $line 150 152 ]
 lappend l [ string range $line 154 156 ]
 return [ list ucac2 $fields $l ]
}

# http://cdsarc.u-strasbg.fr/viz-bin/Cat?I/315
proc vo_aclient_parse_ucac3 { line } {
 set fields { 3UC RAdeg DEdeg e_RAdeg e_DEdeg ePos EpRA EpDE f.mag a.mag e_a.mag ot db Na Nu Ca Cu pmRA pmDE e_pmRA e_pmDE MPOS 2Mkey Jmag e_Jmag --- q_Jmag Hmag e_Hmag --- q_Hmag Kmag e_Kmag --- q_Kmag sc Bmag --- q_Bmag R2mag --- q_R2mag Imag --- q_Imag catflg --- g c LEDA 2MX }
 set l {}
 lappend l [ string range $line 0 9 ]
 lappend l [ string range $line 11 21 ]
 lappend l [ string range $line 22 32 ]
 lappend l [ string range $line 34 36 ]
 lappend l [ string range $line 38 40 ]
 lappend l [ string range $line 42 45 ]
 lappend l [ string range $line 47 53 ]
 lappend l [ string range $line 55 61 ]
 lappend l [ string range $line 63 68 ]
 lappend l [ string range $line 70 75 ]
 lappend l [ string range $line 77 81 ]
 lappend l [ string range $line 83 84 ]
 lappend l [ string range $line 86 86 ]
 lappend l [ string range $line 89 90 ]
 lappend l [ string range $line 93 94 ]
 lappend l [ string range $line 96 98 ]
 lappend l [ string range $line 101 102 ]
 lappend l [ string range $line 104 111 ]
 lappend l [ string range $line 113 120 ]
 lappend l [ string range $line 122 125 ]
 lappend l [ string range $line 127 130 ]
 lappend l [ string range $line 132 140 ]
 lappend l [ string range $line 142 151 ]
 lappend l [ string range $line 153 158 ]
 lappend l [ string range $line 160 163 ]
 lappend l [ string range $line 164 164 ]
 lappend l [ string range $line 165 166 ]
 lappend l [ string range $line 168 173 ]
 lappend l [ string range $line 175 178 ]
 lappend l [ string range $line 179 179 ]
 lappend l [ string range $line 180 181 ]
 lappend l [ string range $line 183 188 ]
 lappend l [ string range $line 190 193 ]
 lappend l [ string range $line 194 194 ]
 lappend l [ string range $line 195 196 ]
 lappend l [ string range $line 198 199 ]
 lappend l [ string range $line 201 206 ]
 lappend l [ string range $line 207 207 ]
 lappend l [ string range $line 208 209 ]
 lappend l [ string range $line 211 216 ]
 lappend l [ string range $line 217 217 ]
 lappend l [ string range $line 218 219 ]
 lappend l [ string range $line 221 226 ]
 lappend l [ string range $line 227 227 ]
 lappend l [ string range $line 228 229 ]
 lappend l [ string range $line 231 240 ]
 lappend l [ string range $line 241 241 ]
 lappend l [ string range $line 242 242 ]
 lappend l [ string range $line 243 243 ]
 lappend l [ string range $line 245 247 ]
 lappend l [ string range $line 249 251 ]
 return [ list ucac3 $fields $l ]
}

#
# vo_cds_aclient { catalog ucac3 ra 0.0 dec 0.0 radius 2.0 }
# returns : {  { "ucac3" fields_list row1 } ... }
#
proc vo_cds_aclient { argslist } {
 array set args $argslist
 set catalog $args(catalog)
 set entries {}
 set result [exec aclient 130.79.129.161 1660 $args(catalog) -sr -c $args(ra) $args(dec) -r $args(radius)]
 set lines [ split $result "\n" ]
 foreach line $lines {
  puts $line
  if {[string compare -length 1 "#" $line] == 0} { continue }
  lappend entries [vo_aclient_parse_$catalog $line]
 }
 return $entries
}

