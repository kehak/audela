# fichier lib pour driverTemma.pl
# script polarisfinder.pm
# date dernière modif : 15/05/03
# remi.petitdemange@calixo.net


# todo : usage en hemisphere sud avec pos sigma octan

# *************************************************************
# ++++++++++++++++++ FENETRE POLARISFINDER ++++++++++++++++++++
# *************************************************************

# ---------- fonction polarisfinder ajout au 26/12/02
sub polarisfinder{
#use Tk::Pixmap;
#if(!Exists($fenetre_polaire)){


print "\nOuverture fenetre PolarisFinder ----\n";
#print "pos polaire -> xpol: $x_polaire ypol: $y_polaire AHpol: $angle_hms_polaire\n"; visu de travail
print "Angle horaire Polaire : $angle_hms_polaire\t$TU_system\n";
$fenetre_polaire = $fenetre_driver->Toplevel(	-width=>640,
						-height=>500,
						-background=>"black"
						); # Toplevel $fenetre_polaire

$fenetre_polaire->title("PolarisFinder");

$canvas=$fenetre_polaire->Canvas(-width=>640,
				 -height=>500,
				 -background=>'black',
				 -takefocus=>0,
				 -borderwidth=>1,
				 -highlightbackground=>'gray70'
				)->place(-x=>0, -y=>0);

# repères horaires : affichages d'arcs d'incréments 15 degrés sur cercle rayon=220->1985
for ($rh=0; $rh<=345; $rh+=15){
$canvas->createArc(65,25,505,465,-style=>'pieslice', -outline=>'red', -width=>'1',-start=>$rh, -extent=>'15');}

# repères 20 minutes : affichages d'arcs d'incréments 5 degrés sur cercle rayon=202->2000
for ($r20m=5; $r20m<=350; $r20m+=15){
$canvas->createArc(83,43,487,447,-style=>'pieslice', -outline=>'red', -width=>'1',-start=>$r20m, -extent=>'5');}

# grand masque noir circulaire pour ajuster la longueur des graduations
$canvas->createOval(91,51,479,439,-fill=>'black');

# textes des heures 0, 6, 12, 18 sur réticule
$canvas->createText(286,477, -text=>'0',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(517,245, -text=>'6',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(286,14, -text=>'12',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(51,245, -text=>'18',-font=>$fonte_grande,-fill=>'red');

# textes d'affichage heyres 3, 9, 15, 21 sur réticule
$canvas->createText(448,407, -text=>'3',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(450,84, -text=>'9',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(118,84, -text=>'15',-font=>$fonte_grande,-fill=>'red');
$canvas->createText(120,407, -text=>'21',-font=>$fonte_grande,-fill=>'red');

# reticule: cercles de position polaire de rayon=220->cercle 1985 (65,25,505,465)
$canvas->createOval(83,43,487,447,-outline=>'red');	# rayon=202->cercle 2000
$canvas->createOval(101,61,469,429,-outline=>'red');	# rayon=184->cercle 2015
# $canvas->createOval(119,79,451,411,-outline=>'red');	# rayon=166->cercle 2030 pour info

#### resultat : graphic de position polaire -> polaire.xpm sur réticule selon $rayon
$pixmap_data=<<'end-of-x11-pixmap-data'; # graphic polaire
/* XPM */
static char * unknown[] = {
"15 15 2 1",
"  s None c None",
". c #ffff00",
"       .       ",
"       .       ",
"     . . .     ",
"   .   .   .   ",
"       .       ",
"  .   ...   .  ",
"     .. ..     ",
"......   ......",
"     .. ..     ",
"  .   ...   .  ",
"       .       ",
"   .   .   .   ",
"     . . .     ",
"       .       ",
"       .       "};
end-of-x11-pixmap-data

#$polaris_xpm="polaire.xpm";# si fichier icone externe
#$icone_polaire=$canvas->Pixmap(-file=>$polaris_xpm);#('icone_polaire', -file=>$polaris_xpm);

$icone_polaire=$canvas->Pixmap('icone_polaire', -data=>$pixmap_data);# si pixmap interne au script
$pos_polaire=$canvas->createImage($x_polaire,$y_polaire,-image=>$icone_polaire);
#### fin de graphisme etoile polaire


# reticule : croisillon
$canvas->createLine(286,22,286,468,-fill=>'red');	# trait vertical
$canvas->createLine(63,245,508,245,-fill=>'red');	# trait horizontal

# masque d'ajourage central du croisillon : petit cercle noir central
$canvas->createOval(280,240,292,252,-fill=>'black');

# s/titres d'infos interface
$canvas->createText(550,15,-anchor=>'e',-text=>'Angle horaire Polaire :',-font=>$fonte,-fill=>'DarkSeaGreen4');
#$canvas->createText(512,35, -text=>'T.S.L. :',-font=>$fonte,-fill=>'red');
#$canvas->createText(494,35, -text=>'A.D. polaire :',-font=>$fonte,-fill=>'red');
$canvas->createText(550,35, -anchor=>'e',-text=>'Longitude :',-font=>$fonte,-fill=>'DarkSeaGreen4');
$canvas->createText(550,55, -anchor=>'e',-text=>'Site :',-font=>$fonte,-fill=>'DarkSeaGreen4');
$canvas->createText(15,15, -anchor=>'w',-text=>'Réticule de viseur polaire',-font=>$fonte,-fill=>'DarkSeaGreen4');
$canvas->createText(15,35, -anchor=>'w',-text=>'EM-10, NJP, EM-500',-font=>$fonte,-fill=>'DarkSeaGreen4');
$canvas->createText(15,480, -anchor=>'w',-text=>'Réticule à niveau',-font=>$fonte,-fill=>'DarkSeaGreen4');

$val_anglepol=$canvas->Label(			# résultat txt : angle horaire polaire
	-textvariable=>\$angle_hms_polaire,
	-font=>$fonte,
	-foreground=>'yellow',
	-background=>'black');
$idval_anglepol=$canvas->createWindow(565,15, -anchor=>'w', -window=>$val_anglepol);

$val_longi=$canvas->Label(			# sortie txt longitude
	-textvariable=>\$sortie_longi_dms,
	-font=>$fonte,
	-foreground=>'DarkSeaGreen4',
	-background=>'black');
$idval_longi=$canvas->createWindow(565,35, -anchor=>'w', -window=>$val_longi);

$val_nomsite=$canvas->Label(			# sortie txt nom du site
	-textvariable=>\$sortie_nomsite,
	-font=>$fonte,
	-foreground=>'DarkSeaGreen4',
	-background=>'black');
$idval_nomsite=$canvas->createWindow(565,55, -anchor=>'w', -window=>$val_nomsite);

$val_TUSYS=$canvas->Label(			# sortie txt TU
	-textvariable=>\$TU_system,
	-font=>$fonte,
	-foreground=>'DarkSeaGreen4',
	-background=>'black');
$idval_TUSYS=$canvas->createWindow(550,75, -window=>$val_TUSYS);

$val_TSL=$canvas->Label(			# sortie txt TSL
	-textvariable=>\$lst_hms,
	-font=>$fonte,
	-foreground=>'DarkSeaGreen4',
	-background=>'black');
$idval_TSL=$canvas->createWindow(580,95, -window=>$val_TSL);

### todo : sortie fichier postscript polaire.ps
# $postscript=$canvas->postscript();
# $canvas->postscript(-file=>"polaire.ps");

$canvas->repeat(5000,sub{positionpolaire($canvas,$pos_polaire)});# maj affichage polaire timeout 5s

$bouton_Fermer_polaris=$fenetre_polaire->Button(# bouton fermer la fenetre
	-takefocus=>1,
	-text=>"Fermer",
	-font=>$fonte,
	-foreground=>"black",
	-background=>"SlateGray4",
	-width=>"7",
	-command => sub{$fenetre_polaire->destroy(); #if (Exists($fenetre_polaire));
			print "Fermeture fenetre PolarisFinder\n";}
)->place(-x=>550, -y=>460, -height=>20);
#} # fin de if Exists toplevel
#else	{
#	print "Fenetre PolarisFinder deja ouverte\n";
#	print "Angle horaire Polaire : $angle_hms_polaire\n";
#	$fenetre_polaire->deiconify();
#	$fenetre_polaire->raise();
#	}


######## retour console : position souris ds l'interface Tk ##########
#$canvas->Tk::bind("<Button-1>", [ \&affiche_xy, Ev('x'), Ev('y') ]);
#sub affiche_xy {
#  my ($canv, $x, $y) = @_;
#  print "(x,y) = ", $canv->canvasx($x), ", ", $canv->canvasy($y), "\n";
#}
######################################################################

} # ------- fin de polarisfinder



# ---------- fonction positionpolaire --------------------------------
sub positionpolaire {
	#print "update pos polaire -> xpol: $x_polaire ypol: $y_polaire AHpol: $angle_hms_polaire\n";# visu de travail
	#print "Angle horaire Polaire : $angle_hms_polaire\n";	# pour controle
        my ($canvas2, $pos_polaire_new) = @_;
	$canvas2 ->waitVariable((\$x_polaire) && (\$y_polaire));# maj affichage polaire $x_polaire ou $y_polaire
	$canvas2 ->coords($pos_polaire_new, $x_polaire,$y_polaire );# pour pixmap
	$fenetre_polaire->update;
        #@listecoords=$canvas->coords(polairexy);	# pour controle $pos_polaire
	#print "listecoords : @listecoords\n";		# pour controle $pos_polaire
} # ------- fin de positionpolaire

1;
