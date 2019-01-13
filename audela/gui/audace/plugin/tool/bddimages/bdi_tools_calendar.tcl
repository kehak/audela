## @file bdi_tools_calendar.tcl
#  @brief     Fonctions d'affichage d'un calendrier pour choisir une date
#  @author    Jerome Berthier, sur les bases de Richard Suchenwirth (http://wiki.tcl.tk/1816)
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource 
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bdi_tools_calendar.tcl]
#  @endcode

# $Id: bdi_tools_calendar.tcl 13117 2016-05-21 02:00:00Z jberthier $

##
# @namespace bdi_tools_calendar
# @brief Fonctions d'affichage d'un calendrier pour choisir une date
# @pre Requiert le paquet \c msgcat .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bdi_tools_calendar {

   package provide bdi_tools_calendar 1.0

   package require msgcat
#   package require Tk

   global mycal

   #------------------------------------------------------------
   ## Affichage d'une GUI pour choisir une date dans un calendrier
   # @param w string pathName du Chooser
   # @param args Tableau des arguments du Chooser
   # @return void
   proc chooser {w args} {

      variable $w
      variable defaults
      array set $w [array get defaults]
      upvar 0 $w a

      set now [clock scan now]
      set a(year) [clock format $now -format "%Y"]
      scan [clock format $now -format "%m"] %d a(month)
      scan [clock format $now -format "%d"] %d a(day)

      # The -mon switch gives the position of Monday (1 or 0)
      array set a {
        -font {Helvetica 9} -titlefont {Helvetica 12} -bg white
        -highlight orange -mon 1 -language en -textvariable {}
        -command {} -clockformat "%m/%d/%Y" -showpast 1
      }
      array set a $args
      set a(canvas) [canvas $w -bg $a(-bg) -width 200 -height 180]
      $w bind day <1> {
            set item [%W find withtag current]
            set ::bdi_tools_calendar::%W(day) [%W itemcget $item -text]
            ::bdi_tools_calendar::display %W
            ::bdi_tools_calendar::HandleCallback %W
      }

      if { $a(-textvariable) ne {} } {
         set tmp [set $a(-textvariable)]
         if {$tmp ne {} } {
            set date [clock scan $tmp -format $a(-clockformat)]
            set a(thisday)   [clock format $date -format %d]
            set a(thismonth) [clock format $date -format %m]
            set a(thisyear)  [clock format $date -format %Y]
         }
      }

      cbutton $w 60  10 << {::bdi_tools_calendar::adjust %W  0 -1}
      cbutton $w 80  10 <  {::bdi_tools_calendar::adjust %W -1  0}
      cbutton $w 120 10 >  {::bdi_tools_calendar::adjust %W  1  0}
      cbutton $w 140 10 >> {::bdi_tools_calendar::adjust %W  0  1}
      display $w
      set w
   }
   
   #------------------------------------------------------------
   ## Affichage formate de la date
   # @param w tableau contenant toutes les info de la date
   # @return void
   proc display { w } {

      variable $w
      upvar 0 $w a

      set c $a(canvas)
      foreach tag {title otherday day} {$c delete $tag}
      set x0 20; set x $x0; set y 50
      set dx 25; set dy 20
      set xmax [expr {$x0+$dx*6}]
      set a(date) [clock scan $a(month)/$a(day)/$a(year)]
      set title [formatMY $w [monthname $w $a(month)] $a(year)]
      $c create text [expr ($xmax+$dx)/2] 30 -text $title -fill blue \
           -font $a(-titlefont) -tag title
      set weekdays $a(weekdays,$a(-language))
      if !$a(-mon) {lcycle weekdays}
      foreach i $weekdays {
         $c create text $x $y -text $i -fill blue \
              -font $a(-font) -tag title
         incr x $dx
      }
      set first $a(month)/1/$a(year)
      set weekday [clock format [clock scan $first] -format %w]
      if !$a(-mon) {set weekday [expr {($weekday+6)%7}]}
      set x [expr {$x0+$weekday*$dx}]
      set x1 $x; set offset 0
      incr y $dy
      while {$weekday} {
         set t [clock scan "$first [incr offset] days ago"]
         scan [clock format $t -format "%d"] %d day
         $c create text [incr x1 -$dx] $y -text $day \
              -fill grey -font $a(-font) -tag otherday
         incr weekday -1
      }
      set dmax [numberofdays $a(month) $a(year)]
      for {set d 1} {$d<=$dmax} {incr d} {
         if {($a(-showpast) == 0) && ($d<$a(thisday)) && ($a(month) <= $a(thismonth)) && ($a(year) <= $a(thisyear)) } {
            set id [$c create text $x $y -text $d -fill grey -tag otherday -font $a(-font)]
         } else {
            set id [$c create text $x $y -text $d -tag day -font $a(-font)]
         }
         if {$d==$a(day)} {
            eval $c create rect [$c bbox $id] \
                 -fill $a(-highlight) -outline $a(-highlight) -tag day
         }
         $c raise $id
         if {[incr x $dx]>$xmax} {set x $x0; incr y $dy}
      }
      if {$x != $x0} {
         for {set d 1} {$x<=$xmax} {incr d; incr x $dx} {
            $c create text $x $y -text $d \
                 -fill grey -font $a(-font) -tag otherday
         }
      }
      if { $a(-textvariable) ne {} } {
         set $a(-textvariable) [clock format $a(date) -format $a(-clockformat)]
      }
   }

   proc adjust {w dmonth dyear} {
      variable $w
      upvar 0 $w a

      incr a(year)  $dyear
      incr a(month) $dmonth
      if {$a(month)>12} {set a(month) 1; incr a(year)}
      if {$a(month)<1}  {set a(month) 12; incr a(year) -1}
      set maxday [numberofdays $a(month) $a(year)]
      if {$maxday < $a(day)} {set a(day) $maxday}
      display $w
   }
   
   proc HandleCallback {w} {
      variable $w
      upvar 0 $w a
      if { $a(-command) ne {} } {
          uplevel \#0 $a(-command)
      }
   }

   proc formatMY {w month year} {
      variable $w
      upvar 0 $w a

      if ![info exists a(format,$a(-language))] {
         set format "%m %y" ;# default
      } else {
         set format $a(format,$a(-language))
      }
      foreach {from to} [list %m $month %y $year] {
         regsub $from $format $to format
      }
      subst $format
   }
   
   proc monthname {w month {language default}} {
      variable $w
      upvar 0 $w a

      if {$language=="default"} {set language $a(-language)}
      if {[info exists a(mn,$language)]} {
         set res [lindex $a(mn,$language) $month]
      } else {set res $month}
   }

   variable defaults
   array set defaults {
       -language en
       mn,de {
       . Januar Februar März April Mai Juni Juli August
       September Oktober November Dezember
       }
       weekdays,de {So Mo Di Mi Do Fr Sa}

       mn,en {
       . January February March April May June July August
       September October November December
       }
       weekdays,en {Sun Mon Tue Wed Thu Fri Sat}

       mn,es {
       . Enero Febrero Marzo Abril Mayo Junio Julio Agosto
       Septiembre Octubre Noviembre Diciembre
       }
       weekdays,es {Do Lu Ma Mi Ju Vi Sa}

       mn,fr {
       . Janvier Février Mars Avril Mai Juin Juillet Août
       Septembre Octobre Novembre Décembre
       }
       weekdays,fr {Di Lu Ma Me Je Ve Sa}

       mn,it {
       . Gennaio Febraio Marte Aprile Maggio Giugno Luglio Agosto
       Settembre Ottobre Novembre Dicembre
       }
       weekdays,it {Do Lu Ma Me Gi Ve Sa}

       mn,nl {
       . januari februari maart april mei juni juli augustus
       september oktober november december
       }
       weekdays,nl {Zo Ma Di Wo Do Vr Za}

       mn,ru {
       . \u042F\u043D\u0432\u0430\u0440\u044C
       \u0424\u0435\u0432\u0440\u0430\u043B\u044C \u041C\u0430\u0440\u0442
       \u0410\u043F\u0440\u0435\u043B\u044C \u041C\u0430\u0439
       \u0418\u044E\u043D\u044C \u0418\u044E\u043B\u044C
       \u0410\u0432\u0433\u0443\u0441\u0442
       \u0421\u0435\u043D\u0442\u044F\u0431\u0440\u044C
       \u041E\u043A\u0442\u044F\u0431\u0440\u044C \u041D\u043E\u044F\u0431\u0440\u044C
       \u0414\u0435\u043A\u0430\u0431\u0440\u044C
       }
       weekdays,ru {
           \u432\u43e\u441 \u43f\u43e\u43d \u432\u442\u43e \u441\u440\u435
           \u447\u435\u442 \u43f\u44f\u442 \u441\u443\u431
       }

       mn,sv {
           . januari februari mars april maj juni juli augusti
           september oktober november december
       }
       weekdays,sv {s\u00F6n m\u00E5n tis ons tor fre l\u00F6r}

       mn,pt {
       . Janeiro Fevereiro Mar\u00E7o Abril Maio Junho
       Julho Agosto Setembro Outubro Novembro Dezembro
       }
       weekdays,pt {Dom Seg Ter Qua Qui Sex Sab}

   }
   
   proc numberofdays {month year} {
      if {$month==12} {set month 0; incr year}
      clock format [clock scan "[incr month]/1/$year  1 day ago"] -format %d
   }
   
   proc cbutton {w x y text command} {
      set txt [$w create text $x $y -text " $text "]
      set btn [eval $w create rect [$w bbox $txt] -fill grey -outline grey]
      $w raise $txt
      foreach i [list $txt $btn] {$w bind $i <1> $command}
   }

   proc lcycle _list {
      upvar $_list list
      set list [concat [lrange $list 1 end] [list [lindex $list 0]]]
   }

}
