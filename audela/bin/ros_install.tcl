# Please use this TCL script with AudeLA to install ROS files

namespace eval ::ros_install {



#--------------------------------------------------
#  ::ros_install::get_lastconfig { }
#--------------------------------------------------
# Chargement des chemins pour ros
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::ros_install::get_lastconfig {  } {

      global audace

      puts "Chargement de ros_install_lastconfig.tcl "
      set err [catch {source [file join $::audela_start_dir ros_install_lastconfig.tcl]} msg]
      return -code $err $msg
   }


#--------------------------------------------------
#  ::ros_install::get_root { }
#--------------------------------------------------
# Chargement des chemins pour ros
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::ros_install::get_root {  } {

      global ros

      puts "Chargement de ros_root.tcl "
      set err [catch {source [file join $::audela_start_dir ros_root.tcl]} msg]
      return -code $err $msg
   }



#--------------------------------------------------
#  ::ros_install::run { positionxy}
#--------------------------------------------------
# Demarrage de l interface d installation (fenetree ou ligne de commande)
# @param positionxy position de la fenetre (par defaut : 20+20)
# @return
#--------------------------------------------------
   proc ::ros_install::run { { positionxy 20+20 } } {

      global audace caption color ros

      if {$ros(withtk)==1} {
         if { [ string length [ info commands .ros_install.* ] ] != "0" } {
         puts "Detruit la fenetre"
         destroy .ros_install
         }
      }

      #--- Definition of colors
      if {$ros(withtk)==1} {
         puts "Definition des couleurs"
         set audace(ros_install,configure,color,backpad)  #F0F0FF
         set audace(ros_install,configure,color,backdisp) $color(white)
         set audace(ros_install,configure,color,textkey)  $color(blue_pad)
         set audace(ros_install,configure,color,textdisp) #FF0000
      }

      #--- Initialisation of the variables
      puts "Initialisation..."
      set base $::audela_start_dir
      set dirros $base
      set b [::ros_install::compact ${base}/../../ros]
      if {[file exists $b]==1} {
         set dirros $b
      }
      set dirconf [::ros_install::compact ${base}/../../ros_private_template]
      set b [::ros_install::compact ${base}/../../..]
      set testsrv [file tail $b]
      if {$testsrv=="srv"} {
         set dirwork ${b}/work/ros
         file mkdir $dirwork
         set dirwww ${b}/www
         set b [::ros_install::compact ${dirros}/../ros_private_*]
         set c [glob -nocomplain $b]
         if {$c!=""} {
            set dirconf [lindex [lsort $c] 0]
         }
      } else {
         set b [::ros_install::compact ${base}/..]
         set dirwork $b
         set dirwww $b
      }
      puts "base= $base"
      set audace(ros_install,base) $base
      if {[info exists ros(ros_install,audelabin)]==0} {
         set ros(ros_install,audelabin) $::audela_start_dir
      }

      set audace(ros_install,variables) {ros data ressources logs htdocs cgi-bin catalogs extinctionmaps conf}
      set audace(ros_install,variables,descr) $audace(ros_install,variables)
      set audace(ros_install,print) ""

      set k 0
      foreach name $audace(ros_install,variables) {
         set b $base
         if {[lsearch -exact "ros" $name]>=0} {
            set b $dirros
         }
         if {[lsearch -exact "data ressources logs catalogs extinctionmaps" $name]>=0} {
            set b $dirwork
         }
         if {[lsearch -exact "htdocs cgi-bin" $name]>=0} {
            set b $dirwww
         }
         if {[lsearch -exact "conf" $name]>=0} {
            set b $dirconf
         }
         set audace(ros_install,configure,config,${name}) ${b}
         set audace(ros_install,configure,config,${name}x) 1
      }

      puts "Defauts..."
      if {$testsrv!="srv"} {
         if { $::tcl_platform(os) == "Linux" } {
            set fichiers [glob -nocomplain "/usr/local/*" "/opt/*"]
         } else {
            set fichiers [glob -nocomplain "C:/Program Files/*"]
         }
         set a ""
         foreach fichier $fichiers {
            if {([string first pache $fichier]>=0)&&([file isdirectory $fichier]==1)} {
               set a $fichier
               break
            }
         }

         if {$a!=""} {
            #::console::affiche_resultat "a=$a\n"
            for {set k 0} {$k<3} {incr k} {
               set as [glob -nocomplain $a/htdocs]
               #::console::affiche_resultat "$k as=$as\n"
               if {$as!=""} { break }
               set fichiers [glob -nocomplain $a/*]
               #::console::affiche_resultat "$k fichiers=$fichiers\n"
               foreach fichier $fichiers {
                  if {([string first pache $fichier]>=0)&&([file isdirectory $fichier]==1)} {
                     set a $fichier
                     break
                  }
               }
            }
            set audace(ros_install,configure,config,htdocs)     "$a"
            set audace(ros_install,configure,config,cgi-bin)    "$a"
         }
      }

      set audace(ros_install,lastconfig) $audace(ros_install,base)/ros_install_lastconfig.tcl
      set err [catch {::ros_install::get_lastconfig} msg]

      puts "Demarrage..."
      if {$ros(withtk)==0} {
         ::ros_install::print "======================================\n"
         ::ros_install::print "ROBOTIC OBSERVATORY SOFTWARE Deployer \n"
         ::ros_install::print "======================================\n"
         if {($err==1)&&([file exists $audace(ros_install,lastconfig)]==1)} {
            ::ros_install::print "Error in $audace(ros_install,lastconfig): $msg\n"
         }
         ::ros_install::print "\n"
         ::ros_install::print "AUDELA/BIN folder : $ros(ros_install,audelabin)\n"
         #::ros_install::print "ROS folder : $audace(ros_install,base)\n"
         set texte ""
         set k 0
         set auto 0 ; # * is a shortcut to valide default of every item
         foreach name $audace(ros_install,variables) {
            ::ros_install::print "\n"
            set cap_name [lindex $audace(ros_install,variables,descr) $k]
            while {0==0} {
               ::ros_install::print "Answer 1 if you want to deploy $cap_name (actual=$audace(ros_install,configure,config,${name}x)): "
               if {$auto==0} {
                  gets stdin value
               } else {
                  set value $audace(ros_install,configure,config,${name}x)
               }
               if {$value==""} {
                  set value $audace(ros_install,configure,config,${name}x)
               }
               if {($value=="*")} {
                  set value 1
                  set auto 1
               }
               if {($value=="0")||($value=="1")} {
                  set audace(ros_install,configure,config,${name}x) $value
                  break
               } else {
                  ::ros_install::print "Error. Answer must be 0 or 1\n"
               }
            }
            append texte "set audace(ros_install,configure,config,${name}x) \"$audace(ros_install,configure,config,${name}x)\"\n"
            if {$value==1} {
               while {0==0} {
                  ::ros_install::print "Directory of $cap_name (actual=$audace(ros_install,configure,config,${name})): "
                  if {$auto==0} {
                     gets stdin value
                  } else {
                     set value ""
                  }
                  if {$value==""} {
                     set value $audace(ros_install,configure,config,${name})
                  }
                  set res [file exists $value]
                  if {$res==1} {
                     set audace(ros_install,configure,config,${name}) $value
                     ::ros_install::print "$cap_name will be installed in $audace(ros_install,configure,config,${name})\n"
                     break
                  } else {
                     ::ros_install::print "Error. Directory $value not exists !\n"
                  }
               }
            }
            append texte "set audace(ros_install,configure,config,${name}) \"$audace(ros_install,configure,config,${name})\"\n"
            incr k
         }
         set f [open $audace(ros_install,lastconfig) w]
         puts $f $texte
         close $f
         ::ros_install::print "\n"
         ::ros_install::print "Parameters are stored in $audace(ros_install,lastconfig)\n"
         ::ros_install::print "\n"
         ::ros_install::print "-----------------------------------------------\n"
         if {$auto==0} {
            ::ros_install::print "Answer 1 if you want to deploy ROS (actual=0): "
            gets stdin value
         } else {
            ::ros_install::print "Answer 1 if you want to deploy ROS (actual=1): "
            set value 1
         }
         if {$value=="1"} {
            ::ros_install::go $audace(ros_install,configure,config,ros)
         } else {
            ::ros_install::print "QUIT WITH NO DEPLOYEMENT\n\n"
         }
         cd $ros(ros_install,audelabin)

      } else {

         puts "Demarrage avec interface graphique..."
         set geomohp(larg) 970
         set geomohp(long) 500

         set audace(ros_install,configure,font,c12b) [ list {Courier} 10 bold ]
         set audace(ros_install,configure,font,c10b) [ list {Courier} 10 bold ]
         # =========================================
         # === Setting the graphic interface
         # === Met en place l'interface graphique
         # =========================================

         #--- Cree la fenetre .ros_install de niveau le plus haut
         puts "Cree la fenetre .ros_install de niveau le plus haut"
         toplevel .ros_install -class Toplevel -bg $audace(ros_install,configure,color,backpad)
         wm geometry .ros_install $geomohp(larg)x$geomohp(long)+$positionxy
         wm resizable .ros_install 0 0
         wm title .ros_install "ROBOTIC OBSERVATORY SOFTWARE Deployer"
         puts "fonction quit"
         wm protocol .ros_install WM_DELETE_WINDOW "::ros_install::quit"


         puts "exist: [ info commands .ros_install ]"
         if { [ string length [ info commands .ros_install ] ] != "0" } {
            puts "La fenetre est creee [ info commands .ros_install.* ] -"
         } else {
            puts "La fenetre n est pas creee [ info commands .ros_install.* ] -"
         }


         puts "label..."
         #--- Create the title
         #--- Cree le titre
         label .ros_install.title \
            -font [ list {Arial} 16 bold ] -text "ROBOTIC OBSERVATORY SOFTWARE Deployer" \
            -borderwidth 0 -relief flat -bg $audace(ros_install,configure,color,backpad) \
            -fg $audace(ros_install,configure,color,textkey)
         pack .ros_install.title \
            -in .ros_install -fill x -side top -pady 5

         #--- Buttons
         frame .ros_install.buttons -borderwidth 3 -relief sunken -bg $audace(ros_install,configure,color,backpad)
            button .ros_install.load_button \
               -font $audace(ros_install,configure,font,c12b) \
               -text "QUIT without saving" \
               -command {::ros_install::quit}
            pack  .ros_install.load_button -in .ros_install.buttons -side left -fill none -padx 10
            button .ros_install.return_button \
               -font $audace(ros_install,configure,font,c12b) \
               -text "DEPLOY >>" \
               -command {::ros_install::go $audace(ros_install,configure,config,ros)}
            pack  .ros_install.return_button -in .ros_install.buttons -side left -fill none -padx 10
            pack .ros_install.buttons -in .ros_install -fill x -pady 3 -padx 3 -anchor s -side bottom

         #--- htdocs, etc...
         set k 0
         foreach name $audace(ros_install,variables) {
            set cap_name [lindex $audace(ros_install,variables,descr) $k]
            frame .ros_install.$name -borderwidth 3 -relief sunken -bg $audace(ros_install,configure,color,backpad)
               checkbutton .ros_install.$name.checkbutton \
                  -variable audace(ros_install,configure,config,${name}x) -bg $audace(ros_install,configure,color,backdisp) \
                  -fg $audace(ros_install,configure,color,textdisp) -relief flat -width 1
               pack .ros_install.$name.checkbutton -in .ros_install.$name -side left -fill none
               label .ros_install.$name.label \
                  -font $audace(ros_install,configure,font,c12b) \
                  -text "$cap_name" -bg $audace(ros_install,configure,color,backpad) \
                  -fg $audace(ros_install,configure,color,textkey) -relief flat
               pack .ros_install.$name.label -in .ros_install.$name -side left -fill none
               button .ros_install.$name.button1 \
                  -font $audace(ros_install,configure,font,c12b) \
                  -text "..." \
                  -command [list ::ros_install::button1 $name $cap_name]
               pack  .ros_install.$name.button1 -in .ros_install.$name -side left -fill none
               entry .ros_install.$name.entry \
                  -font $audace(ros_install,configure,font,c12b) \
                  -textvariable audace(ros_install,configure,config,$name) -bg $audace(ros_install,configure,color,backdisp) \
                  -fg $audace(ros_install,configure,color,textdisp) -relief flat
               pack .ros_install.$name.entry -in .ros_install.$name -side left -fill x -expand 1
               button .ros_install.$name.button2 \
                  -font $audace(ros_install,configure,font,c12b) \
                  -text "?" \
                  -command [list ::ros_install::button2 $name]
               pack  .ros_install.$name.button2 -in .ros_install.$name -side left -fill none
            pack .ros_install.$name -in .ros_install -fill x -pady 1 -padx 12
            incr k
         }
         puts "fin label..."

      }

   }

#--------------------------------------------------
#  ::ros_install::analdir { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::ros_install::analdir { base {filefilter *} } {

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
#  ::ros_install::files_in_dir { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::ros_install::files_in_dir { base {filefilter *} } {

      global result resultfile audace

      set result ""
      set resultfile "$audace(ros_install,base)/test.txt"
      file delete -force $resultfile
      set base [::ros_install::compact $base]
      ::ros_install::analdir $base $filefilter
      set k [string last \n $result]
      if {$k>=0} {
         set len [string length $result]
         set result [string range $result 0 [expr $k-1]]
      }
      return $result
   }


#--------------------------------------------------
#  ::ros_install::quit { }
#--------------------------------------------------
# Action du bouton quitter, detruit la fenetre active
# @return
#--------------------------------------------------
   proc ::ros_install::quit { } {
      global conf audace ros

      if {$ros(withtk)==1} {
         if { [ winfo exists .ros_install ] } {

            puts "Detruit la fenetre"
            #--- Enregistre la position de la fenetre
            set geom [wm geometry .ros_install]
            set deb [expr 1+[string first + $geom ]]
            set fin [string length $geom]
            set conf(ros_install,position) "[string range $geom $deb $fin]"
            #--- Supprime la fenetre
            destroy .ros_install
         }
      }
      return
   }





#--------------------------------------------------
#  ::ros_install::print { }
#--------------------------------------------------
# affiche sur la sortie standard (console ou shell)
# @return
#--------------------------------------------------
   proc ::ros_install::print { msg } {

      global audace ros

      if {$ros(withtk)==1} {
         ::console::affiche_resultat "$msg"
      } else {
         puts -nonewline "$msg"
         flush stdout
      }
      append audace(ros_install,print) "$msg"
      return
   }





#--------------------------------------------------
#  ::ros_install::go { ros_install_base}
#--------------------------------------------------
#
# @param ros_install_base
# @return
#--------------------------------------------------
   proc ::ros_install::go { ros_install_base } {
      global audace
      global caption
      global ros

      # --- Enregistre la derniere configuration
      set texte ""
      foreach name $audace(ros_install,variables) {
         append texte "set audace(ros_install,configure,config,${name}) \"$audace(ros_install,configure,config,${name})\"\n"
         append texte "set audace(ros_install,configure,config,${name}x) $audace(ros_install,configure,config,${name}x)\n"
      }
      set f [open $audace(ros_install,lastconfig) w]
      puts $f $texte
      close $f
      # --- copy bin
      set base1 [::ros_install::compact "$ros_install_base/install/bin"]
      set fichiers [split [files_in_dir $base1] \n]
      set base2 [::ros_install::compact "$ros(ros_install,audelabin)"]
      ::ros_install::copy $base1 $fichiers $base2
      # --- cree the .exe files
      set fichiers "[glob $ros_install_base/src/*]"
      if { $::tcl_platform(os) == "Linux" } {
         set audelaext ""
      } else {
         set audelaext ".exe"
      }
      set k [lsearch -regexp $fichiers copieur]
      if {$k>=0} {
         set path [file dirname [lindex $fichiers $k]]
         set fichiers [lreplace $fichiers $k $k "${path}/copieur_ftp" "${path}/copieur_disque"]
      }
      foreach fichier $fichiers {
         set a [file isdirectory $fichier]
         set fic [file tail $fichier]
         set fictcl "${fichier}/${fic}.tcl"
         set b [file exists $fictcl]
         if {(($a==1)&&($b==1)&&($fic!=".svn")&&($fic!="common"))||([string first copieur $fic]>=0)} {
            set f1 [::ros_install::compact "$ros(ros_install,audelabin)/audela${audelaext}"]
            set f2 [::ros_install::compact "$ros(ros_install,audelabin)/${fic}${audelaext}"]
            ::ros_install::print "COPY $f1 => $f2\n"
            catch {file copy -force $f1 $f2}
         }
      }
      # --- copy lib
      set base1 [::ros_install::compact "$ros_install_base/install/lib"]
      set fichiers [split [files_in_dir $base1] \n]
      set base2 [::ros_install::compact "$ros(ros_install,audelabin)/../lib"]
      ::ros_install::copy $base1 $fichiers $base2
      #
      set roots ""
      set n [llength $audace(ros_install,variables)]
      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $audace(ros_install,variables) $k]
         append roots "set ros(root,$name) \"$audace(ros_install,configure,config,$name)\"\n"
      }
      set fichier [::ros_install::compact "$ros(ros_install,audelabin)/.."]
      append roots "set ros(root,audela) \"$fichier\"\n"
      set fichier [::ros_install::compact "$ros(ros_install,audelabin)/ros_root.tcl"]
      ::ros_install::print "CREATE $fichier\n"
      set f [open $fichier w]
      puts $f $roots
      close $f

      set n [llength $audace(ros_install,variables)]

      for {set k 0} {$k<$n} {incr k} {
         set name [lindex $audace(ros_install,variables) $k]
         set cap_name [lindex $audace(ros_install,variables,descr) $k]

         if {$name=="conf"} {
            continue
            #set ros_install_base $audace(ros_install,configure,config,conf)
         }
         ::ros_install::print "\n===== $name ===== \n"
         # --- do not install if not checked
         if {$audace(ros_install,configure,config,${name}x)==0} {
            continue
         }
         ::ros_install::print "\n DESTINATION : $audace(ros_install,configure,config,$name) \n \n"
         # --- cgi-bin : on copie d'abord les /bin et /lib de AudeLA
         if {($name=="cgi-bin")} {
            # /bin
            set base1 [::ros_install::compact "$ros(ros_install,audelabin)"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros/bin"]
            ::ros_install::copy $base1 $fichiers $base2
            # ros_root.tcl
            set base1 [::ros_install::compact "$ros(ros_install,audelabin)/"]
            set fichiers "$base1/ros_root.tcl"
            set base2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros"]
            ::ros_install::copy $base1 $fichiers $base2
            # /lib
            set base1 [::ros_install::compact "$ros(ros_install,audelabin)/../lib"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros/lib"]
            ::ros_install::copy $base1 $fichiers $base2
            # /*.tcl from ros/src/common/*.tcl
            set base1 [::ros_install::compact "$ros_install_base/src/common"]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros"]
            ::ros_install::copy $base1 $fichiers $base2
            # /*.tcl from ros/conf/src/common/*.tcl
            set base1 [::ros_install::compact "$audace(ros_install,configure,config,conf)/conf/src/common"] ; # TAG-CONF
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros"]
            ::ros_install::copy $base1 $fichiers $base2
            # /users.tcl from ros/conf/users.txt
            #set f1 [::ros_install::compact "$audace(ros_install,configure,config,conf)/conf/users.txt"] ; # TAG-CONF
            #set f2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros/users.txt"]
            #::ros_install::print "COPY $f1 => $f2\n"
            catch {file copy -force $f1 $f2}
            # create audela.exe in cgi-bin in the case of Linux
            if { $::tcl_platform(os) == "Linux" } {
               set f2 [::ros_install::compact "$audace(ros_install,configure,config,$name)/${name}/ros/bin/audela.exe"]
               set texte "#! /bin/sh\n./audela --console --file audela.tcl"
               catch {
                  set fid [open $f2 w]
                  puts -nonewline $fid $texte
                  close $fid
                  exec chmod +x $f2
               } msg
               ::ros_install::print "CREATE $f2 (msg=$msg)\n"
            }
            #
         }
         # --- Cree les dossiers
         if {($name!="ros")} {
            ::ros_install::print "FOR $cap_name CREATE $audace(ros_install,configure,config,$name)/${name}\n"
            file mkdir $audace(ros_install,configure,config,$name)/${name}
         }
         # --- htdocs & cgi-bin : copie des fichiers specifiques en ecrasant au besoin ceux de AudeLA
         if {($name=="htdocs")||($name=="cgi-bin")} {
            set base1 [::ros_install::compact $ros_install_base/install/httpd/$name]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact $audace(ros_install,configure,config,$name)/${name}]
            ::ros_install::copy $base1 $fichiers $base2
            # --- copie la configuration privee
            ::ros_install::print "PRIVATE FILES START\n"
            set base1 [::ros_install::compact "$audace(ros_install,configure,config,conf)/install/httpd/$name"]
            set fichiers [split [files_in_dir $base1] \n]
            ::ros_install::copy $base1 $fichiers $base2
            ::ros_install::print "PRIVATE FILES END\n"
         }
         # ---
         if {($name=="ressources")} {
            set base1 [::ros_install::compact $ros_install_base/install/$name]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact $audace(ros_install,configure,config,$name)/${name}]
            ::ros_install::copy $base1 $fichiers $base2
            #
            set base1 [::ros_install::compact $audace(ros_install,configure,config,conf)/conf/$name] ; # TAG-CONF
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact $audace(ros_install,configure,config,$name)/${name}]
            ::ros_install::copy $base1 $fichiers $base2
         }
         # ---
         if {($name=="catalogs")} {
                 #catch {file mkdir $ros_install_base/$name}
         }
         # ---
         if {($name=="extinctionmaps")} {
                 #catch {file mkdir $ros_install_base/$name}
         }
         # ---
         if {($name=="data")} {
            set base1 [::ros_install::compact $ros_install_base/install/$name]
            set fichiers [split [files_in_dir $base1] \n]
            set base2 [::ros_install::compact $audace(ros_install,configure,config,$name)/${name}]
            ::ros_install::copy $base1 $fichiers $base2
         }
      }
      #
      #
      ::ros_install::print "\n"
      ::ros_install::print "INTALLATION FINISHED WITH SUCCESS\n"
      set fichier [::ros_install::compact [file join $::audela_start_dir ros_install.log]]

      set f [open $fichier w]
      puts $f $audace(ros_install,print)
      puts $f [mc_date2iso8601 now]
      close $f
      #
      #
      ::ros_install::quit
   }









#--------------------------------------------------
#  ::ros_install::compact { }
#--------------------------------------------------
# compact the directory name
# @param
# @return
#--------------------------------------------------
   proc ::ros_install::compact { folder } {

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
#  ::ros_install::copy { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::ros_install::copy { base1 fichiers base2 } {

      set base1 [::ros_install::compact $base1]
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
              ::ros_install::print "COPY : $fichier => $fullfic\n"
              catch {file copy -force $fichier $fullfic}
           } else {
              ::ros_install::print "CREATE EMPTY DIR : $fullfic\n"
              catch {file mkdir $fullfic}
           }
        }
   }





#--------------------------------------------------
#  ::ros_install::button1 { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc ::ros_install::button1 { name descr } {

      global audace caption

      set title "Directory of $descr"
      set inidir $audace(ros_install,configure,config,$name)
        set parent .ros_install.$name
      set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]

      if {$res!=""} {
         set audace(ros_install,configure,config,$name) $res
      }
      .ros_install.$name.entry configure -textvariable audace(ros_install,configure,config,$name)

      update
   }




#--------------------------------------------------
#  ::ros_install::button2 { }
#--------------------------------------------------
#
# @param
# @return
#--------------------------------------------------
   proc button2 { name } {
   }




}

