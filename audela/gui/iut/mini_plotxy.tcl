global mini_plotxy

catch {unset mini_plotxy}

namespace eval ::mini_plotxy {
   variable selected_region
   global mini_plotxy
   
   #########################################################################
   #--   Affiche les crosshairs                                            #
   #########################################################################
   proc viewCrosshairs { graph x y } {
      $graph crosshairs configure -position @$x,$y
      set x [format %.2f [ $graph axis invtransform x $x ]]
      set y [format %.2f [ $graph axis invtransform y $y ]]
      return [list $x $y]
   }

   #########################################################################
   #--   Bindings du zoom                                                  #
   #########################################################################
   proc createBindingsZoom { graph } {

      bind $graph <ButtonPress-1> {
         ::mini_plotxy::regionStart %W %x %y
      }
      bind $graph <B1-Motion> {
         ::mini_plotxy::regionMotion %W %x %y
      }
      bind $graph <ButtonRelease-1> {
         ::mini_plotxy::regionEnd %W %x %y
      }
      bind $graph <Double-ButtonRelease-1> {
         ::mini_plotxy::zoomOut %W
      }
      #bind $graph <ButtonPress-2> {
      #   ::mini_plotxy::regionStart %W %x %y
      #}
      #bind $graph <B2-Motion> {
      #   ::mini_plotxy::regionMotion %W %x %y
      #}
      #bind $graph <ButtonRelease-2> {
      #   ::mini_plotxy::regionEndSelect %W %x %y
      #}
      bind $graph <ButtonRelease-2> {
         ::mini_plotxy::zoomOut %W
      }
   }
   
   #########################################################################
   #--   Capture les coordonnees initiales de la zone a zoomer             #
   #--   Entree : nom de la fenetre, coordonnees initiales                 #
   #########################################################################
   proc regionStart { graph x y } {
      global mini_plotxy

      #--   transforme les coordonnees ecran en coordonnees graphique
      #--   memorise les coordonnees initiales
      set mini_plotxy(zoomstart,x) [ $graph axis invtransform x $x ]
      set mini_plotxy(zoomstart,y) [ $graph axis invtransform y $y ]

      #--   cree un rectangle de selection sans coordonnees
#      $graph marker create line -coords {} -name myLine -dashes dash \
#         -linewidth 2 -outline blue -xor yes
      $graph marker configure myLine1 -coords ""
   }

   #########################################################################
   #--   Trace le rectangle de selection de la zone a zoomer               #
   #--   Entree : nom de la fenetre, coordonnees finales courantes         #
   #########################################################################
   proc regionMotion { graph x y } {
      global mini_plotxy

      set x0 $mini_plotxy(zoomstart,x)
      set y0 $mini_plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   trace le rectangle de selection
      $graph marker configure myLine1 -coords "$x0 $y0 $x0 $y1 $x1 $y1 $x1 $y0 $x0 $y0"
   }

   #########################################################################
   #--   Zoom dans le graphe                                               #
   #--   Entree : nom de la fenetre, coordonnees finales                   #
   #########################################################################
   proc regionEnd { graph x y } {
      global mini_plotxy

      set x0 $mini_plotxy(zoomstart,x)
      set y0 $mini_plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   efface le rectangle de selection
#      $graph marker delete myLine
      $graph marker configure myLine1 -coords ""

      #--   intercepte un clic simple dans la fenetre
      if { $x0 == $x1 || $y0 == $y1 } {
         return
      }

      #--   modifie les bornes de la visualisation
      zoomIn $graph $x0 $y0 $x1 $y1
   }

   #########################################################################
   #--   Selectionner dans le graphe                                       #
   #--   Entree : nom de la fenetre, coordonnees finales                   #
   #########################################################################
   proc ::mini_plotxy::regionEndSelect { graph x y } {
      global mini_plotxy

      set x0 $mini_plotxy(zoomstart,x)
      set y0 $mini_plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   efface le rectangle de selection
#      $graph marker delete myLine
      $graph marker configure myLine1 -coords ""

      #--   intercepte un clic simple dans la fenetre
      if { $x0 == $x1 || $y0 == $y1 } {
         return
      }

      #--   modifie les bornes de la visualisation
      set ::mini_plotxy::selected_region [list $x0 $y0 $x1 $y1]
   }

   #########################################################################
   #--   Recuperation de la Selection                                      #
   #--   Entree :                                                          #
   #########################################################################
   proc ::mini_plotxy::get_selected_region {  } {

      set err [ catch {set x $::mini_plotxy::selected_region} msg]
      if {$err} {
         return -code 1 $msg
      }
      return $x
   }

   #########################################################################
   #--   Libere la variable  unset_selected_region                         #
   #--   Entree :                                                          #
   #########################################################################
   proc ::mini_plotxy::unset_selected_region {  } {

      set err [catch {unset ::mini_plotxy::selected_region} ]
      return $err

   }

   #########################################################################
   #--   Zoom dans le graphe                                               #
   #--   Entree : nom de la fenetre, coordonnees du rectangle de selection #
   #########################################################################
   proc zoomIn { graph x0 y0 x1 y1 } {
      #--   pushZoom
      pushZoom $graph

      #--   configure les axes du graphique
      if { $x0 > $x1 } {
         $graph axis configure x -min $x1 -max $x0
      } else {
         $graph axis configure x -min $x0 -max $x1
      }

      if { $y0 > $y1 } {
         $graph axis configure y -min $y1 -max $y0
      } else {
         $graph axis configure y -min $y0 -max $y1
      }

   }

   #########################################################################
   #--   Memorise la commande de retour du zoom                            #
   #--   Entree : nom de la fenetre                                        #
   #########################################################################
   proc pushZoom { graph } {
      global mini_plotxy

      #--   identifie les coordonnees minimales et maximales
      set x1 [ $graph axis cget x -min ]
      set x2 [ $graph axis cget x -max ]
      set y1 [ $graph axis cget y -min ]
      set y2 [ $graph axis cget y -max ]

      #--   remplace la valeur indeterminee par une liste vide
      foreach val { x1 y1 x2 y2 } {
         if { [ llength [ set $val ] ] == "0" } {
            set $val [ list "" ]
         }
      }

      #--   prepare la commande qui permettra le retour
      set cmd "$graph axis configure x -min $x1 -max $x2 ;
         $graph axis configure y -min $y1 -max $y2"

      #--   memorise la commande
      lappend mini_plotxy(zoomstack,$graph) $cmd
   }

   #########################################################################
   #--   Commande arriere du zoom                                          #
   #--   Entree : nom de la fenetre                                        #
   #########################################################################
   proc zoomOut { graph } {

      global mini_plotxy

      #--   si le stack du zoomIn n'est pas vide
      if [ info exists mini_plotxy(zoomstack,$graph) ] {
         eval [ popZoom $graph ]
      }

   }

   #########################################################################
   #--   Execute la commande de retour du zoom                             #
   #--   Entree : nom de la fenetre                                        #
   #########################################################################
   proc popZoom { graph } {
      global mini_plotxy

      #--   recupere le precedent niveau de zoom
      set cmd [ lindex $mini_plotxy(zoomstack,$graph) end ]

      #--   suprime la commande de la liste
      set mini_plotxy(zoomstack,$graph) [ lreplace $mini_plotxy(zoomstack,$graph) end end ]

      return $cmd
   }


# --fin du namespace
}
