#
# Fichier : cgi_install.tcl
# Description : Please use this TCL script with AudeLA to install CGI files
# Auteur : Alain KLOTZ
# Mise à jour $Id: cgi_install.tcl 8834 2012-12-03 20:57:40Z alainklotz $
#
# source $audace(rep_install)/bin/cgi_install.tcl ; ::cgi_install::run
#

namespace eval ::cgi_install {

#--------------------------------------------------
#  ::cgi_install::get_lastconfig { }
#--------------------------------------------------
# Chargement des chemins
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::cgi_install::get_lastconfig {  } {

      global audace

      puts "Chargement de cgi_install_lastconfig.tcl "
      set err [catch {source [file join $::audela_start_dir cgi_install_lastconfig.tcl]} msg]
      return -code $err $msg
   }

#--------------------------------------------------
#  ::cgi_install::get_root { }
#--------------------------------------------------
# Chargement des chemins pour ros
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::cgi_install::get_root {  } {

      puts "Chargement de cgi_root.tcl "
      set err [catch {source [file join $::audela_start_dir cgi_root.tcl]} msg]
      return -code $err $msg
   }

   proc ::cgi_install::withtk { } {
      if {[info commands tkwait]==""} {
         return 0
      } else {
         return 1
      }
   }

#--------------------------------------------------
#  ::cgi_install::run { positionxy}
#--------------------------------------------------
# Demarrage de l interface d installation (fenetree ou ligne de commande)
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::cgi_install::run { { positionxy 20+20 } } {

      global audace caption color ros

      if {[::cgi_install::withtk]==1} {
         if { [ string length [ info commands .cgi_install.* ] ] != "0" } {
         puts "Detruit la fenetre"
         destroy .cgi_install
         }
      }

      #--- Definition of colors
      if {[::cgi_install::withtk]==1} {
         puts "Definition des couleurs"
         set audace(cgi_install,configure,color,backpad)  #F0F0FF
         set audace(cgi_install,configure,color,backdisp) $color(white)
         set audace(cgi_install,configure,color,textkey)  $color(blue_pad)
         set audace(cgi_install,configure,color,textdisp) #FF0000
      }

      #--- Initialisation of the variables
      puts "Initialisation..."
      set base $::audela_start_dir

      # --- Search for the httpd.conf file
      if { $::tcl_platform(os) == "Linux" } {
         set fichiers [glob -nocomplain "/etc/apache2/default-server.conf"]
      } else {
         set fichiers [glob -nocomplain "C:/Program Files/Apache Software Foundation/Apache2.2/conf/httpd.conf"]
      }
      set fichier [lindex $fichiers 0]
      if {$fichier!=""} {
         # --- Read the httpd.conf
         set f [open $fichier r]
         set lignes [split [read $f] \n]
         close $f
         foreach ligne $lignes {
            set k [string first # [string trim $ligne]]
            if {$k==0} {
               continue
            }
            set key "DocumentRoot"
            set k [string first $key $ligne]
            if {$k>=0} {
               set ligne [string range $ligne $k end]
               set dirhtdocs [lindex $ligne 1]
            }
            set key "ScriptAlias /cgi-bin/ "
            set k [string first $key $ligne]
            if {$k>=0} {
               set ligne [string range $ligne $k end]
               set dircgibin [lindex $ligne 2]
            }
         }
      } else {
         set dircgibin $audace(rep_install)
         set dirhtdocs $audace(rep_install)
      }

      set audace(cgi_install,base) $base

      set audace(cgi_install,variables) {htdocs cgi-bin}
      set audace(cgi_install,variables,descr) $audace(cgi_install,variables)
      set audace(cgi_install,print) ""

      set droits ""
      if { $::tcl_platform(os) == "Linux" } {
         set user [exec whoami]
         append droits "Verify you can write in the web directories."
         append droits "\nFor example:"
         append droits "\nchown -R ${user}:users $dircgibin"
         append droits "\nchown -R ${user}:users $dirhtdocs"
      } else {
         append droits "Verify you can write in the web directories."
      }

      set k 0
      foreach name $audace(cgi_install,variables) {
         set b $base
         if {[lsearch -exact "htdocs" $name]>=0} {
            set b $dirhtdocs
         }
         if {[lsearch -exact "cgi-bin" $name]>=0} {
            set b $dircgibin
         }
         set audace(cgi_install,configure,config,${name}) ${b}
         set audace(cgi_install,configure,config,${name}x) 1
      }

      set audace(cgi_install,lastconfig) $audace(cgi_install,base)/cgi_install_lastconfig.tcl
      set err [catch {::cgi_install::get_lastconfig} msg]

      if {[::cgi_install::withtk]==0} {
         ::cgi_install::print "======================================\n"
         ::cgi_install::print "ROBOTIC OBSERVATORY SOFTWARE Deployer \n"
         ::cgi_install::print "======================================\n"
         if {($err==1)&&([file exists $audace(cgi_install,lastconfig)]==1)} {
            ::cgi_install::print "Error in $audace(cgi_install,lastconfig): $msg\n"
         }
         ::cgi_install::print "\n"
         ::cgi_install::print "AUDELA/BIN folder : $audace(rep_install)/bin\n"
         set texte ""
         set k 0
         set auto 0 ; # * is a shortcut to valide default of every item
         foreach name $audace(cgi_install,variables) {
            ::cgi_install::print "\n"
            set cap_name [lindex $audace(cgi_install,variables,descr) $k]
            while {0==0} {
               ::cgi_install::print "Answer 1 if you want to deploy $cap_name (actual=$audace(cgi_install,configure,config,${name}x)): "
               if {$auto==0} {
                  gets stdin value
               } else {
                  set value $audace(cgi_install,configure,config,${name}x)
               }
               if {$value==""} {
                  set value $audace(cgi_install,configure,config,${name}x)
               }
               if {($value=="*")} {
                  set value 1
                  set auto 1
               }
               if {($value=="0")||($value=="1")} {
                  set audace(cgi_install,configure,config,${name}x) $value
                  break
               } else {
                  ::cgi_install::print "Error. Answer must be 0 or 1\n"
               }
            }
            append texte "set audace(cgi_install,configure,config,${name}x) \"$audace(cgi_install,configure,config,${name}x)\"\n"
            if {$value==1} {
               while {0==0} {
                  ::cgi_install::print "Directory of $cap_name (actual=$audace(cgi_install,configure,config,${name})): "
                  if {$auto==0} {
                     gets stdin value
                  } else {
                     set value ""
                  }
                  if {$value==""} {
                     set value $audace(cgi_install,configure,config,${name})
                  }
                  set res [file exists $value]
                  if {$res==1} {
                     set audace(cgi_install,configure,config,${name}) $value
                     ::cgi_install::print "$cap_name will be installed in $audace(cgi_install,configure,config,${name})\n"
                     break
                  } else {
                     ::cgi_install::print "Error. Directory $value not exists !\n"
                  }
               }
            }
            append texte "set audace(cgi_install,configure,config,${name}) \"$audace(cgi_install,configure,config,${name})\"\n"
            incr k
         }
         set f [open $audace(cgi_install,lastconfig) w]
         puts $f $texte
         close $f
         ::cgi_install::print "\n"
         ::cgi_install::print "Parameters are stored in $audace(cgi_install,lastconfig)\n"
         ::cgi_install::print "\n"
         ::cgi_install::print "-----------------------------------------------\n"
         if {$auto==0} {
            ::cgi_install::print "Answer 1 if you want to deploy AudeLA CGI (actual=0): "
            gets stdin value
         } else {
            ::cgi_install::print "Answer 1 if you want to deploy AudeLA CGI (actual=1): "
            set value 1
         }
         if {$value=="1"} {
            ::cgi_install::go
            ::cgi_install::print "$droits"
         } else {
            ::cgi_install::print "QUIT WITH NO DEPLOYEMENT\n\n"
         }
         cd "$audace(rep_install)/bin"

      } else {

         puts "Demarrage avec interface graphique..."
         set geomcgi(larg) 500
         set geomcgi(long) 250

         set audace(cgi_install,configure,font,c12b) [ list {Courier} 10 bold ]
         set audace(cgi_install,configure,font,c10b) [ list {Courier} 10 bold ]
         # =========================================
         # === Setting the graphic interface
         # === Met en place l'interface graphique
         # =========================================

         #--- Cree la fenetre .cgi_install de niveau le plus haut
         puts "Cree la fenetre .cgi_install de niveau le plus haut"
         toplevel .cgi_install -class Toplevel -bg $audace(cgi_install,configure,color,backpad)
         wm geometry .cgi_install $geomcgi(larg)x$geomcgi(long)+$positionxy
         wm resizable .cgi_install 0 0
         wm title .cgi_install "AudeLA CGI Deployer"
         puts "fonction quit"
         wm protocol .cgi_install WM_DELETE_WINDOW "::cgi_install::quit"

         puts "exist: [ info commands .cgi_install ]"
         if { [ string length [ info commands .cgi_install ] ] != "0" } {
            puts "La fenetre est creee [ info commands .cgi_install.* ] -"
         } else {
            puts "La fenetre n est pas creee [ info commands .cgi_install.* ] -"
         }

         puts "label..."
         #--- Create the title
         #--- Cree le titre
         label .cgi_install.title \
            -font [ list {Arial} 16 bold ] -text "AudeLA CGI Deployer" \
            -borderwidth 0 -relief flat -bg $audace(cgi_install,configure,color,backpad) \
            -fg $audace(cgi_install,configure,color,textkey)
         pack .cgi_install.title \
            -in .cgi_install -fill x -side top -pady 5

         #--- Buttons
         frame .cgi_install.buttons -borderwidth 3 -relief sunken -bg $audace(cgi_install,configure,color,backpad)
            button .cgi_install.load_button \
               -font $audace(cgi_install,configure,font,c12b) \
               -text "QUIT without saving" \
               -command {::cgi_install::quit}
            pack  .cgi_install.load_button -in .cgi_install.buttons -side left -fill none -padx 10
            button .cgi_install.return_button \
               -font $audace(cgi_install,configure,font,c12b) \
               -text "DEPLOY >>" \
               -command { ::cgi_install::go }
            pack  .cgi_install.return_button -in .cgi_install.buttons -side left -fill none -padx 10
            pack .cgi_install.buttons -in .cgi_install -fill x -pady 3 -padx 3 -anchor s -side bottom

         #--- htdocs, etc...
         set k 0
         foreach name $audace(cgi_install,variables) {
            set cap_name [lindex $audace(cgi_install,variables,descr) $k]
            frame .cgi_install.$name -borderwidth 3 -relief sunken -bg $audace(cgi_install,configure,color,backpad)
               checkbutton .cgi_install.$name.checkbutton \
                  -variable audace(cgi_install,configure,config,${name}x) -bg $audace(cgi_install,configure,color,backdisp) \
                  -fg $audace(cgi_install,configure,color,textdisp) -relief flat -width 1
               pack .cgi_install.$name.checkbutton -in .cgi_install.$name -side left -fill none
               label .cgi_install.$name.label \
                  -font $audace(cgi_install,configure,font,c12b) \
                  -text "$cap_name" -bg $audace(cgi_install,configure,color,backpad) \
                  -fg $audace(cgi_install,configure,color,textkey) -relief flat
               pack .cgi_install.$name.label -in .cgi_install.$name -side left -fill none
               button .cgi_install.$name.button1 \
                  -font $audace(cgi_install,configure,font,c12b) \
                  -text "..." \
                  -command [list ::cgi_install::button1 $name $cap_name]
               pack  .cgi_install.$name.button1 -in .cgi_install.$name -side left -fill none
               entry .cgi_install.$name.entry \
                  -font $audace(cgi_install,configure,font,c12b) \
                  -textvariable audace(cgi_install,configure,config,$name) -bg $audace(cgi_install,configure,color,backdisp) \
                  -fg $audace(cgi_install,configure,color,textdisp) -relief flat
               pack .cgi_install.$name.entry -in .cgi_install.$name -side left -fill x -expand 1
               button .cgi_install.$name.button2 \
                  -font $audace(cgi_install,configure,font,c12b) \
                  -text "?" \
                  -command [list ::cgi_install::button2 $name]
               pack  .cgi_install.$name.button2 -in .cgi_install.$name -side left -fill none
            pack .cgi_install.$name -in .cgi_install -fill x -pady 1 -padx 12
            incr k
         }

         label .cgi_install.droits \
            -font [ list {Arial} 10 bold ] -text "$droits" \
            -borderwidth 0 -relief flat -bg $audace(cgi_install,configure,color,backpad) \
            -fg $audace(cgi_install,configure,color,textkey)
         pack .cgi_install.droits \
            -in .cgi_install -fill x -side top -pady 5

      }

   }

#--------------------------------------------------
#  ::cgi_install::analdir { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::analdir { base {filefilter *} } {

      global result resultfile

      set listfiles ""
      set a [catch {set listfiles [glob ${base}/${filefilter}]} msg]
      if {$a==0} {
         # --- tri des fichiers dans l'ordre chrono decroissant
         set listdatefiles ""
         foreach thisfile $listfiles {
            set a [file isdirectory $thisfile]
            if {($a>=0) && ([file tail $thisfile] != ".svn") && ([file tail $thisfile] != "CVS")} {
               set datename [file mtime $thisfile]
               lappend listdatefiles [list $datename $thisfile]
            }
         }
         set listdatefiles [lsort -decreasing $listdatefiles]
         # --- isole les fichiers
         foreach thisdatefile $listdatefiles {
            set thisfile [lindex $thisdatefile 1]
            set a [file isdirectory $thisfile]
            if {($a>=0) && ([file tail $thisfile] != ".svn") && ([file tail $thisfile] != "CVS")} {
               append result "$thisfile\n"
            }
         }
         # --- recursivite sur les dossiers
         foreach thisfile $listfiles {
            set a [file isdirectory $thisfile]
            if {$a==1} {
               if {([file tail $thisfile] != "CVS") && ([file tail $thisfile] != ".svn")} {
                  analdir $thisfile
               }
            }
         }
      }
   }

#--------------------------------------------------
#  ::cgi_install::files_in_dir { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::files_in_dir { base {filefilter *} } {

      global result resultfile audace

      set result ""
      set resultfile "$audace(cgi_install,base)/test.txt"
      file delete -force $resultfile
      set base [::cgi_install::compact $base]
      ::cgi_install::analdir $base $filefilter
      set k [string last \n $result]
      if {$k>=0} {
         set len [string length $result]
         set result [string range $result 0 [expr $k-1]]
      }
      return $result
   }

#--------------------------------------------------
#  ::cgi_install::quit { }
#--------------------------------------------------
# Action du bouton quitter, detruit la fenetre active
# @return
#--------------------------------------------------
   proc ::cgi_install::quit { } {
      global conf audace ros

      if {[::cgi_install::withtk]==1} {
         if { [ winfo exists .cgi_install ] } {

            puts "Detruit la fenetre"
            #--- Enregistre la position de la fenetre
            set geom [wm geometry .cgi_install]
            set deb [expr 1+[string first + $geom ]]
            set fin [string length $geom]
            set conf(cgi_install,position) "[string range $geom $deb $fin]"
            #--- Supprime la fenetre
            destroy .cgi_install
         }
      }
      return
   }

#--------------------------------------------------
#  ::cgi_install::print { }
#--------------------------------------------------
# affiche sur la sortie standard (console ou shell)
# @return
#--------------------------------------------------
   proc ::cgi_install::print { msg } {

      global audace ros

      if {[::cgi_install::withtk]==1} {
         ::console::affiche_resultat "$msg"
      } else {
         puts -nonewline "$msg"
         flush stdout
      }
      append audace(cgi_install,print) "$msg"
      return
   }

#--------------------------------------------------
#  ::cgi_install::go { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::go { } {
      global audace
      global caption
      #global cgi

      # --- Enregistre la derniere configuration
      set texte ""
      foreach name $audace(cgi_install,variables) {
         append texte "set audace(cgi_install,configure,config,${name}) \"$audace(cgi_install,configure,config,${name})\"\n"
         append texte "set audace(cgi_install,configure,config,${name}x) $audace(cgi_install,configure,config,${name}x)\n"
      }
      set f [open $audace(cgi_install,lastconfig) w]
      puts $f $texte
      close $f
      #
      set roots ""
      set n [llength $audace(cgi_install,variables)]
      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $audace(cgi_install,variables) $k]
         append roots "set cgi(root,$name) \"$audace(cgi_install,configure,config,$name)\"\n"
      }
      set fichier [::cgi_install::compact "$audace(rep_install)/bin/.."]
      append roots "set cgi(root,audela) \"$fichier\"\n"
      set fichier [::cgi_install::compact "$audace(rep_install)/bin/cgi_root.tcl"]
      ::cgi_install::print "CREATE $fichier\n"
      set f [open $fichier w]
      puts $f $roots
      close $f

      set n [llength $audace(cgi_install,variables)]

      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $audace(cgi_install,variables) $k]
         set cap_name [lindex $audace(cgi_install,variables,descr) $k]

         ::cgi_install::print "\n===== $name ===== \n"
         # --- do not install if not checked
         if {$audace(cgi_install,configure,config,${name}x)==0} {
            continue
         }
         ::cgi_install::print "\n DESTINATION : $audace(cgi_install,configure,config,$name) \n \n"
         # --- cgi-bin : on copie d'abord les /bin et /lib de AudeLA
         if {($name=="cgi-bin")} {
            # /bin
            set base1 [::cgi_install::compact "$audace(rep_install)/bin"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela/bin"]
            ::cgi_install::copy $base1 $fichiers $base2
            # cgi_root.tcl
            set base1 [::cgi_install::compact "$audace(rep_install)/bin"]
            set fichiers "$base1/cgi_root.tcl"
            set base2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela"]
            ::cgi_install::copy $base1 $fichiers $base2
            # /lib
            set base1 [::cgi_install::compact "$audace(rep_install)/lib"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela/lib"]
            ::cgi_install::copy $base1 $fichiers $base2
            # copy files from gui/cgi/cgi-bin/audela
            set base1 [::cgi_install::compact "$audace(rep_install)/gui/cgi/cgi-bin/audela"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela"]
            ::cgi_install::copy $base1 $fichiers $base2
            # create audela.exe in cgi-bin in the case of Linux
            if { $::tcl_platform(os) == "Linux" } {
               set f2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela/bin/audela.exe"]
               set texte "#! /bin/sh\n./audela --console --file audela.tcl"
               catch {
                  set fid [open $f2 w]
                  puts -nonewline $fid $texte
                  close $fid
                  exec chmod +x $f2
               } msg
               ::cgi_install::print "CREATE $f2 (msg=$msg)\n"
            }
            #
         }
         # --- htdocs : on cree le point d'entree http
         if {($name=="htdocs")} {
            # copy files from gui/cgi/htdocs/audela
            set base1 [::cgi_install::compact "$audace(rep_install)/gui/cgi/htdocs/audela"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::cgi_install::compact "$audace(cgi_install,configure,config,$name)/audela"]
            ::cgi_install::copy $base1 $fichiers $base2
         }
      }
      #
      ::cgi_install::print "\n"
      ::cgi_install::print "INTALLATION FINISHED WITH SUCCESS\n"
      set fichier [::cgi_install::compact [file join $::audela_start_dir cgi_install.log]]

      set f [open $fichier w]
      puts $f $audace(cgi_install,print)
      puts $f [mc_date2iso8601 now]
      close $f
      #
      #
      ::cgi_install::quit
   }

#--------------------------------------------------
#  ::cgi_install::compact { }
#--------------------------------------------------
# compact the directory name
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::compact { folder } {

      while {1==1} {
      set k [string first ".." $folder]
         if {$k>=0} {
            set deb [string range $folder 0 [expr $k-2]]
            set fin [string range $folder [expr $k+2] end]
            set k [string last "/" $deb]
            set debdeb [string range $folder 0 [expr $k-1]]
            set folder ${debdeb}${fin}
         } else {
            break
         }
      }
      return $folder
   }

#--------------------------------------------------
#  ::cgi_install::copy { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::copy { base1 fichiers base2 } {

      set base1 [::cgi_install::compact $base1]
      #::console::affiche_saut "BASE1 => $base1\n"
      set n1 [expr 1+[string length $base1]]
      if {[string index $base2 end]=="/"} {
         set n2 [string length $base2]
         set base2 [string range $base2 0 [expr $n2-2]]
      }
      foreach fichier $fichiers {
           #::console::affiche_resultat "FICHIER : $fichier => $base2\n"
         set fic [file tail $fichier]
         set dir [file dirname $fichier]
         set dir1 [string range $dir $n1 end]
           #::console::affiche_resultat "DIR1 : $dir1 ($n1)\n"
         set dir2 ${base2}/${dir1}
           if {[string index $dir2 end]=="/"} {
            set n2 [string length $dir2]
            set dir2 [string range $dir2 0 [expr $n2-2]]
         }
         set fullfic "$dir2/$fic"
           catch {file mkdir $dir2}
           if {[file isdirectory $fichier]==0} {
              ::cgi_install::print "COPY : $fichier => $fullfic\n"
              catch {file copy -force $fichier $fullfic}
           } else {
              ::cgi_install::print "CREATE EMPTY DIR : $fullfic\n"
              catch {file mkdir $fullfic}
           }
        }
   }

#--------------------------------------------------
#  ::cgi_install::button1 { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::cgi_install::button1 { name descr } {

      global audace caption

      set title "Directory of $descr"
      set inidir $audace(cgi_install,configure,config,$name)
        set parent .cgi_install.$name
      set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]

      if {$res!=""} {
         set audace(cgi_install,configure,config,$name) $res
      }
      .cgi_install.$name.entry configure -textvariable audace(cgi_install,configure,config,$name)

      update
   }

#--------------------------------------------------
#  ::cgi_install::button2 { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc button2 { name } {
   }

}

