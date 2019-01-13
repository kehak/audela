# fichier lib pour driverTemma.pl
# script zview.pm
# date dernière modif : 09/06/03
# remi.petitdemange@calixo.net

### fonctions : ################################
# fenetre_zview		: fenetre zview
# afficheposcourante	: affiche le reticule de position RADEC en cours
# affiche_xy		: pour construction : affiche la position xy des clic de souris
# pos_sur_zview	: affiche le cercle des saisies RADEC (pour visu avant commande synchro/goto)
################################################


# todo :
# popup d'infos sur les objets affichés sur zview
# bouton de centrage et suivi sur le curseur de pos courante
# zone d'infos sur le type de pointage : direct ou retournement
# positionner la ligne d'horizon zview selon la latitude 20->70deg, prévoir usage en hemisphere sud
# usage hemisphere sud



# *************************************************************
# ++++++++++++++++++++++ FENETRE ZVIEW ++++++++++++++++++++++++
# *************************************************************

# ---------- fonction fenetre_zview
sub fenetre_zview{
if(!Exists($fenetre_zview)){
print "\nOuverture fenetre ZView ----\n";

# variables formatées utilisateur h:m:s ou d:m:s
#print "$TU_system\n";
#print "RADEC Zenith:\tRA $lst_hms Dec $entree_lat_dms\n";
#print "Position courante:\t$temmaRAhmsDECdms $posEWtelescope\n";
#print "Derniere sync:\t$ctrl_synchro_coords\n";
#print "Goto:\t\t$ctrl_goto_coords\n";


$fenetre_zview = $fenetre_driver->Toplevel(-background=>"black"); # Toplevel $fenetre_zview
$fenetre_zview->geometry("460x450+386+0");
$fenetre_zview->title("ZView");

$facteur_scale=1; # init zoom (scale) 1X

# cadre pour canvas :
$cadre_canvaszv=$fenetre_zview->Frame(	-relief=>'flat',
					-borderwidth=>0,
					-background=>'black'
					)->pack(-padx =>2,-pady =>2,-side=>"top", -fill=>'both', -expand=>1);

# cadre pour boutons :
$cadre_bouton =$fenetre_zview->Frame(	-relief=>'flat',
					-background=>'black',
					-height=>"20"
					)->pack(-padx =>2,-pady =>2,-side=>"bottom", -fill=>'both', -expand=>0);

# canvas avec methode Scrolled pour defilements en x et y
$canvas_zv=$cadre_canvaszv->Scrolled(	"Canvas",
					#-scrollregion=> ,
				 	-scrollbars=>"se",
					-xscrollincrement=>20,
					-yscrollincrement=>20,
				 	#-width=>440,
				 	#-height=>390,
				 	-background=>'black',
					-highlightthickness=>0,
				 	-takefocus=>0,
					-borderwidth=>0,
					)->pack(-side=>"top", -fill=>'both', -expand=>1);

# le canvas pour la carte
$canvaszv=$canvas_zv->Subwidget("canvas");

# config barre de defilements x du canvas
$xs_canvaszv=$canvas_zv->Subwidget("xscrollbar")->configure(-background=>'black',
							-highlightbackground=>'gray30',
							-highlightcolor=>'gray30',
							#-width=>10,
							-activebackground=>'gray30',# black
							-relief=>'groove',
							-activerelief=>'groove',
							-borderwidth=>0,
							-elementborderwidth=>1,
							-troughcolor=>'black',
							-jump=>1,
							);

# config barre de defilement y du canvas
$ys_canvaszv=$canvas_zv->Subwidget("yscrollbar")->configure(-background=>'black',
							-highlightbackground=>'gray30',
							-highlightcolor=>'gray30',
							#-width=>10,
							-activebackground=>'gray30',#black
							-relief=>'groove',
							-activerelief=>'groove',
							-borderwidth=>0,
							-elementborderwidth=>1,
							-troughcolor=>'black',
							-jump=>1,
							);


#### --- items ds le canvas : geometrie de la carte --- ###

# horizon : partie visible du ciel selon latitude -> todo : ajustable selon latitude
# ellipse zview circonf horizon : petitaxe=358 grandaxe=420, centre zenith 245,312
#$canvaszv->createOval(35,120,455,478,-outline=>'DeepSkyBlue4');#55,120,435,478

# todo : réglage sur latitude
# ligne d'horizon visible (latitude 48:03:00) : petitaxe=358 grandaxe=420, centre zenith 245,312
$canvaszv->createPolygon(
			 245,500,	# S
			 84,413,	# se
			 35,299,	# E
			 80,160,	# ne
			 245,100,	# N
			 412,160,	# nw
			 452,299,	# W
			 408,413,	# sw
			-width=>2,
			-smooth=>1,
			-splinesteps=>10,
			-outline=>'DeepSkyBlue4',
			-tags=>["carte","horizon"]
			);


##### meridiens virtuels de decallages limites ##################

# todo : ajuster les meridiens modifiés selon longueur de tube

# lignes de meridiens modifiés pour goto driver selon curpos et byte E/W
#$AH_meridien_modif
#$x_meridien_modif=int(246+(sin(0.26180*$AH_meridien_modif))); 	# $rayon centre xy : 246,215
#$y_meridien_modif=int(215+(cos(0.26180*$AH_meridien_modif)));	# $rayon centre xy : 246,215
#$canvaszv->createLine(246,215,$x_meridien_modif,$y_meridien_modif, -width=>'1', -fill=>'red');# meridien virtuel

# arc pour decallages meridiens +/-1H

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DeepSkyBlue4',
			-width=>'1',
			-start=>'270',
			-extent=>'15',
			-tags=>["carte","meridien1"]
			);#1h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DeepSkyBlue4',
			-width=>'1',
			-start=>'255',
			-extent=>'15',
			-tags=>["carte","meridien1"]
			);#0h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DeepSkyBlue4',
			-width=>'1',
			-start=>'75',
			-extent=>'15',
			-tags=>["carte","meridien1"]
			);#12h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DeepSkyBlue4',
			-width=>'1',
			-start=>'90',
			-extent=>'15',
			-tags=>["carte","meridien1"]
			);#11h

# textes d'infos decallage meridien
$canvaszv->createText(	160,530,
			-text=>'+1H',
			-font=>'Helvetica -12 normal',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","txtmeridien1"]
			);

$canvaszv->createText	(328,530,
			-text=>'-1H',
			-font=>'Helvetica -12 normal',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","txtmeridien1"]
			);

##### fin de decallages limites 1H #########################################


# arc pour decallages meridiens +/-2H

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DarkSeaGreen4',
			-width=>'1',
			-start=>'270',
			-extent=>'30',
			-tags=>["carte","meridien2"]
			);#1h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DarkSeaGreen4',
			-width=>'1',
			-start=>'240',
			-extent=>'30',
			-tags=>["carte","meridien2"]
			);#0h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DarkSeaGreen4',
			-width=>'1',
			-start=>'60',
			-extent=>'30',
			-tags=>["carte","meridien2"]
			);#12h

$canvaszv->createArc(	-55,-85,547,516,
			-style=>'pieslice',
			-outline=>'DarkSeaGreen4',
			-width=>'1',
			-start=>'90',
			-extent=>'30',
			-tags=>["carte","meridien2"]
			);#11h

# textes d'infos decallage meridien
$canvaszv->createText(	80,500,
			-text=>'+2H',
			-font=>'Helvetica -12 normal',
			-fill=>'DarkSeaGreen4',
			-tags=>["carte","txtmeridien2"]
			);

$canvaszv->createText(	408,500,
			-text=>'-2H',
			-font=>'Helvetica -12 normal',
			-fill=>'DarkSeaGreen4',
			-tags=>["carte","txtmeridien2"]
			);

##### fin de decallages limites 2H #########################################


# cercle DEC=80 : rayon=20, centre etoile polaire x=245 y=215
$canvaszv->createOval(225,195,266,236,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=60 : rayon=60, centre etoile polaire x=245 y=215
$canvaszv->createOval(185,155,306,276,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=40 : rayon=100, centre etoile polaire x=245 y=215
$canvaszv->createOval(145,115,346,316,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=20 : rayon=140, centre etoile polaire x=245 y=215
$canvaszv->createOval(105,75,386,356,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=0 EQUATEUR CELESTE : rayon=180, centre etoile polaire x=245 y=215
$canvaszv->createOval(65,35,426,396, -width=>2, -outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=-20 : rayon=220, centre etoile polaire x=245 y=215
$canvaszv->createOval(25,-5,466,436,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=-40 : rayon=260, centre etoile polaire x=245 y=215
$canvaszv->createOval(-15,-45,506,476,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);

# cercle DEC=-60 : rayon=280, centre etoile polaire x=245 y=215
$canvaszv->createOval(-55,-85,546,516,-outline=>'DarkSeaGreen4',-tags=>["carte","ligne_dec"]);


# ligne horizontale dir EW equatoriales
$canvaszv->createLine(0,215,500,215, -width=>'1', -fill=>'DarkSeaGreen4',-tags=>["carte","ligne_ew"]);

# ligne verticale meridien
$canvaszv->createLine(246,75,246,518, -width=>'1', -fill=>'DarkSeaGreen4',-tags=>["carte","meridien0"]);

# ligne horizon EW droite -> repere construc
#$canvaszv->createLine(48,298,443,298, -width=>'1', -fill=>'DeepSkyBlue4');

# courbe pour ligne de direction EW sur zview
$canvaszv->createLine(	66,215, # debut
			117,275, # gauche -130
			214,298, # centre point de gauche
			#247,298, # point central Zenith
			280,298, # centre point de droite
			377,275, # milieu droit +130
			426,215, # fin
			-smooth=>1,
			-splinesteps=>10,
			-width=>'1',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon"]
			);

# ligne verticale meridien local
$canvaszv->createLine(	246,110,246,480,
			-width=>'1',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon","meridien0"]);

# texte d'affichage directions N,S,E,W
$canvaszv->createText(	246,500,
			-text=>'S',
			-font=>'Helvetica -14 bold',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon","texte_dir"]
			);

$canvaszv->createText	(440,198,
			-text=>'W',
			-font=>'Helvetica -14 bold',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon","texte_dir"]
			);

$canvaszv->createText	(246,95,
			-text=>'N',
			-font=>'Helvetica -14 bold',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon","texte_dir"]
			);

$canvaszv->createText	(56,198,
			-text=>'E',
			-font=>'Helvetica -14 bold',
			-fill=>'DeepSkyBlue4',
			-tags=>["carte","horizon","texte_dir"]
			);

#### pixmap pour reticule de position courante (retour encodeurs) -> sur zview
$pixmap_data=<<'end-of-x11-pixmap-data';
/* XPM */
static char * unknown[] = {
"33 33 2 1",
"  s None c None",
". c #00ff00",
"                                 ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
" ............................... ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
" ............................... ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"              .   .              ",
"                                 "};
end-of-x11-pixmap-data

$icone_reticule=$canvaszv->Pixmap('icone_reticule', -data=>$pixmap_data);# pixmap interne au script
$poscourante=$canvaszv->createImage($x_curpos,$y_curpos,-image=>$icone_reticule, -tags=>["carte","curpostag"]);

#### fin de graphisme position courante

#### --- fin du canvas ---- ####



########## boutons de commandes diverses ###########

# init facteur de zoom : 1
$set_facteur_scale = 1;

$BEzoom = $cadre_bouton->BrowseEntry(
    	#-labelBorderwidth=>1,
	#-labelFont=>$fonte,
	#-font=>$fonte,
	#-labelForeground=>"grey",
	#-labelBackground=>"black",
	-highlightbackground=>"gray30",
	-label => "Zoom : ",
   	-variable => \$set_facteur_scale,
	-choices=>[qw/1 2 4/],
	-background=>"black",
	-foreground=>"DarkSeaGreen4",
	-relief=> "groove",
	-width=>5,
	-listwidth=>10,
	-browsecmd=>\&set_zoom
	);
$BEzoom->pack(-side=>'left',-padx =>4,-pady =>2);


# init $decal_lstmerid : 1 -> au lancement du script principal
$BE_decal_lstmerid = $cadre_bouton->BrowseEntry(
    	#-labelBorderwidth=>1,
	#-labelFont=>$fonte,
	#-font=>$fonte,
	#-labelForeground=>"grey",
	#-labelBackground=>"black",
	-highlightbackground=>"gray30",
	-label => "offset LST",
   	-variable => \$decal_lstmerid,
	-choices=>[qw/1 2/],
	-background=>"black",
	-foreground=>"DarkSeaGreen4", #"tomato3",
	-relief=> "groove",
	-width=>5,
	-listwidth=>10,
	-browsecmd=>\&set_decal_lstmerid
)->pack(-side=>'left',-padx =>4,-pady =>2);


# test : positionnement manuel de la ligne d'horizon vers sud (selon latitude)
$bouton_deplacehorizonS = $cadre_bouton->Button(
#	-state=>'disable',
	-text=>"H-",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-width=>"2",
	-height=>"1",
	-command=>sub{	print "deplace ligne d'horizon vers le sud\n";
			$canvaszv->move("horizon", 0, 10);}
)->pack(-side=>'left',-padx =>4,-pady =>2);

# test : positionnement manuel de la ligne d'horizon vers nord (selon latitude)
$bouton_deplacehorizonN = $cadre_bouton->Button(
#	-state=>'disable',
	-text=>"H+",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"DeepSkyBlue4",
	-width=>"2",
	-height=>"1",
	-command=>sub{	print "deplace ligne d'horizon vers le nord\n";
			$canvaszv->move("horizon", 0, -10);}
)->pack(-side=>'left',-padx =>4,-pady =>2);


#$bouton_deleteobjet = $cadre_bouton->Button(
#	-state=>'disable',
#	-text=>"Clear",
#	-font=>$fonte,
#	-foreground=>"black",
#	-background=>"DeepSkyBlue4",
#	-width=>"7",
#	-height=>"1",
#	-command=>sub{	$canvaszv->delete("objettag");}
#)->pack(-side=>'left',-padx =>4,-pady =>2);


# bouton de construc
#$bouton_update_posobjet = $cadre_bouton->Button(
#	-state=>'disable',
#	-text=>"Update",
#	-font=>$fonte,
#	-foreground=>"black",
#	-background=>"DeepSkyBlue4",
#	-width=>"7",
#	-height=>"1",
#	#-command=>\&deplace_listeob_zview,@liste_objets_place_surzv
#	#-command=>sub{	$canvaszv->delete("objettag");			# ok pour update pos manuellement
#	#		&listeobjetzview;
#	-command=>sub{$canvaszv->repeat(1000,\&update_posliste)} 	# update pos auto
#)->pack(-side=>'left',-padx =>4,-pady =>2);


$bouton_Fermer_zview=$cadre_bouton->Button(# bouton masquer la fenetre
	-takefocus=>1,
	-text=>"Masquer",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-height=>"1",
	-command => sub{$fenetre_zview->withdraw;
			print "Masquer fenetre ZView\n";}
	)->pack(-side=>'right',-padx =>4,-pady =>2,);
	} # fin de if Exists toplevel
	else	{
		print "Fenetre ZView deja ouverte\n";
		$fenetre_zview->deiconify();
		$fenetre_zview->raise();
		}



#### pixmap du reticule circulaire de previsu pos SYNC/GOTO -> sur zview
$pixmap_data_sync=<<'end-of-x11-pixmap-data'; # definition du pixmap reticule de sync (interne au script)
/* XPM */
static char * unknown[] = {
"33 33 2 1",
"  s None c None",
". c #00ff00",
"             .......             ",
"          ...       ...          ",
"        ..             ..        ",
"       .                 .       ",
"     ..                   ..     ",
"    .                       .    ",
"    .                       .    ",
"   .                         .   ",
"  .                           .  ",
"  .                           .  ",
" .                             . ",
" .                             . ",
" .                             . ",
".                               .",
".               .               .",
".               .               .",
".             .....             .",
".               .               .",
".               .               .",
".                               .",
" .                             . ",
" .                             . ",
" .                             . ",
"  .                           .  ",
"  .                           .  ",
"   .                         .   ",
"    .                       .    ",
"    .                       .    ",
"     ..                   ..     ",
"       .                 .       ",
"        ..             ..        ",
"          ...       ...          ",
"             .......             "};
end-of-x11-pixmap-data

# creation du pixmap de synchro
$icone_sync=$canvaszv->Pixmap('icone_sync', -data=>$pixmap_data_sync);
# placement pixmap (init hors champ)
#$pos_sync=$canvaszv->createImage(-100,-100,-image=>$icone_sync, -tags=>["carte","selectag"]);
$pos_sync=$canvaszv->createImage(-100,-100,-image=>$icone_sync, -tags=>["selectag"]);




#### pixmap circulaire bleu de visu objet pré-selectionnée dans les listes -> sur zview
$pixmap_data_presel=<<'end-of-x11-pixmap-data'; # definition du pixmap reticule de preselection (interne au script)
/* XPM */
static char * unknown[] = {
"33 33 2 1",
"  s None c None",
". c #0000ff",
"             .......             ",
"          ...       ...          ",
"        ..             ..        ",
"       .                 .       ",
"     ..                   ..     ",
"    .                       .    ",
"    .                       .    ",
"   .                         .   ",
"  .                           .  ",
"  .                           .  ",
" .                             . ",
" .                             . ",
" .                             . ",
".                               .",
".               .               .",
".               .               .",
".             .....             .",
".               .               .",
".               .               .",
".                               .",
" .                             . ",
" .                             . ",
" .                             . ",
"  .                           .  ",
"  .                           .  ",
"   .                         .   ",
"    .                       .    ",
"    .                       .    ",
"     ..                   ..     ",
"       .                 .       ",
"        ..             ..        ",
"          ...       ...          ",
"             .......             "};
end-of-x11-pixmap-data

# creation du pixmap de synchro
$icone_presel=$canvaszv->Pixmap('icone_presel', -data=>$pixmap_data_presel);
# placement pixmap (init hors champ)
#$pos_sync=$canvaszv->createImage(-100,-100,-image=>$icone_sync, -tags=>["carte","selectag"]);
$pos_presel=$canvaszv->createImage(-120,-120,-image=>$icone_presel, -tags=>["preseltag"]);





#### pixmap pour objets fixes selectionnés -> sur zview
$pixmap_data_objet=<<'end-of-x11-pixmap-data';
/* XPM */
static char * unknown[] = {
"15 15 2 1",
"  s None c None",
". c #ff0000",
"...............",
".             .",
".             .",
".             .",
".      .      .",
".      .      .",
".      .      .",
".  .........  .",
".      .      .",
".      .      .",
".      .      .",
".             .",
".             .",
".             .",
"..............."};
end-of-x11-pixmap-data

$icone_objet_fixe=$canvaszv->Pixmap('icone_objet', -data=>$pixmap_data_objet); 	# creation du pixmap d'objets fixes



#### pixmap pour objets non fixes type planètes -> sur zview
$pixmap_data_planete=<<'end-of-x11-pixmap-data';
/* XPM */
static char * unknown[] = {
"17 17 2 1",
"  s None c None",
". c #ffff00",
"      .....      ",
"    ..     ..    ",
"   .         .   ",
"  .           .  ",
" .             . ",
" .             . ",
".       .       .",
".       .       .",
".     .....     .",
".       .       .",
".       .       .",
" .             . ",
" .             . ",
"  .           .  ",
"   .         .   ",
"    ..     ..    ",
"      .....      "};
end-of-x11-pixmap-data

$icone_planete=$canvaszv->Pixmap('icone_planete', -data=>$pixmap_data_planete); # creation du pixmap planete


# centre la ligne dans la zone canvas à l'ouverture de la fenetre zview
#$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("horizon")]);
$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("horizon")]);

#$canvaszv->Tk::bind("<Button-1>", [ \&affiche_xy, Ev('x'), Ev('y') ]);

# maj affichage position courante timeout 1s
$canvaszv->repeat(1000,sub{afficheposcourante($canvaszv,$poscourante,$facteur_scale)});

#&set_zoom;
} # ------- fin de fenetre_zview --------------------------




####### fonction affiche_xy : retour console info construct  pos souris sur canvas
#sub affiche_xy {
#  my ($canv, $x, $y) = @_;
#  print "(x,y) = ", $canv->canvasx($x), ", ", $canv->canvasy($y), "\n";
#}
##################################################################################





# ---------- fonction afficheposcourante --------------------------------
sub afficheposcourante {
        my ($canvas2, $curpos_new,$facteur_scale_new) = @_;
	$canvas2 ->waitVariable((\$x_curpos) && (\$y_curpos));	# maj affichage pos en cours

	# applique facteur de zoom sur pos xy
	$x_curpos*=$facteur_scale_new;
	$y_curpos*=$facteur_scale_new;
	$canvas2 ->coords($curpos_new, $x_curpos,$y_curpos );	# pour pixmap de position courante
        #@listecoords=$canvaszv->coords(polairexy);		# pour controle $poscourante
	#print "listecoords : @listecoords\n";			# pour controle $poscourante

# maj position objet sync
if(defined($x_selecpos) && defined($y_selecpos)){&pos_sur_zview;}

$fenetre_zview->update;
} # ------- fin de afficheposcourante




# ---------- fonction pos_sur_zview ------------------ placement des objets selectionnés sur ZVIEW
sub pos_sur_zview{
# RADEC objets selec recup ou saisies : $RA_hms_objet,$DEC_dms_objet valeurs deci
# RA selec sur ZView (avec l'angle horaire)
$angleHselec=$lst_horaire-$RA_h_deci;#+0.5/60;
$angleHselec_modulo=($angleHselec/24-(int($angleHselec/24)))*24;

$posDECseleczview=(90-$DEC_d_deci)*(180/90);					# repere coords equatoriale
$x_selecpos=int(246+($posDECseleczview*(sin(0.26180*$angleHselec_modulo)))); 	# $rayon centre xy : 246,215
$y_selecpos=int(215+($posDECseleczview*(cos(0.26180*$angleHselec_modulo))));	# $rayon centre xy : 246,215

# applique facteur de zoom sur pos xy
$x_selecpos*=$facteur_scale;
$y_selecpos*=$facteur_scale;

# deplacement sideral de l'objet pointé
$canvaszv->coords("selectag", $x_selecpos,$y_selecpos);# ajouter ici preseltag (cercle bleu)

#$fenetre_zview->update;
} # ------- fin de pos_sur_zview ---------------------




# ---------- fonction set_decal_lstmerid -------------
sub set_decal_lstmerid{
if($decal_lstmerid==1)
	{
	$canvaszv->itemconfigure("meridien1",-outline=>'DeepSkyBlue4');
	$canvaszv->itemconfigure("meridien2",-outline=>'DarkSeaGreen4');
	$canvaszv->itemconfigure("txtmeridien1",-fill=>'DeepSkyBlue4');
	$canvaszv->itemconfigure("txtmeridien2",-fill=>'DarkSeaGreen4');
	}

elsif($decal_lstmerid==2)
	{
	$canvaszv->itemconfigure("meridien1",-outline=>'DarkSeaGreen4');
	$canvaszv->itemconfigure("meridien2",-outline=>'DeepSkyBlue4');
	$canvaszv->itemconfigure("txtmeridien1",-fill=>'DarkSeaGreen4');
	$canvaszv->itemconfigure("txtmeridien2",-fill=>'DeepSkyBlue4');
	}
print "Decallage méridien utilisable : $decal_lstmerid\n";

} # ------- fin de set_decal_lstmerid -----------------




# ---------- fonction set_zoom -----------------------
sub set_zoom{

if(($facteur_scale==1)&&($set_facteur_scale==2))
	{
	$facteur_scale=2; # set zoom 1x->2x
	$canvaszv->scale("carte",0,0,2,2);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("curpostag")],-confine=>1);#  carte
	print "ZView : set zoom 2x\n";
	}
elsif(($facteur_scale==2)&&($set_facteur_scale==1))
	{
	$facteur_scale=1; # reset zoom 2x->1x
	$canvaszv->scale("carte",0,0,.5,.5);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("horizon")],-confine=>1);
	print "ZView : reset zoom 1x\n";
	}
elsif(($facteur_scale==4)&&($set_facteur_scale==1))
	{
	$facteur_scale=1; # reset zoom 4x->1x
	$canvaszv->scale("carte",0,0,.25,.25);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("horizon")],-confine=>1);
	print "ZView : reset zoom 1x\n";
	}
elsif(($facteur_scale==4)&&($set_facteur_scale==2))
	{
	$facteur_scale=2; # reset zoom 4x->2x
	$canvaszv->scale("carte",0,0,.5,.5);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("curpostag")],-confine=>1);#curpostag
	print "ZView : reset zoom 2x\n";
	}
elsif(($facteur_scale==1)&&($set_facteur_scale==4))
	{
	$facteur_scale=4; # set zoom 1x->4x
	$canvaszv->scale("carte",0,0,4,4);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("curpostag")],-confine=>1);#curpostag
	print "ZView : reset zoom 4x\n";
	}
elsif(($facteur_scale==2)&&($set_facteur_scale==4))
	{
	$facteur_scale=4; # set zoom 2x->4x
	$canvaszv->scale("carte",0,0,2,2);
	$canvaszv->configure(-scrollregion=>[$canvaszv->bbox("curpostag")],-confine=>1);#curpostag
	print "ZView : set zoom 4x\n";
	}
} # ------- fin de set_zoom --------------------------


1;
