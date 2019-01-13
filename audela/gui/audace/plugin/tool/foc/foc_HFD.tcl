#
## @file foc_HFD.tcl
#  @brief Scripts pour la mise en oeuvre du HFD, compatible avec USB_Focus et AudeCom
#  @author Raymond ZACHANTKE
#  $Id: foc_HFD.tcl 12889 2016-01-24 22:06:15Z rzachantke $
#

#---------------------------------------------------------------------------
#  brief découpe les vecteurs de résultats en gauche et droite si le minimum est dépassé
#  return liste de la pente à gauche, de la pente à droite et du point optimum
#
proc ::foc::computeSlope { } {

   set slopeLeft  "0.000000"
   set step0Left  "0.00"
   set slopeRight "0.000000"
   set step0Right "0.00"
   set positionOpt "0.00"

   blt::vector create yleft yright xleft xright -watchunset 1
   yleft set ::VShfd          ; #-- copie le vecteur
   xleft set ::VSpos          ; #-- copie le vecteur

   #--   Ne fait rien si toutes les (au moins 2) positions sont identiques
   set len [xleft length]
   if { $len < 2 || ($len >= 2 && $xleft(0) == $xleft(end)) } {
      return [list $slopeLeft $slopeRight $positionOpt]
   }

   #--   liste les index (s'il y en a plusieurs) de la valeur minimale
   set listIndexMin [yleft search $yleft(min)]

   #--   rang du minimum (neglige les index plus eleves)
   set rankMin [lindex $listIndexMin 0]

   if {$rankMin != [expr { [yleft length]-1 }]} {

      #--   isole les mesures > minimum = vecteur des valeurs a droite
      yright set [yleft range [expr { $rankMin+1 }] end]
      xright set [xleft range [expr { $rankMin+1 }] end]

      #--   ignore le premier depassement (si moins de 2 valeurs)
      if {[yright length] == [xright length] && [yright length] >= 2} {
         set side right
         lassign [::foc::getParam $side $yright(:) $xright(:)] constanteRight slopeRight step0Right
      }

      #--   raccourci le vecteur gauche
      yleft length [expr { $rankMin-1 }]
      xleft length [expr { $rankMin-1 }]
   }

   #--   traite le vecteur gauche
   if {[yleft length] == [xleft length] && [yleft length] >= 2} {
      set side left
      lassign [::foc::getParam $side $yleft(:) $xleft(:)] constanteLeft slopeLeft step0Left
   }

   #--   calcule de l'intersection
   if {$slopeLeft != 0 && $slopeRight != 0} {
      set xIntersect [expr { ($constanteLeft-$constanteRight)/($slopeRight-$slopeLeft) }]
      set positionOpt [format "%0.2f" $xIntersect]
   }

   set slopeLeft [format "%0.6f" $slopeLeft]
   set slopeRight [format "%0.6f" $slopeRight]

   blt::vector destroy yleft yright xleft xright

   return [list $slopeLeft $slopeRight $positionOpt]
}

#---------------------------------------------------------------------------
#  brief calcule la variation de HFD en fonction de la position par ajustement linéaire
#  param side
#  param mHfd
#  param mPos
#  return liste de la constante, de la pente et du pas
#
proc ::foc::getParam { side mHfd mPos } {

   blt::vector create xLine yLine w -watchunset 1
   yLine set $mHfd
   xLine set $mPos
   set n [yLine length]

   #--   calcule les parametres de HFD= A + pente * pas de focuser
   w length $n             ; #--matrice de longueur n remplie de 0
   w expr { w == 0 }       ; #--matrice unitaire

   set X ""
   for { set i 0 } { $i <  $n } { incr i } {
      lappend X [list 1 [xLine index $i]]
   }

   #--   resoud le systeme y=a+b*x
   lassign [lindex [ gsl_mfitmultilin $yLine(:) $X $w(:) ] 0] constante slope
   #set chi2 [lindex [ gsl_mfitmultilin $yLine(:) $X $w(:) ] 1]
   #set pConf [::foc::computePconf $chi2 $n 2]
   #set msg [format $::caption(foc,interp) $chi2 $pConf]
   #::console::affiche_resultat "$side $msg\n"

   #--   calcule l'intersection avec l'axe des abscisses (les pas)
   if {$slope != 0} {
      set step0 [expr { -1.*$constante/$slope }]
   } else {
      set step0 "ind"
   }

   blt::vector destroy xLine yLine w

   return [list $constante $slope $step0]
}

#---------------------------------------------------------------------------
#  brief ordonnance la mise à jour des graphiques
#  param args
#
proc ::foc::processHFD { args } {
   global panneau

   #--   filtrage des images plates
   if {$panneau(foc,biny) eq ""} {
      set panneau(foc,hfd) 1000
      return
   }

   #--   etape 1 : extraction de la boite et de la coupe horizontale
   #--   peuple les vecteurs abscisses (::Vx) et ordonnees(::Vint) du graphe1
   ::foc::createCoupeHoriz

   #--   extraction des limites d'analyse
   #--   1/e² = 0.135 du pic (1/e-Squared Halfwidth)
   lassign [getAnalyseLimits ::Vintx 0.135] start end

   if {$start != 1 && $end != [::Vx length]} {

      #--   si les limites sont dans la boite
      #--   etape 2 : extraction du flux cumule en fonction du rayon
      #--   peuple les vecteurs abscisses (::Vradius) et ordonnees(::Vhfd) du graphe2
      set rayon [computeHFD ::Vintx $start $end]

      #--   etape 3 : met a jour les titres et les graphiques
      ::foc::updateHFDGraphe $start $end $rayon

   } else {
      ::console::affiche_resultat "mesure invalide\n"
   }
}

#---------------------------------------------------------------------------
#  brief binne l'image en Y et met les valeurs dans panneau(foc,biny)
#  param bufNo numéro du buffer contenant l'image normale
#
proc ::foc::extractBiny { bufNo } {
   global panneau

   set naxis1 [buf$bufNo getpixelswidth]
   set naxis2 [buf$bufNo getpixelsheight]

   #--   recopie l'image vers un nouveau buffer
   set dest [::buf::create]
   buf$bufNo copyto $dest

   #--   somme toutes les lignes
   buf$dest biny 1 $naxis2 1

   set panneau(foc,biny) [list ]

   set s [ stat ]
   set inten [expr { [lindex $s 2 ]-[lindex $s 6] } ]

   if {$inten > 10} {
      for {set col 1} {$col <= $naxis1} {incr col} {
         lappend panneau(foc,biny) [lindex [buf$dest getpix [list $col 1]] 1]
      }
   }
   ::buf::delete $dest
}

#---------------------------------------------------------------------------
#  brief binne en Y une image extraite de la boîte de sélection
#
proc ::foc::createCoupeHoriz { } {
   global panneau

   #--   peuple le vecteur intensite du profil en X (variation entre {0|1})
   blt::vector create temporaire -watchunset 1
   temporaire offset 1                             ; #-- fait correspondre les indices et le N° de pixel
   temporaire append $panneau(foc,biny)
   temporaire expr { temporaire/$temporaire(max) } ; #-- maintenant max == 1.0
   ::Vintx set temporaire                          ; #-- transfert vers le vecteur graphique

   #--   peuple le vecteur ::Vx abscisse du graphe1
   ::Vx offset 1                                   ; #-- fait correspondre les indices et le N° de pixel
   ::Vx seq 1 [::Vintx length]                     ; #-- graduation entre 1 et naxis1

   blt::vector destroy temporaire
}

#---------------------------------------------------------------------------
#  brief cherche les limites dans un vecteur de flux
#  param vectorName nom du vecteur à traiter
#  param limit limite d'écretage (en fraction du max)
#  return limites robustes
#
proc ::foc::getAnalyseLimits { vectorName limit } {

   blt::vector create Vindex -watchunset 1

   #--    attention : le pemier indice de Vindex est 1
   Vindex expr { $vectorName >= $limit }                 ; #--   Vindex contient 1 si la valeur > $limit, sinon 0
   Vindex set [Vindex search 1.0]                        ; #--   Vindex contient la liste des index des valeurs > $limit
   set len [Vindex length]

   #--   la serie d'index est sans trou si la difference entre les index == 1
   #     dans ce cas le nombre d'elements est egal a
   #     la difference entre le dernier et le premier+1
   if {$len  != [expr { $Vindex(end)-$Vindex(1)+1 }]} {

      #--   filtre les index hors serie
      set listToDestroy [list]
      set middle [expr { int($len/2) }]

      #--   etablit la liste des index a supprimer
      for {set j 1} {$j < $len} {incr j} {
         set delta [expr { $Vindex($j+1)-$Vindex($j) }]  ; #--   difference entre deux index successifs
         if {$delta !=1 && $j < $middle} {
            lappend listToDestroy $j                     ; #--   index de l'element courant
         } elseif {$delta !=1 && $j > $middle} {
            lappend listToDestroy [expr { $j+1} ]        ; #--   index de l'element suivant
         }
      }

      set indexEnd [expr { [llength $listToDestroy]-1 }]
      #--   on commence par la fin du vecteur
      #--   (sens inverse ==  erreur assuree)
      for {set k $indexEnd} {$k >= 0} {incr k -1} {
         #--   supprime l'index dans le vecteur
         Vindex delete [lindex $listToDestroy $k]
      }
   }

   set result [list $Vindex(1) $Vindex(end)]             ; # premier et dernier index de la serie sans trou

   blt::vector destroy Vindex

   return $result
}

#---------------------------------------------------------------------------
#  brief calcule le rayon du cercle contenant 50% du flux
#  param vectorName
#  param lim1 limite d'exploration
#  param lim2 limite d'exploration
#  return rayon
#
proc ::foc::computeHFD { vectorName lim1 lim2 } {

   set pi [expr { 4*atan(1) }]

   #--   transforme en indices
   set lim1 [expr { int($lim1) }]
   set lim2 [expr { int($lim2) }]

   set k [expr { int(($lim2-$lim1)/2) }]

   blt::vector create V1 temporaire -watchunset 1

   set sum 0
   for {set i $k} {$i >= 0} {incr i -1} {
      set first [expr { $lim1+$i }]                ; # index du premier element a sommer
      set second [expr { $lim2-$i }]               ; # index du second element
      if {$first != $second} {
         #--   calcule la somme des deux elements et le cumul
         set sum [expr { $sum+[$vectorName index $first]+[$vectorName index $second] }]
      }  else {
        #--   ne prend que l'element central (nb de mesures impair)
         set sum [expr { $sum+[$vectorName index $first] }]
      }
      V1 append $sum
   }

   #--   peuple l'axe des abscisses du graphique 2
   ::Vradius seq 0 [V1 length] 1

   #--   la surface d'un anneau vaut pi*(R2²-R1²)
   #--   pour des anneaux concentriques de rayon 1 2 3 4 ...
   #--   la différence R2²-R1² varie comme       1 3 5 7 ... (serie des nombres impairs, de pas 2)
   #     le pas de la surface vaut donc 2*pi
   set pas [expr { 2*$pi }]
   #--   calcule le poids de chaque anneau de 1 pixel
   temporaire seq $pi [expr { ($k+1)*$pas }] $pas

   #--   pondere chaque valeur par le coefficient surfacique
   V1 expr { V1*temporaire  }

   ::Vhfd expr { V1/$V1(max) }                     ; # transfert vers le vecteur graphique
   temporaire expr {::Vhfd < 0.5}                  ; #--  element == 1 si valeur < 0.5, sinon 0
   set start [lindex [temporaire search 1.0] end]  ; #--  extrait l'index du dernier element < 0.5
   set startValue [::Vhfd index $start]            ; #--  sa valeur
   set end [expr { $start+1 }]                     ; #--  index de la premiere valeur > 0.5
   set endValue [::Vhfd index $end]                ; #--  sa valeur

   #--   interpolation lineaire pour 0.5
   set rayon [expr { $start+(0.5-$startValue)/($endValue-$startValue) }]

   blt::vector destroy V1 temporaire

   return $rayon
}

#------------------------------------------------------------
#  brief calcule le niveau de confiance d'un X²
#  param chisquare chi²
#  param nbValues nombre de valeurs
#  param nbParameters nombre de paramètres
#  return l'intervalle de confiance
#
proc ::foc::computePconf { chisquare nbValues nbParameters } {

   set ddl [expr { 2*$nbValues-$nbParameters-1 }]
   return [gsl_cdf_chisq_Q $chisquare $ddl]
}

