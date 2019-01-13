#
## @file catalogexplorer_typeSp.tcl
#  @brief Identification du type spectral pour catalogexplorer
#  @author Raymond Zachantke
#  $Id: catalogexplorer_typesp.tcl 12858 2016-01-24 11:29:42Z rzachantke $
#  @details Fonctions dériveées de bdi_tools_cdl.tcl, avec l'aide F. Vachier

#------------------------------------------------------------
#  brief   créé une matrice avec les noms et les valeurs
#
#          la matrice est disponible sous forme de variable sptypeMatrix
#  param   path chemin du fichier sptype.csv
#

proc ::catalogexplorer::init_spectral_type { path } {
   variable sptypeMatrix

   #pm : package require struct::matrix

   #--   Extrait le catalogue avec les titres
   regsub -all {\{\}} [split [K [read [set fi [open $path]]] [close $fi]] "\n"] "" catalog

   #--   Definit le nombre de colonnes et de lignes
   set nbRow [llength $catalog]
   set nbCol [llength [split [lindex $catalog 0] ";"]]

   #--   Cree la matrice
   catch { struct::matrix sptypeMatrix }

   #--   Cree le nombre de colonnes
   sptypeMatrix add columns $nbCol

   #--   Remplit la matrice
   for {set k 0} {$k < $nbRow} {incr k} {
      sptypeMatrix add row  [split [lindex $catalog $k] ";"]
   }
}

#------------------------------------------------------------
#  brief   identifie le type spectral
#  param   lmags liste ordonnancée des magnitudes magB magR mabV magJ magH magK ; ex. "B 18.990 R 15.310 V 17.150 J 13.923 H 13.074 K 12.816"
#  return  liste indice moyen, nb de mesures, écart, spType
#
proc ::catalogexplorer::get_spectral_type { lmags } {
   variable sptypeMatrix : # matrice remplie

   #--   Arrete s'il n'y a pas au moins 3 valeurs donc 6 parametres
   #--  car on ne peut rien en faire
   if {[llength $lmags] < 6} { return ? }

   #pm : package require BLT 2.4

   #--Initialisation des variables
   set C "" ; set U "" ; set B ""; set R "" ; set V "" ; set I ""
   set H "" ; set J "" ; set K ""; set L "" ; set M "" ; set N ""

   #--   Affectation des valeurs aux variables
   foreach {var val} $lmags { set $var $val }

   set listDat {}
   #--   Cree un liste alternant le nom de la bande et la valeur
   #--   seules les valeurs non vides seront traitees
   if {$U!="" && $B!=""} { lappend listDat "(U-B)" [expr { $U-$B }] }
   if {$B!="" && $V!=""} { lappend listDat "(B-V)" [expr { $B-$V }] }
   if {$V!="" && $R!=""} { lappend listDat "(V-R)C" [expr { $V-$R }] }
   if {$V!="" && $I!=""} { lappend listDat "(V-I)C" [expr { $V-$I }] }
   if {$V!="" && $J!=""} { lappend listDat "(V-J)" [expr { $V-$J }] }
   if {$V!="" && $H!=""} { lappend listDat "(V-H)" [expr { $V-$H }] }
   if {$V!="" && $K!=""} { lappend listDat "(V-K)" [expr { $V-$K }] }
   if {$V!="" && $L!=""} { lappend listDat "(V-L)" [expr { $V-$L }] }
   if {$V!="" && $M!=""} { lappend listDat "(V-M)" [expr { $V-$M }] }
   if {$V!="" && $N!=""} { lappend listDat "(V-N)" [expr { $V-$N }] }

   #--   Cree un vecteur recuperant les rangs dans les colonnes
   ::blt::vector create Vidst -watchunset 1

   #--   les sous-fonctions mean, min et max des vecteurs sont bien utiles
   foreach {band val} $listDat {
      Vidst append [::catalogexplorer::get_indice_by_band $band $val]
   }

   set len  [Vidst length]
   #--   Valeurs par defaut
   set mean -99
   set sep -99

   if {$len > "1"} {
      set mean $Vidst(mean)
      set sep [expr { $Vidst(max)-$Vidst(min) }]
   } elseif {$len eq "1"} {
      set mean $Vidst(mean)
   } elseif { $len eq "0" } {
      return ?
   }

  if {$mean>=0 && $mean<50} {
      #--   Identifie le nom de ligne (indice $row dans la colonne 0)
      set spType [ sptypeMatrix get cell 0 [expr { round($mean) }]]
      set res [list $mean $len $sep $spType]
   }

   ::blt::vector destroy Vidst

   return $res
}

#------------------------------------------------------------
#  brief   cherche l'indice dans la colonne afférente à la bande
#  param   band littéral
#  param   dmag différence de magnitude
#  return  l'indice dans la table
#
proc ::catalogexplorer::get_indice_by_band { band dmag } {
   variable sptypeMatrix ; # matrice des valeurs

   ::blt::vector create Vt -watchunset 1

   set idmin ""

   #--   Identifie l'index de la colonne
   #--   Premier index de la liste = index de la colonne
   #--   attention aux parentheses
   set col [lindex [lindex [ sptypeMatrix search -exact row 0 $band ] 0] 0]

   #--   Remplit le vecteur avec les valeurs numeriques de la colonne
   Vt set [lrange [sptypeMatrix get column $col] 1 50]

   #--   Calcul unique de la valeur absolue de la difference
   Vt expr { abs(Vt-$dmag) }

   #--   L'index de la valeur minimale est aussi l'index de la ligne dans la colonne !
   set idmin [lindex [Vt search $Vt(min)] 0]

   ::blt::vector destroy Vt

   return $idmin
}

