#
# Fichier : visio2.tcl
# Description : Outil de visialisation des images et des films
# Auteur : Michel PUJOL
# Mise à jour $Id: visio2.tcl 13571 2016-04-02 19:00:27Z michelpujol $
#

namespace eval ::visio2 {
   package provide visio2 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] visio2.cap ]
}

proc ::visio2::createPluginInstance { base { visuNo 1 } } {
   variable private
   global audace caption conf

   #--- icone directory
   set private(folderIcon) [image create photo folderopen16 -data {
       R0lGODlhEAAQAIYAAPwCBAQCBExKTBQWFOzi1Ozq7ERCRCwqLPz+/PT29Ozu
       7OTm5FRSVHRydIR+fISCfMTCvAQ6XARqnJSKfIx6XPz6/MzKxJTa9Mzq9JzO
       5PTy7OzizJSOhIyCdOTi5Dy65FTC7HS2zMzm7OTSvNTCnIRyVNza3Dw+PASq
       5BSGrFyqzMyyjMzOzAR+zBRejBxqnBx+rHRmTPTy9IyqvDRylFxaXNze3DRu
       jAQ2VLSyrDQ2NNTW1NTS1AQ6VJyenGxqbMTGxLy6vGRiZKyurKyqrKSmpDw6
       PDw6NAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
       AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAAA
       LAAAAAAQABAAAAfCgACCAAECg4eIAAMEBQYCB4mHAQgJCgsLDAEGDQGIkw4P
       BQkJBYwQnRESEREIoRMUE6IVChYGERcYGaoRGhsbHBQdHgu2HyAhGSK6qxsj
       JCUmJwARKCkpKsjKqislLNIRLS4vLykw2MkRMRAGhDIJMzTiLzDXETUQ0gAG
       CgU2HjM35N3AkYMdAB0EbCjcwcPCDBguevjIR0jHDwgWLACBECRIBB8GJekQ
       MiRIjhxEIlBMFOBADR9FIhiJ5OnAEQB+AgEAIf5oQ3JlYXRlZCBieSBCTVBU
       b0dJRiBQcm8gdmVyc2lvbiAyLjUNCqkgRGV2ZWxDb3IgMTk5NywxOTk4LiBB
       bGwgcmlnaHRzIHJlc2VydmVkLg0KaHR0cDovL3d3dy5kZXZlbGNvci5jb20A
       Ow==
    }]

   #--- Chargement des autres sources (en attendant de les charger depuis aud.tcl)
   source [ file join $audace(rep_gui) audace movie.tcl ]
   source [ file join $audace(rep_gui) audace ftpclient.tcl ]
   source [ file join $audace(rep_gui) audace image.tcl ]

   #--- je charge le package Tablelist
   package require Tablelist

   #--- je verifie que les variables de cet outil existent dans $conf(...)
   #--- indicateurs d'affichage des colonnes
   if {![info exists conf(visio2,show_column_type)]}    { set conf(visio2,show_column_type)    "1" }
   if {![info exists conf(visio2,show_column_series)]}  { set conf(visio2,show_column_series)  "0" }
   if {![info exists conf(visio2,show_column_date)]}    { set conf(visio2,show_column_date)    "0" }
   if {![info exists conf(visio2,show_column_size)]}    { set conf(visio2,show_column_size)    "0" }

   #--- largeur des colonnes en nombre de caracteres (valeur positive) ou en nombre de pixel (valeur negative)
   if {![info exists conf(visio2,width_column_name)]}   { set conf(visio2,width_column_name)   "-90" }
   if {![info exists conf(visio2,width_column_type)]}   { set conf(visio2,width_column_type)   "-70" }
   if {![info exists conf(visio2,width_column_series)]} { set conf(visio2,width_column_series) "-60" }
   if {![info exists conf(visio2,width_column_date)]}   { set conf(visio2,width_column_date)   "-104" }
   if {![info exists conf(visio2,width_column_size)]}   { set conf(visio2,width_column_size)   "-70" }

   #--- extensions des fichiers par defaut
   if {![info exists conf(visio2,enableExtension)]} {
      set conf(visio2,enableExtension) [list]
   }
   if { [lsearch $conf(visio2,enableExtension) "fit"] == -1 } {
     lappend conf(visio2,enableExtension) "fit" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "raw"] == -1 } {
     lappend conf(visio2,enableExtension) "raw" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "jpg"] == -1 } {
     lappend conf(visio2,enableExtension) "jpg" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "bmp"] == -1 } {
      lappend conf(visio2,enableExtension) "bmp" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "gif"] == -1 } {
      lappend conf(visio2,enableExtension) "gif" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "png"] == -1 } {
      lappend conf(visio2,enableExtension) "png" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "tif"] == -1 } {
      lappend conf(visio2,enableExtension) "tif" "1"
   }
   if { [lsearch $conf(visio2,enableExtension) "avi"] == -1 } {
     lappend conf(visio2,enableExtension) "avi" "1"
   }
   if {![info exists conf(visio2,show_all_files)]} { set conf(visio2,show_all_files) "0" }

   #--- Types des objets affiches
   #---   bidouille !!! je met un espace au debut de private(parentFolder) et private(folder)
   #---   pour que les repertoires apparaissent en premier par ordre alphabetique
   set private(parentFolder) " $caption(visio2,parent_folder)"
   set private(folder)       " $caption(visio2,folder)"
   set private(fileImage)    "$caption(visio2,image)"
   set private(fileMovie)    "$caption(visio2,movie)"
   set private(file)         "$caption(visio2,file)"
   set private(volume)       "$caption(visio2,disque)"

   #--- j'affiche l'outil
   #--- j'initialise la variable private
   set private($visuNo,This)          $base.visio2
   set private($visuNo,ftptbl)        ""
   set private($visuNo,ftpconnection) "0"
   set private($visuNo,animation)     "0"
   set private($visuNo,sortedColumn)  "0"

   #--- j'affiche l'outil
   createPanel $visuNo

   #---
   return $private($visuNo,This)
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::visio2::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::visio2::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
      multivisu    { return 1 }
      rank         { return 1 }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::visio2::getPluginTitle { } {
   global caption

   return "$caption(visio2,title)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::visio2::getPluginHelp { } {
   return "visio2.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::visio2::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::visio2::getPluginDirectory { } {
   return "visio2"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::visio2::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  startTool
#     demarre le plugin
#------------------------------------------------------------
proc ::visio2::startTool { visuNo } {
   variable private
   global audace

   #--- je refraichis la liste des fichiers
   ::visio2::localTable::init $visuNo $private($visuNo,This) $audace(rep_images)
   ::visio2::localTable::refresh $visuNo
}

#------------------------------------------------------------
#  stopTool
#     arrete le plugin
#------------------------------------------------------------
proc ::visio2::stopTool { visuNo } {
   variable private

   #--- j'arrete le diaporama
   set ::visio2::localTable::private($visuNo,slideShowState) "0"
   ::visio2::localTable::setSlideShow $visuNo
   #--- j'arrete l'animation
   ::visio2::localTable::stopAnimation $visuNo
   #--- je supprime le canvas des films
   ::Movie::close $visuNo
   #--- je copie la largeur des colonnes dans conf()
   ::visio2::localTable::saveColumnWidth $visuNo
   #--- je ferme la connexion ftp
   ftpclient::closeCnx
}

#------------------------------------------------------------------------------
# configure
#   affiche la fenetre de configuration
#------------------------------------------------------------------------------
proc ::visio2::configure { visuNo } {
   variable private

   #--- j'affiche la fenetre de configuration
   ::confGenerique::run $visuNo "$private($visuNo,This).confvisio2" "::visio2::config" -modal 0

   #--- je refraichis les tables pour prendre en compte la nouvelle config
   localTable::refresh $visuNo
   ftpTable::refresh $visuNo
}

#------------------------------------------------------------------------------
# getFileList
#   retourne la liste des fichiers et des sous-repertoires presents
#   dans le repertoire donne en parametre
#   retourne une liste de 4 attributs pour chaque fichier [isdir shortname date size]
#------------------------------------------------------------------------------
 proc ::visio2::getFileList { visuNo directory } {
   variable private

   set files ""
   foreach fullname [glob -nocomplain -dir $directory *] {
      set shortname [file tail $fullname]
      if { [string index $shortname 0 ] == "~" } {
         #--- j'ignore les fichiers dont le nom commence par un tilde car cfitsio refuse de les lire
         #--- (cfitsio va chercher le fichier dans le repertoir HOME du user)
         continue
      }
      set isdir [file isdir $fullname]
      set date [file mtime $fullname]
      if { $isdir == 1 } {
         set size ""
      } else {
         set size [file size $fullname]
      }
      lappend files [list "$isdir" "$shortname" "$date" "$size" ]
   }
   return $files
}

#------------------------------------------------------------------------------
# fillTable
#   affiche les noms des fichiers dans la table
#------------------------------------------------------------------------------
 proc ::visio2::fillTable { visuNo tbl files } {
   variable private
   global conf

   #--- je recupere les extensions autorisees dans un tableau
   array set enableExtension $conf(visio2,enableExtension)

   #--- raz de la liste
   $tbl delete 0 end
   ##$tbl resetsortinfo

   #--- je cree une ligne correspondant au repertoire parent
   lappend item " .." $private(parentFolder) "" ""
   #--- j'insere la ligne dans la table
   $tbl insert end $item
   #--- j'ajoute l'icone
   $tbl cellconfigure end,0 -image $private(folderIcon)

   #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
   foreach i [lsort -dictionary $files] {
      set isdir "[lindex $i 0 ]"
      set name  "[lindex $i 1 ]"
      set date  "[lindex $i 2 ]"
      set size  "[lindex $i 3 ]"

      if { $isdir == 1 } {
         # cas d'un repertoire : affiche le nom du repertoire et l'icone private(folderIcon)
         set item {}
         #--- colonne name
         #--- bidouille !!! : j'ajoute un espace au debut du nom du repertoire
         #--- pour que le tri automatique mette les repertoires en premier par ordre alphabetique
         set name " $name"
         #--- colonne type
         set type "$private(folder)"
         #--- colonne date
         if { "$date" != "" && [string is integer $date ] } {
            set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         }
         #--- colonne serie (toujours vide pour un repertoire)
         set serie ""
         #--- colonne size (toujours vide pour un repertoire)
         set size ""
         #--- je cree la ligne
         lappend item "$name" "$type" "$serie" "$date" "$size"
         #--- j'insere la ligne dans la table
         $tbl insert end $item
         #--- j'ajoute l'icone
         $tbl cellconfigure end,0 -image $private(folderIcon)

      } elseif {  [regexp ($conf(extension,defaut)|$conf(extension,defaut).gz)$ [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fit)$                [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fit.gz)$             [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fits)$               [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fits.gz)$            [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fts)$                [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.fts.gz)$             [string tolower $name]] && $enableExtension(fit)==1
               || [regexp (.jpg|.jpeg)$          [string tolower $name]] && $enableExtension(jpg)==1
               || [regexp (.crw|.nef|.cr2|.dng)$ [string tolower $name]] && $enableExtension(raw)==1
               || [regexp (.bmp)$                [string tolower $name]] && $enableExtension(bmp)==1
               || [regexp (.gif)$                [string tolower $name]] && $enableExtension(gif)==1
               || [regexp (.tif|.tiff)$          [string tolower $name]] && $enableExtension(tif)==1
               || [regexp (.png)$                [string tolower $name]] && $enableExtension(png)==1
               } {

         #--- cas d'une image : ajoute une ligne dans la table avec le nom, type, serie et date du fichier
         #--- colonne name
         set name $name
         #--- colonne type
         set type "$private(fileImage)"
         #--- colonne date
         if { "$date" != "" && [string is integer $date ] } {
            set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         }

         #--- colonne serie
         #------ 1) je prepare les variables
         set serie ""
         set serialName ""
         set serialInd ""
         set rootname [file rootname $name]
         #------ 2) je supprime les extensions avec une boucle car il peut y avoir plusieurs extensions
         while { [string first "." "$rootname" ] != -1 } {
            set rootname [file rootname $rootname]
         }
         #------ 3) je cherche un numero a la fin de rootname => serialind
         set result [regexp {([^0-9]*)([0-9]+$)} $rootname match serialName serialInd ]
         if { $result == 1 } {
            if { $serialInd != "" } {
               #--- si serialInd n'est pas vide, ce fichier fait partie d'une serie
               set serialName [string range $rootname 0 [expr [string last $serialInd $rootname ] -1 ]]
               #--- je supprime les zeros a gauche pour que serialInd ne soit pas interprete comme une valeur en octal
               if { $serialInd != "0" } {
                  set serialInd [string trimleft $serialInd "0" ]
               }
               if { [string is integer $serialInd] && "$serialInd" != ""} {
                  set serie [format "%s % 5d" $serialName $serialInd]
               } else {
                  console::affiche_erreur "fillTable error serialInd=$serialInd name=$name \n"
               }
            }
         } else {
            #--- pas de chiffre trouve a la fin du nom du fichier
            set serie " "
         }
         #--- colonne size
         if { [string is integer $size ] } {
            set size [format "%12d" $size]
         }

         #--- je cree la ligne
         set item {}
         lappend item "$name" "$type" "$serie" "$date" "$size"
         #--- j'ajoute une ligne dans la table
         $tbl insert end $item

      } elseif { [regexp (.avi|.mpeg)$ [string tolower $name]] && $enableExtension(avi)==1 } {
         #--- cas d'un film : ajoute une ligne avec le nom, type, serie et date du fichier
         set item {}
         #--- colonne name
         set name $name
         #--- colonne type
         set type "$private(fileMovie)"
         #--- colonne date
         if { [string is integer $date ] } {
            set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         }
         #--- colonne serie
         set serie ""
         #--- colonne size
         if { [string is integer $size ] } {
            set size [format "%12d" $size]
         }
         #--- je cree la ligne
         lappend item "$name" "$type" "$serie" "$date" "$size"
         #--- j'ajoute une ligne dans la table
         $tbl insert end $item
      } elseif  { $conf(visio2,show_all_files)==1 } {
         #--- cas d'un fichier quelconque
         set item {}
         #--- colonne name
         set name $name
         #--- colonne type
         set type "$private(file)"
         #--- colonne date
         set date "[clock format $date -format "%Y/%m/%d %H:%M:%S" ]"
         #--- colonne serie
         set serie ""
         #--- colonne size
         if { [string is integer $size ] } {
            set size [format "%12d" $size]
         }
         #--- je cree la ligne
         lappend item "$name" "$type" "$serie" "$date" "$size"
         #--- j'ajoute une ligne dans la table
         $tbl insert end $item
      }
   }

   #--- je trie par ordre alphabetique de la colonne selectionnee
   #tablelist::sortByColumn $tbl $private($visuNo,sortedColumn)
   #--- je rafraichis les scrollbars
   ##update
}

#------------------------------------------------------------------------------
# fillVolumeTable
#   affiche la liste des disques dans la table
#------------------------------------------------------------------------------
 proc ::visio2::fillVolumeTable { visuNo tbl } {
   variable private
   global conf

   #--- raz de la liste
   $tbl delete 0 end
   #$tbl resetsortinfo

   #--- j'ajoute les lignes correspondant aux fichiers et sous-repertoires
   foreach i [file volumes] {
      #--- colonne name
      set name [file nativename "$i"]
      #--- colonne type
      set type "$private(volume)"
      #--- colonne date
      set date ""
      #--- colonne serie (toujours vide pour un disque)
      set serie ""
      #--- colonne size (toujours vide pour un disque)
      set size ""
      #--- je cree la ligne
      set item {}
      lappend item "$name" "$type" "$serie" "$date" "$size"
      #--- j'insere la ligne dans la table
      $tbl insert end $item
      #--- j'ajoute l'icone
      $tbl cellconfigure end,0 -image $private(folderIcon)
   }

   #--- je trie par ordre alphabetique de la premiere colonne selectionnee
   #tablelist::sortByColumn $tbl $private($visuNo,sortedColumn)
}

#------------------------------------------------------------------------------
# cmdSortColumn
#   trie les lignes par ordre alphabetique de la colonne
#   (est appele quand on clique sur le titre de la colonne)
#------------------------------------------------------------------------------
proc ::visio2::cmdSortColumn { visuNo tbl col } {
   variable private
   set private($visuNo,sortedColumn) $col
   set sens [tablelist::sortByColumn $tbl $col]
}

#------------------------------------------------------------------------------
# showColumn
#   affiche ou masque une colonne
#   et adapte la largeur de la table en fonction des colonnes restant affichees
#------------------------------------------------------------------------------
proc ::visio2::showColumn { visuNo tbl columnIndex } {
   variable private

   switch $columnIndex {
      "0" { set show "1" }
      "1" { set show $::conf(visio2,show_column_type) }
      "2" { set show $::conf(visio2,show_column_series) }
      "3" { set show $::conf(visio2,show_column_date) }
      "4" { set show $::conf(visio2,show_column_size) }
   }
   if { $show == 1 } {
      $tbl columnconfigure $columnIndex -hide 0
   } else {
      $tbl columnconfigure $columnIndex -hide 1
   }

   #--- je recalcule la largeur de la liste
   set width 0
   for {set i 0} {$i < [$tbl columncount] } {incr i } {
      if { [$tbl columncget $i -hide] == 0 } {
         incr width [$tbl columncget $i -width]
      }
      #console::disp "width $i=[$tbl columncget $i -width] \n"
   }
   $tbl configure -width $width

   #--- je fais pareil pour la table ftpTable si elle est affichee
   if { [info exists ::visio2::ftpTable::private($visuNo,tbl)]
       && [winfo exists $::visio2::ftpTable::private($visuNo,tbl)] } {
      if { "$::visio2::ftpTable::private($visuNo,tbl)" != "" } {
         set tbl $::visio2::ftpTable::private($visuNo,tbl)
         if { $show == 1 } {
            $tbl columnconfigure $columnIndex -hide 0
         } else {
            $tbl columnconfigure $columnIndex -hide 1
         }

         #--- je recalcule la largeur de la liste
         set width 0
         for {set i 0} {$i < [$tbl columncount] } {incr i } {
            if { [$tbl columncget $i -hide] == 0 } {
               incr width [$tbl columncget $i -width]
            }
         }
         $tbl configure -width $width
      }
   }
}

#------------------------------------------------------------------------------
# cmdFtpConnection
#   etablit une connexion ftp
#   et affiche le contenu du repertoire distant dans la table ftpTable
#------------------------------------------------------------------------------
proc ::visio2::cmdFtpConnection { visuNo } {
   variable private

   if { $private($visuNo,ftpconnection) == 1 } {
      set result [::visio2::ftpTable::init $visuNo "$private($visuNo,This)" ]
      if {  $result == 0 } {
          #--- si la connexion est annulee, je decoche le checkbutton
          set private($visuNo,ftpconnection) 0
      }
   } else {
      #--- je ferme la connexion FTP et supprime la liste FTP
      set result [ftpTable::close $visuNo ]
      if { $result == "0" } {
         #--- si la fermeture est annulee, je recoche le checkbutton
         set private($visuNo,ftpconnection) 1
      }
   }
}

#------------------------------------------------------------------------------
# createPanel
#   affiche l'outil visio2
#------------------------------------------------------------------------------
proc ::visio2::createPanel { visuNo } {
   global caption
   global conf
   variable private

   set This $private($visuNo,This)

   frame $This -borderwidth 2 -relief groove

   #--- Frame du titre
   frame $This.titre -borderwidth 2 -relief groove

   #--- Bouton du titre
   Button $This.titre.but -borderwidth 1 \
      -text "$caption(visio2,help,titre1)\n$caption(visio2,title)" \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::visio2::getPluginType ] ] \
         [ ::visio2::getPluginDirectory ] [ ::visio2::getPluginHelp ]"
   DynamicHelp::add $This.titre.but -text $caption(visio2,help,titre)
   pack $This.titre.but -in $This.titre -anchor center -expand 1 -fill x -side top -ipadx 5

   pack $This.titre -in $This -fill x

   #--- Frame de la liste locale
   frame $This.locallist -borderwidth 1 -relief groove
   ::visio2::localTable::createTbl $visuNo $This.locallist
   pack $This.locallist -fill both -expand 1 -anchor n -side top

   #--- Frame SlideShow
   frame $This.slideShow -borderwidth 1 -relief groove

   checkbutton $This.slideShow.check -pady 0 -text "$caption(visio2,slideshow)" \
            -variable ::visio2::localTable::private($visuNo,slideShowState) \
            -command "::visio2::localTable::setSlideShow $visuNo"
   pack $This.slideShow.check -in $This.slideShow -anchor center -expand 0 -fill none -side left

   set list_combobox [ list "0.5" "1" "2" "3" "5" "10" ]
   ComboBox $This.slideShow.delay \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [llength $list_combobox] \
      -relief sunken    \
      -borderwidth 1    \
      -editable 1       \
      -takefocus 1      \
      -textvariable ::visio2::localTable::private($visuNo,slideShowDelay) \
      -values $list_combobox
   $This.slideShow.delay setvalue @1
   pack $This.slideShow.delay -in $This.slideShow -anchor center -expand 0 -fill none -side left

   label $This.slideShow.labdelay -borderwidth 1 -text "s."
   pack $This.slideShow.labdelay -in $This.slideShow -anchor center -expand 0 -fill none -side left
   pack $This.slideShow -fill x -anchor n

   #--- frame ftp
   frame $This.ftp -borderwidth 1 -relief groove

   checkbutton $This.ftp.check -pady 0 -text $caption(visio2,ftp_connection_title) \
            -variable ::visio2::private($visuNo,ftpconnection) \
            -command "::visio2::cmdFtpConnection $visuNo"
   pack $This.ftp.check -in $This.ftp -anchor center -expand 0 -fill none -side left
   pack $This.ftp -in $This -fill x -anchor n

   #--- Frame de la liste ftp
   frame $This.ftplist -borderwidth 1 -relief groove
   ::visio2::ftpTable::createTbl $visuNo $This.ftplist

   #--- la table sera "packe" plus tard quand on demandera a l'afficher
   #pack $This.ftplist -after $This.ftp -fill both -expand 1 -anchor n -side bottom
   ::confColor::applyColor $This
}

################################################################
# namespace ::visio2::config
#    fenetre de configuration de l'outil visio2
################################################################
namespace eval ::visio2::config {
}

#------------------------------------------------------------
# ::visio2::config::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::visio2::config::getLabel { } {
   global caption

   return "$caption(visio2,title)"
}

#------------------------------------------------------------
# ::visio2::config::showHelp
#   affiche l'aide de cet outil
#------------------------------------------------------------
proc ::visio2::config::showHelp { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::visio2::getPluginType ] ] \
         [ ::visio2::getPluginDirectory ] [ ::visio2::getPluginHelp ] "config"
}

#------------------------------------------------------------
# ::visio2::config::confToWidget { }
#   copie les parametres du tableau conf() dans les variables des widgets
#------------------------------------------------------------
proc ::visio2::config::confToWidget { } {
   variable private
   variable widget
   variable widgetEnableExtension
   global conf

   #--- je mets les extensions dans un array (de-serialisation)
   array set widgetEnableExtension $conf(visio2,enableExtension)

   #--- j'initialise les variables utilisees par le widgets
   set widget(show_all_files) $conf(visio2,show_all_files)
}

#------------------------------------------------------------
# ::visio2::config::cmdApply { }
#   copie les variable des widgets dans le tableau conf()
#------------------------------------------------------------
proc ::visio2::config::cmdApply { visuNo } {
   variable private
   variable widget
   variable widgetEnableExtension
   global conf

   set conf(visio2,enableExtension) [array get widgetEnableExtension]
   set conf(visio2,show_all_files)  $widget(show_all_files)
}

#------------------------------------------------------------
# ::visio2::config::fillConfigPage { }
#   fenetre de configuration de l'outil
#   return rien
#------------------------------------------------------------
proc ::visio2::config::fillConfigPage { frm visuNo } {
   variable widget
   variable widgetEnableExtension
   global caption
   global conf

  ### array set fileExtension [array get ::visio2::fileExtension]

   #--- je memorise la reference de la frame
   set widget(frm) $frm

   #--- j'initialise les variables des widgets
   confToWidget

   frame $frm.extension -borderwidth 1 -relief ridge
   pack $frm.extension -side top -fill both -expand 1

   label $frm.extension.knownfiles -text "$caption(visio2,known_files)" \
      -justify left
   pack $frm.extension.knownfiles -anchor w -side top -padx 5 -pady 0

   #--- fichiers extension par defaut
   if { $conf(extension,defaut) == ".jpg"  || $conf(extension,defaut) == ".jpeg" || \
        $conf(extension,defaut) == ".crw"  || $conf(extension,defaut) == ".nef"  || \
        $conf(extension,defaut) == ".cr2"  || $conf(extension,defaut) == ".dng"  || \
        $conf(extension,defaut) == ".CRW"  || $conf(extension,defaut) == ".NEF"  || \
        $conf(extension,defaut) == ".CR2"  || $conf(extension,defaut) == ".DNG"  || \
        $conf(extension,defaut) == ".gif"  || $conf(extension,defaut) == ".bmp"  || \
        $conf(extension,defaut) == ".png"  || $conf(extension,defaut) == ".tif"  || \
        $conf(extension,defaut) == ".tiff" || $conf(extension,defaut) == ".avi"  || \
        $conf(extension,defaut) == ".mpeg"
      } {
      checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut)" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(defautext)
      pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
   } else {
      checkbutton $frm.extension.extdefaut -text "$conf(extension,defaut) $conf(extension,defaut).gz" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(defautext)
      pack $frm.extension.extdefaut -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers fit
   if { $conf(extension,defaut) == ".fit" } {
      checkbutton $frm.extension.extfit -text ".fts .fts.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".fts" } {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".fits" } {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   } else {
      checkbutton $frm.extension.extfit -text ".fit .fit.gz .fts .fts.gz .fits .fits.gz" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(fit)
      pack $frm.extension.extfit -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers raw
   if { ( $conf(extension,defaut) != ".crw" ) && ( $conf(extension,defaut) != ".cr2" ) && \
      ( $conf(extension,defaut) != ".nef" ) && ( $conf(extension,defaut) != ".dng" ) && \
      ( $conf(extension,defaut) != ".CRW" ) && ( $conf(extension,defaut) != ".CR2" ) && \
      ( $conf(extension,defaut) != ".NEF" ) && ( $conf(extension,defaut) != ".DNG" ) } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".crw" } {
      checkbutton $frm.extension.raw -text ".cr2 .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".cr2" } {
      checkbutton $frm.extension.raw -text ".crw .nef .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".nef" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .dng .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".dng" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .CRW .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".CRW" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CR2 .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".CR2" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .NEF .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".NEF" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .DNG" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".DNG" } {
      checkbutton $frm.extension.raw -text ".crw .cr2 .nef .dng .CRW .CR2 .NEF" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(raw)
      pack $frm.extension.raw -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers jpg
   if { ( $conf(extension,defaut) != ".jpg" ) && ( $conf(extension,defaut) != ".jpeg" ) } {
      checkbutton $frm.extension.jpg -text ".jpg .jpeg" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".jpg" } {
      checkbutton $frm.extension.jpg -text ".jpeg" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".jpeg" } {
      checkbutton $frm.extension.jpg -text ".jpg" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(jpg)
      pack $frm.extension.jpg -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers bmp
   if { $conf(extension,defaut) != ".bmp" } {
      checkbutton $frm.extension.bmp -text ".bmp" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(bmp)
      pack $frm.extension.bmp -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers gif
   if { $conf(extension,defaut) != ".gif" } {
      checkbutton $frm.extension.gif -text ".gif" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(gif)
      pack $frm.extension.gif -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers png
   if { $conf(extension,defaut) != ".png" } {
      checkbutton $frm.extension.png -text ".png" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(png)
      pack $frm.extension.png -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers tif
   if { ( $conf(extension,defaut) != ".tif" ) && ( $conf(extension,defaut) != ".tiff" ) } {
      checkbutton $frm.extension.tif -text ".tif .tiff" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(tif)
      pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".tif" } {
      checkbutton $frm.extension.tif -text ".tiff" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(tif)
      pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".tiff" } {
      checkbutton $frm.extension.tif -text ".tif" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(tif)
      pack $frm.extension.tif -anchor w -side top -padx 5 -pady 0
   }

   #--- fichiers avi
   if { ( $conf(extension,defaut) != ".avi" ) && ( $conf(extension,defaut) != ".mpeg" ) } {
      checkbutton $frm.extension.avi -text ".avi .mpeg" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".avi" } {
      checkbutton $frm.extension.avi -text ".mpeg" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   } elseif { $conf(extension,defaut) == ".mpeg" } {
      checkbutton $frm.extension.avi -text ".avi" \
          -highlightthickness 0 -variable ::visio2::config::widgetEnableExtension(avi)
      pack $frm.extension.avi -anchor w -side top -padx 5 -pady 0
   }

   if { [package versions Img ]== "" } {
      #--- je decoche les checkbox
      set ::visio2::config::widgetEnableExtension(bmp) 0
      set ::visio2::config::widgetEnableExtension(jpg) 0
      set ::visio2::config::widgetEnableExtension(png) 0
      set ::visio2::config::widgetEnableExtension(tif) 0
      #--- je desactive les checkbox pour qu'on ne puisse pas les cocher
      $frm.extension.bmp configure -state disabled
      $frm.extension.jpg configure -state disabled
      $frm.extension.png configure -state disabled
      $frm.extension.tif configure -state disabled
   }

   #--- pas de film si on est sous Linux ou si le package tmci n'est pas present
   if { $::tcl_platform(os) == "Linux" && [package versions tmci ]== "" } {
      #--- je decoche la checkbox
      set ::visio2::config::widgetEnableExtension(avi) 0
      #--- je desactive la checkbox pour qu'on ne puisse pas la cocher
      $frm.extension.avi configure -state disabled
   }

  ### #--- remarque
  ### label $frm.extension.remark -text "$caption(visio2,remark)" \
  ###    -justify left
  ### pack $frm.extension.remark -anchor w -side top -padx 5 -pady 0

   #--- remarque
   label $frm.extension.remark -text "$caption(visio2,remark1)" \
      -justify left
   pack $frm.extension.remark -anchor w -side top -padx 5 -pady 0

   #--- frame des options
   frame $frm.display -borderwidth 1 -relief ridge
   pack $frm.display -side top -fill both -expand 1

   #--- afficher tous les fichiers
   checkbutton $frm.display.show_all_afiles -text $caption(visio2,show_all_files) \
       -highlightthickness 0 -variable ::visio2::config::widget(show_all_files)
   pack $frm.display.show_all_afiles -anchor w -side top -padx 5 -pady 0
}

################################################################
# namespace localTable
#    gere la table des fichiers du disque local
################################################################
namespace eval ::visio2::localTable {
}

#------------------------------------------------------------------------------
# localTable::init
#   affiche les fichiers dans la table
#------------------------------------------------------------------------------
proc ::visio2::localTable::init { visuNo mainframe directory } {
   variable private

   #--- local captions
   set private(parentFolder) $::visio2::private(parentFolder)
   set private(folder)       $::visio2::private(folder)
   set private(fileImage)    $::visio2::private(fileImage)
   set private(fileMovie)    $::visio2::private(fileMovie)
   set private(file)         $::visio2::private(file)
   set private(volume)       $::visio2::private(volume)

   set private($visuNo,localtbl)             ""
   set private($visuNo,directory)            ""
   set private($visuNo,previousType)         ""
   set private($visuNo,previousFileNameType) ""
   set private($visuNo,currentItemIndex)     "0"
   set private($visuNo,slideShowState)       "0"
   set private($visuNo,slideShowAfterId)     ""
   set private($visuNo,slideShowDelay)       "1"
   set private($visuNo,animation)            "0"
   set private($visuNo,directory)            "$directory"
   set private($visuNo,genericName)          "image"
   set private($visuNo,newFileName)          ""
   set private($visuNo,firstIndex)           "1"
   set private($visuNo,copy)                 "0"
   set private($visuNo,overwrite)            "0"
   set private($visuNo,itemList)             ""

   fillTable $visuNo
}

#------------------------------------------------------------------------------
# localTable::getDirectory
#   retourne le reperoire courant
#------------------------------------------------------------------------------
proc ::visio2::localTable::getDirectory { visuNo } {
   variable private

   return "$private($visuNo,directory)"
}

#------------------------------------------------------------------------------
# localTable::fillTable
#   affiche les fichiers et sous repertoires dans la table
#   et affiche le nom du repertoire courant dans le titre de la fenetre principale
#------------------------------------------------------------------------------
proc ::visio2::localTable::fillTable { visuNo } {
   variable private

   #--- j'affiche les fichiers dans la table
   ::visio2::fillTable $visuNo  $private($visuNo,tbl) [::visio2::getFileList $visuNo $private($visuNo,directory)]

   #--- je trie la table
   set sortorder "-[$private($visuNo,tbl) sortorder]"
   if { $sortorder == "-" } {
      #--- la premiere fois
      set sortorder "-increasing"
   }
   $private($visuNo,tbl) sortbycolumn  $::visio2::private($visuNo,sortedColumn) $sortorder
   #--- j'affiche le nom du repertoire courant
   configureLabelDirectory $visuNo $private($visuNo,labelDirectory)
   #--- je place le focus sur le contenu de la table pour permettre les deplacements
   #--- avec les touches de direction du clavier
   focus [$private($visuNo,tbl) bodypath]
}

#------------------------------------------------------------------------------
# localTable::cmdButton1Click
#   charge l'item selectionne (appelle loadItem)
#------------------------------------------------------------------------------
proc ::visio2::localTable::cmdButton1Click { visuNo tbl } {
   variable private

   set selection [$tbl curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { "$selection" == "" } {
      return
   }
   if { $private($visuNo,slideShowState) == 1 } {
      #--- j'arrete le slideshow
      set private($visuNo,slideShowState) 0
   }
   #--- je charge l'item selectionne
   after idle [list ::visio2::localTable::loadItem $visuNo [lindex $selection 0 ] ]

}

#------------------------------------------------------------------------------
# localTable::cmdButton1DoubleClick
#
#------------------------------------------------------------------------------
proc ::visio2::localTable::cmdButton1DoubleClick { visuNo tbl } {
   variable private

   set selection [$tbl curselection]
   #--- retourne immediatemment si aucun item selectionne
   if { "$selection" == "" } {
      return
   }

   if { $private($visuNo,slideShowState) == 1 } {
      #--- j'arrete le slideshow
      set private($visuNo,slideShowState) 0
   }

   #--- je charge l'item selectionne (avec option double-clic)
   after idle [list ::visio2::localTable::loadItem $visuNo [lindex $selection 0 ] 1 ]

}

#------------------------------------------------------------------------------
# localTable::loadItem
#   si simple click :
#    si image : affiche l'image
#    si film  : charge le film et affiche la premiere image
#    si sous-repertoire : efface l'image affichee precedemment
#   sinon double click :
#    si image : affiche l'image
#    si film  : charge le film et affiche la premiere image
#    si sous-repertoire : va dans le repertoire et affiche le contenu (appelle fillTable)
#------------------------------------------------------------------------------
proc ::visio2::localTable::loadItem { visuNo index { doubleClick 0 } } {
   variable private
   global audace conf

   $private($visuNo,tbl) configure -cursor watch
   update

   set catchResult [ catch {
      set tbl $private($visuNo,tbl)
      if { $private($visuNo,animation) == 1 } {
         #--- j'arrete l'animation
         stopAnimation $visuNo
      }

      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      set filename [file join "$private($visuNo,directory)" "$name"]

      if { [string first "$private(fileImage)" "$type" ] != -1 } {
         #--- j'affiche l'image
         ::confVisu::loadIma $visuNo $filename
         if { $::tcl_platform(os) == "Linux" } {
            #--- Avec Linux, j'affiche le profil 1D avec spcaudace
            #--- Avec Windows, le profil 1D est affiche par confVisu
            #--- je recupere naxis1 de l'image qui vient d'etre chargee
            set mynaxis [ lindex [ buf[::confVisu::getBufNo $visuNo] getkwd "NAXIS" ] 1 ]
            if { $mynaxis == 1 } {
               #--- j'ouvre la fenetre de spcaudace
               ::confVisu::selectTool 1 ::spcaudace
               #--- j'affiche l'image 1D
               spc_load "$filename"
            }
         }

         if { [::Image::isAnimatedGIF "$filename"] == 1 } {
            setAnimationState $visuNo "1"
            if { $doubleClick == 1 } {
               startAnimation $visuNo
            }
         } else {
            setAnimationState $visuNo "0"
         }

      } elseif { "$type" == "$private(fileMovie)" } {
         #--- j'affiche la premiere image du film
         ::Image::loadmovie $visuNo $filename
         setAnimationState $visuNo "1"
         if { $doubleClick == 1 } {
            startAnimation $visuNo
         }

      } elseif { "$type" == "$private(folder)" || "$type" == "$private(volume)" } {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du sous repertoire
            set private($visuNo,directory) [ file join "$private($visuNo,directory)" "$name" ]
            fillTable $visuNo
         }
         setAnimationState $visuNo "0"
         set name ""

      } elseif { "$type" == "$private(parentFolder)"} {
         if { $doubleClick == 1 } {
            #--- j'affiche le contenu du repertoire parent
            if { "[file tail $private($visuNo,directory)]" != "" } {
               #--- si on n'est pas a la racine du disque, on monte d'un repertoire
               set private($visuNo,directory) [ file dirname "$private($visuNo,directory)" ]
               fillTable $visuNo
            } else {
               #--- si on est a la racine d'un disque, j'affiche la liste des disques
               ::visio2::fillVolumeTable $visuNo $private($visuNo,tbl)
            }
         }
         setAnimationState $visuNo "0"
         #--- je masque le nom pour que ".." n'apparaisse pas dans la barre de titre
         set name ""
      }

      #--- j'affiche le widget dans le canvas
      set private($visuNo,previousType)     "$type"
      set private($visuNo,previousFileName) "$filename"

      set private($visuNo,currentItemIndex) $index

   } ]
   if { $catchResult == 1 } {
      ::console::affiche_erreur "$::errorInfo\n"
   }

   $private($visuNo,tbl) configure -cursor arrow

}

#------------------------------------------------------------------------------
# localTable::refresh
#   recharge la liste des fichiers dans la table
#   et affiche une image si le parametre filename est renseigne
#------------------------------------------------------------------------------
proc ::visio2::localTable::refresh { visuNo { fileName "" } } {
   variable private

   set tbl $private($visuNo,tbl)
   #--- je memorise la position verticale courante de la fenetre
   set position [ lindex [$tbl yview ] 0]
   #--- je refraichis la liste des fichiers dans la table
   fillTable $visuNo

   #--- je memorise la position verticale courante de la fenetre
   $tbl yview moveto $position

   #--- j'affiche l'image
   set tbl $private($visuNo,tbl)
   if { "$fileName" != "" } {
      #--- je recupere les noms des fichiers presents
      set files [$tbl getcolumns 0]
      #--- je recherche l'index du fichier
      set index [lsearch -exact $files "$fileName"]
      if { $index != -1 } {
         #--- j'efface la selection courante
         $tbl selection clear 0 end
         #--- je selectione le fichier
         $tbl selection set [list $index]
         #--- je scrolle la table pour voir la ligne selectionnee
         $tbl see $index
         #--- je charge l'item
         loadItem $visuNo $index
      }
   }
}

#------------------------------------------------------------------------------
# localTable::selectAll
#   selectionne tous les fichiers dans la table
#------------------------------------------------------------------------------
proc ::visio2::localTable::selectAll { visuNo } {
   variable private

   $private($visuNo,tbl) selection set 0 end
}

#------------------------------------------------------------------------------
# localTable::renameFile
#   renomme un fichier ou une liste de fichiers
#
#------------------------------------------------------------------------------
proc ::visio2::localTable::renameFile { visuNo } {
   variable private
   global caption

   #--- j'arrete le diaporama
   set private($visuNo,slideShowState) "0"
   setSlideShow $visuNo
   #--- j'arrete l'animation
   stopAnimation $visuNo
   #--- je ferme le film
   ::Movie::close $visuNo

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]

   #--- je constitue la liste des noms des fichiers
   set fileList [list ]
   foreach index $selection {
      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]
      if { $type != "$private(folder)" } {
         lappend fileList $name
      }
   }

   #--- je retourne immediatemment si aucun item n'est selectionne
   if { [llength $fileList ] == 0 } {
      set message "$caption(visio2,select_file_error)"
      tk_messageBox -title "$caption(visio2,dialog_title)" -type ok -message "$message" -icon error
      return
   }

   #--- je copie les parametres  par defaut pour renameDialog
   ::visio2::renameDialog::setProperty $visuNo "fileList" $fileList
   ::visio2::renameDialog::setProperty $visuNo "genericName" $private($visuNo,genericName)
   ::visio2::renameDialog::setProperty $visuNo "newFileName" $private($visuNo,newFileName)
   ::visio2::renameDialog::setProperty $visuNo "firstIndex" $private($visuNo,firstIndex)
   ::visio2::renameDialog::setProperty $visuNo "destinationFolder" $private($visuNo,directory)
   ::visio2::renameDialog::setProperty $visuNo "overwrite" $private($visuNo,overwrite)
   ::visio2::renameDialog::setProperty $visuNo "copy" $private($visuNo,copy)

   #--- j'affiche la fenetre
   set result [::visio2::renameDialog::run $visuNo ]
   if { $result == 1 } {
      #--- je recupere les nouvelles valeurs des parametres
      set private($visuNo,genericName) [::visio2::renameDialog::getProperty $visuNo "genericName"]
      set private($visuNo,newFileName) [::visio2::renameDialog::getProperty $visuNo "newFileName"]
      set private($visuNo,firstIndex) [::visio2::renameDialog::getProperty $visuNo "firstIndex"]
      set destinationFolder [::visio2::renameDialog::getProperty $visuNo "destinationFolder"]
      set private($visuNo,copy) [::visio2::renameDialog::getProperty $visuNo "copy"]
      set private($visuNo,overwrite) [::visio2::renameDialog::getProperty $visuNo "overwrite"]
      #--- je verifie que le repertoire desitnation existe
      if { [file exists $destinationFolder] == "0" } {
         tk_messageBox -title "$caption(visio2,dialog_title) (visu$visuNo)" -type ok -icon error \
            -message "$caption(visio2,show_directory) \n$destinationFolder"
         return
      }
      #--- je copie l'index dans la varable a incrementer
      set fileIndex $private($visuNo,firstIndex)
      set confirm "1"
      foreach name $fileList {
         set filename [file join "$private($visuNo,directory)" "$name"]
         if { [llength $fileList] > 1 } {
            set newFileName "$private($visuNo,genericName)$fileIndex[file extension $filename]"
         } else {
            #--- s'il n'y a qu'un fichier, je n'insere pas l'index dans le nom
            set newFileName "$private($visuNo,newFileName)[file extension $filename]"
         }

         if { $private($visuNo,overwrite) == "0" && [file exists $newFileName]== "1" } {
            tk_messageBox -title "$caption(visio2,dialog_title) (visu$visuNo)" -type ok -icon error \
               -message "$caption(visio2,dialog_title) \n$newFileName "
            break
         }
         if { $confirm == 1 } {
            set choice [tk_dialog .renamefile \
                  "$caption(visio2,dialog_title) (visu$visuNo)" \
                  "$caption(visio2,rename_file_confirm) \n$name ==> $newFileName" \
                  question 3 "  $caption(visio2,delete_button0)  " $caption(visio2,delete_button1) "  $caption(visio2,delete_button2)  " $caption(visio2,delete_button3)]
         } else {
            set choice 0
         }

         if { $choice == 0 || $choice == 1} {
            #--- je renomme le fichier
            if { $private($visuNo,copy) == 1 } {
               file copy -force "$filename" "$destinationFolder/$newFileName"
            } else {
               file rename -force "$filename" "$destinationFolder/$newFileName"
            }
            #--- j'incremente l'index
            incr fileIndex
         } elseif { $choice == 2 } {
            #--- non => je ne renomme pas le fichier
         } elseif { $choice == 3 } {
            #--- abandonner
            break
         }
         if { $choice == 1 } {
            #--- OK pour tous => je ne demanderai plus de confirmation pour supprimer chaque fichier
            set confirm 0
         }
      }

      #--- je refraichis la table
      ::visio2::localTable::refresh $visuNo
   }
}

#------------------------------------------------------------------------------
# localTable::deleteFile
#   supprime le(s) fichier(s) selectionne(s)
#------------------------------------------------------------------------------
proc ::visio2::localTable::deleteFile { visuNo } {
   variable private
   global caption

   #--- j'arrete le diaporama
   set private($visuNo,slideShowState) "0"
   setSlideShow $visuNo
   #--- j'arrete l'animation
   stopAnimation $visuNo
   #--- je ferme le film
   ::Movie::close $visuNo

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]
   #--- je retourne immediatemment si aucun item n'est selectionne
   if { "$selection" == "" } {
      set message "$caption(visio2,select_file_error)"
      tk_messageBox -title "$caption(visio2,dialog_title) (visu$visuNo)" -type ok -message "$message" -icon error
      return
   }

   #--- par defaut, je demande une confirmation avant de supprimer chaque fichier
   set confirm 1

   foreach index $selection {
      set name [string trimleft [$tbl cellcget $index,0 -text]]
      set type [$tbl cellcget $index,1 -text]

      if { $type == "$private(folder)" } {
         set dir [ file join "$private($visuNo,directory)" "$name" ]
         set message "$caption(visio2,delete_dir_confirm) \n $dir"
         set choice [tk_messageBox -title "$caption(visio2,dialog_title) (visu$visuNo)" -type okcancel -message "$message" -icon question]

         if { $choice == "ok" } {
            #--- je supprime le repertoire
            file delete -force "$dir"
         }

      } elseif { "$type" == "$private(fileImage)" || "$type" == "$private(fileMovie)" || "$type" == "$private(file)"} {
         set filename [file join "$private($visuNo,directory)" "$name"]

         if { $confirm == 1 } {
            set choice [tk_dialog .deletefile \
               "$caption(visio2,dialog_title) (visu$visuNo)" \
               "$caption(visio2,delete_file_confirm) $name" \
               {} 3 $caption(visio2,delete_button0) $caption(visio2,delete_button1) $caption(visio2,delete_button2) $caption(visio2,delete_button3)]
         } else {
            set choice 0
         }

         if { $choice == 0 || $choice == 1} {
            #--- je ferme le fichier
            if { "$type" == "$private(fileMovie)" } {
               ::Movie::close $visuNo
            }
            #--- je supprime le fichier
            file delete "$filename"
            if { $choice == 1 } {
               #--- OK pour tous => je ne demanderai plus de confirmation pour supprimer chaque fichier
               set confirm 0
            }
         } elseif { $choice == 2 } {
            #--- non => je ne supprime pas le fichier
         } elseif { $choice == 3 } {
            #--- abandonner
            break
         }
      }
   }

   #--- je refraichis la table
   ::visio2::localTable::refresh $visuNo
}

#------------------------------------------------------------------------------
# localTable::toggleFullScreen
#   bascule l'affichages des images normal<=>plein ecran
#------------------------------------------------------------------------------
proc ::visio2::localTable::toggleFullScreen { visuNo } {
   variable private

   if { $::confVisu::private($visuNo,fullscreen) == "1" } {
      #--- je ferme les films
      ::Movie::close $visuNo

      #--- je recupere la selection courante
      set tbl $private($visuNo,tbl)
      set selection [$tbl curselection ]

      if { "$selection" == "" } {
         #--- je selectionne tout
         $tbl selection set 0 end
         set selection [$tbl curselection ]
         #--- raz de la selection
         $tbl selection clear 0 end
      }

      #--- je copie le nom et le type des fichiers
      set files ""
      foreach index $selection {
         set name [string trimleft [$tbl cellcget $index,0 -text]]
         set type [$tbl cellcget $index,1 -text]
         if { $type == $private(fileImage) || $type =="$private(fileMovie)" } {
            lappend files [list "$name" "$type"]
         }
      }
      #--- j'ouvre la fenetre plein ecran
      set ::confVisu::private($visuNo,fullscreen) "1"
      ::FullScreen::showFiles $visuNo $::confVisu::private($visuNo,hCanvas) $private($visuNo,directory) $files
   } else {
      ::FullScreen::cmdClose $visuNo
      #--- je re-affiche l'image ou le film
      cmdButton1Click $visuNo $private($visuNo,tbl)
   }
}

#------------------------------------------------------------------------------
# localTable::setAnimationState
#   active/desactive les boutons de commande de l'animation
#------------------------------------------------------------------------------
proc ::visio2::localTable::setAnimationState { visuNo state } {
   variable private
   global caption

   set menu $private($visuNo,popupmenu)
   #--- je configure le popup menu
   if { $state == 1 } {
      #--- j'active les commandes d'animation
      $menu entryconfigure $caption(visio2,play_movie) -state normal
   } else {
      #--- je desactive les commandes d'animation
      $menu entryconfigure $caption(visio2,play_movie) -state disabled
   }
}

#------------------------------------------------------------------------------
# localTable::toggleAnimation
#
#------------------------------------------------------------------------------
proc ::visio2::localTable::toggleAnimation { visuNo } {
   variable private

   if { $private($visuNo,animation) == 1 } {
      startAnimation $visuNo
   } else {
      stopAnimation $visuNo
   }
}

#------------------------------------------------------------------------------
# localTable::startAnimation
#   Lance une animation (film ou GIF anime)
#------------------------------------------------------------------------------
proc ::visio2::localTable::startAnimation { visuNo } {
   variable private

   #--- je recupere le nom du fichier selectionne
   set selection [$private($visuNo,tbl) curselection ]
   set index [lindex $selection 0 ]
   set name [string trimleft  [$private($visuNo,tbl) cellcget $index,0 -text]]
   set filename [file join "$private($visuNo,directory)" "$name"]
   if { "$private($visuNo,previousType)" == "$private(fileImage)" } {
      ::Image::startGifAnimation imagevisu[visu$visuNo image] $::confVisu::private($visuNo,zoom) $filename
   } elseif { "$private($visuNo,previousType)" == "$private(fileMovie)" } {
      ::Movie::start $visuNo
   }
   set private($visuNo,animation) 1
   update
}

#------------------------------------------------------------------------------
# localTable::stopAnimation
#   arrete une animation (film ou GIF anime)
#------------------------------------------------------------------------------
proc ::visio2::localTable::stopAnimation { visuNo } {
   variable private

   if { "$private($visuNo,previousType)" == "$private(fileImage)" } {
      ::Image::stopGifAnimation
   } elseif { "$private($visuNo,previousType)" == "$private(fileMovie)" } {
      ::Movie::stop $visuNo
   }
   set private($visuNo,animation) 0
   update
}

#------------------------------------------------------------------------------
# localTable::setSlideShow
#   lance/arrete le diaporama
#------------------------------------------------------------------------------
proc ::visio2::localTable::setSlideShow { visuNo } {
   variable private
   global caption

   if { $private($visuNo,slideShowState) == 1 } {
      #--- je recupere le nombre d'images selectionnees
      set selection [$private($visuNo,tbl) curselection ]
      #--- je verifie que le nombre d'images selectionnees est suffisant (>=2)
      if { [llength $selection] < 2 } {
         #--- erreur, il n'y a moins de 2 images selectionnees
        ### tk_messageBox -title "$caption(visio2,dialog_title)" -type ok -message "$caption(visio2,slideshow_error)" -icon error
         tk_dialog .tempdialog \
            "$caption(visio2,dialog_title)" \
            "$caption(visio2,slideshow_error)" \
            {} \
            0  \
            "OK"
         #--- j'abandonnne le SlideShow
         set private($visuNo,slideShowState) "0"
         return
      } else {
         #--- je lance le SlideShow
         set private($visuNo,slideShowListe) $selection
         set private($visuNo,slideShowAfterId) [after 10 ::visio2::localTable::showNextSlide $visuNo]
      }

   } else {
      set private($visuNo,slideShowState) "0"
      if { "$private($visuNo,slideShowAfterId)" != "" } {
         #--- je tue l'iteration en attente
         after cancel $private($visuNo,slideShowAfterId)
         set private($visuNo,slideShowAfterId) ""
      }
   }
}

#------------------------------------------------------------------------------
# localTable::showNextSlide
#   affiche l'image suivante du diaporama
#------------------------------------------------------------------------------
proc ::visio2::localTable::showNextSlide { visuNo { currentitem "0" } } {
   variable private

   #--- si une demande d'arret a deja ete faite, je sors de la boucle
   if { $private($visuNo,slideShowState) == 0 } {
      return

   }
   #--- je recupere les informations de l'item suivante
   set index [lindex $private($visuNo,slideShowListe) $currentitem ]

   loadItem $visuNo $index 1

   #--- j'incremente currentitem
   if { $currentitem < [expr [llength $private($visuNo,slideShowListe)] -1 ] } {
      incr currentitem
   } else {
      set currentitem "0"
   }

   #--- je lance l'iteration suivante
   if { $private($visuNo,slideShowState) == "1" } {
      set result [ catch { set delay [expr round($private($visuNo,slideShowDelay) * 1000) ] } ]
      if { $result != 0 } {
         #--- remplace le delai incorrect
         set delay "1000"
      }
      set private($visuNo,slideShowAfterId) [after $delay ::visio2::localTable::showNextSlide $visuNo $currentitem ]
   }
}

#------------------------------------------------------------------------------
# localTable::saveColumnWidth
#   sauve la largeur des colonnes dans conf()
#------------------------------------------------------------------------------
proc ::visio2::localTable::saveColumnWidth { visuNo } {
   variable private
   global conf

   #--- save columns width
   set conf(visio2,width_column_name)   [$private($visuNo,tbl) columncget 0 -width]
   set conf(visio2,width_column_type)   [$private($visuNo,tbl) columncget 1 -width]
   set conf(visio2,width_column_series) [$private($visuNo,tbl) columncget 2 -width]
   set conf(visio2,width_column_date)   [$private($visuNo,tbl) columncget 3 -width]
   set conf(visio2,width_column_size)   [$private($visuNo,tbl) columncget 4 -width]
}

#------------------------------------------------------------------------------
# localTable::createTbl
#   affiche la table avec ses scrollbars dans une frame
#   et cree le menu pop-up associe
#------------------------------------------------------------------------------
proc ::visio2::localTable::createTbl { visuNo frame } {
   global caption
   global conf
   variable private

   #--- quelques raccourcis utiles
   set tbl $frame.tbl
   set private($visuNo,tbl) "$tbl"
   set private($visuNo,labelDirectory) "$frame.directory"
   set menu $frame.menu
   set private($visuNo,popupmenu) "$menu"

   #--- repertoire
   label $frame.directory -anchor w -relief raised -bd 1
   #--- pour intercepter les mises a jour du label (equivalent a l'option -textvariable)
   bind $frame.directory <Configure> "::visio2::localTable::configureLabelDirectory $visuNo $frame.directory"

   #--- table des fichiers
   tablelist::tablelist $tbl \
      -columns [ list \
         20 $caption(visio2,column_name)   left  \
         10 $caption(visio2,column_type)   left  \
         10 $caption(visio2,column_series) left  \
         17 $caption(visio2,column_date)   left  \
         10 $caption(visio2,column_size)   right \
         ] \
      -labelcommand "::visio2::cmdSortColumn $visuNo" \
      -xscrollcommand [list $frame.hsb set] -yscrollcommand [list $frame.vsb set] \
      -selectmode extended \
      -exportselection 0 \
      -showarrow 1 \
      -activestyle none

   #--- je fixe la largeur des colonnes
   $tbl columnconfigure 0 -width $conf(visio2,width_column_name) -sortmode dictionary
   $tbl columnconfigure 1 -width $conf(visio2,width_column_type) -sortmode dictionary
   $tbl columnconfigure 2 -width $conf(visio2,width_column_series) -sortmode dictionary
   $tbl columnconfigure 3 -width $conf(visio2,width_column_date)   -sortmode dictionary
   $tbl columnconfigure 4 -width $conf(visio2,width_column_size)   -sortmode dictionary

   #--- j'affiche ou masque les colonnes (la premiere colonne est toujours visible)
   $tbl columnconfigure 0 -hide 0
   $tbl columnconfigure 1 -hide [expr !$conf(visio2,show_column_type) ]
   $tbl columnconfigure 2 -hide [expr !$conf(visio2,show_column_series) ]
   $tbl columnconfigure 3 -hide [expr !$conf(visio2,show_column_date) ]
   $tbl columnconfigure 4 -hide [expr !$conf(visio2,show_column_size) ]

   #--- choix de l'ordre aphabetique en fonction de l'OS ( pour ne pas depayser les habitues)
   if { $::tcl_platform(os) == "Linux" } {
      #--- je classe les fichiers par ordre alphabetique, en tenant compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode ascii
   } else {
      #--- je classe les fichiers par ordre alphabetique, sans tenir compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode dictionary
   }

   #--- j'adapte la largeur de la liste en fonction des colonnes affichees
   ::visio2::showColumn $visuNo $tbl 0

   #--- scrollbars verticale et horizontale
   scrollbar $frame.vsb -orient vertical   -command [list $tbl yview]
   scrollbar $frame.hsb -orient horizontal -command [list $tbl xview]

   #--- je place la liste et les scrollbar dans une grille
   grid $frame.directory -row 0 -column 0 -columnspan 2 -sticky ew
   grid $tbl -row 1 -column 0 -sticky nsew
   grid $frame.vsb -row 1 -column 1 -sticky ns
   grid $frame.hsb -row 2 -column 0 -sticky ew
   grid rowconfigure    $frame 1 -weight 1
   grid columnconfigure $frame 0 -weight 1

   #--- pop-up menu associe a la table
   menu $menu -tearoff no
   $menu add command -label $caption(visio2,refresh) \
      -command "::visio2::localTable::refresh $visuNo"
   $menu add command -label $caption(visio2,select_all) \
      -command "::visio2::localTable::selectAll $visuNo"
   $menu add command -label $caption(visio2,rename_file)  \
      -command "::visio2::localTable::renameFile $visuNo"
   $menu add command -label $caption(visio2,delete_file) \
      -command "::visio2::localTable::deleteFile $visuNo"

   $menu add separator
   $menu add checkbutton -label $caption(visio2,column_type)   \
      -variable conf(visio2,show_column_type)       \
      -command "::visio2::showColumn $visuNo $::visio2::localTable::private($visuNo,tbl) 1"
   $menu add checkbutton -label $caption(visio2,column_series) \
      -variable conf(visio2,show_column_series)     \
      -command "::visio2::showColumn $visuNo $::visio2::localTable::private($visuNo,tbl) 2"
   $menu add checkbutton -label $caption(visio2,column_date)   \
      -variable conf(visio2,show_column_date)       \
      -command "::visio2::showColumn $visuNo $::visio2::localTable::private($visuNo,tbl) 3"
   $menu add checkbutton -label $caption(visio2,column_size)   \
      -variable conf(visio2,show_column_size)       \
      -command "::visio2::showColumn $visuNo $::visio2::localTable::private($visuNo,tbl) 4"

   $menu add separator

   $menu add checkbutton -label $caption(visio2,full_screen) \
      -variable ::confVisu::private($visuNo,fullscreen) \
      -command "::visio2::localTable::toggleFullScreen $visuNo"

   $menu add command -label $caption(visio2,config) -command "::visio2::configure $visuNo"

   $menu add separator
   $menu add checkbutton -label $caption(visio2,play_movie) \
      -variable ::visio2::localTable::private($visuNo,animation) \
      -command "::visio2::localTable::toggleAnimation $visuNo"

   bind [$tbl bodypath] <<Button3>> [list tk_popup $menu %X %Y]

   bind $tbl <<ListboxSelect>>      [list ::visio2::localTable::cmdButton1Click $visuNo $tbl]
   bind [$tbl bodypath] <Double-1>  [list ::visio2::localTable::cmdButton1DoubleClick $visuNo $tbl]
   bind [$tbl bodypath] <Return>    [list ::visio2::localTable::cmdButton1DoubleClick $visuNo $tbl]

}

#------------------------------------------------------------------------------
# localTable::configureLabelDirectory
#   affiche private($visuNo,directory) dans le label
#     si le label a une taille suffisante, affiche private($visuNo,directory) en entier
#     si le label a une taille insuffisante, affiche la fin de private($visuNo,directory)
#------------------------------------------------------------------------------
proc ::visio2::localTable::configureLabelDirectory { visuNo label } {
   variable private

   set tt "$private($visuNo,directory)"
   set labelwidth [expr [winfo width $label]-5]
   if { [font measure [$label cget -font] $tt] <= $labelwidth } {
      #--- affiche private($visuNo,directory) en entier
      $label configure -text $tt
   } else {
      while { [string length $tt] > 3 } {
         set tt [string range $tt 1 end]
         if { [font measure [$label cget -font] ...$tt] <= $labelwidth } {
            break
         }
      }
      #--- affiche "..." suivi de la fin de private($visuNo,directory)
      $label configure -text .$tt
   }
}

################################################################
# namespace ::visio2::ftpTable
#    gere la table des fichiers du serveur FTP
################################################################
namespace eval ::visio2::ftpTable {
}

#------------------------------------------------------------------------------
# ftpTable::init
#   affiche les fichiers dans la table
#   retourne 1 si la connexion a reussi, sinon retourne 0
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::init { visuNo mainframe } {
   variable private
   global caption

   set private($visuNo,frame) "$mainframe.ftplist"

      #--- j'affiche la fenetre de selection d'un connexion ftp
      set result [::ftpclient::selectConnection $visuNo ]

      if { $result == 1 } {
         set private($visuNo,directory) "[::ftpclient::getDirectory]"
         #--- si la connection a reussi, j'affiche la liste des fichiers
         if { [ fillTable $visuNo "$private($visuNo,directory)" ] != 1 } {
            set message "$caption(visio2,show_directory) $private($visuNo,directory)"
            console::affiche_erreur "$message \n"
            tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
            set result 0
         } else {
            #--- j'affiche la table
            pack $mainframe.ftplist -fill both -expand 1 -anchor n -side bottom
            update
            configureLabelDirectory $visuNo $private($visuNo,labelDirectory) "$private($visuNo,directory)"
            set result 1
         }
      } elseif { $result == 0 } {
         #--- si la connexion a echoue, j'affiche un message d'erreur
         #set message "$caption(visio2,ftp_connection_error) [::ftpclient::getUrl]"
         #console::affiche_erreur "$message \n"
         #tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
         set result 0
      } else {
         #--- je decoche le checkbutton
         set result 0
      }
   return $result
}

#------------------------------------------------------------------------------
# ftpTable::close
#   ferme la connexion ftp
#   et supprime la table de l'affichage
#   retourne 1 si la fermeture est faite, sinon retourne 0
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::close { visuNo } {
   variable private
   global caption

   #--- ferme la connexion et supprime la table ftpTable
   if { "[::ftpclient::isOpened]" == "0" } {
      #--- s'il n'y a pas de connexion en cours
      #--- il suffit de masquer la table ftp
      pack forget $private($visuNo,frame)
      set result 1
   } else {
      #--- si une connexion est en cours
      #--- je demande d'abord la confirmation de la fermeture
      set message "$caption(visio2,ftp_connection_close) [::ftpclient::getUrl]"
      set choice [tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type okcancel -message "$message" -icon question ]
      if { $choice == "ok" } {
         #--- je ferme la connexion FTP en cours
         ::ftpclient::closeCnx
         #--- je masque la table ftp
         pack forget $private($visuNo,frame)
         set result 1
      } else {
         #--- refus de l'utilisateur
         set result 0
      }
   }
   return $result
}

#------------------------------------------------------------------------------
# ftpTable::fillTable
#   affiche les fichiers dans la table
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::fillTable { visuNo directory } {
   global conf
   variable private

   set result 0
   #--- je recupere la liste des fichiers du serveur distant
   set files  [::ftpclient::getFileList "$directory" ]

   if { $files != "" } {
      set private($visuNo,directory) "$directory"
      #--- j'affiche les noms des fichiers dans la table
      ::visio2::fillTable $visuNo $private($visuNo,tbl) $files
      #--- je place le focus sur le contenu de la table pour permettre les deplacements avec les touches de direction du clavier
      focus [$private($visuNo,tbl) bodypath]
      set result 1
   }
   return $result
}

#------------------------------------------------------------------------------
# ftpTable::refresh
#   recharge la liste des fichiers dans la table
#   et affiche une image si le parametre filename est renseigne
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::refresh { visuNo { fileName "" } } {
   variable private

   set tbl $private($visuNo,tbl)
   if { "$private($visuNo,frame)" == "" } {
      #--- rien a faire si la table n'est pas affichee
      return
   }

   if { [winfo manager $private($visuNo,frame)] == "" } {
      #--- rien a faire si la table n'est pas affichee
      return
   }
   #--- je refraichis la liste des fichiers dans la table
   fillTable $visuNo "$private($visuNo,directory)"

   #--- j'affiche l'image
   if { "$fileName" != "" } {
      #--- je recupere les noms des fichiers presents
      set files [$tbl getcolumns 0]
      #--- je recherche l'index du fichier
      set index [lsearch -exact $files "$fileName"]
      if { $index != -1 } {
         #--- j'efface la selection courante
         $tbl selection clear 0 end
         #--- je selection le fichier
         $tbl selection set [list $index]
         #--- je scrolle la table pour voir la ligne selectionnee
         $tbl see $index
         #--- j'affiche le fichier
         cmdButton1Click $visuNo
      }
   }
}

#------------------------------------------------------------------------------
# ftpTable::cmdButton1Click
#   simple click sur le bouton 1
#     n'est pas utilise pour l'instant
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::cmdButton1Click { visuNo } {
   variable private

   return
}

#------------------------------------------------------------------------------
# ftpTable::cmdButton1DoubleClick
#   Double click sur le bouton 1
#     si image : copie l'image dans le repertoire local courant (appelle ::ftpclient::get)
#     si film  : copie le film dans le repertoire local courant (appelle ::ftpclient::get)
#     si sous-repertoire : va dans le repertoire et affiche le contenu (appelle fillTable)
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::cmdButton1DoubleClick { visuNo } {
   variable private
   global caption

   set tbl $private($visuNo,tbl)
   set selection [$tbl curselection]
   if { "$selection" == "" } {
      return
   }

   #--- j'extrait l'index, le nom et le type contenus dans la ligne selectionnee
   set index [lindex $selection 0 ]
   set name [string trimleft  [$tbl cellcget $index,0 -text]]
   set type [$tbl cellcget $index,1 -text]
   set size [$tbl cellcget $index,4 -text]

   if { $type == "$private(parentFolder)" } {
      #--- j'affiche le contenu du repertoire parent
      set directory [ file dirname "$private($visuNo,directory)" ]
      if { [ fillTable $visuNo "$directory" ] != 1 } {
         set message "$caption(visio2,show_directory) $directory"
         console::affiche_erreur "$message \n"
         tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
      }

   } elseif { $type == "$private(folder)" } {
      #--- j'affiche le contenu du sous-repertoire
      set directory [ file join "$private($visuNo,directory)" "$name" ]
      if { [ fillTable $visuNo "$directory" ] != 1 } {
         set message "$caption(visio2,show_directory) $directory"
         console::affiche_erreur "$message \n"
         tk_messageBox -title "$caption(visio2,ftp_connection_title)" -type ok -message "$message" -icon error
      }

   } elseif { "$type" == "$private(fileImage)" || "$type" == "$private(fileMovie)" ||  "$type" == "$private(file)" } {
      #--- copie le fichier du serveur distant vers le repertoire local et affiche l'image
      set targetDir "[::visio2::localTable::getDirectory $visuNo]"
      if { [ file exists [file join "$targetDir" "$name"] ] } {
         #--- demande de confirmation d'ecrasement du fichier existant
         set choice [tk_messageBox -message "$caption(visio2,confirm_overwrite)" -title "$caption(visio2,dialog_title)" -icon question -type yesno]
         if {$choice=="no"} {
            return
         }
      }

      #--- je copie le fichier
      set filename [file join "$private($visuNo,directory)" "$name"]
      ::ftpclient::get "$filename" "$targetDir" "$size"

      #--- je refraichis l'affichage de la table locale pour faire apparaitre
      #--- les fichiers copies sur le disque local et affiche l'image
      ::visio2::localTable::refresh $visuNo "$name"
   }
}

#------------------------------------------------------------------------------
# ftpTable::createTbl
#   cree la table et les scrollbar dans une frame
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::createTbl { visuNo frame } {
   global caption
   global conf
   variable private

   set private(parentFolder)      $::visio2::private(parentFolder)
   set private(folder)            $::visio2::private(folder)
   set private(fileImage)         $::visio2::private(fileImage)
   set private(fileMovie)         $::visio2::private(fileMovie)
   set private(file)              $::visio2::private(file)
   set private($visuNo,tbl)       ""
   set private($visuNo,directory) "/"
   set private($visuNo,frame)     ""

   #--- quelques raccourcis utiles
   set tbl $frame.tbl
   set private($visuNo,tbl) "$tbl"
   set private($visuNo,labelDirectory) "$frame.directory"

   #--- repertoire
   label $frame.directory -anchor w -relief raised -bd 1
   #--- pour intercepter les mises a jour du label (equivalent a l'option -textvariable)
   bind $frame.directory <Configure> "::visio2::ftpTable::configureLabelDirectory $visuNo $::visio2::ftpTable::private($visuNo,labelDirectory) $::visio2::ftpTable::private($visuNo,directory) "

   #--- table des fichiers
   tablelist::tablelist $tbl \
      -columns [ list \
         12 $caption(visio2,column_name)   left  \
         10 $caption(visio2,column_type)   left  \
         10 $caption(visio2,column_series) left  \
         17 $caption(visio2,column_date)   left  \
         10 $caption(visio2,column_size)   right \
         ] \
      -labelcommand "::visio2::cmdSortColumn $visuNo" \
      -xscrollcommand [list $frame.hsb set] -yscrollcommand [list $frame.vsb set] \
      -selectmode extended \
      -exportselection 0 \
      -activestyle none

   #--- je fixe la largeur des colonnes
   $tbl columnconfigure 0 -width $conf(visio2,width_column_name)  -sortmode dictionary
   $tbl columnconfigure 1 -width $conf(visio2,width_column_type)  -sortmode dictionary
   $tbl columnconfigure 2 -width $conf(visio2,width_column_series) -sortmode dictionary
   $tbl columnconfigure 3 -width $conf(visio2,width_column_date)  -sortmode dictionary
   $tbl columnconfigure 4 -width $conf(visio2,width_column_size)  -sortmode dictionary

   #--- j'affiche ou masque les colonnes (la premiere colonne est toujours visible)
   $tbl columnconfigure 0 -hide 0
   $tbl columnconfigure 1 -hide [expr !$conf(visio2,show_column_type) ]
   $tbl columnconfigure 2 -hide [expr !$conf(visio2,show_column_series) ]
   $tbl columnconfigure 3 -hide [expr !$conf(visio2,show_column_date) ]
   $tbl columnconfigure 4 -hide [expr !$conf(visio2,show_column_size) ]

   #--- j'adapte la largeur de la liste en fonction des colonnes affichees
   ::visio2::showColumn $visuNo $tbl 0

   #--- choix de l'ordre aphabetique en fonction de l'OS pour ne pas depayser les habitues
   if { $::tcl_platform(os) == "Linux" } {
      #--- je classe les fichiers par ordre alphabetique, en tenant compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode ascii
   } else {
      #--- je classe les fichiers par ordre alphabetique, sans tenir compte des majuscules/minuscules
      $tbl columnconfigure 0 -sortmode dictionary
   }

   #--- scrollbar verticale et horizontale
   scrollbar $frame.vsb -orient vertical   -command [list $tbl yview]
   scrollbar $frame.hsb -orient horizontal -command [list $tbl xview]

   #--- je place la liste et les scrollbar dans une grille
   grid $frame.directory -row 0 -column 0 -columnspan 2 -sticky ew
   grid $tbl -row 1 -column 0 -sticky ns
   grid $frame.vsb -row 1 -column 1 -sticky ns
   grid $frame.hsb -row 2 -column 0 -sticky ew
   grid rowconfigure    $frame 1 -weight 1
   grid columnconfigure $frame 0 -weight 1

   #--- pop-up menu for the tablelist
   set menu $frame.menu
    menu $menu -tearoff no
   $menu add command -label $caption(visio2,get_file) \
      -command "::visio2::ftpTable::cmdButton1DoubleClick $visuNo"

   bind [$tbl bodypath] <<Button3>> [list tk_popup $menu %X %Y]

   bind $tbl <<ListboxSelect>>      [list ::visio2::ftpTable::cmdButton1Click $visuNo ]
   bind [$tbl bodypath] <Double-1>  [list ::visio2::ftpTable::cmdButton1DoubleClick $visuNo ]
   bind [$tbl bodypath] <Return>    [list ::visio2::ftpTable::cmdButton1DoubleClick $visuNo ]
}

#------------------------------------------------------------------------------
# ftpTable::configureLabelDirectory
#   affiche private($visuNo,directory) dans le label
#   si le label a une taille suffisante, affiche private($visuNo,directory) en entier
#   si le label a une taille insuffisante, affiche la fin de private($visuNo,directory)
#------------------------------------------------------------------------------
proc ::visio2::ftpTable::configureLabelDirectory { visuNo label directory} {
   variable private

   set tt "$directory"
   set labelwidth [expr [winfo width $label]-5]
   if { [font measure [$label cget -font] $tt] <= $labelwidth } {
      #--- affiche en entier
      $label configure -text $tt
   } else {
      while { [string length $tt] > 3 } {
        set tt [string range $tt 1 end]
         if { [font measure [$label cget -font] ...$tt] <= $labelwidth } {
            break
         }
      }
      #--- affiche "..." suivi de la fin de directory
      $label configure -text ...$tt
   }
}

#------------------------------------------------------------
# ========== Namespace de la fenetre de renommage des fichiers ========
#
# cette fenetre est modale
# A la fermeture, sa procedure run retourne les valeurs
#   { genericName firstIndex }
#------------------------------------------------------------

namespace eval ::visio2::renameDialog {
}

#------------------------------------------------------------
# config::run
#   affiche la fenetre de renommage
#------------------------------------------------------------
proc ::visio2::renameDialog::run { visuNo } {
   variable private

   set private($visuNo,toplevel) "[confVisu::getBase $visuNo].renameDialog"
   if { [info exists private($visuNo,geometry)] == 0 } {
      set private($visuNo,geometry) "+150+80"
   }

   #--- j'affiche la fenetre de configuration
   if { [winfo exists $private($visuNo,toplevel)] == 0 } {
      set result [::confGenerique::run $visuNo $private($visuNo,toplevel) "::visio2::renameDialog" \
         -modal 1 -resizable 1 -geometry $private($visuNo,geometry)]
   } else {
      focus $private($visuNo,toplevel)
      set result "0"
   }
   return $result
}

#------------------------------------------------------------
# ::visio2::renameDialog::cmdApply
#   copie les valeurs saisies da
#------------------------------------------------------------
proc ::visio2::renameDialog::cmdApply { visuNo } {
   variable private

}

#------------------------------------------------------------
# ::visio2::renameDialog::cmdClose
#   ferme la fenetre de configuration
#------------------------------------------------------------
proc ::visio2::renameDialog::cmdClose { visuNo } {
   variable private

   #--- j'enregistre la position et la dimension de la fenetre de configuration
   set private($visuNo,geometry) [ wm geometry $private($visuNo,toplevel)]
}

#------------------------------------------------------------
# ::visio2::renameDialog::getLabel
#   retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::visio2::renameDialog::getLabel { } {
   return "[::visio2::getPluginTitle]"
}

#------------------------------------------------------------
# ::visio2::renameDialog::fillConfigPage { }
#   fenetre de configuration de la camera
#   return rien
#------------------------------------------------------------
proc ::visio2::renameDialog::fillConfigPage { frm visuNo } {
   variable private
   global caption

   set private($visuNo,This) $frm

   if { [llength $private($visuNo,fileList)] >  1 } {
      TitleFrame $frm.renameFile -borderwidth 2 -relief ridge -text "$caption(visio2,renameFile)"
         listbox $frm.renameFile.list -state normal -height 4 -state disabled \
            -listvariable ::visio2::renameDialog::private($visuNo,fileList) \
            -xscrollcommand [list $frm.renameFile.hsb set] \
            -yscrollcommand [list $frm.renameFile.vsb set]
         #--- scrollbars verticale et horizontale
         scrollbar $frm.renameFile.vsb -orient vertical   -command [list $frm.renameFile.list yview]
         scrollbar $frm.renameFile.hsb -orient horizontal -command [list $frm.renameFile.list xview]

         grid $frm.renameFile.list -in [$frm.renameFile getframe] -row 0 -column 0 -sticky nsew
         grid $frm.renameFile.vsb  -in [$frm.renameFile getframe] -row 0 -column 1 -sticky ns
         grid $frm.renameFile.hsb  -in [$frm.renameFile getframe] -row 1 -column 0 -sticky ew
         grid rowconfigure    [$frm.renameFile getframe] 0 -weight 1
         grid columnconfigure [$frm.renameFile getframe] 0 -weight 1
      pack $frm.renameFile -anchor w -side top -fill both -expand 1

      LabelEntry $frm.genericName -label "$caption(visio2,genericName)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::visio2::renameDialog::private($visuNo,genericName)
      pack $frm.genericName -side top -anchor w -padx 10 -pady 2 -fill x -expand 0

      LabelEntry $frm.firstIndex -label "$caption(visio2,firstIndex)" \
         -labeljustify left -justify right -labelwidth 12 -width 6 \
         -textvariable ::visio2::renameDialog::private($visuNo,firstIndex)
      pack $frm.firstIndex -side top -anchor w -padx 10 -pady 2 -fill none -expand 0
   } else {
      TitleFrame $frm.renameFile -borderwidth 2 -relief ridge -text "$caption(visio2,renameFile)"
         listbox $frm.renameFile.list -state normal -height 1 -state disabled \
            -listvariable ::visio2::renameDialog::private($visuNo,fileList)
         pack $frm.renameFile.list -in [$frm.renameFile getframe] -side top -anchor w -padx 10 -pady 5 -fill x -expand 0
      pack $frm.renameFile -anchor w -side top -fill x -expand 0

      LabelEntry $frm.newName -label "$caption(visio2,newName)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::visio2::renameDialog::private($visuNo,newFileName)
      pack $frm.newName -side top -anchor w -padx 10 -pady 2 -fill x -expand 0
   }

   frame $frm.destination -borderwidth 1 -relief flat
      LabelEntry $frm.destination.folder -label "$caption(visio2,destinationFolder)" \
         -labeljustify left -justify left -labelwidth 12 \
         -textvariable ::visio2::renameDialog::private($visuNo,destinationFolder)
      pack $frm.destination.folder -side left -anchor w -padx 10 -pady 2 -fill x -expand 1
      button $frm.destination.explore -text "  ...  " -width 1 \
                  -command "::visio2::renameDialog::explore $visuNo"
      pack $frm.destination.explore -side left -anchor w -padx 4 -pady 2 -fill none -expand 0
   pack $frm.destination -side top -anchor w -pady 2 -fill x -expand 0

   checkbutton $frm.copy -text "$caption(visio2,copyFile)" \
         -variable ::visio2::renameDialog::private($visuNo,copy)
   pack $frm.copy -side top -anchor w -padx 10 -pady 2 -fill none -expand 0

   checkbutton $frm.overwrite -text "$caption(visio2,overwrite)" \
         -variable ::visio2::renameDialog::private($visuNo,overwrite)
   pack $frm.overwrite -side top -anchor w -padx 10 -pady 2 -fill none -expand 0

}

#------------------------------------------------------------
# ::visio2::renameDialog::getProperty
#   exploration de repertoire
#------------------------------------------------------------
proc ::visio2::renameDialog::explore { visuNo } {
   variable private

   set directory [ tk_chooseDirectory -title "[::visio2::getPluginTitle] $::caption(visio2,destinationFolder)" \
      -initialdir $private($visuNo,destinationFolder) -parent $private($visuNo,toplevel) ]

   if { $directory != "" } {
      set private($visuNo,destinationFolder) $directory
   }
}

#------------------------------------------------------------
# ::visio2::renameDialog::getProperty
#   retourne la valeur d'une propriete
#------------------------------------------------------------
proc ::visio2::renameDialog::getProperty { visuNo propertyName } {
   variable private

   return $private($visuNo,$propertyName)
}

#------------------------------------------------------------
# ::visio2::renameDialog::setProperty
#
#------------------------------------------------------------
proc ::visio2::renameDialog::setProperty { visuNo propertyName value } {
   variable private

   set private($visuNo,$propertyName) $value
}

#--- commande pour lancer un serveur FTP local
#ftpserver::start

