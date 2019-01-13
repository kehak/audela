##
# @file calaphot_doc.tcl
#
# @author Jacques Michelet (jacques.michelet@laposte.net)
#
# @brief Documentation générale de Calaphot
#
# $Id: calaphot_doc.tcl 13500 2016-03-27 09:43:49Z jacquesmichelet $
#
#


##
# @defgroup calaphot_documentation_fr Manuel d'utilisation de Calaphot
# @ingroup calaphot_notice_fr
# @section calaphot_generalites Generalites
# Calaphot est un script dédié à des calculs de <b> photométrie différentielle </b> effectués sur une série d'image, c'est-à-dire qu'il procède au calcul de la magnitude d'astres variables (astéroïdes, par exemple) par comparaison avec la magnitude d'astres de référence. Calaphot utilise abondamment l'interface graphique AudACE et la librairie de fonctions fournies par l'ensemble Audela.
#
# @subsection calaphot_generalite_conventions Conventions
# Pour la suite de cette documentation, et dans un but de simplification, on va appeler
# - @b astéroïde : un astre dont on veut calculer la magnitude. Dans les faits, il peut s'agir de tout astre suppose variable, que ce soit un veritable astéroïde ou une simple étoile.
# - @b étoile : un astre dont on va se servir comme référence pour calculer la magnitude de l'astéroïde. Il faut donc que cet astre ait une magnitude constante pour la periode de temps consideree.
# - @b astre : de façon générique, tout astéroïde ou étoile tels que précédemment spécifié.
# - @b super-étoile : un astre fictif obtenu en additionnant les flux de plusieurs étoiles, et par consequent dont la magnitude est plus faible que toutes les magnitudes des étoiles qui le compose. Ainsi le rapport signal/bruit de cette super-étoile est meilleur (plus grand) que celui des étoiles de référence prises isolément.
# - @b séquence : l'ensemble des images dont on veut extraire la magnitude d'un astéroïde. Les images de la séquence doivent obeir à quelques contraintes (cf @ref calaphot_limitations_logiciel_images )
# .
# @section calaphot_limitations_logiciel Limitations du logiciel
# @subsection calaphot_limitations_intrinsèques_logiciel Limitations intrinsèques
# - Calaphot ne sait effectuer que des calculs de photométrie différentielle, et ne sait donc pas traiter des problèmes de photométrie absolue autrement plus ardus.
# - Calaphot ne sait traiter qu'un seul astéroïde à la fois. Le fait de pouvoir en traiter plusieurs à la fois fera l'objet d'améliorations futures de ce script.
# - Pour les étoiles de référence, Calaphot ne sait pas extraire automatiquement les magnitudes depuis un catalogue, même si les images contiennent des informations astrométriques dans leur entête. Cette liaison avec un ou plusieurs catalogues fera l'objet d'une version future de ce script.
# @subsection calaphot_limitations_logiciel_images Limitations sur les images
# -# Les images doivent correspondre à un champ stellaire <b> avec un fort recouvrement d'une image à l'autre </b>, de façon à pouvoir être recalées en x,y automatiquement. Si ce n'est pas le cas (comme pour un astéroïde géocroiseur avec un déplacement très rapide sur le fond de ciel, par exemple), il faudra "tronçonner" la séquence en plusieurs sous-séquences dont le recouvrement inter-images soit meilleur. Par contre le recalage photométrique des différentes séquences ne sera pas effectué par le script, et sera donc à faire "à la main".
# -# Les images à traiter ont toutes la même taille c'est-à-dire les mêmes dimensions sur les 2 axes.
# -# Les images ont été <b> préalablement pré-traitées </b> : elles ont été nettoyées des artefacts dus à l'électronique de la caméra, à la température du capteur et au dispositif optique à l'aide d'images de calibration comme les offsets, thermiques (darks) et plats (flats).
# -# Les images doivent être numérotées par un champ numéral à la fin de leur nom de ficher (ex : kandrup_27.fit). Les nombres dans les champs numéraux doivent former une suite sans trous. Il n'est pas nécessaire que le suite commence avec le nombre 1. Et il n'est pas nécessaire que l'ordre de la suite corresponde à l'ordre temporel des images (cf @ref calaphot_saisie_parametres_tri_images "Tri des images par date croissante" )
# .
#
# @section calaphot_plan_mode_emploi Plan du mode d'emploi
# De facon logique, le plan reflète le deroulement normal du script
# - @ref calaphot_saisie_parametres
# - @ref calaphot_reperage_astres
# - @ref calaphot_calculs
# - @ref calaphot_exploitation_resultats
# .
#
# @section calaphot_saisie_parametres Saisie des parametres
# Dans cette partie, l'opérateur va saisir ou modifier des paramètres de configuration de la session de Calaphot.
# Dans le cas d'une première utilisation ou dans le cas d'un changement de version de Calaphot, un certain nombre de paramètres reçoivent une valeur par défaut.
# Dans les autres cas, les paramètres affichés ont la valeur qu'ils avaient reçus lors de la session précédente de Calaphot.
# L'écran de saisie se présente sous cette forme
# @image html calaphot_saisie_parametres.png Ecran de saisie des paramètres
# L'écran est divisé en 3 parties, les 2 premières étant générales pour le script et font l'objet du paragraphe @ref calaphot_saisie_parametres_generaux , la dernière dépendant du mode de calcul choisi (ouverture, modélisation ou via SExtractor) est décrite au paragraphe @ref calaphot_saisie_parametres_specifiques .
# @subsection calaphot_saisie_parametres_generaux Paramètres généraux
# - <b>Nom de l'objet</b> : l'utilisateur peut mettre là le nom de l'astéroïde dont il veut déterminer la courbe de photométrie. Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Nom de l'opérateur</b> : l'utilisateur peut indiquer le nom de l'auteur des travaux. Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Code UAI de l'observatoire</b> : permet de repérer l'endroit des prises de vue. Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Type du capteur</b> : il s'agit d'indiquer, s'il est connu, le type du capteur d'image. Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Type du télescope</b> : l'utilisateur peut indiquer le type de l'optique principale utilisée (télescope, lunette ou objectif photo). Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Diamètre du télescope</b> : il convient de préciser le diamètre en mètre de l'optique principale (lentille ou miroir). Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Focale du télescope</b> : on mentionne la distance focale de l'optique utilisée, incluant toutes les optiques secondaires (aplanisseur de champ, réducteur de focale, lentille de Barlow, etc...). Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Filtre optique</b> : l'utilisateur peut indiquer le ou les filtres utilisés durant la prise de vue (R, V, B ou I). Ne rien mettre en l'absence de filtre. Ce champ sera utilisé dans le @ref calaphot_exploitation_resultats_resume "résumé final" s'il est au format CDR.
# - <b>Nom générique des images</b> : il s'agit du nom des fichiers d'image, sans le chemin d'accès, ni le suffixe numéral, ni l'extension. Exemple : si les fichiers s'appellent @c /tmp/kandrup_18.fit, @c /tmp/kandrup_19.fit, ..., @c /tmp/kandrup_63.fit, on mettra @c kandrup_ dans ce champ.
# - <b>Indice de la première image</b> : en reprenant l'exemple précédent, on met @c 18 dans ce champ.
# - <b>Indice de la dernière image</b> : en reprenant l'exemple précédent, on met @c 63 dans ce champ.
# - <b>Demi-largeur de la fenêtre</b> : la valeur en pixels donnée dans ce champ va définir une fenêtre à l'intérieur de laquelle on va chercher le centroïde des astres. Une largeur faible va accélérer les calculs, mais si les images sont mal recalées, certains astres risquent d'être mal identifiés car situés en dehors de la fenêtre. A l'inverse, une trop grande fenêtre pourrait faire que 2 astres se trouvent dans la même fenêtre, et fausser les calculs. Par expérience, une valeur égale à 2 ou 3 fois le FWHM moyen des images suffit généralement.
# - <b>Rapport S/B limite</b> : il s'agit de la valeur du rapport signal sur bruit éliminatoire : si au moins un astre (astéroïde ou étoile de référence) a une mesure de rapport S/B en dessous de cette limite dans une image donnée, l'image sera invalidée, c'est-à-dire que que toutes les mesures faites sur cette image seront éliminées (voir @ref doc_tech_filtrage_sb ).
# - <b>Gain de la caméra</b> : il faut indiquer ici la valeur du gain inverse en électron/ADU de la caméra. Cette valeur sert pour certains @ref doc_tech_incert_mag_ouv "calculs d'incertitude".
# - <b>Bruit de lecture</b> : il faut indiquer ici la valeur du bruit de lecture en électron de la caméra. Cette valeur sert pour certains @ref doc_tech_incert_mag_ouv "calculs d'incertitude".
# - <b>Nom du fichier texte résultat</b> : nom du fichier (sans chemin d'accès) qui contiendra l'ensemble des @ref calaphot_exploitation_resultats_fichier_texte "résultats numériques des mesures".
# - <b>Nom du fichier Postscript résultat</b> : nom du fichier au format Postscript (sans chemin d'accès) qui contiendra le graphique de la @ref calaphot_exploitation_resultats_courbe_lumiere "courbe de lumière".
# - <b>@anchor calaphot_saisie_parametres_niveau_affichage Affichage des calculs</b> : les boutons définissent le niveau de verbiage des messages dans la console de l'interface Audela. Depuis "Erreur", mode le moins bavard à "Info", mode très bavard.
# - <b>Mode de calcul</b> : on indique là le mode de calcul de photométrie retenu pour la séquence. Le détail des calculs effectués pour chacun de ces modes est décrit dans la @ref calaphot_documentation_technique_fr. Le fait de sélectionner une des modes va changer l'aspect de la sous-fenêtre des @ref calaphot_saisie_parametres_specifiques .
# - <b>Type des images</b> : on indique là si les images ont été préalablement recalées ou pas, c'est à dire si les coordonnées en pixels des étoiles sont constantes ou pas dans toute la séquence.
#   - images recalées : le mentionner va accélérer les calculs. Sinon les images seront considérées comme non recalées, et un recalage inutile va être systématiquement fait.
#@note : Si les images sont en fait non recalées, alors qu'on a mentionné qu'elles l'étaient, le script va travailler sur les astres "aléatoires" et va vraisemblablement procéder au @ref age_du_capitaine .
#   - images non recalées : les images vont être alors recalées pour connaître le déplacement de toutes les étoiles, déplacement relatif à la 1ère image de la séquence. Une fois le vecteur translation connu, on en déduit les coordonnées des étoiles dans les images non recalées. <b><i>Tous les calculs de photométrie sont faits sur les images non-recalées.</i></b>
#@note Les algorithmes de recalage procèdent parfois à des filtrages passe-bas destinés à gommer certains effets visuels dus au changement d'échantillonage, ce qui peut nuire à la justesse des calculs de photométrie. Pour cette raison, <b><i>il est recommandé de travailler sur des séquences d'images non-recalées</i></b>.
#@note Pour accélérer les calculs, les résultats du recalage sont stockés, et sont donc ré-utilisés si l'utilisateur est amené à relancer le script sur la même séquence. Ainsi l'utilisateur n'est "pénalisé" qu'une seule fois.
# - <b>Date des images</b> : il faut indiquer à quoi correspond la date indiquée dans les entêtes FITS des images (début ou milieu de la pose). Le faible degré de normalisation des entêtes FITS est la cause de cette entrée.
# - <b>@anchor calaphot_saisie_parametres_tri_images Tri des images par date croissante</b> : il faut répondre @c 'oui' dans le cas où l'ordre de numérotation des images de la séquence ne correspond pas à l'ordre croissant de leur date d'acquisition. En effet, il est nécessaire que le traitement se fasse suivant l'ordre des dates, de façon à pouvoir calculer la position mouvante par essence de l'astéroïde par interpolation linéaire sur les dates précises des images. Il faut noter que le tri des images de la séquence est un processus qui peut paraître long.
# - <b>Durée de la pose</b> : il faut indiquer l'unité du temps de pose des images. Le faible degré de normalisation des entêtes FITS est la cause de cette entrée.
# - <b>@anchor calaphot_saisie_parametres_format_donnees Format des données</b> : on definit là le type des informations générées dans le @ref calaphot_exploitation_resultats_resume "résumé" à la fin du fichier @ref calaphot_exploitation_resultats "texte résultat".
# - <b>Reprise des objets déjà saisis</b> : en répondant @c 'oui', on saute l'étape de @ref calaphot_reperage_astres , sous réserve que les astres aient été saisis au moins une fois évidemment.
# @note Si la séquence d'image a changé, il faut impérativement répondre @c 'non' à ce champ, pour éviter que le script ne travaille sur des étoiles inexistantes et ne passe dans le mode @ref age_du_capitaine .
#
# @subsection calaphot_saisie_parametres_specifiques Paramètres dépendant du mode de calcul.
# -# <b> @anchor calaphot_saisie_parametres_specifiques_ouverture Mode photométrie par ouverture </b>
# @image html calaphot_param_ouverture.png Ecran de saisie des paramètres spécifiques au mode ouverture
#   - <b>Facteur de division des pixels</b> : pour augmenter la précision des calculs, les pixels sont divisés en sous-pixels (voir @ref doc_tech_mesure_flux_ouv_division_pixels "les explications techniques"). Il faut noter que le temps de calcul du flux d'une étoile va croître comme le carré de ce facteur.
#   - <b>Rayon de l'ovale intérieur (en fwhm)</b> : on définit une distance exprimée en fwhm qui va permettre de calculer le flux de l'astre dans une ellipse (voir @ref doc_tech_mesure_flux_ouv_disque_interne "la mesure du flux dans la fenêtre" ).
# @note : Cette valeur impacte directement la précision des calculs, et a fait l'objet de @ref calaphot_biblio1 "[1]" (chapitre 5.3) et d'une étude détaillée dans @ref calaphot_biblio2 "[2]".
#   - <b>Rayon interne de la couronne (en fwhm)</b> : on définit une distance exprimée en fwhm d'une couronne qui va permettre de calculer le niveau moyen du fond de ciel (voir @ref doc_tech_mesure_flux_ouv_couronne_externe "la mesure du flux dans la couronne" ).
#   - <b>Rayon externe de la couronne (en fwhm)</b> : on définit une distance exprimée en fwhm d'une couronne qui va permettre de calculer le niveau moyen du fond de ciel (voir @ref doc_tech_mesure_flux_ouv_couronne_externe "la mesure du flux dans la couronne" ).
#   .
# -# <b> @anchor calaphot_saisie_parametres_specifiques_modelisation Mode photométrie par modélisation </b> : il n'y a pas de paramètre spécifique pour ce mode de calcul.
# -# <b> @anchor calaphot_saisie_parametres_specifiques_sextractor Mode photométrie par SExtractor </b>
# @image html calaphot_param_sextractor.png Ecran de saisie des paramètres spécifiques au mode SExtractor
#   - <b>Niveau de saturation (en ADU)</b> : SExtractor a besoin de savoir quel est la plus grande valeur possible d'un niveau de gris. Pour une séquence d'images 16 bits issues d'une caméra d'une linéarité parfaite, ce niveau correspond à \f$ \displaystyle 2^{16} - 1 = 65535 \f$.
# .
#
# @subsection calaphot_fin_saisie_parametres Fin de la saisie des paramètres
# L appui sur @b Annuler va arrêter le script, alors que l'appui sur @b Continuer va permettre d'indiquer l'emplacement des astres. Dans les 2 cas, tous les paramètres sont sauvegardés dans un fichier et seront repris lors d'une utilisation ultérieure du script.
#
# @section calaphot_reperage_astres Repérage des astres.
# Le repérage des astres s'effectue en 3 étapes :
# - @ref calaphot_reperage_reference
# - @ref calaphot_reperage_asteroide
# - @ref calaphot_reperage_indesirable
# .
#
# @subsection calaphot_reperage_reference Repérage des étoiles de référence.
# Il s'agit d'indiquer l'emplacement et la magnitude des étoiles de référence. La première image de la séquence est chargée et affichée, et l'écran ci-dessous s'affiche. Le repérage va se faire sur cette image.
# @image html calaphot_etoiles_ref.png Fenêtre de repérage des étoiles de référence
# - <b> Ajout d'une étoile </b> : pour ajouter une étoile, il suffit de la sélectionner en dessinant un rectangle autour d'elle, et de cliquer sur le bouton <i> Ajout d'une étoile </i>. S'affiche alors une fenêtre demandant la magnitude de cette étoile, qu'il convient de compléter avant d'appuyer sur OK.
# @note pour la 1ère étoile, la magnitude proposée est toujours 13,5, puisque l'image n'a pas encore été calibrée. Les étoiles suivantes se voient proposer une magnitude plus conforme à la vraie valeur, puisque la 1ère étoile a pu permettre une calibration photométrique grossière.
# - <b> Retrait d'une étoile </b> : de la même façon qu'on a pu ajouter une étoile, on peut enlever une étoile de liste des références. On sélectionne l'étoile à ôter et on clique sur <i> Retrait d'une étoile </i>.
# - <b> Suite du script </b> : une fois toutes les étoiles de référence sélectionnées, on peut passer au @ref calaphot_reperage_asteroide en cliquant sur le bouton correspondant.
# - <b> Arrêt du script </b> : l'appui sur ce bouton va simplement arrêter le script.
#
# @subsection calaphot_reperage_asteroide Repérage de l'astéroïde.
# Il s'agit d'indiquer l'emplacement de l'astéroïde. Mais comme celui-ci se déplace sur le fond de ciel, l'utilisateur va devoir le repérer dans la première image de la séquence, puis dans la dernière.
# - <b> Première image de la séquence </b> : cet écran affiche @image html calaphot_aster1.png Fenêtre de repérage de l'astéroïde dans la première image.
#   - <b> Pos dans la première image </b> : comme pour les étoiles de référence, on sélectionne l'astéroïde et on appuie sur ce bouton.
#   - <b> Suite du script </b> : une fois l'astéroïde sélectionnée, l'appui sur ce bouton permet passer à la sélection sur la dernière image.
#   - <b> Arrêt du script </b> : l'appui sur ce bouton va simplement arrêter le script.
#   .
# - <b> Dernière image de la séquence </b> :
# @image html calaphot_aster2.png Fenêtre de repérage de l'astéroïde dans la dernière image.
#   - <b> Pos dans la dernière image </b> : comme précédemment, on sélectionne l'astéroïde et on appuie sur ce bouton.
#   - <b> Suite du script </b> : une fois l'astéroïde sélectionnée, l'appui sur ce bouton permet passer au @ref calaphot_reperage_indesirable
#   - <b> Retour </b> : on peut vouloir revenir sur la première image pour reprendre la sélection de l'astéroïde. Il suffit d'appuyer sur ce bouton, et les coordonnées déjà mémorisées de l'astéroide seront effacées.
#   - <b> Arrêt du script </b> : l'appui sur ce bouton va simplement arrêter le script.
#   .
# .
#
# @subsection calaphot_reperage_indesirable Repérage des astres indésirables.
# Certains astres peuvent s'avérer gênants car ils sont situés proches du trajet de l'astéroïde. L'écran suivant va permettre de les sélectionner afin qu'ils soient effacés de l'image au fur et à mesure de la progression du script dans la séquence.
# @image html calaphot_indesirables.png Fenêtre de repérage des étoiles à supprimer.
# - <b> Ajout d'une étoile </b> : pour ajouter une étoile indésirable, il suffit de la sélectionner en dessinant un rectangle autout d'elle, et de cliquer sur le bouton <i> Ajout d'une étoile </i>.
# - <b> Retrait d'une étoile </b> : de la même façon qu'on a pu ajouter une étoile, on peut enlever une étoile de liste des indésirables. On sélectionne l'étoile à oter et on clique sur <i> Retrait d'une étoile </i>.
# - <b> Suite du script </b> : une fois toutes les étoiles indésirables sélectionnées, on peut passer au @ref calaphot_calculs en cliquant sur ce bouton.
# - <b> Arrêt du script </b> : l'appui sur ce bouton va simplement arrêter le script.
# .
#
# @section calaphot_calculs Calculs automatiques de photométrie
# Durant cette phase du script, l'écran de l'utilisateur ressemble à ceci
# @image html calaphot_calculs.png Phase des calculs automatiques.
# - Les astres repérés par l'utilisateur sont entourés par des petits carrés sur chaque image. Cela permet à l'utilisateur de vérifier que les calculs s'effectuent sur les bons astres.
# - Un bouton Arrêt s'affiche. L'appui sur ce bouton permet d'interrompre immédiatement le script.
# - Un graphique de visualisation des premiers résultats photométriques va aussi s'afficher, ce graphique permet juste aux impatients de suivre la progression des calculs qui peuvent parfois durer plusieurs dizaines de minutes. Dans ce graphique, les valeurs de magnitude affichées pour chaque astre sont relatives, c'est-à-dire que les valeurs représentées sont les différences entre la magnitudes calculées pour une image et celles calculées sur la première image de la séquence.@n
# Les détails sur les calculs lancés pour la séquence d'image font l'objet de la @ref calaphot_documentation_technique_fr , et en particulier du paragraphe @ref  doc_tech_sequencement_operations
#
# @section calaphot_exploitation_resultats Résultats
# @subsection calaphot_exploitation_resultats_courbe_lumiere Courbe de lumière
# Une fois les calculs terminés, une fenêtre similaire à celle-ci s'affiche
# @image html calaphot_courbe_lumiere.png
# Cette fenêtre est automatiquement sauvegardée au format PostSCript sous le nom saisi par l'opérateur. De même que pour la phase des @ref calaphot_calculs , cette fenêtre contient des valeurs de magnitude relative.
# @subsection calaphot_exploitation_resultats_fichier_texte Fichier texte
# Le logiciel créé un fichier texte de résultats dont le nom a été saisi par l'opérateur. Ce fichier contient 3 parties :
#   -# <b>Récapitulation des saisies.</b> Les saisies faites dans les parties @ref calaphot_saisie_parametres et @ref calaphot_reperage_astres du script sont résumées sous une forme analogue à celle donnée en exemple ci-dessous.
# @verbatim
# Récapitulation des paramètres
# Nom de l'objet : kandrup
# Nom de l'opérateur : Tycho Brahé
# Code UAI de l'observatoire : 615
# Type du capteur : Kaf401E
# Type du telescope : Schmidt-Cassegrain
# Diamètre du télescope (m) : 0.203
# Focale du télescope (m) : 2.000
# Catalogue de référence : USNO A2,R
# Nom générique des images : z_
# Indice de la première image : 1
# Indice de la dernière image : 60
# Demi-largeur des fenêtres : 10
# Rapport S/B limite : 20
# Gain de la caméra (e-/pas codeur) : 3
# Bruit de lecture (e-) : 20
# Nom du fichier texte résultat : resultat.txt
# Nom du fichier PostScript résultat : resultat.ps
# Mode de calcul : Phot. d'ouverture
# Type des images : Recalées
# Date des images : Début de pose
# Durée de la pose en : Secondes
# Format des données : CDR
# Facteur de division des pixels : 4
# Rayon du cercle intérieur (en sigma) : 3
# Rayon du cercle central (en sigma) : 6
# Rayon du cercle extérieur (en sigma) : 9
#
# ------------Etoile de référence--------------
# ----------------------------
# Etoile n1: 148.00 182.50 13.50
# Etoile n2: 415.00 466.47 13.80
# ----------------------------
# ------------Asteroïde--------------
# Vitesse de l'astéroïde (pixel/jour)     0.32/   -0.32
# ----------------------------
#
# ------------Pas d'étoile à supprimer--------------
#
# Magnitude de la super-étoile 12.887
# @endverbatim
#   -# <b>Calculs de photométrie</b> : Suivent ensuite les résultats des calculs faits image par image. Le niveau des informations données dans cette partie dépend du paramètre @ref calaphot_saisie_parametres_niveau_affichage "affichage des calculs" rentré par l'utilisateur. En mode "Info" (mode par défaut), les informations sont analogues à celles qui suivent
# @verbatim
# No      JJ                  | Mag.    Err    Flux    S/N    | Mag.    Err    Flux    S/N    | Mag.    Err    Flux    S/N    | mag.abs | v
# 00001 2008/04/26 19:56:36.7 | 14.3102 0.0501 0004490 0033.7 | 13.4965 0.0365 0009483 0068.2 | 13.8035 0.0365 0007170 0052.6 | 22.2428 | Y
# 00002 2008/04/26 20:01:23.5 | 14.3349 0.0501 0004705 0033.4 | 13.4258 0.0364 0010450 0071.0 | 13.8742 0.0364 0007404 0051.4 | 22.3185 | Y
# 00003 2008/04/26 20:03:32.3 | 14.3436 0.0501 0004555 0033.4 | 13.4957 0.0358 0009925 0069.6 | 13.8043 0.0358 0007498 0053.6 | 22.2919 | Y
# 00004 2008/04/26 20:05:41.9 | 14.3112 0.0532 0004816 0031.7 | 13.4833 0.0387 0010233 0065.0 | 13.8167 0.0387 0007644 0049.4 | 22.3199 | Y
# 00005 2008/04/26 20:07:51.5 | 14.3021 0.0498 0005127 0034.0 | 13.5299 0.0363 0010604 0067.7 | 13.7701 0.0363 0008268 0053.6 | 22.3787 | Y
# etc ...
# @endverbatim
# La dernière colonne indique si l'image sera prise en compte ou pas dans le rapport final.
#   -# <b>@anchor calaphot_exploitation_resultats_resume Résumé final</b> : La dernière partie reprend les informations issus des calculs de photométrie dans un format compatible avec d'autres logiciels. Le choix du type de compatibilité a été défini par l'utilisateur dans le champ @ref calaphot_saisie_parametres_format_donnees "Format des données"
#     - Format Canopus : les données sont sensées pouvoir être comprises par ce logiciel commercial @ref calaphot_liens_utiles_canopus "MPO Canopus" .
#     - @anchor calaphot_exploitation_resultats_cdr Format CDR : le format CDR est l'appellation du format d'entrée du logiciel @ref calaphot_liens_utiles_courbrot "CourbRot" mis gracieusement à disposition des amateurs par Raoul Behrend, astronome à l'observatoire de Genève. Ce logiciel permet de déterminer les coefficients principaux d'une série de Fourier représentant au mieux la courbe de lumière décrite par les données en entrée. Il a aussi une sortie graphique et est l'outil principal de génération des pages du projet @ref calaphot_liens_utiles_cdrcdl "CdR/CdL".
# Les données au format CDR se présentent sous la forme d'un entête et d'une liste de données analogues à :
# @verbatim
# ---------------------------------------------------------------------------------------
# Format CDR
# ---------------------------------------------------------------------------------------
# NOM Kandrup
# MES Tycho Brahé @615
# POS 0 120.00
# CAP Kaf401E
# TEL 0.203 2.000 Schmidt-Cassegrain
# CAT USNO A2,R
# FIL -
# ; Données traitées par CalaPhot v5.0 sous AudeLA
#  1 1 20080426.83098 T 14.310  0.050
#  1 1 20080426.83430 T 14.335  0.050
#  1 1 20080426.83579 T 14.344  0.050
#  1 1 20080426.83729 T 14.311  0.053
#  1 1 20080426.83879 T 14.302  0.050
#  1 1 20080426.84028 T 14.368  0.059
#  1 1 20080426.84178 T 14.288  0.052
#  1 1 20080426.84327 T 14.332  0.053
#  1 1 20080426.84476 T 14.349  0.050
#  1 1 20080426.84776 T 14.354  0.059
#  1 1 20080426.84925 T 14.295  0.052
#  1 1 20080426.85075 T 14.306  0.046
#  1 1 20080426.85224 T 14.313  0.046
#  1 1 20080426.85373 T 14.274  0.049
#  1 1 20080426.85524 T 14.339  0.047
# @endverbatim
# L'utilisateur peut, par un copier-coller, récupérer telles qu'elles ces données pour les stocker dans le fichier "courbrot.obs" à partir duquel travaille Courbrot


##
# @defgroup calaphot_documentation_technique_fr Documentation technique de Calaphot
# @ingroup calaphot_notice_fr
#
# @section doc_tech_algo_global Algorithme global
# Dans cette section ne sont décrites que les fonctions propres aux calculs de photométrie. Toutes les fonctions graphiques ou relatives à l'interface humain sont ignorées.
# @subsection doc_tech_principe_base Principe de base des calculs
# Calaphot est un script dédié à des calculs de <b> photométrie différentielle </b> effectués sur une série d'image. Chaque image est considérée individuellement. Et donc dans une image donnée, on mesure le flux d'un astéroïde et les flux d'étoiles dites de référence qui ont été sélectionnées au préalable. Les flux des étoiles de référence sont aggrégés en un flux unique représentant ainsi une super-étoile.
# La magnitude catalogue des étoiles de référence étant connue au préalable, celui de la super-étoile s'en déduit par une formule simple. De ces trois données (flux de l'astéroïde, flux de la super-étoile, magnitude de la super-étoile), on en déduit immédiatement la magnitude de l'astéroïde par appilcation directe de la formule de Pogson.
# @subsection doc_tech_etoiles_reference Etoiles de référence.
# Les étoiles de référence sont des étoiles qui à priori ont une photométrie considérée comme stable pour la durée totale couverte par les images à étudier. Mais il se peut que cette présomption s'avère fausse, soit qu'une ou plusieurs étoiles soient en fait variables, ou que durant la durée des poses, l'atmosphère absorbe différemment les radiations de ces étoiles en fonction de leur classe spectrale (effet du à la variation de la masse d'air). Pour mettre en évidence cette possible variabilité des étoiles de référence, on effectue un calcul similaire à celui effectué pour l'astéroïde, mais en utilisant une pseudo-super-étoile. Pour une étoile de référence donnée, sa pseudo-super-étoile sera formé à partir de toutes les étoiles de référence autres qu'elle-même.
# -# Cas où <b> une seule étoile </b> de référence est sélectionnée : dans ce cas, la comparaison avec une pseudo-super-étoile n'a pas de sens, et ce calcul n'est pas fait. La possible variabilité de cette étoile de référence ne peut pas être mise en évidence.
# -# Cas où @b deux étoiles de référence sont sélectionnées : chaque étoile de référence est comparée à son alter-égo. On obtient alors deux courbes de variabilité symétriques, sans qu'il soit possible de dire si l'une est meilleure que l'autre.
# .
# @subsection doc_tech_constante_magnitudes Constante des magnitudes.
# La constante des magnitudes est la magnitude d'un astre fictif dont le flux serait 1 ADU pour un temps de pose de 1s. Ce calcul est fait pour chaque image à partir du flux de l'étoile de référence et permet de caractériser la transparence du ciel. Sur une nuit très claire, le profil de la constante des magnitudes dessine une courbe en cloche, témoin de la variation de la masse d'air que doit traverser les photons issus des étoiles de référence. Par nuit brumeuse, on voir aussi nettement se dessiner les instants de passage des bancs de nuages élevés (baisse de cette valeur). Ce calcul est juste informatif, mais il permet de repérer rapidement dans une séquence les périodes où les mesures sont les meilleures.
# @subsection doc_tech_sequencement_operations Séquencement des opérations.
# - Saisie d'une certain nombre de paramètres nécessaires aux calculs :
#   - \f$ \displaystyle {\frac {S}{B}}_{lim} \f$ : rapport signal sur bruit limite.
#   - \f$ \displaystyle G \f$ : gain inverse de la caméra (en électron/ADU).
#   - paramètres spécifiques à la photométrie d'ouverture.
#     - \f$ \displaystyle N_R \f$ : bruit de lecture de la caméra (en électrons).
#     - \f$ \displaystyle n_p \f$ : facteur de division des pixels.
#     - \f$ \displaystyle r_1\f$ : rayon exprimé en FWHM du disque entourant l'astre (nécessaire à la mesure du flux de l'astre).
#     - \f$ \displaystyle r_2\f$ : rayon interne exprimé en FWHM de la couronne entourant l'astre (nécessaire à la mesure du flux de fond de ciel).
#     - \f$ \displaystyle r_3\f$ : rayon externe exprimé en FWHM de la couronne entourant l'astre (nécessaire à la mesure du flux de fond de ciel).
#     .
#   .
# - Sélection de l'astéroïde à étudier.
# - Sélection des \f$ \displaystyle N_{ref} \f$ étoiles de référence, et entrée de leur magnitude @b catalogue \f$ \displaystyle M_{rc} \f$.
# - Calcul de la @ref doc_tech_calcul_mag_super_etoile "magnitude de la super-étoile" \f$ \displaystyle M_{se} \f$ à partir des \f$ \displaystyle N_{ref} \f$ valeurs \f$ \displaystyle M_{rc} \f$. Celle-ci est donc une @b constante pour toutes les images qui vont être traitées
# - Boucle pour toutes les images.
#   - Modélisation de tous les astres par une @ref doc_tech_modelisation_nappe_gaussienne "nappe gaussienne" de façon à déterminer précisément le centroïde ainsi que d'autres paramètres utilisés en photométrie d'ouverture.
#   - Mesure du flux de l' @ref doc_tech_calcul_mesure_flux "astéroïde" \f$ \displaystyle F_a \f$.
#   - Mesure du flux de chacune des étoiles de @ref doc_tech_calcul_mesure_flux "référence" \f$ \displaystyle F_r \f$.
#   - Calcul du @ref doc_tech_calcul_flux_super_etoile "flux de la super-étoile"\f$ \displaystyle M_{se} \f$.
#   - Calcul de l' @ref doc_tech_incert_totale_super_etoile "incertitude sur la magnitude de la super-étoile".
#   - Calcul de la @ref doc_tech_calcul_mag_astre "magnitude de l'astéroïde" \f$ \displaystyle M_a \f$.
#   - Calcul de l' @ref doc_tech_incert_mag "incertitude sur la magnitude de l'astéroïde" \f$ \displaystyle C_m \f$.
#   - A titre de vérification, calcul des magnitudes des étoiles de référence (à partir de leur pseudo-super-étoile).
#   - A titre de vérification, calcul des incertitudes sur les étoiles de référence (à partir de leur pseudo-super-étoile).
#   - @ref doc_tech_filtrage_sb.
#   - Calcul de la @ref doc_tech_calcul_cste_mag "constante des magnitudes".
# - Fin boucle pour toutes les images.
# - @ref doc_tech_filtrage_cm
# .
# @section doc_tech_detail_calcul Détail des calculs.
#
# @subsection doc_tech_calcul_mesure_flux Mesure des flux des astres.
# -# @anchor doc_tech_mesure_flux_ouv <b>Photometrie d'ouverture</b> : Toutes les étoiles de référence ont préalablement été modélisés. On dispose pour chacune de ces étoiles des paramètres de l'ellipse qui l'englobe ( \f$ \displaystyle \sigma_x, \sigma_y, \rho, \alpha \f$ ).
#    - @anchor doc_tech_mesure_flux_ouv_ellipse <b>Ellipse moyenne</b> : on détermine tout d'abord une ellipse moyenne de paramètres (\f$ \displaystyle \sigma_{xm}, \sigma_{ym}, \rho_m \f$) par
#       - \f$ \displaystyle \sigma_{xm} = \frac { \sum_{k=1}^{N_{ref}} \sigma_{xk} } {N_{ref}} \f$
#       - \f$ \displaystyle \sigma_{ym} = \frac { \sum_{k=1}^{N_{ref}} \sigma_{yk} } {N_{ref}} \f$
#       - \f$ \displaystyle \rho_m = \frac { \sum_{k=1}^{N_{ref}} \rho_k } {N_{ref}} \f$ où
#           - \f$ \displaystyle N_{ref} \f$ est le nombre d'étoile de référence.
#           - \f$ \displaystyle \sigma_{xk} \f$ et \f$ \displaystyle \sigma_{yk} \f$ sont les écarts-types sur les axes principaux de l'ellipse de l'étoile de référence \f$ \displaystyle k \f$.
#           - \f$ \displaystyle \rho_k \f$ est le facteur d'allongement de l'étoile de référence \f$ \displaystyle k \f$.
#           .
#       .
#    - @anchor doc_tech_mesure_flux_ouv_disque_interne <b>Disque interne</b> : puis on détermine une fenêtre d'ouverture elliptique d'axes \f$ \displaystyle \lambda_{xm} \f$ et \f$ \displaystyle \lambda_{ym} \f$ et de facteur d'allongement \f$ \displaystyle \rho_m \f$ centrée sur l'étoile.@n
#       - \f$ \displaystyle \lambda_{xm} = 1.66511.r_1.\sigma_{xm} \f$
#       - \f$ \displaystyle \lambda_{ym} = 1.66511.r_1.\sigma_{ym} \f$ où
#           - \f$ \displaystyle r_1 \f$ est le rayon exprimé en FWHM du disque elliptique qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
# @note : Cette valeur \f$ \displaystyle r_1 \f$ impacte directement la précision des calculs, et a fait l'objet de @ref calaphot_biblio1 "[1]" (chapitre 5.3) et d'une étude détaillée dans @ref calaphot_biblio2 "[2]".
#
#           .
#       .
# @anchor doc_tech_mesure_flux_ouv_division_pixels Pour augmenter la précision de calcul, les pixels sont artificiellement découpés en \f$ \displaystyle n_p^2 \f$ sous-pixels, \f$ \displaystyle n_p \f$ étant le facteur de division entré par l'utilisateur. Ainsi chaque sous-pixel se voit attribuer un niveau de gris égal à celui du pixel divisé par \f$ \displaystyle n_p^2 \f$.Finalement, on détermine sur l'image l'ensemble des sous-pixels qui sont englobés par l'ellipse et on somme les niveaux de gris de ces sous-pixels dans \f$ \displaystyle F_b \f$. On récupère aussi le nombre décimal de pixels \f$ \displaystyle n_{pix} \f$ inclus dans la fenêtre.
#    - @anchor doc_tech_mesure_flux_ouv_couronne_externe <b>Couronne externe</b> : on procède de même pour déterminer 2 cercles définissant une couronne dans laquelle sera mesuré le niveau de gris du fond de ciel. Les rayons de ces 2 cercles sont donnés par @n
#       - cercle interne : \f$ \displaystyle r_{2c} = 1.66511.r_2.\max ({\sigma_{xm}},{\sigma_{ym}}) \f$
#       - cercle externe : \f$ \displaystyle r_{3c} = 1.66511.r_3.\max ({\sigma_{xm}},{\sigma_{ym}}) \f$
#           - \f$ \displaystyle r_2 \f$ est le rayon interne exprimé en FWHM de la couronne qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
#           - \f$ \displaystyle r_3 \f$ est le rayon externe exprimé en FWHM de la couronne qui entoure l'astre à mesurer. Il a été spécifié par l'utilisateur.
#           .
#       .
# De même que pour le disque interne, chaque pixel est divisé en \f$ \displaystyle n_p^2 \f$ sous-pixels. A partir de tous les sous-pixels compris dans la couronne, on mesure alors le niveau de gris moyen \f$ \displaystyle N_B \f$ du fond de ciel par pixel, ainsi que le nombre de pixels (décimal) correspondant à la surface de la couronne \f$ \displaystyle n_B \f$.
#    - @anchor doc_tech_mesure_flux_ouv_flux <b>Le flux \f$ \displaystyle F \f$ de l'astre </b> considéré est déterminé par \f$ \displaystyle F = F_b - n_B.N_B \f$
#    .
# -# @anchor doc_tech_mesure_flux_mod <b>Photométrie par modélisation</b> : L'astre est tout d'abord modélisée par une @ref doc_tech_modelisation_nappe_gaussienne "nappe gaussienne". Le flux \f$ \displaystyle F \f$ est défini par le volume compris entre la nappe modélisant le profil de l'étoile et le plan du fond de ciel. @n
# \f$ \displaystyle F = \pi . S_o . \frac {\sigma_x.\sigma_y} {\sqrt{1-\rho^2}} \f$ où
#    - \f$ \displaystyle S_0 \f$ : niveau de gris maximum au niveau du centroïde
#    - \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$ : écart-types suivant les axes principaux de l'ellipse
#    - \f$ \displaystyle \rho \f$ : facteur d'allongement de l'ellipse (\f$ \displaystyle \|\rho\| < 1 \f$)
#    .
# -# @anchor doc_tech_mesure_flux_sext <b>Photométrie par SExtractor</b> :
# SExtractor inclue un module de photométrie qui est documenté dans le chapitre 9.4 du @ref calaphot_liens_utiles_sextractor "SExtractor user's manual". Calaphot utilise ce module avec les options suivantes :
#    - DETECT_TYPE  CCD
#    - MAG_ZEROPOINT 0.0
#    - GAIN mis à la valeur entrée par l'utilisateur.
#    - BACK_SIZE 32
#    - BACK_FILTERSIZE 3
#    - BACKPHOTO_TYPE  GLOBAL
#    .
# et récupère les données :
#    - MAG_AUTO
#    - MAGERR_AUTO
#    - FLUX_AUTO
#    - FLUXERR_AUTO
#    .
# .
# Il convient de se référer à la documentation de SExtractor pour connaître la signification et l'impact de ces paramètres.
#
# @subsection doc_tech_calcul_flux_super_etoile Calcul du flux de la super-étoile.
# Le flux de la super-étoile \f$ \displaystyle F_{se} \f$ est déterminé en sommant les flux \f$ \displaystyle F_r \f$ des \f$ \displaystyle N_{ref} \f$ étoiles de référence.@n
# \f$ \displaystyle F_{se} = \sum_{r=1}^{N_{ref}} F_r \f$
# @subsection doc_tech_calcul_flux_pseudo-super_etoile Calcul du flux de la pseudo-super-étoile.
# Le flux \f$ \displaystyle F_{pse}(r) \f$ de la pseudo-super-étoile \f$ \displaystyle r \f$ (qui sert à vérifier le comportement de l'étoile de référence \f$ \displaystyle r \f$) est déterminé en sommant les flux \f$ \displaystyle F_k \f$ des \f$ \displaystyle N_{ref}-1 \f$ étoiles de référence autres que l'étoile de référence \f$ \displaystyle r \f$).@n
# \f$ \displaystyle F_{pse}(r) = \sum_{k=1,k \neq r}^{N_{ref}} F_k \f$
# @subsection doc_tech_calcul_mag_aster Calcul des magnitudes.
# -# @anchor doc_tech_calcul_mag_astre <b>Magnitude de l'astéroïde</b> : le calcul de la magnitude utilise la formule de Pogson, la référence étant fournies par la magnitude et le flux de la super-étoile @n
#\f$ \displaystyle M_a = M_{se} - 2.5 * \log(\frac {F_a} {F_{se}}) \f$ où @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle F_{se} \f$ est le flux mesuré de la super-étoile @n
#    - \f$ \displaystyle F_a \f$ est le flux mesuré de l'astéroïde @n
#    - \f$ \displaystyle M_a \f$ est la magnitude de l'astéroïde @n
# -# @anchor doc_tech_calcul_cste_mag <b>Constante des magnitudes</b> : la constante des magnitudes est la magnitude d'un astre fictif dont le flux intégré sur une unité de temps (ici la seconde) correspond à 1 ADU au dessus du fond de ciel. Son calcul se fait à partir des flux et magnitudes de la super-étoile.@n
#\f$ C_m = M_{se} + 2.5.\log(F_{se}) - 2.5.\log(T_{exp}) \f$ où : @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle F_{se} \f$ est le flux mesuré de la super-étoile @n
#    - \f$ \displaystyle T_{exp} \f$ est le temps de pose (exprimé en seconde) de l'image considéré @n
#    - \f$ \displaystyle C_m \f$ est la constante des magnitudes.
#    .
# -# @anchor doc_tech_calcul_mag_super_etoile <b>Magnitude de la super-étoile</b> : @n
#\f$ \displaystyle M_{se} = -2.5.\log(\sum_{r=1}^{N_{ref}} 10^{-0.4.M_{rc}}) \f$ où @n
#    - \f$ \displaystyle M_{se} \f$ est la magnitude de la super-étoile @n
#    - \f$ \displaystyle M_{rc} \f$ est la magnitude @b catalogue de l'étoile de référence no r @n
#    - \f$ \displaystyle N_{ref} \f$ est le nombre d'étoile de référence
#    .
# @subsection doc_tech_incert_mag Calcul d'incertitude sur les magnitudes
# -# @anchor doc_tech_incert_mag_ouv <b>Photométrie d'ouverture</b> : la formule générale (dite équation générale des CCD) est tirée de @ref calaphot_biblio1 "[1]". Elle donne le rapport signal à bruit \f$ \displaystyle \frac {S}{B} \f$ : @n
#\f$ \displaystyle \frac {S}{B} = \frac {N_*}{\sqrt{N_* + n_{pix}.(1+\frac{n_{pix}}{n_B}).(N_S+N_D+N_R^2+G^2.\sigma_f^2)}} \f$ où @n
#    - \f$ \displaystyle N_* \f$ est le nombre total de photons correspondant à l'étoile. @n
#    - \f$ \displaystyle n_{pix} \f$ est le nombre de pixels de l'étoile. @n
#    - \f$ \displaystyle n_B \f$ est le nombre total de pixels utilisés pour calculer le fond de ciel moyen. @n
#    - \f$ \displaystyle N_S \f$ est le nombre de photons par pixel correspondant au fond de ciel. @n
#    - \f$ \displaystyle N_D \f$ est le nombre d'électrons par pixel du courant d'obscurité. @n
#    - \f$ \displaystyle N_R \f$ est le nombre total d'électrons par pixel générés par le bruit de lecture du CCD. @n
#    - \f$ \displaystyle G \f$ est le gain de la caméra CCD (exprimé en electron / ADU.) @n
#    - \f$ \displaystyle \sigma_f \f$ est un facteur constant valant approximativement 0.289.
#    .
# @note Les mots photon et électrons sont des synonymes dans les expressions ci-dessus, on devrait normalement parler de photo-electron, notion qui intégrerait le rendement quantique du CCD.@n
# Pour des observations avec des caméra CCD classiques, dont le gain est assez élevé, on peut négliger les 2 termes \f$ \displaystyle N_R^2+G^2.\sigma_f^2 \f$ .
# La formule ci-dessus est exprimée en photons (ou électrons). Or, les mesures sur les images s'effectuant en ADU, cette formule devient alors (en reprenant les notations ci-dessus )@n
# \f$ \displaystyle \frac {S}{B} = \frac {G.S_*}{\sqrt{G.S_* + n_{pix}.(1+\frac{n_{pix}}{n_B}).(G*N_B + N_R^2)}} \f$ où :
#    - \f$ \displaystyle S_* \f$ est le nombre d'ADU correspondant à l'étoile
#    - \f$ \displaystyle N_B \f$ est le nombre d'ADU par pixel du fond de ciel
#    .
# Finalement, l'incertitude \f$ \displaystyle E \f$ sur la mesure de la magnitude est donnée par
#\f$ \displaystyle E = \frac {1.0857} {\frac {S}{B}} \f$ .
# -# <b>Photometrie par modelisation</b> .
# L'incertitude sur le flux est directement issue du calcul des paramètres de la modélisation de l'astre. (voir @ref doc_tech_modelisation_nappe_gaussienne )
# -# <b>Photometrie par SExtractor</b> .
# voir le paragraphe sur la mesure des flux par @ref doc_tech_mesure_flux_sext "SExtractor".
# .
# @subsection doc_tech_incert_totale Calcul des incertitudes totales.
# -# @anchor doc_tech_incert_totale_super_etoile Pour la @b super-étoile, l'incertitude \f$ \displaystyle E_{se} \f$ est calculée à partir des incertitudes \f$ \displaystyle E_r \f$ et des magnitudes @b mesurées \f$ \displaystyle M_r \f$ de chacune des \f$ \displaystyle N_{ref} \f$ étoiles de référence : @n
#\f$ \displaystyle E_{se} = \frac {\sum_{r=1}^{N_{ref}} E_r.10^{-0.4.M_r}} {\sum_{r=1}^N 10^{-0.4.M_r}} \f$
# -# Pour l' @b astéroïde, l'incertitude totale \f$ \displaystyle E_{at} \f$ est la somme de son incertitude propre \f$ \displaystyle E_a \f$ et de celle de la super-étoile \f$ \displaystyle E_{se} \f$ @n
#\f$ \displaystyle E_{at} = E_a + E_{se} \f$
# -# Cas particulier des <b>étoiles de référence</b> : pour une étoile de référence \f$ \displaystyle r \f$, on calcule l'incertitude de la pseudo-super_étoile \f$ \displaystyle E_{pse} \f$, puis l'incertitude globale de l'étoile de référence \f$ \displaystyle E_{rt} \f$ à l'aide des formules (\f$ \displaystyle E_r \f$ désignant l'incertitude propre de l'étoile de référence) @n
#\f$ \displaystyle E_{pse} = \frac {\sum_{k=1, k \neq r}^{N_{ref}} E_k.10^{-0.4.M_k}} {\sum_{k=1, k \neq r}^{N_{ref}} 10^{-0.4.M_k}} \f$. @n
#\f$ \displaystyle E_{rt} = E_r + E_{pse} \f$. @n
# où les \f$ \displaystyle M_k \f$ designent les magnitude @b mesurées des étoiles de référence autres que l'étoile \f$ \displaystyle r \f$.
# .
# @subsection doc_tech_modelisation_nappe_gaussienne Modélisation d'une étoile par une nappe gaussienne.
# La modélisation permet de trouver une fonction analytique qui soit la plus proche au sens des moindres carrés de la fonction de niveaux de gris d'un astre. On peut trouver plus de détails dans @ref calaphot_biblio4 "les conférences de Peter B. Stetson". Dans le cas de la nappe gaussienne, la fonction de modélisation \f$ \displaystyle f(x,y) \f$ est donnée par @n
#\f$ \displaystyle f(x,y) = S_0 . e^{-h(x,y)} + B_0 \f$ où \f$ \displaystyle h(x,y) \f$ vaut @n
#\f$ \displaystyle h(x,y) = \frac {(x-x_c)^2}{\sigma_x^2} + \frac{(y-y_c)^2}{\sigma_y^2} - 2.\rho.\frac{x-x_c}{\sigma_x}.\frac{y-y_c}{\sigma_y} \f$
#Il faut noter que l'équation \f$ \displaystyle h(x,y) = constante \f$ est l'équation au centre d'une ellipse, dont les axes sont proportionnels aux valeurs \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$. Pour les notations :
# - \f$ \displaystyle S_0 \f$ est le niveau de gris maximum au niveau du centroïde.
# - \f$ \displaystyle (x_c,y_c) \f$ sont coordonnées du centroïde.
# - \f$ \displaystyle \sigma_x \f$ et \f$ \displaystyle \sigma_y \f$ sont écart-types suivant les axes principaux de l'ellipse.
# - \f$ \displaystyle \rho \f$ est le facteur d'allongement de l'ellipse (\f$ \displaystyle \|\rho\| < 1 .\f$)
# - \f$ \displaystyle B_0 \f$ est le niveau de gris du fond de ciel.
# .
# La modélisation consiste donc à trouver les sept valeurs précédentes. De ces valeurs, on en tire aisément :
# - \f$ \displaystyle \lambda_x \f$ le FWHM suivant un des axes de l'ellipse, \f$ \displaystyle \lambda_x = 1,66511.\sigma_x \f$
# - \f$ \displaystyle \lambda_y \f$ le FWHM suivant l'axe perpendiculaire au précédent, \f$ \displaystyle \lambda_y = 1,66511.\sigma_y \f$
# - \f$ \displaystyle \alpha \f$ l'angle entre les axes principaux de l'ellipse et les axes de l'image.@n
#   - si \f$ \displaystyle \sigma_x \neq \sigma_y \f$, on a \f$ \displaystyle \alpha = \frac{1}{2}.\arctan \frac {2.\rho.\sigma_x.\sigma_y}{\sigma_x^2 - \sigma_y^2} \f$ .@n
#   - dans le cas contraire, l'ellipse est un cercle, et \f$ \displaystyle \alpha \f$ est indéterminé.
#   .
# .
# Les incertitudes sont données par le produit du résidu de la modélisation par la covariance du paramètre recherché. En termes plus simples, les incertitudes sont directement fournies par le calcul des paramètres de la modélisation. Pour plus de détails, se rapporter au début de la "lecture 2" de @ref calaphot_biblio4 "[4]"
#
# @section doc_tech_filtrage Filtrage des images
# Certaines images de mauvaise qualité, ou dont les résultats semblent aberrants doivent être écartées du rapport final.
# @subsection doc_tech_filtrage_sb Filtrage à partir des rapports signal sur bruit.
# Ce filtrage vise à éliminer les images douteuses. Sont qualifiées de douteuses les images dont <b>au moins</b> un astre a un rapport signal à bruit inférieur à la limite \f$ \displaystyle {\frac {S}{B}}_{lim} \f$ définie par l'utilisateur. Ce filtrage est fait au fur et à mesure des calculs.
# @section doc_tech_filtrage_cm Filtrage à partir de la constante des magnitudes
# La @ref doc_tech_calcul_cste_mag "constante des magnitudes" étant calculée directement à partir du flux de la super-étoile, son évolution dans le temps est sensée être lente et ne suivre que les variations de la masse d'air. On peut donc s'appuyer sur sa valeur pour tenter de détecter rapidement les images qui semblent aberrantes pour des raisons diverses (passage nuageux, disfonctionnement de la caméra, dérive brutale brutale du télescope, etc...)@n
# L'algorithme est le suivant : pour une image donné, on calcule la moyenne \f$ \displaystyle m \f$ et l'écart-type \f$ \displaystyle \sigma \f$ de la constante des magnitudes pour les 5 images précédentes et les 5 images suivantes. Si la constante des magnitude de l'image donnée est dans l'intervalle \f$ \displaystyle [m-3.\sigma, m+3.\sigma] \f$, l'image est conservée. Elle est rejetée dans le cas contraire, et ne participera plus au calcul de la moyenne et écart-type pour les images suivantes.
# S'il y a moins de 5 images avant ou après l'image donnée, on ne prend que celle qui existent (éternel problème des bords).
#
# @section age_du_capitaine Calcul de l'âge du capitaine.
# Le problème soulevé par ce calcul n'est pas récent et a été posé par l’écrivain français Gustave Flaubert (1821-1880) dans une lettre à sa sœur Caroline en 1843. <i> Puisque tu fais de la géométrie et de la trigonométrie, je vais te donner un problème : Un navire est en mer, il est parti de Boston chargé de coton, il jauge 200 tonneaux, il fait voile vers Le Havre, le grand mât est cassé, il y a un mousse sur le gaillard d'avant, les passagers sont au nombre de douze, le vent souffle NNE, l'horloge marque trois heures un quart d'après-midi, on est au mois de mai ... On demande l'âge du capitaine </i>

##
# @defgroup calaphot_liens_biblio_fr Liens utiles et bibliographie
# @ingroup calaphot_notice_fr
# @section calaphot_liens_utiles Liens utiles
# - Les pages maintenues par Raoul Behrend :
#   - Le project CdR/CdL : @anchor calaphot_liens_utiles_cdrcdl http://obswww.unige.ch/~behrend/page_cou.html
#   - Le logiciel Courbrot et son format pour les données d'entrée : @anchor calaphot_liens_utiles_courbrot http://obswww.unige.ch/~behrend/redcouro/redcouro.html
#   .
# - Le logiciel SExtractor : @anchor calaphot_liens_utiles_sextractor http://terapix.iap.fr/rubrique.php?id_rubrique=91/index.html
# - Le logiciel MPO Canopus : @anchor calaphot_liens_utiles_canopus http://www.minorplanetobserver.com/MPOSoftware/MPOCanopus.htm
# .
#
# @section calaphot_biblio Bibliographie
# - @anchor calaphot_biblio1 [1] Handbook of CCD Astronomy, Steve B.Howell, Cambridge University Press, ISBN 0-521-64834-3
# - @anchor calaphot_biblio2 [2] Howell, S.B, <i> Publ. Astrom. Soc. Pac. </i>, @b 101, 616. Une copie est disponible sur http://astrosurf.com/michelet/calaphot/biblio/Howell_1989_PASP_101_616_CCD_aperture_photometry.pdf
# - @anchor calaphot_biblio3 [3] Newberry, M, <i> Publ. Astrom. Soc. Pac. </i>, @b 103, 122. Une copie est disponible sur http://astrosurf.com/michelet/calaphot/biblio/Newberry_1991_PASP_103_122_CCD_sky_substraction.pdf
# - @anchor calaphot_biblio4 [4] Peter B. Stetson, The techniques of least squares and stellar photometry with CCDs : http://nedwww.ipac.caltech.edu/level5/Stetson/Stetson_contents.html
# .
