#
# Fichier : updateaudela.tcl
# Description : Outil de fabrication des fichiers Kit et de deploiement des plugins
# Auteur : Michel Pujol
# Mise a jour $Id: updateaudela.tcl 14263 2017-09-23 09:04:57Z robertdelmas $
#

namespace eval ::updateaudela {
   package provide updateaudela 1.5

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] updateaudela.cap ]
}

#------------------------------------------------------------
#  ::updateaudela::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::updateaudela::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "setup" }
      subfunction1 { return "update" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
#  ::updateaudela::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::updateaudela::getPluginTitle { } {
   global caption

   return "$caption(updateaudela,title)"
}

#------------------------------------------------------------
#  ::updateaudela::getPluginHelp
#     retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::updateaudela::getPluginHelp { } {
   return "updateaudela.htm"
}

#------------------------------------------------------------
#  ::updateaudela::getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::updateaudela::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  ::updateaudela::getPluginDirectory
#     retourne le repertoire du plugin
#------------------------------------------------------------
proc ::updateaudela::getPluginDirectory { } {
   return "updateaudela"
}

#------------------------------------------------------------
#  ::updateaudela::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::updateaudela::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#------------------------------------------------------------
proc ::updateaudela::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
#  ::updateaudela::createPluginInstance
#     cree une instance l'outil
#
#------------------------------------------------------------
proc ::updateaudela::createPluginInstance { base { visuNo 1 } } {
   global conf
   global audace
   variable private

   package require Tkhtml 3.0
   package require http
   package require uri

   package require BWidget
   package require Tablelist

   package require starkit
   starkit::startup

   #--- Creation des variables si elles n'existaient pas
   if { ! [ info exists conf(updateaudela,geometry) ] }          { set conf(updateaudela,geometry)           "520x420+140+60" }
   if { ! [ info exists conf(updateaudela,kitDirectory) ] }      { set conf(updateaudela,kitDirectory)       "$::audace(rep_install)" }
   if { ! [ info exists conf(updateaudela,downloadAndInstall ] } { set conf(updateaudela,downloadAndInstall) "1" }
   if { ! [ info exists conf(updateaudela,addressList) ] }       { set conf(updateaudela,addressList)        [list "http://www.audela.org/test2.php" "http://pagesperso-orange.fr/michel.pujol/audela/" "http://spcaudace.free.fr/"] }

   set private(base)            $base
   set private(kitDirectory)    "$::audace(rep_install)"
   set private(pluginDirectory) "$::audace(rep_plugin)"

   set private(this) "$private(base).updateaudela"

   ::confGenerique::run $visuNo $private(this) [namespace current] -modal 0 -geometry $::conf(updateaudela,geometry)

   return $private(this)
}

#------------------------------------------------------------
#  ::updateaudela::deleteKit
#  supprime un kit
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::deleteKit { kitFileName } {
   variable private

   set kitFileFullName [file join $private(kitDirectory) $kitFileName]
   file delete -force $kitFileFullName
}

#------------------------------------------------------------
#  ::updateaudela::deletePlugin
#  supprime un plugin
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::deletePlugin { pluginName pluginType } {
   variable private

   set pluginDirectory [getTypeDirectory $pluginType $pluginName]
   set pkgIndexFileName [file join $pluginDirectory pkgIndex.tcl]

   #--- je supprime le plugin des menus si pluginInfo(type) == "tool"
   if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
      if { $pluginInfo(type) == "tool" } {
         ::confChoixOutil::removeTool $toolNamespace
      }
   }

   #--- je supprime le repertoire , sauf les fichiers CVS
   set dirs $pluginDirectory
   if { [ file exists [file join $pluginDirectory "cvs" ]] == 1
   && [file exists [file join $pluginDirectory "CVS" ]] == 1 } {
      #--- supprime tous les sous-repertoires sauf CVS ou cvs
      while {[llength $dirs] > 0} {
         set dir [lindex $dirs 0]
         set dirs [lrange $dirs 1 end]
         set entries [glob -nocomplain -types {d f r} [file join $dir *]]
         foreach path [lsort $entries] {
            if { [file tail $dir] == "cvs" || [file tail $dir] == "CVS"} {
               ::console::disp "cvsFound $dir\n"
            } else {
               if { [file isdir $path] } {
                  lappend dirs $path
               } else {
                  file delete $path
                  ::console::disp "delete $path\n"
               }
            }
         }
      }
   } else {
      #--- j'efface tout le repertoire
      file delete -force $pluginDirectory
      ::console::disp "deleteall $pluginDirectory\n"
   }
}

#------------------------------------------------------------
#  ::updateaudela::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::getLabel { } {
   global caption

   return "$caption(updateaudela,title)"
}

#------------------------------------------------------------
#  ::updateaudela::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm)      $frm

   #--- J'initialise les variables des widgets

   #--- Je positione la fenetre
   wm resizable [ winfo toplevel $private(frm) ] 1 1

   set notebook [NoteBook $frm.nb]

   set downloadFrame [$notebook insert end downloadPage -text $caption(updateaudela,download) ]
   set kitFrame      [$notebook insert end kitPage      -text $caption(updateaudela,availableUpdate) ]
   set pluginFrame   [$notebook insert end pluginPage   -text $caption(updateaudela,pluginFrame) ]

   ::updateaudela::download::fillConfigPage $downloadFrame $visuNo
   ::updateaudela::kit::fillConfigPage      $kitFrame $visuNo
   ::updateaudela::plugin::fillConfigPage   $pluginFrame $visuNo

   ##$notebook compute_size
   pack $notebook -fill both -expand yes -padx 4 -pady 4
   $notebook raise [$notebook page 0]

}

#------------------------------------------------------------
#  ::updateaudela::getTypeDirectory
#  retourne le repertoire du plugin en fonction de son type
#
#  - "audela" est dans le répertoire audace(rep_install)/bin
#  - les plugins sont dans un repertoire dont le nom est
#  retourne le repertoire du plugin en fonction de son type
#  Actuellement les types de plugin sont dans un repertoire dont le nom est
#  identique au type, sauf  le type "focuser" qui est dans le repertoire "equipement"
#  - les libtcl sont dans le répertoire audace(rep_install)/bin
#------------------------------------------------------------
proc ::updateaudela::getTypeDirectory { pluginType pluginName } {
   global audace

      switch $pluginType {

      "audela" {
         set typeDirectory "$::audace(rep_install)/bin"
      }
      "camera" -
      "chart" -
      "equipment" -
      "link" -
      "mount" -
      "pad" -
      "tool" {
         set typeDirectory "$::audace(rep_plugin)/$pluginType/$pluginName"
      }
      "focuser" {
         set typeDirectory "$::audace(rep_plugin)/equipment/$pluginName"
      }
      "spectroscope" {
         set typeDirectory "$::audace(rep_plugin)/equipment/$pluginName"
      }
      "libtcl" {
         set typeDirectory "$::audace(rep_install)/lib/$pluginName"
      }
      default {
         set typeDirectory ""
      }
   }
   return $typeDirectory
}

#------------------------------------------------------------
#  ::updateaudela::showHelp
#  affiche l'aide de la fenêtre de configuration
#------------------------------------------------------------
proc ::updateaudela::showHelp { } {
   variable private

   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::updateaudela::getPluginType ] ] \
      [ ::updateaudela::getPluginDirectory ] [ ::updateaudela::getPluginHelp ]
}

#------------------------------------------------------------
#  ::updateaudela::cmdClose
#  recupere la position de l'outil apres appui sur Fermer
#------------------------------------------------------------
proc ::updateaudela::cmdClose { visuNo } {
   variable private

   #--- je sauve la taille et la position de la fenetre
   set ::conf(updateaudela,geometry) [winfo geometry [winfo toplevel $private(frm) ]]
}

#------------------------------------------------------------
#  ::updateaudela::recupPosition
#  recupere la position de l'outil
#------------------------------------------------------------
proc ::updateaudela::recupPosition { } {
   variable private

   #--- Je mets la position actuelle de la fenetre dans conf()
   set geom [ winfo geometry [winfo toplevel $private(frm) ] ]
   set deb [ expr 1 + [ string first + $geom ] ]
   set fin [ string length $geom ]
   set ::conf(updateaudela,geometry) "+[ string range $geom $deb $fin ]"
}

#------------------------------------------------------------
#  ::updateaudela::installKit { }
#   extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::installKit { kitFileName } {
   variable private

   set kitFileFullName [file join $private(kitDirectory) $kitFileName]
   set vfsNo ""
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      #--- j'ouvre le repertoire virtuel du kit
      set vfsName "$kitFileName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName -readonly ]
      set pkgIndexFileName [file join $vfsName pkgIndex.tcl]

      if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
         set pluginDirectory [getTypeDirectory $pluginInfo(type) $pluginInfo(name)]

         #--- je recupere la version de Audela
         set catchResult [catch { package present audela } audelaVersion ]
         if { $catchResult == 1 } {
             #--- je force la version pour compatibilite ascendente
             set audelaVersion "1.3.999"
         }
         #--- je recupere la version necessite par la mise à jour
         if { $pluginInfo(audelaVersion) == "" } {
             #--- je force la version pour compatibilite ascendente
             set pluginAudelaVersion "1.3.999"
         } else {
             set pluginAudelaVersion $pluginInfo(audelaVersion)
         }
         if { [package vcompare $audelaVersion $pluginAudelaVersion] >= 0 } {
            #--- je recupere les informations de la version deja installee
            set currentPkgIndexFileName [file join [getTypeDirectory $pluginInfo(type) $pluginInfo(name)]  pkgIndex.tcl]
            if { [file exists $currentPkgIndexFileName] == 1 } {
               if { [::audace::getPluginInfo $currentPkgIndexFileName currentPluginInfo ] == 0 } {
                  #--- si le plugin est deja installe , je propose la mise la jour
                  set message [format $::caption(updateaudela,confirmInstall) "\"$currentPluginInfo(name) $currentPluginInfo(version)\"" "\"$pluginInfo(name) $pluginInfo(version)\""]
               }
            } else {
               #--- si le plugin n'est pas installe , je propose l'installation
               set message [format $::caption(updateaudela,confirmInstallNew) "$pluginInfo(name) ($pluginInfo(version))"]
            }
            set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
            if { $answer == "ok" } {
               #--- j'extrait le plugin
               set result [::updateaudela::sync [list -verbose 0 -auto 0 -noerror 0 $vfsName $pluginDirectory]]
               #--- je rafraichis l'affichage des plugins
               ::updateaudela::plugin::fillPluginTable
               #--- je suppprime de la memoire la version precedente du plugin
               package forget $pluginInfo(name)
               #--- je charge la nouvelle version du plugin
               package require $pluginInfo(name)
               #--- j'execute la procedure d'installation du plugin si elle existe
               if { [info command ::$pluginInfo(namespace)::install]  != "" } {
                  $pluginInfo(namespace)::install
               } else {
                  ##console::disp "::updateaudela::installKit la procedure [info command ::$pluginInfo(namespace)::install] n'existe pas\n"
               }

               #--- j'ajoute le plugin dans les menus si pluginInfo(type)=tool
               if { $pluginInfo(type)== "tool" } {
                  ::confChoixOutil::addTool $pluginInfo(namespace) 1 ""
               }

               #--- j'affiche un message OK
               set message [format $::caption(updateaudela,installPluginOk) $kitFileName $pluginDirectory $result ]
               if { $result != 0 } {
                  append message "\n$::caption(updateaudela,restart)"
               }
               tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
            }
         } else {
            set message [format $::caption(updateaudela,badAudelaVersion) $pluginInfo(audelaVersion) ]
            tk_messageBox -message $message -type ok -icon error -title $::caption(updateaudela,title)
         }
      } else {
        ::console::affiche_erreur "$::errorInfo\n"
        tk_messageBox -message "$::errorInfo. See console" -icon error
      }
   } catchMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult == "1" } {
     ::console::affiche_erreur "$::errorInfo\n"
     tk_messageBox -message "$catchMessage. See console" -icon error
   }

   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   #--- je ferme le repertoire virtuel si necessaire (dans le cas ou une erreur aurait intrrompu le traitement)
   if { $vfsNo != "" } {
      vfs::mk4::Unmount $vfsNo $vfsName
      ###mk4vfs::umount $vfsName
      set vfsNo ""
   }

}

#------------------------------------------------------------
#  ::updateaudela::getPluginInfoFile
#    retourne les informations sur un plugin dans le tableau passe en parametre
#      pluginInfo(name)      nom du plugin
#      pluginInfo(version)   version du plugin
#      pluginInfo(command)   commande pour charger le plugin
#      pluginInfo(namespace) namespace principal du plugin
#      pluginInfo(title)     titre du plugin dans la langue de l'utilisateur
#      pluginInfo(type)      type du plugin
#
# parametres :
#    pkgIndexFileName : nom complet du fichier pkgIndex.tcl (avec le repertoire)
#    pluginInfo : tableau (array) des informations sur le plugin rempli par cette procedure
# return :
#     0 si pas d'erreur, le resultat est dans le tableau donné en paramètre.
#    -1 si une erreur, le libellé de l'erreur est dans ::::errorInfo
#
#------------------------------------------------------------
proc ::updateaudela::getPluginInfoFile { kitFileName  pluginInfo } {
   variable private
   upvar $pluginInfo localPluginInfo

   set kitFileFullName [file join $private(kitDirectory) $kitFileName]

   set vfsNo ""
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      #--- j'ouvre le repertoire virtuel du kit
      set vfsName "$kitFileName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName -readonly ]
      set pkgIndexFileName [file join $vfsName pkgIndex.tcl]
      set result [::audace::getPluginInfo $pkgIndexFileName localPluginInfo ]
   } catchMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult != "0" } {
     ::console::affiche_erreur "$::errorInfo\n"
     set result "-1"
   }

   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   #--- je ferme le repertoire virtuel si necessaire (dans le cas ou une erreur aurait intrrompu le traitement)
   if { $vfsNo != "" } {
      vfs::mk4::Unmount $vfsNo $vfsName
      set vfsNo ""
   }

   return $result
}

#------------------------------------------------------------
#  ::updateaudela::makeKit { }
#  copie des fichiers dans un fichier kit
#------------------------------------------------------------
proc ::updateaudela::makeKit { kitFileFullName sourceDirectory { fileList ""} } {
   variable private

   if { [info exists private(base)] == 0 } {
      #--- s'il n'existe aucune instance du plugin, j'en cree une
      ::updateaudela::createPluginInstance ".audace" "1"
   }

   #--- je cree le fichier kit
   set vfsName "makekit.vfs"
   set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName ]
   #--- je copie les fichiers dans le kit
   set catchResult [catch {
      if { $fileList != "" } {
         foreach fileName $fileList {
            set sourceFileName [file join $sourceDirectory $fileName]
            set destDirectory [file join $vfsName [file dirname $fileName]]
            set destFileName  [file join $vfsName $fileName]
            #--- je cree le sous-repertoire
            file mkdir $destDirectory
            ::updateaudela::sync [list -compress 1 -verbose 0 -ignore "cvs" -ignore "CVS" -auto 0 -noerror 0 $sourceFileName $destFileName]
         }
      } else {
         ::updateaudela::sync [list -compress 1 -verbose 0  -ignore "cvs" -ignore "CVS" -auto 0 -noerror 0 $sourceDirectory $vfsName]
      }
   } catchMessage ]

   #--- j'intercepte l'erreur pour pouvoir fermer le fichier kit
   #--- avant de remonter l'erreur a la procedure appelante
   if { $catchResult == "1" } {
      #--- je ferme le fichier kit
      vfs::mk4::Unmount $vfsNo $vfsName
      #--- je remonte l'erreur a la procedure appelante
      error $::errorInfo
   } else {
      #--- je ferme le fichier kit
      vfs::mk4::Unmount $vfsNo $vfsName
   }
}

#------------------------------------------------------------
#  ::updateaudela::addFileToKit { }
#  ajoute un fichier dans le kit
#------------------------------------------------------------
proc ::updateaudela::addFileToKit { kitFileFullName fileName lines } {
   variable private

   #--- j'ouvre fichier kit
   set vfsName "makekit.vfs"
   set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName ]
   #--- je cree le fichier
   set fileNo [open [file join $vfsName $fileName] "w"]
   puts -nonewline $fileNo $lines
   close $fileNo
   #--- je ferme le fichier kit
   vfs::mk4::Unmount $vfsNo $vfsName
}

#------------------------------------------------------------
#  ::updateaudela::showKitContent { }
#   extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::showKitContent { kitFileName } {
   variable private

   set kitFileFullName [file join $private(kitDirectory) $kitFileName]

   set vfsNo ""
   set interpTemp [interp create -safe ]
   interp expose $interpTemp source
   interp expose $interpTemp file
   set catchResult [catch {
      #--- j'ouvre le repertoire virtuel du kit
      set vfsName "$kitFileName.vfs"
      set vfsNo [vfs::mk4::Mount $kitFileFullName $vfsName -readonly ]
      set dirs [list "$vfsName" ]
      while {[llength $dirs] > 0} {
         set dir [lindex $dirs 0]
         set dirs [lrange $dirs 1 end]
         ::console::disp "\n$dir:\n"
         set entries [glob -nocomplain [file join $dir *]]
         foreach path [lsort $entries] {
            if {[file isdir $path]} {
              set len ""
              set tim "dir"
              set suf "/"
              lappend dirs $path
            } else {
              set len [format %10d [file size $path]]
              set tim [clock format [file mtime $path] -format {%Y/%m/%d %H:%M:%S}]
              set suf ""
            }
            ::console::disp "$len  $tim  [file tail $path]$suf\n"
         }
      }

   } catchMessage ]

   #--- Traitement des erreurs detectees par le catch
   if { $catchResult == "1" } {
     ::console::affiche_erreur "$::errorInfo\n"
     tk_messageBox -message "$catchMessage. See console" -icon error
   }

   #--- je supprime l'interpreteur temporaire
   interp delete $interpTemp

   #--- je ferme le repertoire virtuel si necessaire (dans le cas ou une erreur aurait intrrompu le traitement)
   if { $vfsNo != "" } {
      vfs::mk4::Unmount $vfsNo $vfsName
      set vfsNo ""
   }
}

#------------------------------------------------------------

################################################################################
# Synchronize two directory trees, VFS-aware
#
# Copyright (c) 1999 Matt Newman, Jean-Claude Wippler and Equi4 Software.
#
#
# Recursively sync two directory structures
#
proc ::updateaudela::rsync {arr src dest} {
    #tclLog "rsync $src $dest"
    upvar 1 $arr opts

    if {$opts(-auto)} {
        # Auto-mounter
        vfs::auto $src -readonly
        vfs::auto $dest
    }

    if {![file exists $src]} {
        return -code error "source \"$src\" does not exist"
    }
    if {[file isfile $src]} {
        #tclLog "copying file $src to $dest"
        return [rcopy opts $src $dest]
    }
    if {![file isdirectory $dest]} {
        #tclLog "copying non-file $src to $dest"
        return [rcopy opts $src $dest]
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $src *]
    eval lappend contents [glob -nocomplain -dir $src .*]

    set count 0                ;# How many changes were needed
    foreach file $contents {
        #tclLog "Examining $file"
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        set target [file join $dest $tail]

        set seen($tail) 1

        if {[info exists opts(ignore,$file)] || \
            [info exists opts(ignore,$tail)]} {
            if {$opts(-verbose)} {
                tclLog "skipping $file (ignored)"
            }
            continue
        }
        if {[file isdirectory $file]} {
            incr count [rsync opts $file $target]
            continue
        }
        if {[file exists $target]} {
            #tclLog "target $target exists"
            # Verify
            file stat $file sb
            file stat $target nsb
            #tclLog "$file size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
            if {$sb(size) == $nsb(size)} {
                # Copying across filesystems can yield a slight variance
                # in mtime's (typ 1 sec)
                if { ($sb(mtime) - $nsb(mtime)) < $opts(-mtime) } {
                    # Good
                    #continue
                }
            }
            #tclLog "size=$sb(size)/$nsb(size), mtime=$sb(mtime)/$nsb(mtime)"
        }
        incr count [rcopy opts $file $target]
    }
    #
    # Handle stray files
    #
    if {$opts(-prune) == 0} {
        return $count
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $dest *]
    eval lappend contents [glob -nocomplain -dir $dest .*]
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        if {[info exists seen($tail)]} {
            continue
        }
        rdelete opts $file
        incr count
    }
    return $count
}

proc ::updateaudela::_rsync {arr args} {
    upvar 1 $arr opts
    #tclLog "_rsync $args ([array get opts])"

    if {$opts(-show)} {
        # Just show me, don't do it.
        tclLog $args
        return
    }
    if {$opts(-verbose)} {
        tclLog $args
    }
    if {[catch {
        eval $args
    } err]} {
        if {$opts(-noerror)} {
            tclLog "Warning: $err"
        } else {
            return -code error -errorinfo ${::errorInfo} $err
        }
    }
}

# This procedure is better than just 'file copy' on Windows,
# MacOS, where the source files probably have native eol's,
# but the destination should have Tcl/unix native '\n' eols.
# We therefore need to handle text vs non-text files differently.
proc ::updateaudela::file_copy {src dest {textmode 0}} {
    set mtime [file mtime $src]
    if {!$textmode} {
      file copy $src $dest
    } else {
      switch -- [file extension $src] {
          ".tcl" -
          ".txt" -
          ".msg" -
          ".test" -
          ".itk" {
          }
          default {
              if {[file tail $src] != "tclIndex"} {
                  # Other files are copied as binary
                  #return [file copy $src $dest]
                  file copy $src $dest
                  file mtime $dest $mtime
                  return
              }
          }
      }
      # These are all text files; make sure we get
      # the translation right.  Automatic eol
      # translation should work fine.
      set fin [open $src r]
      set fout [open $dest w]
      fcopy $fin $fout
      close $fin
      close $fout
    }
    file mtime $dest $mtime
}

proc ::updateaudela::rcopy {arr path dest} {
    #tclLog "rcopy: $arr $path $dest"
    upvar 1 $arr opts
    # Recursive "file copy"

    set tail [file tail $dest]
    if {[info exists opts(ignore,$path)] || \
        [info exists opts(ignore,$tail)]} {
        if {$opts(-verbose)} {
            tclLog "skipping $path (ignored)"
        }
        return 0
    }
    if {![file isdirectory $path]} {
        if {[file exists $dest]} {
            _rsync opts file delete $dest
        }
        _rsync opts file_copy $path $dest $opts(-text)
        return 1
    }
    set count 0
    if {![file exists $dest]} {
        _rsync opts file mkdir $dest
        set count 1
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $path *]
    eval lappend contents [glob -nocomplain -dir $path .*]
    #tclLog "copying entire directory $path, containing $contents"
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        set target [file join $dest $tail]
        incr count [rcopy opts $file $target]
    }
    return $count
}

proc ::updateaudela::rdelete {arr path} {
    upvar 1 $arr opts
    # Recursive "file delete"
    if {![file isdirectory $path]} {
        _rsync opts file delete $path
        return
    }
    set contents {}
    eval lappend contents [glob -nocomplain -dir $path *]
    eval lappend contents [glob -nocomplain -dir $path .*]
    foreach file $contents {
        set tail [file tail $file]
        if {$tail == "." || $tail == ".."} {
            continue
        }
        rdelete opts $file
    }
    _rsync opts file delete $path
}

proc ::updateaudela::rignore {arr args} {
    upvar 1 $arr opts

    foreach file $args {
        set opts(ignore,$file) 1
    }
}

proc ::updateaudela::rpreserve {arr args} {
    upvar 1 $arr opts

    foreach file $args {
        catch {unset opts(ignore,$file)}
    }
}

#------------------------------------------------------------
#  ::updateaudela::sync { }
#  parameters :
#
# return : number of created or udated files
#
#------------------------------------------------------------
proc ::updateaudela::sync {argv} {
   # 28-01-2003: changed -text default to 0, i.e. copy binary mode
   array set opts {
       -prune        0
       -verbose        1
       -show        0
       -ignore        ""
       -mtime        1
       -compress        1
       -auto        1
       -noerror        1
       -text        0
   }
   # 2005-08-30 only ignore the CVS subdir
   #rignore opts CVS RCS core a.out
   rignore opts CVS

   set USAGE "[file tail \$argv0] ?options? src dest

       Where options are:-

       -auto        0|1        Auto-mount starkits (default: $opts(-auto))
       -compress        0|1        Enable MetaKit compression (default: $opts(-compress))
       -mtime        n        Acceptable difference in mtimes (default: $opts(-mtime))
       -prune        0|1        Remove extra files in dest (default: $opts(-prune))
       -show        0|1        Show what would be done, but don't do it (default: $opts(-show))
       -verbose        0|1        Show each file being processed (default: $opts(-verbose))
       -noerror    0|1     Continue processing after errors (default: $opts(-noerror))
       -ignore     glob        Pattern of files to ignore (default: CVS RCS core a.out)
       -preserve        glob        Pattern of files not to ignore (i.e. to clear defaults)
       -text       0|1        Copy .txt/tcl/msg/test/itk files as text (default: $opts(-text))"

   if {[llength $argv] < 2} {
       error "sync : src desc parameters are missing"
       return
   }

   while {[llength $argv] > 0} {
       set arg [lindex $argv 0]

       if {![string match -* $arg]} {
           break
       }
       if {![info exists opts($arg)]} {
           puts stderr "invalid option \"$arg\"\n$USAGE"
           exit 1
       }
       if {$arg == "-ignore"} {
           rignore opts [lindex $argv 1]
       } elseif {$arg == "-preserve"} {
           rpreserve opts [lindex $argv 1]
       } else {
           set opts($arg) [lindex $argv 1]
       }
       set argv [lrange $argv 2 end]
   }

   ##package require vfs::mk4
   ###set vfs::mk4::compress $opts(-compress)

   set src [lindex $argv 0]
   set dest [lindex $argv 1]

   #
   # Perform actual sync
   #
   set n [rsync opts $src $dest]
   return "$n"
}

namespace eval ::updateaudela::kit {

}

#------------------------------------------------------------
#  ::testaudela::kit::deleteKit
#  supprime un fichier kit
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::kit::deleteKit { } {
   variable private

   set selectedRow [$private(kitTable) curselection]
   if { $selectedRow == "" } {
      tk_messageBox -message "Error: No file selected." -icon error
      return
   }
   set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]

   set message [format $::caption(updateaudela,confirmDelete) $kitFileName]
   set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
   if { $answer == "ok" } {
      ::updateaudela::deleteKit $kitFileName
      #--- je refraichis la liste des kits
      fillKitTable
   }
}

#------------------------------------------------------------
#  ::updateaudela::kit::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::kit::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm)      $frm

   #--- J'initialise les variables des widgets

   #--- frame de fichiers kit
   TitleFrame $frm.kit -borderwidth 2 -text $caption(updateaudela,availableUpdate)

      LabelEntry $frm.directory -label $caption(updateaudela,rep_plugin) \
          -labeljustify left -width 0 -padx 2 -justify left -editable 0 \
          -textvariable ::updateaudela::private(kitDirectory)

      #--- Information du plugin
      frame $frm.kit.info -borderwidth 0
      #Label $frm.kit.info.title -text ""
      #listbox $frm.kit.info.updateList
      set private(kitTable) $frm.kit.info.updateList

      scrollbar $frm.kit.info.ysb -command "$private(kitTable) yview"
      scrollbar $frm.kit.info.xsb -command "$private(kitTable) xview" -orient horizontal

      #---  Liste des fichiers .kit
      #---   l'option setfocus est necessaire pour activer la molette de la souris
      tablelist::tablelist $private(kitTable) \
         -columns [ list \
            20 "File" left  \
            7  "Version\nPlugin" center \
            7  "Version\nAudela\nrequise" center \
            ] \
         -xscrollcommand [list $frm.kit.info.xsb set] -yscrollcommand [list $frm.kit.info.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -selectmode single \
         -exportselection 0 \
         -showarrow 1 \
         -stretch 0 \
         -setfocus 1 \
         -activestyle none

      bind $private(kitTable) <<ListboxSelect>>  [list ::updateaudela::kit::onSelectKitFile ]

      grid $private(kitTable)          -row 0 -column 0 -sticky ewns
      grid $frm.kit.info.ysb           -row 0 -column 1 -sticky nsew
      grid $frm.kit.info.xsb           -row 1 -column 0 -sticky ew
      grid rowconfig    $frm.kit.info  0 -weight 1
      grid columnconfig $frm.kit.info  0 -weight 1

      #--- frame des boutons
      frame $frm.kit.button -borderwidth 0
         Button $frm.kit.button.install -text "$caption(updateaudela,installPlugin)" \
            -command "::updateaudela::kit::installKit"
         Button $frm.kit.button.delete -text "$caption(updateaudela,delete)" \
            -command "::updateaudela::kit::deleteKit"
         Button $frm.kit.button.show -text "$caption(updateaudela,show)"  \
            -command "::updateaudela::kit::showKitContent"
         grid $frm.kit.button.install  -row 0 -column 0 -sticky ewns -padx 4
         grid $frm.kit.button.delete   -row 0 -column 1 -sticky ewns -padx 4
         grid $frm.kit.button.show     -row 0 -column 2 -sticky ewns -padx 4

      grid $frm.kit.info    -in [$frm.kit getframe] -row 0 -column 0 -columnspan 2 -sticky ewns
      grid $frm.kit.button  -in [$frm.kit getframe] -row 2 -column 0 -columnspan 2 -sticky ewns
      grid rowconfig    [$frm.kit getframe] 0 -weight 1
      grid columnconfig [$frm.kit getframe] 0 -weight 1

   grid $frm.directory  -row 0 -column 0 -sticky ewns
   grid $frm.kit        -row 1 -column 0 -sticky ewns

   grid rowconfig    $frm 1 -weight 1
   grid columnconfig $frm 0 -weight 1

   set private(kitDirectory) $::updateaudela::private(kitDirectory)
   #--- je remplis la table
   fillKitTable
}

#------------------------------------------------------------
#  ::updateaudela::kit::fillKitTable
#  affiche la liste des fichiers kit dans la table des kits
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::kit::fillKitTable { } {
   variable private

   #--- je vide la liste des mises a jour
   $private(kitTable) delete 0 end
   #--- je recherche les fichiers de mise à jour
   set kitList [lsort -dictionary [glob -nocomplain -dir $::updateaudela::private(kitDirectory) -type f "*.kit"]]
   #--- je remplis la table avec la liste des fichiers kit
   foreach kitFileFullName $kitList {
      set kitFileName [file tail $kitFileFullName]
      if { [::updateaudela::getPluginInfoFile $kitFileName kitFileInfo] == 0 } {
         $private(kitTable) insert end [list $kitFileName $kitFileInfo(version) $kitFileInfo(audelaVersion)]
      }
   }
   #--- je deselectionne les boutons
   onSelectKitFile

}

#------------------------------------------------------------
#  ::updateaudela::kit::installKit { }
#       extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::kit::installKit { } {
   variable private

   set selectedRow [$private(kitTable) curselection]
   if { $selectedRow == "" } {
      tk_messageBox -message "Error: No file selected." -icon error
      return
   }
   set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]

   ::updateaudela::installKit $kitFileName
}

#------------------------------------------------------------
#  ::updateaudela::kit::onSelectKitFile { }
#     affiche les informations du plugin
#------------------------------------------------------------
proc ::updateaudela::kit::onSelectKitFile {  } {
   variable private

   set rowIndex [$private(kitTable) curselection]
   if { $rowIndex != "" } {
      #--- j'affiche le titre dans la langue de l'utilisateur
      $private(frm).kit.button.install configure -state normal
      $private(frm).kit.button.delete  configure -state normal
      $private(frm).kit.button.show     configure -state normal
   } else {
      #---je desactive les boutons si aucun kit est selectionne
      $private(frm).kit.button.install configure -state disabled
      $private(frm).kit.button.delete  configure -state disabled
      $private(frm).kit.button.show     configure -state disabled
   }

}

#------------------------------------------------------------
#  ::updateaudela::kit::showKitContent { }
#   extrait le plugin du fichier kit
#------------------------------------------------------------
proc ::updateaudela::kit::showKitContent {  } {
   variable private

   set selectedRow [$private(kitTable) curselection]
   if { $selectedRow == "" } {
      tk_messageBox -message "Error: No file selected." -icon error
      return
   }
   set kitFileName [$private(kitTable) cellcget $selectedRow,0 -text]
   ::updateaudela::showKitContent $kitFileName
}

namespace eval ::updateaudela::download {

}

####------------------------------------------------------------
####  :updateaudela::download::connect
####    ouvre la connexion vers le site WEB de audela
####  dans la table des kits
####  param : aucun
####------------------------------------------------------------
###proc ::updateaudela::download::connectAudela { } {
###   variable private
###
###   $private(frm).address.list.e configure -text "http://www.audela.org/test2.php"
###   ::updateaudela::download::connect
###}

#------------------------------------------------------------
#  :updateaudela::download::connect
#    ouvre la connexion vers le site WEB
#  dans la table des kits
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::download::connect { } {
   variable private

   #--- je recupere l'adresse selectionne dans la combobox
   set private(currentUrl) [$private(frm).address.list get]
   if { [$private(frm).address.list get] != "" } {
      set result [loadUrl $private(currentUrl)]
      if { $result == 0 } {
         set addressListBox [$private(frm).address.list getlistbox ]
         #--- si le chargement de l'URL est OK,
         #--- et si l'URL n'est pas deja dans la liste
         #--- alors j'ajoute l'URL au début de la liste
         #--- puis je supprime le 11 element s'il existe
         if { [lsearch -exact [$addressListBox get 0 end] $private(currentUrl) ] == -1 } {
            $addressListBox insert 0 "$private(currentUrl)"
            if { [$addressListBox size] > 10 } {
               $addressListBox delete 10
            }
            #--- je copie la nouvelle liste dans la variable conf
            set ::conf(updateaudela,addressList) [$addressListBox get 0 end]
         }
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::download::modifyAddress
#
#------------------------------------------------------------
proc ::updateaudela::download::modifyAddress { } {
   variable private

}

#------------------------------------------------------------
#  ::updateaudela::download::postcommand
#
#------------------------------------------------------------
proc ::updateaudela::download::postcommand { } {
   variable private

   ::console::disp "postcommand [$private(frm).address.list get] \n"
}

#------------------------------------------------------------
#  ::updateaudela::download::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::download::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm)      $frm

   #--- J'initialise les variables des widgets
   set private(address) "audela"

   #--- Je positione la fenetre
   wm resizable [ winfo toplevel $private(frm) ] 1 1

   TitleFrame $frm.address -borderwidth 2 -text $caption(updateaudela,address)

      Button  $frm.address.go -text "GO" -command "::updateaudela::download::connect"
      ###Button  $frm.address.goAudela -text "GO Audela" -command "::updateaudela::download::connectAudela"

      ComboBox $frm.address.list -relief sunken -borderwidth 1 -editable 1 \
              -height 10 \
              -modifycmd "::updateaudela::download::modifyAddress" \
              -values $::conf(updateaudela,addressList)
      $frm.address.list setvalue "@0"
      pack $frm.address.list     -in [$frm.address getframe] -side left -padx 4 -expand 1 -fill x
      pack $frm.address.go       -in [$frm.address getframe] -side left -padx 4
      ###pack $frm.address.goAudela -in [$frm.address getframe] -side left -padx 4

   #--- frame des kits
   TitleFrame $frm.website -borderwidth 2 -text $caption(updateaudela,kitFrame)

      scrollbar $frm.website.ysb -command "$frm.website.html yview"
      scrollbar $frm.website.xsb -command "$frm.website.html xview" -orient horizontal
      set private(html) $frm.website.html
      html $private(html) -width 10 -height 10 -shrink 0 \
          -yscrollcommand "$frm.website.ysb set" \
          -xscrollcommand "$frm.website.xsb set"

      bind $private(html) <Button-1> {::updateaudela::download::processHyperlink %x %y}
      bind $private(html) <Motion>   {::updateaudela::download::onMouseMotion %x %y}

      grid $frm.website.html          -in [$frm.website getframe] -row 0 -column 0 -sticky nsew
      grid $frm.website.ysb           -in [$frm.website getframe] -row 0 -column 1 -sticky nsew
      grid $frm.website.xsb           -in [$frm.website getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.website getframe] 0 -weight 1
      grid columnconfig [$frm.website getframe] 0 -weight 1

   #--- frame de boutons
   frame $frm.button -borderwidth 2
      Label $frm.button.state  -text "test" -relief sunken -width 20 -textvariable ::updateaudela::download::private(downloadProgress)
      checkbutton $frm.button.install -text "$caption(updateaudela,downloadAndInstall)" \
         -variable ::conf(updateaudela,downloadAndInstall)
      pack $frm.button.install  -side left
      pack $frm.button.state    -side right

   grid $frm.address     -row 0 -column 0 -sticky ewns
   grid $frm.website     -row 1 -column 0 -sticky ewns
   grid $frm.button      -row 2 -column 0 -sticky ewns

   grid rowconfig    $frm 1 -weight 1
   grid rowconfig    $frm 1 -weight 1
   grid columnconfig $frm 0 -weight 1
   ##after idle "::updateaudela::download::connect"
   #bind $private(frm) <Enter> "::updateaudela::download::connect"

}

proc ::updateaudela::download::processHyperlink {x y} {
   variable private

   # tkhtml 2
   #set new [$private(html) href $x $y]
   #if {$new!=""} {
   #   set pattern "$private(currentUrl)#"
   #   set len [string length $pattern]
   #   incr len -1
   #   if {[string range $new 0 $len]==$pattern} {
   #      incr len
   #      $private(html) yview [string range $new $len end]
   #   } else {
   #      ::updateaudela::download::loadUrl "[lindex $new 0]"
   #   }
   #}

   set nodes [$private(html) node $x $y]
   set node [lindex $nodes 0]

   set value ""
   for {set n $node} {$n ne ""} {set n [$n parent]} {
      if {[info commands $n] eq ""} break
      set tag [$n tag]
      if {$tag eq ""} {
        set value [$n text]
      } elseif {$tag eq "a" && [$n attr -default "" href] ne ""} {
        set value "hyper-link: [string trim [$n attr href]]"
        set uri [string trim [$n attr href]]
        ::updateaudela::download::loadUrl "$uri"
        break
      } elseif {[set nid [$n attr -default "" id]] ne ""} {
        set value "<$tag id=$nid>$value"
      } else {
        set value "<$tag>$value"
      }
    }
}

proc ::updateaudela::download::onMouseMotion {x y} {
   variable private

   set nodeList [$private(html) node $x $y]
   set text 0
   foreach node $nodeList {
      if {[$node tag] eq ""} {set text 1}
      for {set n $node} {$n ne ""} {set n [$n parent]} {
         if {[$n tag] eq "a" && [$n attr -default "" href] ne ""} {
            $private(frm) configure -cursor hand2
            return
         }
      }
   }
   if {$text == 0} {
      $private(frm) configure -cursor ""
   } else {
     $private(frm) configure -cursor xterm
   }
}

#------------------------------------------------------------
#  ::updateaudela::download::loadUrl
#     affiche une page HTML ou telecharge un plugin
#  param : aucun
#  return :
#    0 si OK
#    1 si erreur de connexion
#------------------------------------------------------------
proc ::updateaudela::download::loadUrl { url } {
   variable private

   set url [::uri::resolve $private(currentUrl) $url]
   array set currentAddress [::uri::split $url]
   #console::disp "   scheme=$currentAddress(scheme)\n"
   #console::disp "   host=$currentAddress(host)\n"
   #console::disp "   port=$currentAddress(port)\n"
   #console::disp "   path=$currentAddress(path)\n"
   #console::disp "   relative=[::uri::isrelative $url]\n"
   set fileName      [file tail $currentAddress(path)]
   set fullFileName  [file join "$::audace(rep_install)" $fileName]

   #--- je demande l'autorisation d'ecraser le fichier s'il existe deja
   if { [file exists $fullFileName] && [file isfile $fullFileName] } {
      set message [format $::caption(updateaudela,fileExists) $fullFileName]
      set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
      if { $answer == "cancel" } {
         return
      }
   }

   set catchError [catch {

      set private(token) [http::geturl $url -binary 1 \
          -progress ::updateaudela::download::onDownloadProgress \
      ]

      #--- declaration de state(type)
      upvar #0 $private(token) state

      #--- je recupere le format mime, juste avant le premier point virgule
      set type [lindex [split $state(type) ";"] 0]
      switch $type {
      "text/html" {
            #--- j'efface l'affichage precedent
            # tkhtml 2.0
            # $private(html) clear
            $private(html) reset
            #--- j'affiche la nouvelle page HTML
            $private(html) parse [http::data $private(token)]
         }
      "text/plain" {
            #--- je charge le fichier kit
            set fileHandle [open "$fullFileName" w]
            fconfigure $fileHandle -translation binary
            puts -nonewline $fileHandle [http::data $private(token)]
            ::close $fileHandle

            #--- je rafraichis la liste des fichiers kit
            ::updateaudela::kit::fillKitTable

            #--- j'installe le plugin immediatement si l'utilisateur l'a demande
            if { $::conf(updateaudela,downloadAndInstall) == 1 } {
                #--- j'installe le plugin immediatement
               ::updateaudela::installKit $fileName
            } else {
               #--- j'affiche un message pour signaler la fin du chargement
               set message [format $::caption(updateaudela,downloadOk) $fileName  ]
               tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
            }
         }
      }

      http::cleanup $private(token)
      http::reset $private(token)
   }]
   if { $catchError != 0 } {
      tk_messageBox -message "$::errorInfo  \nURL=$url" -icon error
      return 1
   }

   return 0

}

#------------------------------------------------------------
#  ::updateaudela::download::onDownloadProgress
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::download::onDownloadProgress { token total current } {
   variable private
   upvar #0 $token state

   if { $total <= $current } {
      #--- je ferme la fenetre de progression
      #destroy $private(frm).downloadProgress
      set ::updateaudela::download::private(downloadProgress) ""
   } else {
      #--- je mets a jour la variable de la fenetre de progression
      set private(downloadProgress) "[expr $current/1024] / [expr $total/1024] Ko"
   }
}

#------------------------------------------------------------
#  ::updateaudela::download::stopDownload
#     interompt le telechargement
#------------------------------------------------------------
proc ::updateaudela::download::stopDownload { args } {
   variable private

   #--- je ne sais pas arreter le telechargement
   ###http::reset $private(token)
   if { [winfo exists $private(frm).downloadProgress] } {
      destroy $private(frm).downloadProgress
   }
}

#------------------------------------------------------------
#------------------------------------------------------------
namespace eval ::updateaudela::plugin {

}

#------------------------------------------------------------
#  ::testaudela::plugin::deletePlugin
#  supprime un plugin
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::plugin::deletePlugin {} {
   variable private

   set rowIndex [$private(pluginTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error: No plugin selected." -icon error
      return
   }
   set pluginName [$private(pluginTable) cellcget $rowIndex,1 -text]
   set pluginType [$private(pluginTable) cellcget $rowIndex,0 -text]

   set pluginDirectory [::updateaudela::getTypeDirectory $pluginType $pluginName]

   if { [file exists ${pluginDirectory}] == "1" } {
      set message [format $::caption(updateaudela,confirmDelete) $pluginName]
      set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
      if { $answer == "ok" } {
         #--- j'efface le plugin
         ::updateaudela::deletePlugin $pluginName $pluginType
         #--- je met a jour la liste de plugins
         ::updateaudela::plugin::fillPluginTable
      }
   } else {
      set message [format $::caption(updateaudela,directoryNotExits) $pluginDirectory]
      :console::affiche_erreur "$message\n"
      tk_messageBox -message "$message. See console" -icon error
   }
}

#------------------------------------------------------------
#  ::updateaudela::kit::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::plugin::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- frame des plugins
   set private(frm) $frm
   set private(visuNo) $visuNo
   set private(pluginTable) $frm.plugin.table
   TitleFrame $frm.plugin -borderwidth 2 -text $::caption(updateaudela,pluginFrame)

      #--- table des plugins
      #---   l'option setfocus est necessaire pour activer la molette de la souris
      scrollbar $frm.plugin.ysb -command "$frm.plugin.table yview"
      scrollbar $frm.plugin.xsb -command "$frm.plugin.table xview" -orient horizontal
      tablelist::tablelist $frm.plugin.table \
         -columns [ list \
            8 "Type" left  \
            12 "Name" left  \
            10 "Title" center \
            8  "Version" center \
            ] \
         -xscrollcommand [list $frm.plugin.xsb set] -yscrollcommand [list $frm.plugin.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -selectmode single \
         -exportselection 0 \
         -showarrow 1 \
         -stretch 2 \
         -setfocus 1 \
         -activestyle none

      bind $frm.plugin.table <<ListboxSelect>>  [list ::updateaudela::plugin::onSelectPlugin  ]

      #--- frame des boutons
      frame $frm.plugin.button -borderwidth 0
         Button $frm.plugin.button.refresh -text "$caption(updateaudela,refresh)" \
            -command "::updateaudela::plugin::fillPluginTable"
         Button $frm.plugin.button.delete  -text "$caption(updateaudela,delete)" \
            -command "::updateaudela::plugin::deletePlugin"
         Button $frm.plugin.button.moreInfo -text $::caption(updateaudela,moreInfo) \
            -command "::updateaudela::plugin::showPluginHelp"
         Button $frm.plugin.button.makeKit -text "$caption(updateaudela,makeKit)" \
            -command "::updateaudela::plugin::makeKit"

         grid $frm.plugin.button.delete    -row 0 -column 1
         grid $frm.plugin.button.moreInfo  -row 0 -column 2
         grid $frm.plugin.button.refresh   -row 0 -column 3
         grid $frm.plugin.button.makeKit   -row 0 -column 4   -padx 4 -pady 2

      grid $frm.plugin.table         -in [$frm.plugin getframe] -row 0 -column 0 -sticky nsew
      grid $frm.plugin.ysb           -in [$frm.plugin getframe] -row 0 -column 1 -sticky nsew
      grid $frm.plugin.xsb           -in [$frm.plugin getframe] -row 1 -column 0 -sticky ew
      grid $frm.plugin.button        -in [$frm.plugin getframe] -row 2 -column 0 -columnspan 2 -sticky ewns
      grid rowconfig    [$frm.plugin getframe] 0 -weight 1
      grid columnconfig [$frm.plugin getframe] 0 -weight 1

   grid $frm.plugin         -row 0 -column 0 -sticky ewns

   grid rowconfig    $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1

   set private(pluginDirectory) $::updateaudela::private(pluginDirectory)
   #--- je remplis la table
   fillPluginTable

 }

#------------------------------------------------------------
#  ::testaudela::plugin::fillPluginTable
#  affiche la liste des plugins dans la table des plugins
#  param : aucun
#------------------------------------------------------------
proc ::updateaudela::plugin::fillPluginTable { } {
   variable private

   #--- je vide la table
   $private(pluginTable) delete 0 end

   #--- je recupere le plugin de Audela
   set pkgIndexFileName [file join $::audace(rep_install) bin pkgIndex.tcl]
   if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
      $private(pluginTable) insert end [list "$pluginInfo(type)" "$pluginInfo(name)" "$pluginInfo(title)" "$pluginInfo(version)" "" ]
   } else {
      ::console::affiche_erreur "Error reading $pkgIndexFileName :\n$::errorInfo\n\n"
   }

   #--- je recupere la liste de types de plugin ( noms des sous-repertoires de private(pluginDirectory))
   set pluginTypeList [lsort -dictionary [glob -nocomplain -dir $private(pluginDirectory) -type d "*"]]
   #--- je remplis la table des plugins
   foreach typeDirectory $pluginTypeList {
      set pluginType [file tail $typeDirectory]

      #--- je recherche la liste des plugins
      set pkgIndexList [lsort -dictionary [glob -nocomplain -dir $typeDirectory -join * pkgIndex.tcl ]]
      foreach pkgIndexFileName $pkgIndexList {
         if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
            $private(pluginTable) insert end [list "$pluginInfo(type)" "$pluginInfo(name)" "$pluginInfo(title)" "$pluginInfo(version)" "" ]
         } else {
            ::console::affiche_erreur "Error reading $pkgIndexFileName:\n$::errorInfo\n\n"
         }
      }
   }

}

#------------------------------------------------------------
#  ::updateaudela::plugin::onSelectPlugin { }
#     affiche les informations du plugin
#------------------------------------------------------------
proc ::updateaudela::plugin::onSelectPlugin {  } {
   variable private

   set rowIndex [$private(pluginTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error: No plugin selected." -icon error
      return
   }
   set pluginName [$private(pluginTable) cellcget $rowIndex,1 -text]
   set pluginType [$private(pluginTable) cellcget $rowIndex,0 -text]
   set pluginDirectory [::updateaudela::getTypeDirectory $pluginType $pluginName]
   set pkgIndexFileName [file join $pluginDirectory pkgIndex.tcl]

   if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
      $private(frm).plugin.button.delete   configure -state normal
      $private(frm).plugin.button.moreInfo configure -state normal
      $private(frm).plugin.button.makeKit  configure -state normal
   } else {
      $private(frm).plugin.button.delete   configure -state disabled
      $private(frm).plugin.button.moreInfo configure -state disabled
      $private(frm).plugin.button.makeKit  configure -state disabled
   }

}

#------------------------------------------------------------
#  ::updateaudela::makeKit { }
#     affiche la fenetre de fabrication d'un kit
#------------------------------------------------------------
proc ::updateaudela::plugin::makeKit { } {
   variable private

   set rowIndex [$private(pluginTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error : no plugin selected" -icon error
      return
   }
   set pluginName [$private(pluginTable) cellcget $rowIndex,1 -text]
   set pluginType [$private(pluginTable) cellcget $rowIndex,0 -text]

   if { $pluginName == "audela" && $pluginType == "audela" } {
      #--- fabrication d'un kit de mise a jour du coeur de audela
      ::updateaudela::makecore::run $::updateaudela::private(base) $private(visuNo)"
   } else {
      #--- fabrication d'un kit de mise a jour d'un plugin
      ::updateaudela::makePluginUpdate::run $::updateaudela::private(base) $private(visuNo) $pluginType $pluginName
   }
}

#------------------------------------------------------------
#  ::updateaudela::plugin::showPluginHelp
#     affiche l'aide d'un plugin
#------------------------------------------------------------
proc ::updateaudela::plugin::showPluginHelp { } {
   variable private

   set rowIndex [$private(pluginTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error: No plugin selected." -icon error
      return
   }

   set pluginName [$private(pluginTable) cellcget $rowIndex,1 -text]
   set pluginType [$private(pluginTable) cellcget $rowIndex,0 -text]

   if { $pluginType != "audela" } {
      ::audace::showHelpPlugin [::audace::getPluginTypeDirectory $pluginType] $pluginName [ $pluginName\::getPluginHelp ]
   } else {
      ::audace::showMain
   }
}

#------------------------------------------------------------
#------------------------------------------------------------
namespace eval ::updateaudela::makecore {

}

#------------------------------------------------------------
#  ::updateaudela::makecore::run
#     affiche la fenetre de fabrication de mise a jour du
#     coeur de Audela
#------------------------------------------------------------
proc ::updateaudela::makecore::run { base visuNo } {
   variable private

   if { ! [ info exists ::conf(updateaudela,makecorePosition) ] }   { set ::conf(updateaudela,makecorePosition)     "300x200+250+75" }

   set private(this) "$base.updateaudela.makecore"
   set private(previousVersion) "AUDELA-1-4-0-BETA2"
   set private(currentVersion) "AUDELA-1-4-0"
   set private(major) $::audela(major)
   set private(minor) $::audela(minor)
   set private(date)  $::audela(date)
   if { [winfo exists $private(this) ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private(this) [namespace current] -modal 0 -geometry $::conf(updateaudela,makecorePosition) -resizable 1
   } else {
      focus $private(this)
   }
}
#------------------------------------------------------------
#  ::updateaudela::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::makecore::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- frame de fichiers selectionnes
   TitleFrame $frm.files -borderwidth 2 -text $caption(updateaudela,selectedFiles)
      set private(fileTable) $frm.files.table
      scrollbar $frm.files.ysb -command "$private(fileTable) yview"
      scrollbar $frm.files.xsb -command "$private(fileTable) xview" -orient horizontal
      tablelist::tablelist $private(fileTable) \
         -columns [ list \
            20 "Directory" left  \
            20 "File" left \
            ] \
         -xscrollcommand [list $frm.files.xsb set] -yscrollcommand [list $frm.files.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -selectmode single \
         -exportselection 0 \
         -showarrow 1 \
         -stretch 0 \
         -setfocus 1 \
         -activestyle none

      grid $private(fileTable) -in [$frm.files getframe] -row 0 -column 0 -sticky ewns
      grid $frm.files.ysb      -in [$frm.files getframe] -row 0 -column 1 -sticky ewns
      grid $frm.files.xsb      -in [$frm.files getframe] -row 1 -column 0 -sticky ew
      grid rowconfig    [$frm.files getframe]  0 -weight 1
      grid columnconfig [$frm.files getframe]  0 -weight 1

   #--- frame des boutons
   frame $frm.button -borderwidth 0

      frame $frm.button.cvs -borderwidth 2
         ###Button $frm.button.cvs.addCvs -text "$caption(updateaudela,addCvs)" \
         ###   -command "::updateaudela::makecore::addCvs"
         ###LabelEntry $frm.button.cvs.previousVersion -label "" \
         ###   -labeljustify left -labelwidth 20 -justify left \
         ###   -textvariable ::updateaudela::makecore::private(previousVersion)
         ###LabelEntry $frm.button.cvs.currentVersion -label "$caption(updateaudela,currentVersion)" \
         ###   -labeljustify left -labelwidth 20  -justify left \
         ### -textvariable ::updateaudela::makecore::private(currentVersion)
         LabelEntry $frm.button.cvs.major -label "Release Major" \
            -labeljustify left -labelwidth 4 -justify left \
            -textvariable ::updateaudela::makecore::private(major)
         LabelEntry $frm.button.cvs.minor -label ".minor" \
           -labeljustify left -labelwidth 4 -justify left \
           -textvariable ::updateaudela::makecore::private(minor)
         LabelEntry $frm.button.cvs.major -label "date" \
           -labeljustify left -labelwidth 10 -justify left \
           -textvariable ::updateaudela::makecore::private(date)

         Button $frm.button.cvs.listfile -text "Make list" \
               -command "::updateaudela::makecore::makeFileList"

         #pack $frm.button.cvs.addCvs -side left -padx 4
         #pack $frm.button.cvs.previousVersion -side left -padx 4
         #pack $frm.button.cvs.currentVersion -side left -padx 4

         ###grid $frm.button.cvs.addCvs  -row 0 -column 0 -rowspan 2 -sticky ew -padx 4 -pady 2
         ###grid $frm.button.cvs.previousVersion  -row 0 -column 1 -sticky ewns -padx 4 -pady 2
         ###grid $frm.button.cvs.currentVersion   -row 1 -column 1 -sticky ewns -padx 4 -pady 2
         ###grid columnconfig $frm.button.cvs 1 -weight 1

      ###Button $frm.button.add -text "$caption(updateaudela,addFile) ..." \
      ###   -command "::updateaudela::makecore::addFile"
      ###Button $frm.button.remove -text "$caption(updateaudela,removeFile)" \
      ###   -command "::updateaudela::makecore::removeFile"
      ###Button $frm.button.create -text "$caption(updateaudela,createCoreUpdate)" \
      ###   -command "::updateaudela::makecore::makeKit"

      grid $frm.button.cvs     -row 0 -column 0 -columnspan 3 -sticky ewns -padx 4 -pady 2
      grid $frm.button.add     -row 1 -column 0 -sticky ewns -padx 4
      grid $frm.button.remove  -row 1 -column 1 -sticky ewns -padx 4
      grid $frm.button.create  -row 1 -column 2 -sticky ewns -padx 4

   grid $frm.files      -row 0 -column 0 -sticky ewns
   grid $frm.button     -row 1 -column 0 -sticky ewns
   grid rowconfig    $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1

}

#------------------------------------------------------------
#  ::updateaudela::makecore::cmdClose
#  recupere la position de l'outil apres appui sur Fermer
#------------------------------------------------------------
proc ::updateaudela::makecore::cmdClose { visuNo } {
   variable private

   #--- je sauve la taille et la position de la fenetre
   set ::conf(updateaudela,makecorePosition) [winfo geometry [winfo toplevel $private(this) ]]
}

#------------------------------------------------------------
#  ::updateaudela::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::makecore::getLabel { } {
   return "$::caption(updateaudela,makeCoreUpdate)"
}

#------------------------------------------------------------
#  ::updateaudela::makecore::addFile
#   ajoute un fichier dans la liste
#------------------------------------------------------------
proc ::updateaudela::makecore::makeFileList {  } {
   variable private

   ###global tab result resultfile f base0 make level

   set version "$::private(major).$private(minor).20100228"
   set makes audela

   foreach make $makes {

      ::console::affiche_resultat "make $make\n"
      ###set base "[file dirname [info script]]/../../../"
      set base $::audela(rep_install)
      set base0 "$base"
      set tab 0
      if {$base=="."} {
         set base [pwd]
      }

      if {($make=="audela")||($make=="bin")} {
         # --- efface les fichiers en trop dans images
         set fimas [glob -nocomplain "${base}/images/*"]
         set fima0s {47toucan.jpg c2.gif c2w.gif m57.fit tempel1_IC.fit CVS}
         foreach fima $fimas {
            set shortname [file tail $fima]
            if {[lsearch -exact $fima0s $shortname ]==-1} {
               ::console::affiche_resultat "Efface $fima\n"
               file delete -force "$fima"
            }
         }
         # --- efface les fichiers en trop dans bin
         file delete -force "${base}/bin/audela.log"
         #file delete _force "${base}/bin/audace.txt"
      }

      if {$make=="audela"} {
         set resultfile "${base}/src/tools/innosetup/audela-${version}.iss"

         set result    "; Script generated by the Inno Setup Script Wizard.\n"
         append result "; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!\n"
         append result "\n"
         append result "\[Setup\]\n"
         append result "AppName=AudeLA\n"
         append result "AppVerName=Audela-${version}\n"
         append result "AppPublisher=My Company, Inc.\n"
         append result "AppPublisherURL=http://www.audela.org\n"
         append result "AppSupportURL=http://www.audela.org\n"
         append result "AppUpdatesURL=http://www.audela.org\n"
         append result "DefaultDirName={pf}\\audela-${version}\n"
         append result "DefaultGroupName=Audela\n"
         append result "LicenseFile=licence.txt\n"
         append result "InfoBeforeFile=before.txt\n"
         append result "InfoAfterFile=after.txt\n"
         append result "UsePreviousAppDir=no\n"
         append result "; uncomment the following line if you want your installation to run on NT 3.51 too.\n"
         append result "; MinVersion=4,3.51\n"
         append result "\n"
         append result "\[Tasks\]\n"
         append result "Name: \"desktopicon\"; Description: \"Create a &desktop icon\"; GroupDescription: \"Additional icons:\"; MinVersion: 4,4\n"
         append result "\n"
         append result "\[Files\]\n"

         set f [open $resultfile w]
         puts -nonewline $f "$result"
         close $f
         set result ""
         analdir $base

         set result    "\n"
         append result "\[Icons\]\n"
         append result "Name: \"{group}\\AudeLA-${version}\"; Filename: \"{app}\\bin\\audela.exe\" ; WorkingDir: \"{app}\\bin\" \n"
         append result "Name: \"{userdesktop}\\AudeLA-${version}\"; Filename: \"{app}\\bin\\audela.exe\" ; WorkingDir: \"{app}\\bin\" ; MinVersion: 4,4; Tasks: desktopicon\n"
         append result "\n"
         append result "\[Run\]\n"
         append result "Filename: \"{app}\\bin\\audela.exe\"; WorkingDir: \"{app}\\bin\" ; Description: \"Launch AudeLA\"; Flags: nowait postinstall skipifsilent\n"

         set f [open $resultfile a]
         puts -nonewline $f "$result"
         close $f
      } else {
         set resultfile "${base}src/tools/innosetup/audela_${make}-${version}.txt"
         file delete -force -- "$resultfile"
         set result ""
         analdir $base

         file delete -force -- ${base}/src/tools/innosetup/audela_${make}-${version}.zip
         set f [open $resultfile r]
         set lignes [split [read $f] \n]
         close $f
         foreach ligne $lignes {
            if {[string length $ligne]<1} {
               continue
            }
            file mkdir [file dirname "${base}src/tools/innosetup/Output/[lindex $ligne 1]"]
            file copy -force -- "[lindex $ligne 0]" "${base}src/tools/innosetup/Output/[lindex $ligne 1]"
            #::console::affiche_resultat "$lignexe\n"
         }
         if {$make!="bin"} {
            set lignexe "exec zip -r \"${base}src/tools/innosetup/Output/audela_${make}-${version}.zip\" \"${make}\""
            set pwd0 [pwd]
            cd ${base}src/tools/innosetup/Output
            set err [catch {eval $lignexe} msg]
            cd $pwd0
            file rename -force -- "${base}src/tools/innosetup/Output/audela_${make}-${version}.zip" "${base}src/tools/innosetup/audela_${make}-${version}.zip"
         } else {
            set dossiers [glob ${base}src/tools/innosetup/Output/*]
            foreach dossier $dossiers {
               set a [file isdirectory $dossier]
               if {$a==1} {
                  set lignexe "exec zip -r \"${base}src/tools/innosetup/Output/audela_${make}-${version}.zip\" \"[file tail $dossier]\""
               }
               set pwd0 [pwd]
               cd ${base}src/tools/innosetup/Output
               set err [catch {eval $lignexe} msg]
               cd $pwd0
            }
            file rename -force -- "${base}src/tools/innosetup/Output/audela_${make}-${version}.zip" "${base}src/tools/innosetup/audela_${make}-${version}.zip"
         }
         foreach ligne $lignes {
            if {[string length $ligne]<1} {
               continue
            }
            set fichier "${base}src/tools/innosetup/Output/[lindex $ligne 1]"
            file delete -force -- $fichier
            file delete -force -- "[file dirname $fichier]"
         }

      }
   }
}

proc ::updateaudela::makecore::analdir { base } {
   global tab result resultfile f base0 make
   set listfiles ""
   set a [catch {set listfiles [glob ${base}/*]} msg]
   if {$a==0} {
      # --- tri des fichiers dans l'ordre chrono decroissant
      set listdatefiles ""
      foreach thisfile $listfiles {
         set a [file isdirectory $thisfile]
         if {$a==0} {
            set datename [file mtime $thisfile]
            lappend listdatefiles [list $datename $thisfile]
         }
      }
      set listdatefiles [lsort -decreasing $listdatefiles]
      # --- affiche les fichiers
      foreach thisdatefile $listdatefiles {
         set thisfile [lindex $thisdatefile 1]
         set a [file isdirectory $thisfile]
         if {$a==0} {
            set shortname [file tail "$thisfile"]
            set dirname [file dirname "$thisfile"]
            set sizename [expr 1+int([file size "$thisfile"]/1000)]
            set datename [file mtime "$thisfile"]
            if {$datename==-1} {
               set datename 0000-00-00T00:00:00
            } else {
               set datename [clock format [file mtime $thisfile] -format %Y-%m-%dT%H:%M:%S ]
            }

            # Formattage du nom du fichier source et repertoire destination pour ISS
            regsub -all / "$thisfile" \\ name1
            regsub -all ${base0} "$thisfile" "\{app\}/" name2
            regsub -all / "[ file dirname $name2 ]" \\ name2

            # Formattage du nom du fichier source et repertoire destination pour ZIP
            regsub -all ${base0} "$thisfile" "./" name3
            set repertoires [split "$name3" /]
            set level [llength $repertoires]

            # Traitement des cas particuliers
            if {[string range $shortname 0 1]==".#"} {
               catch {file delete -force -- "$thisfile"}
               continue
            }
            if {$shortname=="modifications audela-1.4.0-beta1.xls"} {
               continue
            }
            if {($make=="ros")&&(($shortname=="ros_install.log")||($shortname=="ros_install_lastconfig.tcl")||($shortname=="root.tcl"))} {
               continue
            }
            if {(($make=="audela")||($make=="bin"))&&($shortname=="readme.txt")&&($level==2)} {
               continue
            }
            if {(($make=="audela")||($make=="bin"))&&($shortname=="audace.txt")&&($level==3)} {
               continue
            }
            if {(($make=="audela")||($make=="bin"))&&($level==3)} {
               if { $shortname=="audace.txt"
                  || $shortname=="audela.pl"
                  || $shortname=="audela.sh"
                  || $shortname=="makefile"
                  || $shortname=="pkgIndex.tcl.in"
                  || $shortname=="version.tcl.in"
                  || $shortname=="Makefile"
                  || $shortname=="default.nnw"
                  || $shortname=="config.sex"
                  || $shortname=="config.param"
                  || $shortname=="tt_last.err"
                  || $shortname=="tt.err"
               } {
                  continue
               }
            }
            if {(($make=="audela")||($make=="bin"))&&($level==4)} {
               if { $shortname=="config.ini"
                  || $shortname=="config.bak"
                  || $shortname=="audace.ini"
                  || $shortname=="audace.bak"
               } {
                  continue
               }
            }

            if {(($make=="audela")||($make=="bin"))&&($level==5)} {
               if { $shortname=="fonction_transfert.pal"

               } {
                  continue
               }
            }
            if {($make=="audela") && ($shortname=="PortTalk.sys")} {
               append result "Source: \"$name1\"; DestDir: \"$name2\"; \n"
            }
            set extension [file extension "$thisfile"]
            if {(($make!="audela")&&($make!="bin")) && (($extension == ".sbr") || ($extension == ".opt") || ($extension == ".ncb")) } {
               continue
            }
            if {($make=="audela") && (($extension==".vxd") || ($extension==".VXD"))} {
               set name2 "{sys}"
            }
            if {($make=="audela") && ($extension==".sys")} {
               set name2 "{sys}\\drivers"
            }
            if {$make=="audela"} {
               append result "Source: \"$name1\"; DestDir: \"$name2\"; \n"
            } else {
               append result "\"$thisfile\" \"$name3\"\n"
            }
         }
      }
      set f [open $resultfile a]
      puts -nonewline $f "$result"
      close $f
      set result ""
      foreach thisfile $listfiles {
         set a [file isdirectory $thisfile]
         if {$a==1} {
            regsub -all ${base0} "$thisfile" "./" name3
            set repertoires [split "$name3" /]
            set level [llength $repertoires]
            incr tab 1
            set shortname [file tail $thisfile]
            set datename [file mtime $thisfile]
            set extension [file extension $shortname]
            if {$datename==-1} {
               set datename 0000-00-00T00:00:00
            } else {
               set datename [clock format [file mtime $thisfile] -format %Y-%m-%dT%H:%M:%S ]
            }
            #::console::affiche_resultat ">>>> $thisfile => $make => [lindex $repertoires 1] / [lindex $repertoires 2]\n"
            if {(($make=="audela")||($make=="bin")) && !( ([lindex $repertoires 1]=="gui") || ([lindex $repertoires 1]=="bin") || ([lindex $repertoires 1]=="lib") || ([lindex $repertoires 1]=="images") ) } {
               continue
            } elseif { (($make!="audela")&&($make!="bin")) && ($make!=[lindex $repertoires 1]) } {
               #::console::affiche_resultat ">>>> EXPLORATION\n"
               continue
            }
            if {($make=="ros") && ( ([lindex $repertoires 2]=="logs") || ([lindex $repertoires 2]=="ressources") || ([lindex $repertoires 2]=="catalogs") || ([lindex $repertoires 2]=="data") || ([lindex $repertoires 2]=="extinctionmaps")  ) } {
               continue
            }
            #::console::affiche_resultat "= $thisfile"
            if { ([file tail $thisfile] != "CVS") && ([file tail $thisfile] != ".svn") && ([file tail $thisfile] != "Debug") && ([file tail $thisfile] != "Release") && ([file tail $thisfile] != "Output") } {
               analdir $thisfile
            }
         }
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::makecore::addFile
#   ajoute un fichier dans la liste
#------------------------------------------------------------
proc ::updateaudela::makecore::addFile {  } {
   variable private

   #--- j'ouvre la fenetre de selection des fichiers
   set fileList [ tk_getOpenFile \
      -multiple 1 \
      -title $::caption(updateaudela,title) \
      -initialdir $::audace(rep_install) \
      -parent $private(this) \
   ]

   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- Car sous Linux la fenetre n'est pas detruite a la fin de l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }

   set tableFileList [$private(fileTable) get 0 end]
   #--- j'ajoute les fichiers dans la table
   foreach fullFileName  $fileList {
      if { [string first "$::audace(rep_install)/" $fullFileName] == 0 } {
         #--- je convertis le chemin absolu en chemin relatif
         set fileDirectory [file dirname $fullFileName]
         set fileDirectory [string range $fileDirectory [string length "$::audace(rep_install)/"] end]
         set fileName [file tail $fullFileName]
         #--- je verifie que la ligne n'existe pas deja
         if { [lsearch $tableFileList [list $fileDirectory $fileName]] == -1 } {
            #--- j'ajoute le fichier dans une nouvelle ligne de la table
            $private(fileTable) insert end [list $fileDirectory $fileName ]
         }
      } else {
         tk_messageBox -message "$::caption(updateaudela,fileOutside)\n$fileName" -icon error -title $::caption(updateaudela,title)
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::makecore::addCvs
#   ajoute les noms des fichiers modifies de CVS dans la table
#------------------------------------------------------------
proc ::updateaudela::makecore::addCvs { { previousVersion ""} {currentVersion ""} } {
   variable private

   if { $previousVersion == "" } {
      set previousVersion $private(previousVersion)
   }

   if { $currentVersion == "" } {
      set currentVersion $private(currentVersion)
   }

   #--- je cherche les fichiers modifies dans audela/bin
   set diffModule "audela/bin"
   set catchError [catch {
        exec cvs -q rdiff -s -r $previousVersion -r $currentVersion $diffModule
   } difflog]
   if { $catchError != 0 } {
       console::disp "error=$::errorInfo\n"
       tk_messageBox -message "$::errorInfo. See console" -icon error -title $::caption(updateaudela,title)
       return
   }
   set lines [split $difflog "\n"]
   set nblines [llength $lines]
   console::disp "nblines1=$nblines\n"

   set tableFileList [$private(fileTable) get 0 end]
   foreach line $lines {
      #--- j'ajoute les fichiers dans la table
      if { [string first "File audela/" $line] == 0 } {
         set relativeFilename [lindex [string range $line 12 end] 0]
         set fileDirectory [file dirname $relativeFilename]
         set fileName [file tail $relativeFilename]
         #--- je verifie que la ligne n'existe pas deja
         if { [lsearch $tableFileList [list $fileDirectory $fileName]] == -1 } {
            #--- j'ajoute le fichier dans une nouvelle ligne de la table
            $private(fileTable) insert end [list $fileDirectory $fileName ]
         }
      }
   }

   #--- je cherche les fichiers modifies dans audela/gui
   set diffModule "audela/gui"
   set catchError [catch {
        exec cvs -q rdiff -s -r $previousVersion  -r $currentVersion $diffModule
   } difflog]
   if { $catchError != 0 } {
       console::disp "error=$::errorInfo\n"
       tk_messageBox -message "$::errorInfo. See console" -icon error -title $::caption(updateaudela,title)
       return
   }
   set lines [split $difflog "\n"]
   set nblines [llength $lines]
   console::disp "nblines=$nblines\n"
   foreach line $lines {
      #--- j'ajoute les fichiers dans la table (excepte les fichiers des plugins)
      if { [string first "File audela/" $line] == 0 } {
         set relativeFilename [lindex [string range $line 12 end] 0]
         set fileDirectory [file dirname $relativeFilename]
         set fileName [file tail $relativeFilename]
         #--- je verifie que la ligne n'existe pas deja
         if { [lsearch $tableFileList [list $fileDirectory $fileName]] == -1 } {
            #--- j'ajoute le fichier dans une nouvelle ligne de la table
            $private(fileTable) insert end [list $fileDirectory $fileName ]
         }
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::makecore::removeFile
#   supprime les fichiers selectionnes dans la liste
#------------------------------------------------------------
proc ::updateaudela::makecore::removeFile {  } {
   variable private

   set rowIndex [$private(fileTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error : no file selected" -icon error  -title $::caption(updateaudela,title)
      return
   }
   $private(fileTable) delete $rowIndex
}

#------------------------------------------------------------
#  ::updateaudela::makecore::makeKit
#    cree le fichier de mise à jour
#------------------------------------------------------------
proc ::updateaudela::makecore::makeKit { { fileList "" } } {
   variable private

   if { $fileList == "" } {
      #--- je copie le contenu de la table
      set rowList [$private(fileTable) get 0 end]
      foreach row $rowList {
         set relativeFileName [file join [lindex $row 0] [lindex $row 1] ]
         lappend fileList $relativeFileName
         ##console::disp "file: $ relativeFileName\n"
      }
   }

   set kitFileName  "audela-$::audela(version).kit"
   set kitFileFullName  [file join $::updateaudela::private(kitDirectory) $kitFileName]
   if { [file exists $kitFileFullName] == 1 } {
      set message [format $::caption(updateaudela,fileExists) $kitFileFullName]
      set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
      if { $answer == "cancel" } {
         return
      }
   }

   ::updateaudela::makeKit $kitFileFullName $::audace(rep_install) $fileList
   ::updateaudela::addFileToKit $kitFileFullName "pkgIndex.tcl" "package ifneeded audela 1.4.0 \[ list source \[ file join \$dir bin version.tcl \] \]"

   #--- j'actualise la liste des kits
   ::updateaudela::kit::fillKitTable
   ::updateaudela::kit::onSelectKitFile

   #--- j'affiche un message OK
   set message [format $::caption(updateaudela,makeKitOk) $kitFileName]
   tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
}

#------------------------------------------------------------
#------------------------------------------------------------
namespace eval ::updateaudela::makePluginUpdate {

}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::run
#     affiche la fenetre de fabrication de mise a jour du
#     coeur de Audela
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::run { base visuNo pluginType pluginName} {
   variable private

   if { ! [ info exists ::conf(updateaudela,makePluginUpdatePosition) ] }   { set ::conf(updateaudela,makePluginUpdatePosition)     "300x200+250+75" }

   set private(pluginType) $pluginType
   set private(pluginName) $pluginName
   set private(pluginDirectory) [::updateaudela::getTypeDirectory $private(pluginType) $private(pluginName)]
   set private(this) "$base.updateaudela.makePluginUpdate"
   if { [winfo exists $private(this) ] == 0 } {
      #--- j'affiche la fenetre
      ::confGenerique::run $visuNo $private(this) [namespace current] -modal 0 -geometry $::conf(updateaudela,makePluginUpdatePosition) -resizable 1
      #--- je remplis la table avec les noms des fichiers du plugin
      addAllFiles
   } else {
      focus $private(this)
   }
}
#------------------------------------------------------------
#  ::updateaudela::fillConfigPage { }
#  fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::fillConfigPage { frm visuNo } {
   variable private
   global caption

   #--- frame de fichiers selectionnes
   TitleFrame $frm.files -borderwidth 2 -text $caption(updateaudela,selectedFiles)
      LabelEntry $frm.files.directory -label $caption(updateaudela,rep_plugin) \
          -labeljustify left -width 0 -padx 2 -justify left -editable 0 \
          -textvariable ::updateaudela::makePluginUpdate::private(pluginDirectory)

      set private(fileTable) $frm.files.table
      scrollbar $frm.files.ysb -command "$private(fileTable) yview"
      scrollbar $frm.files.xsb -command "$private(fileTable) xview" -orient horizontal
      tablelist::tablelist $private(fileTable) \
         -columns [ list \
            20 "Directory" left  \
            20 "File" left \
            ] \
         -xscrollcommand [list $frm.files.xsb set] -yscrollcommand [list $frm.files.ysb set] \
         -labelcommand "tablelist::sortByColumn" \
         -selectmode single \
         -exportselection 0 \
         -showarrow 1 \
         -stretch 0 \
         -setfocus 1 \
         -activestyle none

      grid $frm.files.directory -in [$frm.files getframe] -row 0 -column 0 -columnspan 2 -sticky ewns
      grid $private(fileTable) -in [$frm.files getframe] -row 1 -column 0 -sticky ewns
      grid $frm.files.ysb      -in [$frm.files getframe] -row 1 -column 1 -sticky ewns
      grid $frm.files.xsb      -in [$frm.files getframe] -row 2 -column 0 -sticky ew
      grid rowconfig    [$frm.files getframe]  1 -weight 1
      grid columnconfig [$frm.files getframe]  0 -weight 1

   #--- frame des boutons
   frame $frm.button -borderwidth 0

      Button $frm.button.addAllFiles -text "$caption(updateaudela,addAllFiles)" \
            -command "::updateaudela::makePluginUpdate::addAllFiles"
      Button $frm.button.add -text "$caption(updateaudela,addFile) ..." \
         -command "::updateaudela::makePluginUpdate::addFile"
      Button $frm.button.remove -text "$caption(updateaudela,removeFile)" \
         -command "::updateaudela::makePluginUpdate::removeFile"
      Button $frm.button.create -text "$caption(updateaudela,createCoreUpdate)" \
         -command "::updateaudela::makePluginUpdate::makeKit"

      grid $frm.button.addAllFiles -row 0 -column 0 -sticky ewns -padx 4
      grid $frm.button.add     -row 0 -column 1 -sticky ewns -padx 4
      grid $frm.button.remove  -row 0 -column 2 -sticky ewns -padx 4
      grid $frm.button.create  -row 1 -column 0 -columnspan 3 -sticky ns -padx 4 -pady 2

   grid $frm.files      -row 0 -column 0 -sticky ewns
   grid $frm.button     -row 1 -column 0 -sticky ewns
   grid rowconfig    $frm 0 -weight 1
   grid columnconfig $frm 0 -weight 1

}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::cmdClose
#  recupere la position de l'outil apres appui sur Fermer
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::cmdClose { visuNo } {
   variable private

   #--- je sauve la taille et la position de la fenetre
   set ::conf(updateaudela,makePluginUpdatePosition) [winfo geometry [winfo toplevel $private(this) ]]
}

#------------------------------------------------------------
#  ::updateaudela::getLabel
#  retourne le nom de la fenetre de configuration
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::getLabel { } {
   variable private
   return "$::caption(updateaudela,makePluginUpdate) $private(pluginName)"
}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::addFile
#   ajoute un fichier dans la liste
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::addFile {  } {
   variable private

   #--- j'ouvre la fenetre de selecion des fichiers
   set fileList [ tk_getOpenFile \
      -multiple 1 \
      -title $::caption(updateaudela,title) \
      -initialdir $private(pluginDirectory) \
      -parent $private(this) \
   ]

   catch {
      #--- Je detruis la boite de dialogue cree par tk_getOpenFile
      #--- Car sous Linux la fenetre n'est pas detruite a la fin de l'utilisation (bug de linux ?)
      destroy $parent.__tk_filedialog
   }

   set tableFileList [$private(fileTable) get 0 end]
   #--- j'ajoute les fichiers dans la table
   foreach fullFileName  $fileList {
      if { [string first "$private(pluginDirectory)/" $fullFileName] == 0 } {
         #--- je convertis le chemin absolu en chemin relatif
         set fileDirectory [file dirname $fullFileName]
         set fileDirectory [string range $fileDirectory [string length "$private(pluginDirectory)/"] end]
         set fileName [file tail $fullFileName]
         #--- je verifie que la ligne n'existe pas deja
         if { [lsearch $tableFileList [list $fileDirectory $fileName]] == -1 } {
            #--- j'ajoute le fichier dans une nouvelle ligne de la table
            $private(fileTable) insert end [list $fileDirectory $fileName ]
         }
      } else {
         tk_messageBox -message "$::caption(updateaudela,fileOutside)\n$fullFileName" -icon error -title $::caption(updateaudela,title)
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::addFiles
#   ajoute les noms des fichiers du repertoire du plugin
#   dans la sélection
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::addAllFiles {  } {
   variable private

   set dirs [list $private(pluginDirectory) ]
   set fileList ""
   #--- recherche recusive des fichiers dans le repertoire du plugin
   while {[llength $dirs] > 0} {
      set dir [lindex $dirs 0]
      set dirs [lrange $dirs 1 end]
      set entries [glob -nocomplain [file join $dir *]]
      foreach path [lsort $entries] {
         if {[file isdir $path]} {
            if { [ string tolower [file tail $path]] != "cvs" } {
               lappend dirs $path
            }
         } else {
           #--- je conserve que le chemin relatif
           lappend fileList $path
         }
      }
   }

   ###::console::disp "fileList=$fileList\n"

   #--- je recupere les noms des fichiers deja presents dans la table
   set tableFileList [$private(fileTable) get 0 end]
   #--- j'ajoute les noms des fichiers
   foreach fullFileName $fileList {
      #--- j'ajoute les fichiers dans la table
      if { [string first "$private(pluginDirectory)/" $fullFileName] == 0 } {
         #--- je convertis le chemin absolu en chemin relatif
         set fileDirectory [file dirname $fullFileName]
         set fileDirectory [string range $fileDirectory [string length "$private(pluginDirectory)/"] end]
         set fileName [file tail $fullFileName]
         #--- je verifie que le fichier n'existe pas deja dans la selection
         if { [lsearch $tableFileList [list $fileDirectory $fileName]] == -1 } {
            #--- j'ajoute le fichier dans une nouvelle ligne de la table
            $private(fileTable) insert end [list $fileDirectory $fileName ]
         }
      } else {
         tk_messageBox -message "$::caption(updateaudela,fileOutside)\n$fullFileName" -icon error -title $::caption(updateaudela,title)
      }
   }
}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::removeFile
#   supprime les fichiers selectionnes dans la liste
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::removeFile {  } {
   variable private

   set rowIndex [$private(fileTable) curselection]
   if { $rowIndex == "" } {
      tk_messageBox -message "Error : no file selected" -icon error  -title $::caption(updateaudela,title)
      return
   }
   $private(fileTable) delete $rowIndex
}

#------------------------------------------------------------
#  ::updateaudela::makePluginUpdate::makeKit
#    cree le fichier de mise à jour
#------------------------------------------------------------
proc ::updateaudela::makePluginUpdate::makeKit { } {
   variable private

   #--- je copie le contenu de la table
   set rowList [$private(fileTable) get 0 end]
   foreach row $rowList {
      set relativeFileName [file join [lindex $row 0] [lindex $row 1] ]
      lappend fileList $relativeFileName
      ##console::disp "file: $ relativeFileName\n"
   }

   set pkgIndexFileName [file join $private(pluginDirectory) pkgIndex.tcl]
   if { [::audace::getPluginInfo $pkgIndexFileName pluginInfo ] == 0 } {
      set kitFileName  "$pluginInfo(name)-$pluginInfo(version).kit"
      set kitFileFullName  [file join $::updateaudela::private(kitDirectory) $kitFileName]

      #
      if { [file exists $kitFileFullName] == 1 } {
         set message [format $::caption(updateaudela,fileExists) $kitFileFullName]
         set answer [tk_messageBox -message $message -type okcancel -icon question -title $::caption(updateaudela,title)]
         if { $answer == "cancel" } {
            return
         }
      }

      #--- je fabrique le fichier kit
      ::updateaudela::makeKit $kitFileFullName $private(pluginDirectory) $fileList
      #--- j'actualise la liste des kits
      ::updateaudela::kit::fillKitTable
      ::updateaudela::kit::onSelectKitFile
      #--- j'affiche un message OK
      set message [format $::caption(updateaudela,makeKitOk) $kitFileName]
      tk_messageBox -message $message -type ok -icon info  -title $::caption(updateaudela,title)
   } else {
     ::console::affiche_erreur "$::errorInfo\n"
     tk_messageBox -message "$::errorInfo. See console" -icon error
   }
}

