   proc ::eye::game_scenario { } {
      
      if {$::eye::widget(game,mes)==0 && $::eye::widget(game,con)==1 \
       && $::eye::widget(game,che)==1 && $::eye::widget(game,gps)==1 } {
          
         gren_info "Lecture du scenario : \n"
         gren_info "Je fais une mise en station sommaire\n"
         gren_info "J'ai l'EQMOD\n"
         gren_info "J ai un chercheur electronique\n"
         gren_info "J'ai un GPS à main\n"
         
         ::eye::game_scenario_1
      }

      if {$::eye::widget(game,mes)==0 && $::eye::widget(game,con)==0 \
       && $::eye::widget(game,che)==0 && $::eye::widget(game,gps)==1 } {
          
         gren_info "Lecture du scenario : \n"
         gren_info "Je fais une mise en station sommaire\n"
         gren_info "Je n'ai pas l'EQMOD\n"
         gren_info "Je n'ai pas de chercheur electronique\n"
         gren_info "J'ai un GPS à main\n"
         
         ::eye::game_scenario_2
      }

      if {$::eye::widget(game,mes)==0 && $::eye::widget(game,con)==1 \
       && $::eye::widget(game,che)==1 && $::eye::widget(game,gps)==0 } {
          
         gren_info "Lecture du scenario : \n"
         gren_info "Je fais une mise en station sommaire\n"
         gren_info "J'ai l'EQMOD\n"
         gren_info "J ai un chercheur electronique\n"
         gren_info "Je n'ai pas de GPS à main\n"
         
         ::eye::game_scenario_3
      }
      
      if {$::eye::widget(game,mes)==1 && $::eye::widget(game,con)==1 \
       && $::eye::widget(game,che)==1 && $::eye::widget(game,gps)==1 } {
          
         gren_info "Lecture du scenario : \n"
         gren_info "Je fais une mise en station precise\n"
         gren_info "J'ai l'EQMOD\n"
         gren_info "J ai un chercheur electronique\n"
         gren_info "J'ai un GPS à main\n"
         
         ::eye::game_scenario_4
      }
      
      
   }
   
   
   
   
   ## Mise en station sommaire
   ## EQMOD
   ## Chercheur electronique
   ## GPS a main
   proc ::eye::game_scenario_1 { } {
   
   

      set ::eye::game_con(1,title) "Etes Vous pret ?"
      set ::eye::game_con(1,request) go
      set ::eye::game_con(1,ok)      101

      set ::eye::game_con(2,title) "Echec Mission"
      set ::eye::game_con(2,request) fin

      set ::eye::game_con(3,title) "Fin de Mission - SUCCESS"
      set ::eye::game_con(3,request) fin

# Demarrage 

      set ::eye::game_con(101,title)   "Tout brancher ( avec raquette + Occulaire au foyer )"
      set ::eye::game_con(101,request) default
      set ::eye::game_con(101,ok)      102
      set ::eye::game_con(101,echec)   2

      set ::eye::game_con(102,title)   "Dans Audela - Configuration - Repertoires - Repertoire des images : verifier que vous etes dans le repertoire de travail" 
      set ::eye::game_con(102,request) default
      set ::eye::game_con(102,ok)      103
      set ::eye::game_con(102,echec)   2

      set ::eye::game_con(103,title)   "Dans Audela - Configuration - Position de l'observateur : entrer les infos" 
      set ::eye::game_con(103,request) default
      set ::eye::game_con(103,ok)      104
      set ::eye::game_con(103,echec)   111

      set ::eye::game_con(104,title)   "Dans Audela - Configuration - Temps : Verifier l'heure du PC"
      set ::eye::game_con(104,request) default
      set ::eye::game_con(104,ok)      105
      set ::eye::game_con(104,echec)   111

      set ::eye::game_con(105,title)   "Tourner la monture jusqu a voir le cercle de la polaire au plus bas, mettre la bague sur le 0"
      set ::eye::game_con(105,request) default
      set ::eye::game_con(105,ok)      106
      set ::eye::game_con(105,echec)   111

      set ::eye::game_con(106,title)   "Dans Audela - Telescope - Viseur polaire : choisir eq6"
      set ::eye::game_con(106,request) default
      set ::eye::game_con(106,ok)      107
      set ::eye::game_con(106,echec)   111

      set ::eye::game_con(107,title)   "Tourner la monture pour mettre la valeur de l angle horaire de la polaire grace la bague (inscription du bas, positif vers l ouest)"
      set ::eye::game_con(107,request) default
      set ::eye::game_con(107,ok)      108
      set ::eye::game_con(107,echec)   111

      set ::eye::game_con(108,title)   "Centrer l'etoile polaire avec le rond du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(108,request) default
      set ::eye::game_con(108,ok)      121
      set ::eye::game_con(108,echec)   111

# Echec orientation viseur polaire

      set ::eye::game_con(111,title)   "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(111,request) default
      set ::eye::game_con(111,ok)      121
      set ::eye::game_con(111,echec)   121

# Parking et position du reticule

      set ::eye::game_con(121,title)   "Mettre le telescope en position parking, et alimenter prise electrique et monture"
      set ::eye::game_con(121,request) default
      set ::eye::game_con(121,ok)      122
      set ::eye::game_con(121,echec)   2

      set ::eye::game_con(122,title)   "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile."
      set ::eye::game_con(122,request) default
      set ::eye::game_con(122,ok)      131
      set ::eye::game_con(122,echec)   2

      set ::eye::game_con(131,title)   "Centrer l etoile a l occulaire."
      set ::eye::game_con(131,request) default
      set ::eye::game_con(131,ok)      132
      set ::eye::game_con(131,echec)   2

      set ::eye::game_con(132,title)   "Enlever l occulaire et mettre la camera au foyer"
      set ::eye::game_con(132,request) default
      set ::eye::game_con(132,ok)      133
      set ::eye::game_con(132,echec)   2

      set ::eye::game_con(133,title)   "Switch video sur le foyer, Centrer l etoile dans l ecran avec la raquette"
      set ::eye::game_con(133,request) default
      set ::eye::game_con(133,ok)      136
      set ::eye::game_con(133,echec)   2

      set ::eye::game_con(136,title)   "Synchroniser Synscan"
      set ::eye::game_con(136,request) default
      set ::eye::game_con(136,ok)      137
      set ::eye::game_con(136,echec)   2

      set ::eye::game_con(137,title)   "Switch video sur le chercheur electronique, Audela : Selectionner le reticule sur l etoile"
      set ::eye::game_con(137,request) default
      set ::eye::game_con(137,ok)      141
      set ::eye::game_con(137,echec)   2

# Eqmod & Synchro

      set ::eye::game_con(141,title)   "Débrancher la raquette et y mettre l Eqmod (les moteurs sont toujours en route normalement)"
      set ::eye::game_con(141,request) default
      set ::eye::game_con(141,ok)      142
      set ::eye::game_con(141,echec)   2

      set ::eye::game_con(142,title)   "Audela : Charger l eqmod"
      set ::eye::game_con(142,request) default
      set ::eye::game_con(142,ok)      143
      set ::eye::game_con(142,echec)   2

      set ::eye::game_con(143,title)   "Audela - EYE - Coordonnees : Verifier que les moteurs sont en marche"
      set ::eye::game_con(143,request) default
      set ::eye::game_con(143,ok)      144
      set ::eye::game_con(143,echec)   2

      set ::eye::game_con(144,title)   "Audela - EYE - Coordonnees : Choisir l etoile d alignement"
      set ::eye::game_con(144,request) default
      set ::eye::game_con(144,ok)      145
      set ::eye::game_con(144,echec)   2

      set ::eye::game_con(145,title)   "Switch video sur le foyer, Verifier que l etoile est toujours au centre du foyer"
      set ::eye::game_con(145,request) default
      set ::eye::game_con(145,ok)      146
      set ::eye::game_con(145,echec)   2

      set ::eye::game_con(146,title)   "Audela - EYE - Coordonnees : Synchroniser la position de la monture sur l etoile d alignement."
      set ::eye::game_con(146,request) default
      set ::eye::game_con(146,ok)      147
      set ::eye::game_con(146,echec)   2

# Pointage Objet

      set ::eye::game_con(147,title)   "Affiner les foyers du primaire et du chercheur electronique"
      set ::eye::game_con(147,request) default
      set ::eye::game_con(147,ok)      148
      set ::eye::game_con(147,echec)   2

      set ::eye::game_con(148,title)   "Switch video sur le chercheur electronique, Audela - EYE - Coordonnees : Selectionner le prochain objet a observer, puis GOTO"
      set ::eye::game_con(148,request) default
      set ::eye::game_con(148,ok)      149
      set ::eye::game_con(148,echec)   2

      set ::eye::game_con(149,title)   "Audela - EYE - FOV : Astrometrie et calcul de la position de l objet voulu dans l image"
      set ::eye::game_con(149,request) default
      set ::eye::game_con(149,ok)      150
      set ::eye::game_con(149,echec)   2

      set ::eye::game_con(150,title)   "Switch video sur le foyer, l'objet est au centre, regler le temps de pose"
      set ::eye::game_con(150,request) default
      set ::eye::game_con(150,ok)      151
      set ::eye::game_con(150,echec)   2

      set ::eye::game_con(151,title)   "Dans Audela - ATOS - Entrer Nom de fichier et repertoire et Lancer l'acquisition"
      set ::eye::game_con(151,request) default
      set ::eye::game_con(151,ok)      152
      set ::eye::game_con(151,echec)   2

      set ::eye::game_con(152,title)   "Enteindre la VTI"
      set ::eye::game_con(152,request) default
      set ::eye::game_con(152,ok)      153
      set ::eye::game_con(152,echec)   2

      set ::eye::game_con(153,title)   "Boucher la camera du Foyer puis Dans Audela - ATOS - Nouveau Nom de fichier et Lancer l'acquisition d'un noir de 30 sec"
      set ::eye::game_con(153,request) default
      set ::eye::game_con(153,ok)      3
      set ::eye::game_con(153,echec)   2

   }



   ## Mise en station sommaire
   ## GPS a main
   proc ::eye::game_scenario_2 { } {

      set ::eye::game_con(1,title) "Etes Vous pret ?"
      set ::eye::game_con(1,request) go
      set ::eye::game_con(1,ok)      201

      set ::eye::game_con(2,title) "Echec Mission"
      set ::eye::game_con(2,request) fin

      set ::eye::game_con(3,title) "Fin de Mission - SUCCESS"
      set ::eye::game_con(3,request) fin

# Demarrage et mise en station du telescope

      set ::eye::game_con(201,title)   "Tout brancher (raquette + oculaire au foyer), mettre la monture en position parking"
      set ::eye::game_con(201,request) default
      set ::eye::game_con(201,ok)      202
      set ::eye::game_con(201,echec)   2

      set ::eye::game_con(202,title)   "Mettre en marche la monture, verifier que le cercle de la polaire est au plus bas, mettre la bague sur 6h"
      set ::eye::game_con(202,request) default
      set ::eye::game_con(202,ok)      203
      set ::eye::game_con(202,echec)   2

      set ::eye::game_con(203,title)   "Raquette : insérer les paramètres de date et de position GPS"
      set ::eye::game_con(203,request) default
      set ::eye::game_con(203,ok)      204
      set ::eye::game_con(203,echec)   2

      set ::eye::game_con(204,title)   "Tourner la monture pour mettre la valeur 24h - 'Polaris position in P.Scope' (donne par la raquette) en face du vernier"
      set ::eye::game_con(204,request) default
      set ::eye::game_con(204,ok)      205
      set ::eye::game_con(204,echec)   2

      set ::eye::game_con(205,title)   "Centrer l'etoile polaire dans le rond du viseur polaire en jouant sur les axes azimuth et hauteur"
      set ::eye::game_con(205,request) default
      set ::eye::game_con(205,ok)      206
      set ::eye::game_con(205,echec)   2

      set ::eye::game_con(206,title)   "Mettre le telescope en position d'initialisation (contrepoids vers le bas, tube vers le nord), serrer les freins"
      set ::eye::game_con(206,request) default
      set ::eye::game_con(206,ok)      207
      set ::eye::game_con(206,echec)   2

      set ::eye::game_con(207,title)   "Realiser l'alignement de la monture sur 2 ou 3 etoiles (au choix)"
      set ::eye::game_con(207,request) default
      set ::eye::game_con(207,ok)      208
      set ::eye::game_con(207,echec)   2

      set ::eye::game_con(208,title)   "Raquette : lire les valeurs Mel et Maz : si elles sont inferieures a 5' -> ok, sinon Echec"
      set ::eye::game_con(208,request) default
      set ::eye::game_con(208,ok)      231
      set ::eye::game_con(208,echec)   211

# Echec mise en station -> mise en station sans viseur polaire

      set ::eye::game_con(211,title)   "Raquette : SETUP > Alignment > Polar Align > Select a star : choisir une etoile puis ENTER"
      set ::eye::game_con(211,request) default
      set ::eye::game_con(211,ok)      212
      set ::eye::game_con(211,echec)   2

      set ::eye::game_con(212,title)   "Centrer l'etoile dans le champ de l'oculaire puis ENTER"
      set ::eye::game_con(212,request) default
      set ::eye::game_con(212,ok)      213
      set ::eye::game_con(212,echec)   2

      set ::eye::game_con(213,title)   "Raquette : noter les valeurs Mel et Maz puis ENTER -> la monture pointe une etoile de controle"
      set ::eye::game_con(213,request) default
      set ::eye::game_con(213,ok)      214
      set ::eye::game_con(213,echec)   2

      set ::eye::game_con(214,title)   "Utiliser les vis de reglage d'azimut et de hauteur pour centrer l'etoile de controle, puis ENTER"
      set ::eye::game_con(214,request) default
      set ::eye::game_con(214,ok)      215
      set ::eye::game_con(214,echec)   2

      set ::eye::game_con(215,title)   "Realiser a nouveau l'alignement de la monture sur 2 ou 3 etoiles (au choix) via le menu Alignment"
      set ::eye::game_con(215,request) default
      set ::eye::game_con(215,ok)      216
      set ::eye::game_con(215,echec)   2

      set ::eye::game_con(216,title)   "Raquette : lire les valeurs Mel et Maz : si elles sont inferieures a 5' -> ok, sinon Echec"
      set ::eye::game_con(216,request) default
      set ::eye::game_con(216,ok)      231
      set ::eye::game_con(216,echec)   221

# Iterations sur la mise en station sans viseur polaire

      set ::eye::game_con(221,title)   "Recommencer 2 ou 3 fois les etapes 211-216 pour atteindre la precision requise"
      set ::eye::game_con(221,request) default
      set ::eye::game_con(221,ok)      231
      set ::eye::game_con(221,echec)   2

# Mise en place camera et mise au point du foyer

      set ::eye::game_con(231,title)   "Enlever l'occulaire et mettre la camera au foyer"
      set ::eye::game_con(231,request) default
      set ::eye::game_con(231,ok)      232
      set ::eye::game_con(231,echec)   2

      set ::eye::game_con(232,title)   "Demarrer Audela - ATOS, connecter la camera et lancer une acquisition sans sauvegarde"
      set ::eye::game_con(232,request) default
      set ::eye::game_con(232,ok)      233
      set ::eye::game_con(232,echec)   2

      set ::eye::game_con(233,title)   "Affiner la mise au point de l'image"
      set ::eye::game_con(233,request) default
      set ::eye::game_con(233,ok)      234
      set ::eye::game_con(233,echec)   234

      set ::eye::game_con(234,title)   "Centrer l'etoile dans l'image avec la raquette"
      set ::eye::game_con(234,request) default
      set ::eye::game_con(234,ok)      235
      set ::eye::game_con(234,echec)   2

      set ::eye::game_con(235,title)   "TODO - Raquette : synchroniser Synscan"
      set ::eye::game_con(235,request) default
      set ::eye::game_con(235,ok)      241
      set ::eye::game_con(235,echec)   2

# GOTO objet

      set ::eye::game_con(241,title)   "TODO - l'objet est au centre, regler le temps de pose"
      set ::eye::game_con(241,request) default
      set ::eye::game_con(241,ok)      242
      set ::eye::game_con(241,echec)   2

      set ::eye::game_con(242,title)   "TODO - Dans Audela - ATOS - Entrer Nom de fichier et repertoire et Lancer l'acquisition"
      set ::eye::game_con(242,request) default
      set ::eye::game_con(242,ok)      243
      set ::eye::game_con(242,echec)   2

      set ::eye::game_con(243,title)   "TODO - Enteindre la VTI"
      set ::eye::game_con(243,request) default
      set ::eye::game_con(243,ok)      244
      set ::eye::game_con(243,echec)   2

      set ::eye::game_con(244,title)   "TODO - Boucher la camera du Foyer puis Dans Audela - ATOS - Nouveau Nom de fichier et Lancer l'acquisition d'un noir de 30 sec"
      set ::eye::game_con(244,request) default
      set ::eye::game_con(244,ok)      3
      set ::eye::game_con(244,echec)   2

   }



   ## Mise en station sommaire
   ## GPS a main
   proc ::eye::game_scenario_2bis { } {

      set ::eye::game_con(1,title) "Etes Vous pret ?"
      set ::eye::game_con(1,request) go
      set ::eye::game_con(1,ok)      201

      set ::eye::game_con(2,title) "Echec Mission"
      set ::eye::game_con(2,request) fin

      set ::eye::game_con(3,title) "Fin de Mission - SUCCESS"
      set ::eye::game_con(3,request) fin

# Demarrage 

      set ::eye::game_con(201,title)   "Tout brancher ( avec raquette + Occulaire au foyer )"
      set ::eye::game_con(201,request) default
      set ::eye::game_con(201,ok)      202
      set ::eye::game_con(201,echec)   2

      set ::eye::game_con(202,title)   "Dans Audela - Configuration - Repertoires - Repertoire des images : verifier que vous etes dans le repertoire de travail" 
      set ::eye::game_con(202,request) default
      set ::eye::game_con(202,ok)      203
      set ::eye::game_con(202,echec)   2

      set ::eye::game_con(203,title)   "Dans Audela - Configuration - Position de l'observateur : entrer les infos" 
      set ::eye::game_con(203,request) default
      set ::eye::game_con(203,ok)      204
      set ::eye::game_con(203,echec)   211

      set ::eye::game_con(204,title)   "Dans Audela - Configuration - Temps : Verifier l'heure du PC"
      set ::eye::game_con(204,request) default
      set ::eye::game_con(204,ok)      205
      set ::eye::game_con(204,echec)   211

      set ::eye::game_con(205,title)   "Tourner la monture jusqu a voir le cercle de la polaire au plus bas, mettre la bague sur le 0"
      set ::eye::game_con(205,request) default
      set ::eye::game_con(205,ok)      206
      set ::eye::game_con(205,echec)   211

      set ::eye::game_con(206,title)   "Dans Audela - Telescope - Viseur polaire : choisir eq6"
      set ::eye::game_con(206,request) default
      set ::eye::game_con(206,ok)      207
      set ::eye::game_con(206,echec)   211

      set ::eye::game_con(207,title)   "Tourner la monture pour mettre la valeur de l angle horaire de la polaire grace la bague (inscription du bas, positif vers l ouest)"
      set ::eye::game_con(207,request) default
      set ::eye::game_con(207,ok)      208
      set ::eye::game_con(207,echec)   211

      set ::eye::game_con(208,title)   "Centrer l'etoile polaire avec le rond du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(208,request) default
      set ::eye::game_con(208,ok)      221
      set ::eye::game_con(208,echec)   211

# Echec orientation viseur polaire

      set ::eye::game_con(211,title)   "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(211,request) default
      set ::eye::game_con(211,ok)      221
      set ::eye::game_con(211,echec)   221

# Parking et position du reticule

      set ::eye::game_con(221,title)   "Mettre le telescope en position parking, et alimenter prise electrique et monture"
      set ::eye::game_con(221,request) default
      set ::eye::game_con(221,ok)      222
      set ::eye::game_con(221,echec)   2

      set ::eye::game_con(222,title)   "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile."
      set ::eye::game_con(222,request) default
      set ::eye::game_con(222,ok)      231
      set ::eye::game_con(222,echec)   2

      set ::eye::game_con(231,title)   "Centrer l etoile a l occulaire."
      set ::eye::game_con(231,request) default
      set ::eye::game_con(231,ok)      232
      set ::eye::game_con(231,echec)   2

      set ::eye::game_con(232,title)   "Enlever l occulaire et mettre la camera au foyer"
      set ::eye::game_con(232,request) default
      set ::eye::game_con(232,ok)      233
      set ::eye::game_con(232,echec)   2

      set ::eye::game_con(233,title)   "Switch video sur le foyer, Centrer l etoile dans l ecran avec la raquette"
      set ::eye::game_con(233,request) default
      set ::eye::game_con(233,ok)      236
      set ::eye::game_con(233,echec)   2

      set ::eye::game_con(236,title)   "Synchroniser Synscan"
      set ::eye::game_con(236,request) default
      set ::eye::game_con(236,ok)      247
      set ::eye::game_con(236,echec)   2

      set ::eye::game_con(247,title)   "Affiner les foyers du primaire et du chercheur electronique"
      set ::eye::game_con(247,request) default
      set ::eye::game_con(247,ok)      250
      set ::eye::game_con(247,echec)   2

# trouver l objet ... TODO

      set ::eye::game_con(250,title)   "Switch video sur le foyer, l'objet est au centre, regler le temps de pose"
      set ::eye::game_con(250,request) default
      set ::eye::game_con(250,ok)      251
      set ::eye::game_con(250,echec)   2

      set ::eye::game_con(251,title)   "Dans Audela - ATOS - Entrer Nom de fichier et repertoire et Lancer l'acquisition"
      set ::eye::game_con(251,request) default
      set ::eye::game_con(251,ok)      252
      set ::eye::game_con(251,echec)   2

      set ::eye::game_con(252,title)   "Enteindre la VTI"
      set ::eye::game_con(252,request) default
      set ::eye::game_con(252,ok)      253
      set ::eye::game_con(252,echec)   2

      set ::eye::game_con(253,title)   "Boucher la camera du Foyer puis Dans Audela - ATOS - Nouveau Nom de fichier et Lancer l'acquisition d'un noir de 30 sec"
      set ::eye::game_con(253,request) default
      set ::eye::game_con(253,ok)      3
      set ::eye::game_con(253,echec)   2

   }


   ## Mise en station sommaire
   ## EQMOD
   ## Chercheur electronique
   proc ::eye::game_scenario_3 { } {

   }




   ## Mise en station precise
   ## EQMOD
   ## Chercheur electronique
   ## GPS a main
   proc ::eye::game_scenario_4 { } {

      set ::eye::game_con(1,title) "Etes Vous pret ?"
      set ::eye::game_con(1,request) go
      set ::eye::game_con(1,ok)      101

      set ::eye::game_con(2,title) "Echec Mission"
      set ::eye::game_con(2,request) fin

      set ::eye::game_con(3,title) "Fin de Mission - SUCCESS"
      set ::eye::game_con(3,request) fin

# Demarrage 

      set ::eye::game_con(101,title)   "Tout brancher ( avec raquette + Occulaire au foyer + alimentation)"
      set ::eye::game_con(101,request) default
      set ::eye::game_con(101,ok)      102
      set ::eye::game_con(101,echec)   2

      set ::eye::game_con(102,title)   "Dans Audela - Configuration - Repertoires - Repertoire des images : verifier que vous etes dans le repertoire de travail" 
      set ::eye::game_con(102,request) default
      set ::eye::game_con(102,ok)      103
      set ::eye::game_con(102,echec)   2

      set ::eye::game_con(103,title)   "Dans Audela - Configuration - Position de l'observateur : entrer les infos" 
      set ::eye::game_con(103,request) default
      set ::eye::game_con(103,ok)      104
      set ::eye::game_con(103,echec)   111

      set ::eye::game_con(104,title)   "Dans Audela - Configuration - Temps : Verifier l'heure du PC"
      set ::eye::game_con(104,request) default
      set ::eye::game_con(104,ok)      105
      set ::eye::game_con(104,echec)   111

      set ::eye::game_con(105,title)   "Tourner la monture jusqu a voir le cercle de la polaire au plus bas, mettre la bague sur le 0"
      set ::eye::game_con(105,request) default
      set ::eye::game_con(105,ok)      106
      set ::eye::game_con(105,echec)   111

      set ::eye::game_con(106,title)   "Dans Audela - Telescope - Viseur polaire : choisir eq6"
      set ::eye::game_con(106,request) default
      set ::eye::game_con(106,ok)      107
      set ::eye::game_con(106,echec)   111

      set ::eye::game_con(107,title)   "Tourner la monture pour mettre la valeur de l angle horaire de la polaire grace la bague (inscription du bas, positif vers l ouest)"
      set ::eye::game_con(107,request) default
      set ::eye::game_con(107,ok)      108
      set ::eye::game_con(107,echec)   111

      set ::eye::game_con(108,title)   "Centrer l'etoile polaire avec le rond du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(108,request) default
      set ::eye::game_con(108,ok)      121
      set ::eye::game_con(108,echec)   111

# Echec orientation viseur polaire

      set ::eye::game_con(111,title)   "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(111,request) default
      set ::eye::game_con(111,ok)      121
      set ::eye::game_con(111,echec)   121

# Parking et position du reticule

      set ::eye::game_con(121,title)   "Mettre le telescope en position parking."
      set ::eye::game_con(121,request) default
      set ::eye::game_con(121,ok)      122
      set ::eye::game_con(121,echec)   2

      set ::eye::game_con(122,title)   "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile."
      set ::eye::game_con(122,request) default
      set ::eye::game_con(122,ok)      131
      set ::eye::game_con(122,echec)   2

      set ::eye::game_con(131,title)   "Centrer l etoile a l occulaire."
      set ::eye::game_con(131,request) default
      set ::eye::game_con(131,ok)      132
      set ::eye::game_con(131,echec)   2

      set ::eye::game_con(132,title)   "Enlever l occulaire et mettre la camera au foyer"
      set ::eye::game_con(132,request) default
      set ::eye::game_con(132,ok)      133
      set ::eye::game_con(132,echec)   2

      set ::eye::game_con(133,title)   "Switch video sur le foyer, Centrer l etoile dans l ecran avec la raquette"
      set ::eye::game_con(133,request) default
      set ::eye::game_con(133,ok)      136
      set ::eye::game_con(133,echec)   2

      set ::eye::game_con(136,title)   "Synchroniser Synscan"
      set ::eye::game_con(136,request) default
      set ::eye::game_con(136,ok)      137
      set ::eye::game_con(136,echec)   2

      set ::eye::game_con(137,title)   "Switch video sur le chercheur electronique, Audela : Selectionner le reticule sur l etoile"
      set ::eye::game_con(137,request) default
      set ::eye::game_con(137,ok)      141
      set ::eye::game_con(137,echec)   2

# Eqmod & Mise en station Precise

      set ::eye::game_con(141,title)   "Débrancher la raquette et y mettre l Eqmod. Eteindre et rallumer la monture en position Parking"
      set ::eye::game_con(141,request) default
      set ::eye::game_con(141,ok)      142
      set ::eye::game_con(141,echec)   2

      set ::eye::game_con(142,title)   "Audela : Charger l eqmod"
      set ::eye::game_con(142,request) default
      set ::eye::game_con(142,ok)      143
      set ::eye::game_con(142,echec)   2

      set ::eye::game_con(143,title)   "Audela - EYE - FOV : Reconnaitre le champ de la polaire et faire l astrometrie"
      set ::eye::game_con(143,request) default
      set ::eye::game_con(143,ok)      144
      set ::eye::game_con(143,echec)   145

      set ::eye::game_con(144,title)   "Audela - EYE - FOV : Calcul du centrage mecanique. Centrer l etoile du rond vers le carré en jouant sur les axes de la monture"
      set ::eye::game_con(144,request) default
      set ::eye::game_con(144,ok)      148
      set ::eye::game_con(144,echec)   145
      
      # erreur 
      
      set ::eye::game_con(145,title)   "Eteindre et rallumer la monture en position Parking"
      set ::eye::game_con(145,request) default
      set ::eye::game_con(145,ok)      146
      set ::eye::game_con(145,echec)   2

      set ::eye::game_con(146,title)   "Audela - EYE - Coordonnees : Selectionner une etoile brillante proche de l'etoile occultée, puis GOTO"
      set ::eye::game_con(146,request) default
      set ::eye::game_con(146,ok)      147
      set ::eye::game_con(146,echec)   2

      set ::eye::game_con(147,title)   "Audela - EYE - Coordonnees : Centrer l etoile sur le reticule et synchroniser la monture"
      set ::eye::game_con(147,request) default
      set ::eye::game_con(147,ok)      148
      set ::eye::game_con(147,echec)   2

# Pointage Objet

      set ::eye::game_con(148,title)   "Audela - EYE - Coordonnees : Selectionner le prochain objet a observer, puis GOTO"
      set ::eye::game_con(148,request) default
      set ::eye::game_con(148,ok)      149
      set ::eye::game_con(148,echec)   2

      set ::eye::game_con(149,title)   "Audela - EYE - FOV : Astrometrie et calcul de la position de l objet voulu dans l image"
      set ::eye::game_con(149,request) default
      set ::eye::game_con(149,ok)      150
      set ::eye::game_con(149,echec)   2

      set ::eye::game_con(150,title)   "Switch video sur le foyer, l'objet est au centre, regler le temps de pose"
      set ::eye::game_con(150,request) default
      set ::eye::game_con(150,ok)      151
      set ::eye::game_con(150,echec)   2

      set ::eye::game_con(151,title)   "Dans Audela - ATOS - Entrer Nom de fichier et repertoire et Lancer l'acquisition"
      set ::eye::game_con(151,request) default
      set ::eye::game_con(151,ok)      152
      set ::eye::game_con(151,echec)   2

      set ::eye::game_con(152,title)   "Enteindre la VTI"
      set ::eye::game_con(152,request) default
      set ::eye::game_con(152,ok)      153
      set ::eye::game_con(152,echec)   2

      set ::eye::game_con(153,title)   "Boucher la camera du Foyer puis Dans Audela - ATOS - Nouveau Nom de fichier et Lancer l'acquisition d'un noir de 30 sec"
      set ::eye::game_con(153,request) default
      set ::eye::game_con(153,ok)      3
      set ::eye::game_con(153,echec)   2

   }






























## Obsolete ...


   proc ::eye::game_scenario_old { } {


      set ::eye::game_con(201,title)   "Tout brancher ( avec raquette + Camera au foyer )"
      set ::eye::game_con(201,cond)    { conf gps 0 } 
      set ::eye::game_con(201,request) default
      set ::eye::game_con(201,ok)      112
      set ::eye::game_con(201,echec)   ???

      set ::eye::game_con(202,title)   "Mettre le telescope en position parking, et alimenter les cameras"
      set ::eye::game_con(202,request) default
      set ::eye::game_con(202,ok)      113
      set ::eye::game_con(202,echec)   ???

      set ::eye::game_con(203,title)   "Dans Audela - ATOS - Lancer la visualisation continue"
      set ::eye::game_con(203,request) default
      set ::eye::game_con(203,ok)      114
      set ::eye::game_con(203,echec)   ???

      set ::eye::game_con(204,title)   "Switch video sur le foyer, et eteindre la VTI"
      set ::eye::game_con(204,request) default
      set ::eye::game_con(204,ok)      114
      set ::eye::game_con(204,echec)   ???

      set ::eye::game_con(205,title)   "Dans Audela - ATOS - Faire un Noir de 1 minute, et finaliser l image de noir"
      set ::eye::game_con(205,request) default
      set ::eye::game_con(205,ok)      121
      set ::eye::game_con(205,echec)   ???

      set ::eye::game_con(21,title)   "Switch video sur le chercheur electronique, Faire un Noir de 1 minute, et finaliser l image de noir"
      set ::eye::game_con(21,cond)    { conf che 1 }
      set ::eye::game_con(21,sinon)   ???
      set ::eye::game_con(21,request) default
      set ::eye::game_con(21,ok)      ???
      set ::eye::game_con(21,echec)   ???

      set ::eye::game_con(31,title)   "Switch video sur le foyer, Allumer la VTI et basculer sur l affichage de la position"
      set ::eye::game_con(31,request) default
      set ::eye::game_con(31,ok)      ???
      set ::eye::game_con(31,echec)   ???

      set ::eye::game_con(32,title)   "Dans Audela - Configuration - Position de l'observateur : entrer les infos"
      set ::eye::game_con(32,request) default
      set ::eye::game_con(32,ok)      ???
      set ::eye::game_con(32,echec)   ???

      set ::eye::game_con(33,title)   "Enlever la camera et mettre un occulaire au foyer"
      set ::eye::game_con(33,request) default
      set ::eye::game_con(33,ok)      ???
      set ::eye::game_con(33,echec)   ???

      set ::eye::game_con(51,title)   "Centrer l'etoile polaire avec la croix centrale du viseur polaire en jouant sur les axes azimuth hauteur"
      set ::eye::game_con(51,request) default
      set ::eye::game_con(51,ok)      ???
      set ::eye::game_con(51,echec)   ???

      set ::eye::game_con(61,title)   "Mettre le telescope en position parking, et alimenter prise electrique et monture"
      set ::eye::game_con(61,request) default
      set ::eye::game_con(61,ok)      ???
      set ::eye::game_con(61,echec)   ???

      set ::eye::game_con(62,title)   "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile."
      set ::eye::game_con(62,request) default
      set ::eye::game_con(62,ok)      ???
      set ::eye::game_con(62,echec)   ???



#####
      lappend ::eye::game_storyboard [list 1 "Etes Vous pret ?" go]

         if { $::eye::widget(game,gps) } {
            lappend ::eye::game_storyboard [list 101 "Tout brancher ( avec raquette + Occulaire au foyer )" default]
            lappend ::eye::game_storyboard [list 102 "Dans Audela - Configuration - Position de l'observateur : entrer les infos" default]
         } else {
            lappend ::eye::game_storyboard [list 111 "Tout brancher ( avec raquette + Camera au foyer )" default]
            lappend ::eye::game_storyboard [list 112 "Mettre le telescope en position parking, et alimenter les cameras" default]
            lappend ::eye::game_storyboard [list 113 "Dans Audela - ATOS - Lancer la visualisation continue" default]
            lappend ::eye::game_storyboard [list 114 "Switch video sur le foyer, et eteindre la VTI" default]
            lappend ::eye::game_storyboard [list 115 "Dans Audela - ATOS - Faire un Noir de 1 minute, et finaliser l image de noir" default]
            if { $::eye::widget(game,che) } {
               lappend ::eye::game_storyboard [list 121 "Switch video sur le chercheur electronique, Faire un Noir de 1 minute, et finaliser l image de noir" default]
            }
            lappend ::eye::game_storyboard [list 131 "Switch video sur le foyer, Allumer la VTI et basculer sur l affichage de la position" default]
            lappend ::eye::game_storyboard [list 132 "Dans Audela - Configuration - Position de l'observateur : entrer les infos" default]
            lappend ::eye::game_storyboard [list 133 "Enlever la camera et mettre un occulaire au foyer" default]
         }

         lappend ::eye::game_storyboard [list 141 "Dans Audela - Configuration - Temps : Verifier l'heure du PC" default]
         lappend ::eye::game_storyboard [list 142 "Tourner la monture jusqu a voir le cercle de la polaire au plus bas, mettre la bague sur le 0" default]
         lappend ::eye::game_storyboard [list 143 "Dans Audela - Telescope - Viseur polaire : choisir eq6" default]
         lappend ::eye::game_storyboard [list 144 "Tourner la monture pour mettre la valeur de l angle horaire de la polaire grace la bague (inscription du bas, positif vers l ouest)" default]
         lappend ::eye::game_storyboard [list 145 "Centrer l'etoile polaire avec le rond du viseur polaire en jouant sur les axes azimuth hauteur" default]

         lappend ::eye::game_storyboard [list 161 "Mettre le telescope en position parking, et alimenter prise electrique et monture" default]
         lappend ::eye::game_storyboard [list 162 "Avec la raquette, insérer les paramètres de date et de position, et demarrer l alignement 1 étoile." default]

#####

         if { $::eye::widget(game,con) } {
            # Pilotage avec Audela
            lappend ::eye::game_storyboard [list 171 "Centrer l etoile a l occulaire." default]
            lappend ::eye::game_storyboard [list 172 "Enlever l occulaire et mettre la camera au foyer" default]
            lappend ::eye::game_storyboard [list 173 "Switch video sur le foyer, Centrer l etoile dans l ecran avec la raquette" default]
            lappend ::eye::game_storyboard [list 174 "Synchroniser Synscan" default]
         } else {
            # Pilotage avec Raquette
            lappend ::eye::game_storyboard [list 171 "Stellarium pour choisir l etoile la plus proche de la zone d observation." default]
            lappend ::eye::game_storyboard [list 172 "Centrer l etoile a l occulaire." default]
            lappend ::eye::game_storyboard [list 173 "Synchroniser Synscan" default]
         }
         if { $::eye::widget(game,che) } {
            lappend ::eye::game_storyboard [list 176 "Switch video sur le chercheur electronique, Audela : Selectionner le reticule sur l etoile" default]
         }

         if { $::eye::widget(game,con) } {
            # Pilotage avec Audela
            lappend ::eye::game_storyboard [list 171 "Débrancher la raquette et y mettre l Eqmod (les moteurs sont toujours en route normalement)" default]
            lappend ::eye::game_storyboard [list 172 "Audela : Charger l eqmod" default]
            lappend ::eye::game_storyboard [list 173 "Audela - EYE - Coordonnees : Verifier que les moteurs sont en marche" default]
            lappend ::eye::game_storyboard [list 174 "Audela - EYE - Coordonnees : Choisir l etoile d alignement" default]
            lappend ::eye::game_storyboard [list 175 "Switch video sur le foyer, Verifier que l etoile est toujours au centre du foyer" default]
            lappend ::eye::game_storyboard [list 177 "Audela - EYE - Coordonnees : Synchroniser la position de la monture sur l etoile d alignement." default]
            if { $::eye::widget(game,bat) } {
               lappend ::eye::game_storyboard [list 178 "Affiner les foyers du primaire et du chercheur electronique a l aide du filtre de batinov ou equivalent" default]
            } else {
               lappend ::eye::game_storyboard [list 178 "Affiner les foyers du primaire et du chercheur electronique" default]
            }

            lappend ::eye::game_storyboard [list 179 "Switch video sur le chercheur electronique, Audela - EYE - Coordonnees : Selectionner le prochain objet a observer, puis GOTO" default]
            lappend ::eye::game_storyboard [list 181 "Audela - EYE - FOV : Astrometrie et calcul de la position de l objet voulu dans l image" default]
            lappend ::eye::game_storyboard [list 182 "Audela - EYE - Coordonnees : Deplacement final" default]
            lappend ::eye::game_storyboard [list 183 "Switch video sur le foyer, l'objet est au centre, regler le temps de pose" default]
         }

   }


