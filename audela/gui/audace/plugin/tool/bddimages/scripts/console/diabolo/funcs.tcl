#   namespace eval ::dbo {
#   }

      # Image
#      variable iwidth  600
#      variable iheight 400
#      variable svgfilename "img.htm"
#      variable svgjournuit "journuit.inc.svg"
#      variable svgobs      "obs.inc.svg"

      # Observatoire
#      variable uai_code 181

      # Date
#      variable firstdate 2017-01-01
      #variable lastdate  2017-01-07
#      variable lastdate  2018-01-01
#      variable firstdatejd 
#      variable lastdatejd  

#   }









   proc ::dbo::init { } {

      global bddconf

      set bddconf(dbname) $::dbo::dbname
      set bddconf(server) $::dbo::server
      set bddconf(login)  $::dbo::login 
      set bddconf(pass)   $::dbo::pass  
      
      ::bddimages_sql::connect

      set ::dbo::home [::bdi_gui_cdl::uai2home $::dbo::uai_code]
      
      set ::dbo::maxwidth  [expr $::dbo::iwidth  - 1]
      set ::dbo::maxheight [expr $::dbo::iheight - 1]
      
      set long  [lindex $::dbo::home 1] 
      set llong [lindex $::dbo::home 2]
      if {[string tolower $llong]=="w"} {
         set ::dbo::offset_midi [expr $long / 360.0]
      } else {
         set ::dbo::offset_midi [expr - $long / 360.0]
      }

      set ::dbo::nowiso [UTnowISO]
      set ::dbo::nowjd  [mc_date2jd $::dbo::nowiso]

   }








   proc ::dbo::main { } {
      
      set datedeb [get_date_sys2ut now]
      
      puts "***********************************"
      puts "* Diabolo     : Creation du SVG"
      puts "* sur la base : $::dbo::dbname"
      puts "* Serveur     : $::dbo::server"
      puts "* Date NOW    : [UTnowISO]"
      puts "***********************************"

      ::dbo::init

      if {1==0} {
         # Annee 2017
         set currentyear "2017"
         set ::dbo::firstdate   "${currentyear}-01-01T12:00:00.000"
         set ::dbo::firstdatejd [expr ceil([mc_date2jd $::dbo::firstdate]) + $::dbo::offset_midi]
         set ::dbo::lastdate    "[expr $currentyear +1]-01-01T12:00:00.000"
         set ::dbo::lastdatejd  [expr ceil([mc_date2jd $::dbo::lastdate]) + $::dbo::offset_midi]
         set ::dbo::firstdate   [mc_date2iso8601 $::dbo::firstdatejd]
         set ::dbo::lastdate    [mc_date2iso8601 $::dbo::lastdatejd]
         set ::dbo::svgfilename [file join $::dbo::workdir "obslog.${currentyear}.svg"]
         set ::dbo::svgjournuit [file join $::dbo::workdir "tmplog.${currentyear}-night.svg.inc"]
         set ::dbo::filetn      [file join $::dbo::workdir "tmplog.${currentyear}-night.tn.inc"]
         set ::dbo::filestat    [file join $::dbo::workdir "obslog.${currentyear}.inc.php"]
         set ::dbo::svgobs      [file join $::dbo::workdir "tmplog.${currentyear}-obs.svg.inc"]
         set ::dbo::title       "Ann&eacute;e ${currentyear}"
         #if {[file exists $::dbo::svgjournuit]} {file delete -force $::dbo::svgjournuit}

         ::dbo::jour_nuit
         ::dbo::get_obs_data
         ::dbo::get_stat
         ::dbo::build_svg

         puts "   + Effacement du fichier : $::dbo::svgjournuit"
         file delete -force $::dbo::svgjournuit
         puts "   + Effacement du fichier : $::dbo::filetn"
         file delete -force $::dbo::filetn
         puts "   + Effacement du fichier : $::dbo::svgobs"
         file delete -force $::dbo::svgobs
      }
      
      if {1==1} {
         # Annee courante
         set currentyear [string range $::dbo::nowiso 0 3]
         set ::dbo::firstdate   "${currentyear}-01-01T12:00:00.000"
         set ::dbo::firstdatejd [expr ceil([mc_date2jd $::dbo::firstdate]) + $::dbo::offset_midi]
         set ::dbo::lastdate    "[expr $currentyear +1]-01-01T12:00:00.000"
         set ::dbo::lastdatejd  [expr ceil([mc_date2jd $::dbo::lastdate]) + $::dbo::offset_midi]
         set ::dbo::firstdate   [mc_date2iso8601 $::dbo::firstdatejd]
         set ::dbo::lastdate    [mc_date2iso8601 $::dbo::lastdatejd]
         set ::dbo::svgfilename [file join $::dbo::workdir "obslog.${currentyear}.svg"]
         set ::dbo::svgjournuit [file join $::dbo::workdir "tmplog.${currentyear}-night.svg.inc"]
         set ::dbo::filetn      [file join $::dbo::workdir "tmplog.${currentyear}-night.tn.inc"]
         set ::dbo::filestat    [file join $::dbo::workdir "obslog.${currentyear}.inc.php"]
         set ::dbo::svgobs      [file join $::dbo::workdir "tmplog.${currentyear}-obs.svg.inc"]
         set ::dbo::title       "Ann&eacute;e ${currentyear}"
         #if {[file exists $::dbo::svgjournuit]} {file delete -force $::dbo::svgjournuit}

         ::dbo::jour_nuit
         ::dbo::get_obs_data
         ::dbo::get_stat
         ::dbo::build_svg

         puts "   + Effacement du fichier : $::dbo::svgjournuit"
         file delete -force $::dbo::svgjournuit
         puts "   + Effacement du fichier : $::dbo::filetn"
         file delete -force $::dbo::filetn
         puts "   + Effacement du fichier : $::dbo::svgobs"
         file delete -force $::dbo::svgobs
      }
      
      if {1==1} {
         # 30 derniers jours
         set ::dbo::lastdatejd  [expr ceil($::dbo::nowjd) + $::dbo::offset_midi]
         set ::dbo::firstdatejd [expr $::dbo::lastdatejd-30.0]
         set ::dbo::firstdate   [mc_date2iso8601 $::dbo::firstdatejd]
         set ::dbo::lastdate    [mc_date2iso8601 $::dbo::lastdatejd]
         set ::dbo::svgfilename [file join $::dbo::workdir "obslog.month.svg"]
         set ::dbo::svgjournuit [file join $::dbo::workdir "tmplog.month-night.svg.inc"]
         set ::dbo::filetn      [file join $::dbo::workdir "tmplog.month-night.tn.inc"]
         set ::dbo::filestat    [file join $::dbo::workdir "obslog.month.inc.php"]
         set ::dbo::svgobs      [file join $::dbo::workdir "tmplog.month-obs.svg.inc"]
         set ::dbo::title       "30 derniers jours"
         if {[file exists $::dbo::svgjournuit]} {file delete -force $::dbo::svgjournuit}

         ::dbo::jour_nuit
         ::dbo::get_obs_data
         ::dbo::get_stat
         ::dbo::build_svg

         puts "   + Effacement du fichier : $::dbo::svgjournuit"
         file delete -force $::dbo::svgjournuit
         puts "   + Effacement du fichier : $::dbo::filetn"
         file delete -force $::dbo::filetn
         puts "   + Effacement du fichier : $::dbo::svgobs"
         file delete -force $::dbo::svgobs
      }

      if {1==1} {
         # 7 derniers jours
         set ::dbo::lastdatejd  [expr ceil($::dbo::nowjd) + $::dbo::offset_midi]
         set ::dbo::firstdatejd [expr $::dbo::lastdatejd-7.0]
         set ::dbo::firstdate   [mc_date2iso8601 $::dbo::firstdatejd]
         set ::dbo::lastdate    [mc_date2iso8601 $::dbo::lastdatejd]
         set ::dbo::svgfilename [file join $::dbo::workdir "obslog.week.svg"]
         set ::dbo::svgjournuit [file join $::dbo::workdir "tmplog.week-night.svg.inc"]
         set ::dbo::filetn      [file join $::dbo::workdir "tmplog.week-night.tn.inc"]
         set ::dbo::filestat    [file join $::dbo::workdir "obslog.week.inc.php"]
         set ::dbo::svgobs      [file join $::dbo::workdir "tmplog.week-obs.svg.inc"]
         set ::dbo::title       "7 derniers jours"
         if {[file exists $::dbo::svgjournuit]} {file delete -force $::dbo::svgjournuit}

         ::dbo::jour_nuit
         ::dbo::get_obs_data
         ::dbo::get_stat
         ::dbo::build_svg

         puts "   + Effacement du fichier : $::dbo::svgjournuit"
         file delete -force $::dbo::svgjournuit
         puts "   + Effacement du fichier : $::dbo::filetn"
         file delete -force $::dbo::filetn
         puts "   + Effacement du fichier : $::dbo::svgobs"
         file delete -force $::dbo::svgobs
      }
           
      set datefin [UTnowISO]
      set tf [mc_date2jd $datefin]
      set duree [format "%0.1f" [ expr ($tf - $::dbo::nowjd)*1440.0 ]]

      set ::dbo::sysfile [file join $::dbo::workdir "obslog.system.inc.php"]

      puts "+ Ecriture du fichier : $::dbo::sysfile"
      set data "<?php\n"
      append data "\$duree=$duree;\n"
      append data "\$datefin=\"$datefin\";\n"
      append data "?>\n"
      set f [open $::dbo::sysfile w]
      puts $f $data
      close $f

      ::dbo::send_ftp

      puts "Fin : $datefin // duree : $duree min"
 
      return
   }
   


   proc ::dbo::send_ftp { } {

      if {$::dbo::ftp == 1} {
         set err [catch { exec lftp -u $::dbo::ftplogin,$::dbo::ftppassword $::dbo::ftphost -e "cd $::dbo::ftpdistdir ; mput ${::dbo::workdir}/*.svg ; mput ${::dbo::workdir}/*.inc.php ; exit" } msg ]
         if {$err!=1 && $err!=0} {
             puts "Sending FTP : echec"
             puts "Sending FTP : cmd = lftp -u $::dbo::ftplogin,$::dbo::ftppassword $::dbo::ftphost -e \"cd $::dbo::ftpdistdir ; mput ${::dbo::workdir}/*.htm ; exit\""
             puts "Sending FTP : err = $err"
             puts "Sending FTP : msg = $msg"
         } else {
             puts "Send by FTP on $::dbo::ftphost"
         }
      }

      return
   }








   proc ::dbo::build_svg { } {
      
      set data ""
      append data "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
      append data "<svg xmlns=\"http://www.w3.org/2000/svg\" height=\"${::dbo::iheight}\" width=\"${::dbo::iwidth}\">\n"

      set f [open $::dbo::svgjournuit r]
      append data [read $f]
      close $f

      set f [open $::dbo::svgobs r]
      append data [read $f]
      close $f

      append data "<text id=\"text3346\" style=\"word-spacing:0px;letter-spacing:0px\" xml:space=\"preserve\" font-size=\"40px\" line-height=\"125%\" y=\"372.71997\" x=\"33.285301\" font-family=\"sans-serif\" fill=\"#000000\"><tspan id=\"tspan3348\" y=\"372.71997\" x=\"33.285301\" font-size=\"15px\">Dark</tspan></text>\n"
      append data "<rect id=\"rect3350\" fill-rule=\"evenodd\" height=\"11.407\" width=\"14.001\" stroke=\"#000\" y=\"361.67\" x=\"16.559\" stroke-width=\".40006px\" fill=\"#FF00F3\"/>\n"
      append data "<text id=\"text3346-3\" style=\"word-spacing:0px;letter-spacing:0px\" line-height=\"125%\" font-size=\"40px\" y=\"372.71997\" x=\"100.10926\" font-family=\"sans-serif\" xml:space=\"preserve\" fill=\"#000000\"><tspan id=\"tspan3348-6\" y=\"372.71997\" x=\"100.10926\" font-size=\"15px\">Flat</tspan></text>\n"
      append data "<rect id=\"rect3350-7\" fill-rule=\"evenodd\" height=\"11.407\" width=\"14.001\" stroke=\"#000\" y=\"361.67\" x=\"83.383\" stroke-width=\".40006px\" fill=\"#FFFFFF\"/>\n"
      append data "<text id=\"text3346-5\" style=\"word-spacing:0px;letter-spacing:0px\" line-height=\"125%\" font-size=\"40px\" y=\"372.71997\" x=\"158.46507\" font-family=\"sans-serif\" xml:space=\"preserve\" fill=\"#000000\"><tspan id=\"tspan3348-3\" y=\"372.71997\" x=\"158.46507\" font-size=\"15px\">Observe on sky</tspan></text>\n"
      append data "<rect id=\"rect3350-5\" fill-rule=\"evenodd\" height=\"11.407\" width=\"14.001\" stroke=\"#000\" y=\"361.67\" x=\"141.74\" stroke-width=\".40006px\" fill=\"#FCDF0E\"/>\n"
      append data "<text id=\"text3346-6\" style=\"word-spacing:0px;letter-spacing:0px\" line-height=\"125%\" font-size=\"40px\" y=\"372.71997\" x=\"292.90533\" font-family=\"sans-serif\" xml:space=\"preserve\" fill=\"#000000\"><tspan id=\"tspan3348-2\" y=\"372.71997\" x=\"292.90533\" font-size=\"15px\">WCS Error</tspan></text>\n"
      append data "<rect id=\"rect3350-9\" fill-rule=\"evenodd\" height=\"11.407\" width=\"14.001\" stroke=\"#000\" y=\"361.67\" x=\"276.18\" stroke-width=\".40006px\" fill=\"#FC190E\"/>\n"
      append data "<text id=\"text3346-6-1\" style=\"word-spacing:0px;letter-spacing:0px\" line-height=\"125%\" font-size=\"40px\" y=\"372.71997\" x=\"396.5903\" font-family=\"sans-serif\" xml:space=\"preserve\" fill=\"#000000\"><tspan id=\"tspan3348-2-2\" y=\"372.71997\" x=\"396.5903\" font-size=\"15px\">WCS Success</tspan></text>\n"
      append data "<rect id=\"rect3350-9-7\" fill-rule=\"evenodd\" height=\"11.407\" width=\"14.001\" stroke=\"#000\" y=\"361.67\" x=\"379.86\" stroke-width=\".40006px\" fill=\"#33C94B\"/>\n"

      append data "Sorry, your browser does not support inline SVG.\n"
      append data "</svg>\n"
      
      puts "   + Ecriture du fichier : $::dbo::svgfilename"
      set f [open $::dbo::svgfilename w]
      puts $f $data
      close $f

      return
   }
   
   
   
   proc ::dbo::get_tag_date { jd } {
      
      set date [mc_date2iso8601 $jd]
      set m [string range $date 5 6]
      set d [string range $date 8 9]
      set l1 [list "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"]
      set l2 [list "jan" "fev" "mar" "avr" "mai" "jun" "jul" "aou" "sep" "oct" "nov" "dec"]
      
      set pos [lsearch $l1 $d]
      if {$pos > -1} {set d [expr $pos+1]} 
      set pos [lsearch $l1 $m]
      set m [lindex $l2 $pos]
      set tag "$d $m"
      
      set w [format "%.0f" [expr $::dbo::lastdatejd - $::dbo::firstdatejd]]
      if {$w>10 && $w<50} {
         set l3 [list 1 5 10 15 20 25]
         if {!($d in $l3) } {set tag ""}
      }
      if {$w>50} {
         set tag $m
         set l3 [list 1]
         if {!($d in $l3) } {set tag ""}
         #if {$d == "15"} {set tag " "}
      }

      return $tag
   }






   proc ::dbo::jour_nuit { } {

      # Nb de jour a afficher
      set ::dbo::nbdays [format "%0.0f" [expr $::dbo::lastdatejd - $::dbo::firstdatejd]]
      # longueur du bord en pixel a gauche et a droite
      set ::dbo::bord 50
      # longueur de l espacement intermediaire en % de long
      set ::dbo::inter 10
      # longueur de l espacement intermediaire en pixel
      set w [expr ($::dbo::iwidth - 2.0 * $::dbo::bord ) / ($::dbo::nbdays * 1.0) ]
      #puts "w       : $w"
      set ::dbo::inter [expr $w * $::dbo::inter / 100.0] 
      # longueur sur l axe X en pixel de chaque colonne 
      set ::dbo::long  [expr $w - $::dbo::inter] 
      
      if {[file exists $::dbo::svgjournuit]} {return}

      puts "+ Graphe jour_nuit \[ ${::dbo::iwidth}x${::dbo::iheight} \] \[ $::dbo::nbdays j \] \[ midi = [format "%0.2f" [expr 24.0*$::dbo::offset_midi]] h \] "
      puts "   + firstdate : $::dbo::firstdate"
      puts "   + lastdate  : $::dbo::lastdate"
      #puts "now       : $::dbo::nowiso"

      set ldflat ""
      set ldnight ""
      set lenight ""

      set ::dbo::total_nuit 0

      # test pour trouver la coordonnees 0 sur l axe X
      # on cherche la date minimale
      set curjd $::dbo::firstdatejd
      set x [lindex [::dbo::d2g [expr $curjd]] 0]
      set doff 0
      while { $x > 0 } {
         incr doff
         set curjd [expr $curjd-1]
         set x [lindex [::dbo::d2g [expr $curjd]] 0]
      }
      #puts "x base doff : $x $doff"
      
      #lassign [::dbo::d2g $::dbo::firstdatejd] x0
      #lassign [::dbo::d2g $::dbo::lastdatejd]  x1
      
      #set x0 [expr $x0 -$::dbo::long/2.0]
      #set x1 [expr $x1 -$::dbo::long/2.0]
      
      #puts "nbdays : $::dbo::nbdays"
      #puts "iwidth : $::dbo::iwidth"
      #puts "long   : $::dbo::long"
      #puts "inter  : $::dbo::inter"
      #puts "bord   : $::dbo::bord"
      #puts "verif=0: [expr $::dbo::bord*2 + $::dbo::nbdays * ($::dbo::long+$::dbo::inter) - $::dbo::iwidth]"
      #puts "verif=0: [expr $::dbo::bord*2 + $x1 - $x0 - $::dbo::iwidth]"

      #puts "BORDS : $x0 $x1 "

#nbdays : 30
#iwidth : 600
#long   : 15
#inter  : 2
#bord   : 50
#verif=0: 8
#BORDS : 50.5 560.5 

#nbdays : 7
#iwidth : 600
#long   : 66
#inter  : 7
#bord   : 50
#verif=0: 4
#BORDS : 50.0 561.0 
      
      # demarrage de la boucle pour les nuitées
      set curjd [expr $::dbo::firstdatejd-$doff]
      while { $curjd < [expr $::dbo::lastdatejd+$doff] } {
         
         set curmin 0
         set dflat  ""
         set dnight ""
         set enight ""
         while { $curmin < 1440 } {
            set jd [expr $curjd + $curmin/1440.0]
            set sun [lindex [mc_ephem {sun} [list $jd] {altitude} -topo $::dbo::home] 0 0 ]
            if { $dflat  == "" && $sun < -4}  {set dflat $jd}
            if { $dnight == "" && $sun < -12} {set dnight $jd}
            if { $enight == "" && $dnight != "" && $sun > -12} {set enight $jd}
            incr curmin
         }
         if {$dnight > $::dbo::firstdatejd && $dnight < $::dbo::nowjd} {
            if {$enight < $::dbo::nowjd} {
               set ::dbo::total_nuit [expr $::dbo::total_nuit + $enight-$dnight]
            } else {
               set ::dbo::total_nuit [expr $::dbo::total_nuit + $::dbo::nowjd - $dnight]
            } 
         }
         lappend ldflat  [::dbo::d2g $dflat]
         lappend ldnight [::dbo::d2g $dnight]
         lappend lenight [::dbo::d2g $enight]
         set curjd [expr $curjd + 1.0]
      }

      set color_nuit "#213C6B"
      set color_flat "#1F4FA5"
      set color_jour "#8BB1F4"
      
      # Creation du SVG 
      set data ""
      append data "\n"


      # Finalisation SVG : total jour
      append data "<polygon points=\"0,0 ${::dbo::iwidth},0 ${::dbo::iwidth},${::dbo::iheight} 0,${::dbo::iheight} 0,0"
      append data "\" style=\"fill:$color_jour;stroke:black;stroke-width:0\" />\n"

      # Finalisation SVG : Fin nuit
      append data "<polygon points=\"0,0 "
      foreach dot $lenight {append data "[lindex $dot 0],[lindex $dot 1] "}
      append data "${::dbo::iwidth},0 0,0\" style=\"fill:$color_nuit;stroke:purple;stroke-width:0\" />\n"

      # Finalisation SVG : debut nuit
      append data "<polygon points=\"0,0 "
      foreach dot $ldnight {append data "[lindex $dot 0],[lindex $dot 1] "}
      append data "${::dbo::iwidth},0 0,0\" style=\"fill:$color_flat;stroke:purple;stroke-width:0\" />\n"

      # Finalisation SVG : Flat
      append data "<polygon points=\"0,0 "
      foreach dot $ldflat {append data "[lindex $dot 0],[lindex $dot 1] "}
      append data "${::dbo::iwidth},0 0,0\" style=\"fill:$color_jour;stroke:purple;stroke-width:0\" />\n"

      # Tag Days
      set curjd [expr $::dbo::firstdatejd]
      set color "#888888"
      while { $curjd < [expr $::dbo::lastdatejd] } {
         lassign [::dbo::d2g $curjd] x y
         
         set tag [::dbo::get_tag_date $curjd]
         set curjd [expr $curjd + 1.0]
         if {$tag == ""} {continue}

         #puts "TAG: $tag $x"
         
         set x [expr $x - $::dbo::long/2]
         set y 20
         append data "<text style=\"word-spacing:0px;letter-spacing:0px\" xml:space=\"preserve\" font-size=\"12.5px\" y=\"$y\" x=\"$x\" font-family=\"sans-serif\" line-height=\"125%\" fill=\"#000000\"><tspan id=\"tspan8060\" y=\"$y\" x=\"$x\" font-family=\"&apos;AR PL SungtiL GB&apos;\">$tag</tspan></text>\n"
         set y1 [expr $y+10]
         set y2 [expr ${::dbo::iheight}-50]
         append data "<line y2=\"$y2\" x2=\"$x\" y1=\"$y1\" x1=\"$x\" style=\"stroke:$color;stroke-width:0.5\"/>\n"       
      }
            
      # FINAL Day
      if {1==0} {
         set curjd $::dbo::lastdatejd
         set color "#F21919"
         lassign [::dbo::d2g $curjd] x y
         set tag [::dbo::get_tag_date $curjd]
         puts "FINAL TAG: $tag $x"
         set curjd [expr $curjd + 1.0]
         set x [expr $x - $::dbo::long/2]
         set y 20
         set y1 [expr $y+10]
         set y2 [expr ${::dbo::iheight}-50]
         append data "<line y2=\"$y2\" x2=\"$x\" y1=\"$y1\" x1=\"$x\" style=\"stroke:$color;stroke-width:0.5\"/>\n"       
      }

      # Bords
      if {1==0} {
         set x 50
         set y1 [expr 30]
         set y2 [expr ${::dbo::iheight}-50]
         set color $color_flat
         append data "<line y2=\"$y2\" x2=\"$x\" y1=\"$y1\" x1=\"$x\" style=\"stroke:$color_flat;stroke-width:0.5\"/>\n"       
         set x 550
         append data "<line y2=\"$y2\" x2=\"$x\" y1=\"$y1\" x1=\"$x\" style=\"stroke:$color_flat;stroke-width:0.5\"/>\n"       
      }

      # Tag NOW
      lassign [::dbo::d2g $::dbo::nowjd] x y
      set x1 $x
      set x2 $x 
      set y1 [expr $y-1]
      set y2 [expr $y+1]
      set color "#F4BCBC"
      append data "<line x1=\"$x1\" y1=\"$y1\" x2=\"$x2\" y2=\"$y2\" style=\"stroke:$color;stroke-width:$::dbo::long\"/>\n"
      append data "<circle cx=\"$x\" stroke=\"#000\" cy=\"$y\" r=\"2\" stroke-width=\"0px\" fill=\"#f00\"/>\n"

      puts "   + Ecriture du fichier : $::dbo::svgjournuit"
      set f [open $::dbo::svgjournuit w]
      puts $f $data
      close $f

      puts "   + Ecriture du fichier : $::dbo::filetn"
      set f [open $::dbo::filetn w]
      puts $f $::dbo::total_nuit
      close $f

      return
   }
























   # transformation Date -> coordonnees graphique
   proc ::dbo::d2g { datejd } {
      set date [expr $datejd - $::dbo::firstdatejd]
      set col [format "%.0f" [expr floor($date)]]
      set h [expr  $date -  $col]    
      set x [format "%.3f" [expr $::dbo::bord + $col * ($::dbo::long+$::dbo::inter) + $::dbo::long/2]]
      set y [format "%.3f" [expr $h * ${::dbo::iheight}]]
      if {$x<0} {set x 0}
      if {$x>$::dbo::iwidth} {set x $::dbo::iwidth}
      if {$y<0} {set y 0}
      if {$y>$::dbo::iheight} {set y $::dbo::iheight}
      return [list $x $y]
   }




   # transformation Date -> coordonnees graphique
   proc ::dbo::d2g2 { datejd } {
      
      set log 0
      

      if {$log} {puts "bord  = $::dbo::bord"}
      if {$log} {puts "long  = $::dbo::long"}
      if {$log} {puts "inter = $::dbo::inter"}


      if {$log} {puts "firstdatejd = $::dbo::firstdatejd"}
      if {$log} {puts "datejd      = $datejd"}
      
      set date [expr $datejd - $::dbo::firstdatejd]
      if {$log} {puts "date = $date"}
      
      set col [format "%.0f" [expr floor($date)]]
      if {$log} {puts "col = $col"}
      
      set h [expr  $date -  $col]    
      if {$log} {puts "h = $h"}

      set x [format "%.3f" [expr $::dbo::bord + $::dbo::long/2.0 + $col * ($::dbo::long+$::dbo::inter)]]
      if {$log} {puts "x = $x"}

      set y [format "%.3f" [expr $h * ${::dbo::iheight}]]
      if {$log} {puts "y = $y"}
      if {$x<0} {set x 0}
      if {$x>$::dbo::iwidth} {set x $::dbo::iwidth}
      if {$y<0} {set y 0}
      if {$y>$::dbo::iheight} {set y $::dbo::iheight}
      
      if {$log} {exit}
      return [list $x $y]

      #puts ""
      #puts "date = [mc_date2iso8601 $datejd]"
      #puts "jd = $datejd"
      #puts "offset_midi = $::dbo::offset_midi"
      #puts "firstdatejd = $::dbo::firstdatejd"
      #puts "lastdatejd  = $::dbo::lastdatejd"
      #puts ""
      set y [expr $datejd - $::dbo::offset_midi]
      #puts "y = $y"
      set z [expr $::dbo::firstdatejd - $::dbo::offset_midi]
      #puts "z = $z"
      set y [expr floor($y) - floor($z) ]
      #puts "y = $y"

      #set x [expr floor($datejd) ]
      #puts "x = $x"
      #set x [expr ($x - $::dbo::firstdatejd) / ($::dbo::lastdatejd - $::dbo::firstdatejd) ]
      #puts "x = $x"

      set x [expr $y * ${::dbo::maxwidth} / ($::dbo::lastdatejd - $::dbo::firstdatejd - 1)]
      #puts "x = $x"
      set x [expr floor($x)]
      #puts "x = $x"
      set x [format "%.0f" $x]
      puts "Fx = $x"
      
      
      set y [expr $datejd - $::dbo::offset_midi]
      set y [expr $y - floor($y) ]
      set y [expr $y * ${::dbo::iheight} ]
      set y [format "%.0f" $y]
      puts "Fy = $y"
      exit
      return [list $x $y]
   }





   # transformation Date -> coordonnees graphique
   proc ::dbo::d2g_old { datejd } {
      #puts ""
      #puts "date = [mc_date2iso8601 $datejd]"
      #puts "jd = $datejd"
      #puts "offset_midi = $::dbo::offset_midi"
      #puts "firstdatejd = $::dbo::firstdatejd"
      #puts "lastdatejd  = $::dbo::lastdatejd"
      #puts ""
      set y [expr $datejd - $::dbo::offset_midi]
      #puts "y = $y"
      set z [expr $::dbo::firstdatejd - $::dbo::offset_midi]
      #puts "z = $z"
      set y [expr floor($y) - floor($z) ]
      #puts "y = $y"

      #set x [expr floor($datejd) ]
      #puts "x = $x"
      #set x [expr ($x - $::dbo::firstdatejd) / ($::dbo::lastdatejd - $::dbo::firstdatejd) ]
      #puts "x = $x"

      set x [expr $y * ${::dbo::maxwidth} / ($::dbo::lastdatejd - $::dbo::firstdatejd - 1)]
      #puts "x = $x"
      set x [expr floor($x)]
      #puts "x = $x"
      set x [format "%.0f" $x]
      #puts "Fx = $x"
      
      
      set y [expr $datejd - $::dbo::offset_midi]
      set y [expr $y - floor($y) ]
      set y [expr $y * ${::dbo::iheight} ]
      set y [format "%.0f" $y]
      return [list $x $y]
   }









   # Recupere les donnees de la base pour le SVG
   proc ::dbo::get_obs_data { } {
      
      ::bddimages_sql::connect

      set sqlcmd "select date, exposure, type from images where date > \"$::dbo::firstdate\" and date < \"$::dbo::lastdate\" order by date asc;"
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des images sur le serveur sql"
         return
      }

      set data ""

      foreach line $resultsql {
         set jd1 [mc_date2jd [lindex $line 0]]
         set jd2 [expr $jd1 + [lindex $line 1] / 86400.0]
         set type [lindex $line 2]
         set line [svg_line $type $jd1 $jd2]
         append data $line
      }

      puts "   + Ecriture du fichier : $::dbo::svgobs"
      set f [open $::dbo::svgobs w]
      puts $f $data
      close $f

 
   }






   proc svg_line { type jd1 jd2 } {
      set g1 [::dbo::d2g $jd1]
      set g2 [::dbo::d2g $jd2]
      lassign $g1 x1 y1
      lassign $g2 x2 y2
      if {$y1==$y2} {set y2 [expr $y1+1]}
      switch $type {
         "IMG"     {set color "#FCDF0E"}
         "SUCCESS" {set color "#33C94B"}
         "ERROR"   {set color "#FC190E"}
         "FLAT"    {set color "#FFFFFF"}
         "DARK"    {set color "#FF00F3"}
         "OFFSET"  {set color "#00FFCB"}
         default   {set color "#AA00FF"}
      }
      
      return "<line x1=\"$x1\" y1=\"$y1\" x2=\"$x2\" y2=\"$y2\" style=\"stroke:$color;stroke-width:$::dbo::long\"/>\n"
   }









   # Recupere les donnees de la base pour la table de donnees
   proc ::dbo::get_stat { } {
      
      if {![file exists $::dbo::filetn]} {return}
      set f [open $::dbo::filetn r]
      set ::dbo::total_nuit [string trim [read $f]]
      close $f
      
      set tn  [format "%.0f" [expr $::dbo::total_nuit*24.0] ]
      set data "<?php\n"
      append data "\$nbhp=$tn;\n"
      
      # All obs
      set sqlcmd "select sum(exposure)/86400.0 from images where "
      append sqlcmd " ( type =\"IMG\" or type =\"SUCCESS\"  or type =\"ERROR\" )"
      append sqlcmd "and date > \"$::dbo::firstdate\" "
      append sqlcmd "and date < \"$::dbo::lastdate\" "
      append sqlcmd "order by date asc;"
      
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des images sur le serveur sql"
         return
      }
      set sum [lindex $resultsql 0 0]
      if {$sum == ""} {set sum 0}
      set pc  [format "%.2f" [expr $sum/$::dbo::total_nuit*100.0] ]
      set sum [format "%.0f" [expr $sum*24.0] ]
      
      append data "\$nbho=$sum;\n"
      append data "\$pco=$pc;\n"

      # SUCCESS
      set sqlcmd "select sum(exposure)/86400.0 from images where "
      append sqlcmd " ( type =\"SUCCESS\" )"
      append sqlcmd "and date > \"$::dbo::firstdate\" "
      append sqlcmd "and date < \"$::dbo::lastdate\" "
      append sqlcmd "order by date asc;"
      
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des images sur le serveur sql"
         return
      }
      set sum [string trim [lindex $resultsql 0 0]]
      if {$sum == ""} {
         set pc  0.00
         set sum 0
      } else {
         set pc  [format "%.2f" [expr $sum/$::dbo::total_nuit*100.0] ]
         set sum [format "%.0f" [expr $sum*24.0] ]
      }
      
      append data "\$nbhu=$sum;\n"
      append data "\$pcu=$pc;\n"

      # ERROR
      set sqlcmd "select sum(exposure)/86400.0 from images where "
      append sqlcmd " ( type =\"IMG\" or type =\"ERROR\" )"
      append sqlcmd "and date > \"$::dbo::firstdate\" "
      append sqlcmd "and date < \"$::dbo::lastdate\" "
      append sqlcmd "order by date asc;"
      
      set err [catch {set resultsql [::bddimages_sql::sql query $sqlcmd]} msg]
      if {$err} {
         puts "Erreur liste des images sur le serveur sql"
         return
      }
      set sum [string trim [lindex $resultsql 0 0] ]
      if {$sum == ""} {
         set pc  0.00
         set sum 0
      } else {
         set pc  [format "%.2f" [expr $sum/$::dbo::total_nuit*100.0] ]
         set sum [format "%.0f" [expr $sum*24.0] ]
      }
      
      append data "\$nbhe=$sum;\n"
      append data "\$pce=$pc;\n"
      append data "?>\n"
      puts "   + Ecriture du fichier : $::dbo::filestat"
      set f [open $::dbo::filestat w]
      puts $f $data
      close $f

   }





proc UTnowISO {  } {
   set t [clock milliseconds]
   set time [format "%s.%03d" [clock format [expr {$t / 1000}] -format "%Y-%m-%dT%H:%M:%S" -timezone :UTC] [expr {$t % 1000}] ]
}
