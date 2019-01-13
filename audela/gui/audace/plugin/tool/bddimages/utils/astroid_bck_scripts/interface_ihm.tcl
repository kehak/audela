# ==========================================================================================
#--- cree l'interface de la grenouille
# ==========================================================================================

# --- return si pas de Tk
set avance "marche"
if {$ros(withtk)==0} {
	return
}

# --- cree la fenetre de plus haut niveau
toplevel .gren -class Toplevel -bg $color(back)
wm geometry .gren 700x400+550+1
wm resizable .gren 1 1
wm minsize .gren 700 400
wm maxsize .gren 700 400
wm title .gren $caption(main_title)
wm protocol .gren WM_DELETE_WINDOW exit

#--- cree un acsenseur vertical pour la console de retour d'etats
frame .gren.fra1 -bg $color(back)
scrollbar .gren.fra1.scr1 -orient vertical \
   -command {.gren.fra1.lst1 yview} -takefocus 0 -borderwidth 1
pack .gren.fra1.scr1 \
   -in .gren.fra1 -side right -fill y
set zone(status_scrl) .gren.fra1.scr1

#--- cree la console de retour d'etats
text .gren.fra1.lst1 \
   -borderwidth 1 -relief sunken -bg $color(backlist) -height 6 -fg $color(forelist) -font {courier 12 bold} \
   -yscrollcommand {.gren.fra1.scr1 set} -wrap word -font {courier 8 bold}
pack .gren.fra1.lst1 \
   -in .gren.fra1 -expand yes -fill both \
   -padx 3 -pady 3
set zone(status_list) .gren.fra1.lst1
pack .gren.fra1 -expand yes -fill both

#--- cree un frame pour y mettre des boutons
frame .gren.fra2 \
   -borderwidth 0 -cursor arrow -bg $color(back)
pack .gren.fra2 \
   -in .gren -anchor s -side bottom -expand 0 -fill x

#--- cree le bouton Suspendre/Reprendre
set avance "marche"
button .gren.fra2.but1 \
   -text $caption(stop) -borderwidth 2 -bg $color(back) -font {courier 12 bold} \
   -command {
      if {[lindex [.gren.fra2.but1 configure -text] 4]==$caption(stop)} {
         set avance "arret"
         .gren.fra2.but1 configure -text $caption(cont)
         update
       } else {
         set avance "marche"
         .gren.fra2.but1 configure -text $caption(stop)
         update
       }
    }
pack .gren.fra2.but1 \
   -in .gren.fra2 -side left  -anchor w \
   -padx 5 -pady 3 -expand 0

#--- cree le bouton EXIT
button .gren.fra2.but2 \
   -text $caption(exit) -borderwidth 2 -bg $color(back) -font {courier 12 bold} \
   -command {
      set sortie "yes"
      set avance "marche"
   }
pack .gren.fra2.but2 \
   -in .gren.fra2 -side left  -anchor w \
   -padx 5 -pady 3 -expand 0

