# =============================================================================
# To launch the GUI :
# Use the batch file audela_pingpong.bat in this folder
#
# =============================================================================

set err [catch {package require mkLibsdl} msg ]
if {$err==0} {
   set have_joystick 1
} else {
   set have_joystick 0
}
global key_axis0
set key_axis0 0

# =======================================
# === Initialisation of the variables.
# === Initialisation des variables.
# =======================================

#--- definition of colors
#--- definition des couleurs
set color(back) #FFFFFF

# =========================================
# === Setting the graphic interface.
# === Met en place l'interface graphique.
# =========================================

#--- hide the window root
#--- cache la fenetre racine
wm withdraw .

#--- create the toplevel window .pingpong
#--- cree la fenetre .pingpong de niveau le plus haut
toplevel .pingpong -class Toplevel -bg $color(back)
wm geometry .pingpong 500x500+0+0
wm resizable .pingpong 0 0
wm title .pingpong "Pingpong"

# --- cree une image pour le player
catch {image delete imageplayer}
image create photo imageplayer
imageplayer configure -file ../gui/pingpong/player1.gif -format gif
label .pingpong.player -image imageplayer
place .pingpong.player -x 0 -y 100

# --- cree une image pour la balle
catch {image delete imageball}
image create photo imageball
imageball configure -file ../gui/pingpong/balle_tennis.gif -format gif
label .pingpong.ball -image imageball
place .pingpong.ball -x 100 -y 100

# =========================================
# === Setting the binding.
# === Met en place les liaisons.
# =========================================

# --- destroy the toplevel window with the upper right cross
# --- detruit la fenetre principale avec la croix en haut a droite
bind .pingpong <Destroy> { destroy .pingpong; exit }
bind .pingpong <Key-Right> { global key_axis0 ; set key_axis0 10000 }
bind .pingpong <Key-Left> { global key_axis0 ; set key_axis0 -10000 }
bind .pingpong <Key-F1> { global key_axis0 ; set key_axis0 0 }

set point1his 0
set megasortie 0
while {$megasortie==0} {

   # =========================================
   # === Setting the game
   # === Met en place le jeu
   # =========================================
   update
   
   # --- Recupere la largeur de la fenetre
   set res [wm geometry .pingpong]
   set res [regsub -all \[+\] $res " "]
   set res [regsub -all x $res " "]
   set largeur_win [lindex $res 0]
   set hauteur_win [lindex $res 1]

   # --- Recupere la largeur de l'image du player
   set largeur_player [image width imageplayer]
   set largeur_p [expr $largeur_win-$largeur_player]
   set hauteur_player [image height imageplayer]
   set hauteur_p [expr $hauteur_win-$hauteur_player]
   place configure .pingpong.player -y $hauteur_p

   # --- Recupere la largeur de l'image du ball
   set largeur_ball [image width imageball]
   set largeur_b [expr $largeur_win-$largeur_ball]
   set hauteur_ball [image height imageball]
   set hauteur_b [expr $hauteur_win-$hauteur_player-$hauteur_ball]
   place configure .pingpong.ball -x [expr $largeur_b/2]
   place configure .pingpong.ball -y [expr $hauteur_b/4]
   set dxb 3
   set dyb 3
   
   # --- Grande boucle du jeu
   set respons ""
   set sortie 0
   set point1s 0
   set point2s 0
   set t0 [clock milliseconds]
   set key_axis0 0
   while {$sortie==0} {

      update
      after 10

      # --- Lecture des evenements du joystick: Sortie de la boucle et du jeu
      catch {
         set res [joystick get 0 button 6]
         if {$res==1} { exit }
      }

      # --- Recupere la position X du joueur
      set xplayer [lindex [place configure .pingpong.player -x] 4]

      # --- Lecture des evenements des fleches du clavier: Deplacement du joueur
      set axis0 $key_axis0

      # --- Lecture des evenements du joystick: Deplacement du joueur
      set axis0 $key_axis0
      catch {
         set axis0 [joystick get 0 axis 0]
      }
      set dxp [expr round($axis0/2000.0)]

      # --- Recupere la position X,Y de la balle
      set xball [lindex [place configure .pingpong.ball -x] 4]
      set yball [lindex [place configure .pingpong.ball -y] 4]

      # --- Calcule et place la nouvelle position de la balle
      set dt [expr [clock milliseconds]-$t0]
      if {$dt>2000} {
         set xball [expr $xball+$dxb]
         if {$xball<1} {set dxb [expr -1*$dxb]}
         if {$xball>$largeur_b} {set dxb [expr -1*$dxb]}
         set yball [expr $yball+$dyb]
         if {$yball<1} {set dyb [expr -1*$dyb]}
      }
      if {$yball>$hauteur_b} {
         if {([expr $xball+$largeur_ball]>$xplayer)&&($xball<[expr $xplayer+$largeur_player])} {
            # --- on rebondit sur le player
            incr point1s 10
            set dyb [expr -1*$dyb]
            # --- accelere ou decelere
            if {($dxp>2)} {
               set dxb [expr $dxb+1]
               if {$dxb>9} { set dxb 9 }
            } elseif {($dxp<-2)} {
               set dxb [expr $dxb-1]
               if {$dxb<-9} { set dxb -9 }
            }
         } else {
            # --- on a perdu
            set dxb 0
            set dyb 0
            if {$point1s>$point1his} {
               set point1his $point1s
            }
            # --- fenetre de choix
            set t [toplevel .t]
            wm title $t ""
            wm geometry $t 200x140+250+100
            wm resizable $t 0 0            
            pack [label $t.m -text "Game over.\n$point1s points (high score $point1his).\n\nVoulez-vous recommencer ?"]
            place [button $t.yes -text "Yes" -command "set respons yes ; destroy $t"] -x 50 -y 80
            place [button $t.no -text "No" -command "set respons no ; destroy $t"] -x 140 -y 80
            tkwait window $t
            #
            set sortie 1
            break
         }
      }
      place configure .pingpong.ball -x $xball -y $yball

      # --- Calcule et place la nouvelle position du joueur
      set xplayer [expr $xplayer+$dxp]
      if {$xplayer<1} {set xplayer 1}
      if {$xplayer>$largeur_p} {set xplayer $largeur_p}
      place configure .pingpong.player -x $xplayer

      wm title .pingpong "Pingpong $point1s points"
   }

   if {$respons=="no"} { set megasortie 1 }

}

tk_messageBox -message "High score $point1his points." -icon info -type ok -detail "A bientot"
destroy .pingpong
exit

