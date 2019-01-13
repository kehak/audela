#
## @file plotxy.tcl
#  @brief Réalisation de graphes à partir de 2 listes de nombres
#  @note La syntaxe est la plus proche possible de Matlab
#  @author Alain KLOTZ
#  $Id: plotxy.tcl 13876 2016-05-19 16:13:50Z fredvachier $
#  @code source $audace(rep_install)/gui/audace/plotxy.tcl
#  here are two vectors :
#  set x {1 2 3 4 5 6 7 8 9}
#  set y {4 6 8 3 2 5 8 5 4 }
#  plot a red crosses of 10 points linked by dashed lines :
#  ::plotxy::plot $x $y r+: 10
#  the next plot will be overlayed :
#  ::plotxy::hold on
#  the y vector has changed a little :
#  set y {4.6 6.8 8.1 3.3 2.6 5.8 8.5 5.3 4.1 }
#  plot a blue disks of 10 points linked by solid lines :
#  ::plotxy::plot $x $y bo- 5
#  ajust the graph to 500x500 pixel window :
#  ::plotxy::geometry 500 500
#  the background will be dark green :
#  ::plotxy::bgcolor #557711
#  set the axes limits (xmin,xmax,ymin,ymax) :
#  ::plotxy::axis {1 10 0 10 }
#  invert the direction along the y axis :
#  ::plotxy::ydir reverse
#  decorations of axis :
#  ::plotxy::xlabel "time"
#  ::plotxy::ylabel "intensity"
#  ::plotxy::title "a big test"
#  @endcode
#  @todo traiter pour Doxygen

global plotxy

catch {unset plotxy}

if {[info commands ::console::affiche_resultat]!="::console::affiche_resultat"} {
   set plotxy(audace) 0
} else {
   set plotxy(audace) 1
}

## namespace plotxy
#  @brief Réalisation de graphes à partir de 2 listes de nombres


namespace eval ::plotxy {
   variable selected_region
   global plotxy

   ## @brief select a figure index to display a graphic
   proc figure { {num ""} {parentframe ""} } {
      global audace
      global caption
      global plotxy

      if {$num!=""} {
         set plotxy(currentfigure) $num
         if {([info exists plotxy(fig$num,ydir)]==0)&&($num>0)} {
            set plotxy(figure,$num) 1
            #--- init public variables of properties for this figure
            set plotxy(fig$num,ydir) normal
            set plotxy(fig$num,xdir) normal
            if {$plotxy(audace)==1} {
               set plotxy(fig$num,plotbackground) $audace(color,backColor)
               set plotxy(fig$num,bgcolor)        $audace(color,backColor)
               set plotxy(fig$num,fgcolor)        $audace(color,textColor)
               set plotxy(fig$num,caption) "$caption(plotxy,figure) $num"
            } else {
               set plotxy(fig$num,plotbackground) #FFFFFF
               set plotxy(fig$num,bgcolor)        #FFFFFF
               set plotxy(fig$num,fgcolor)        #000000
               set plotxy(fig$num,caption) "Figure $num"
            }
            set plotxy(fig$num,position) {40 40 400 400}
            set plotxy(fig$num,hide)      1
            set plotxy(fig$num,hold)      off
            set plotxy(fig$num,axis)      ""
            set plotxy(fig$num,linewidth) 1
            set plotxy(fig$num,xlabel)    "x data"
            set plotxy(fig$num,ylabel)    "y data"
            set plotxy(fig$num,title)     ""
            #--- init private variables of properties for this figure
            set plotxy(fig0,privates) {lastline}
            set plotxy(fig$num,lastline) 0
            set plotxy(fig$num,lasttext) 0
            #--- init frame for this figure
            if {$parentframe==""} {
               if {$plotxy(audace)==1} {
                  set plotxy(fig$num,parent) $audace(base).plotxy$plotxy(currentfigure)
               } else {
                  set plotxy(fig$num,parent) .plotxy$plotxy(currentfigure)
               }
            } else {
               set plotxy(fig$num,parent) ${parentframe}.plotxy$plotxy(currentfigure)
            }
            #--- init the graphic interface
            set baseplotxy $plotxy(fig$num,parent)
            toplevel $baseplotxy
            wm withdraw $baseplotxy
            wm maxsize $baseplotxy [winfo screenwidth .] [winfo screenheight .]
            wm minsize $baseplotxy 200 200
            wm resizable $baseplotxy 1 1
            set texte "wm protocol $baseplotxy WM_DELETE_WINDOW { ::plotxy::clf $num }"
            eval $texte
            ::blt::graph $baseplotxy.xy
            #--- update the graphics
            ::plotxy::setgcf $num [::plotxy::getgcf $num]
            set plotxy(fig$num,hide) 0
            #---
            if {$plotxy(audace)==1} {
               #--- Focus
               focus $baseplotxy
               #--- Raccourci qui donne le focus a la Console et positionne le curseur dans
               #--- la ligne de commande
               bind $baseplotxy <Key-F1> { ::console::GiveFocus }
               #--- Mise a jour dynamique des couleurs
               ::confColor::applyColor $baseplotxy
               ::confColor::applyColor $baseplotxy.xy
            }
         }
      }
      return $plotxy(currentfigure)
   }

   ## @brief destroy a figure index to display a graphic
   proc clf { { num "" } } {
      global audace
      global plotxy

      set nums ""
      #--- search the figure indexes to destroy
      if {$num!=""} {
         set nums $num
      } else {
         set names [array names plotxy]
         foreach name $names {
            set kend [string first , $name ]
            if {$kend>=0} {
               set name1 [string range $name 0 [expr $kend-1] ]
               set name2 [string range $name [expr 1+$kend] end]
               if {$name1=="figure"} {
                  lappend nums $name2
               }
            }
         }
      }
      #--- loop over the figure indexes to destroy
      foreach num $nums {
         if {[info exists plotxy(figure,$num)]==0} {
            continue
         }
         destroy $plotxy(fig$num,parent)
         set name0 fig$num
         set names [array names plotxy]
         unset plotxy(figure,$num)
         foreach name $names {
            set kend [string first , $name ]
            if {$kend>=0} {
               set name1 [string range $name 0 [expr $kend-1] ]
               set name2 [string range $name [expr 1+$kend] end]
               if {$name1==$name0} {
                  unset plotxy($name1,$name2)
               }
            }
         }
      }
      #--- search the figure indexes that left
      set names [array names plotxy]
      set nums 0
      foreach name $names {
         set kend [string first , $name ]
         if {$kend>=0} {
            set name1 [string range $name 0 [expr $kend-1] ]
            set name2 [string range $name [expr 1+$kend] end]
            if {$name1=="figure"} {
               lappend nums $name2
            }
         }
      }
      set num [lindex $nums end]
      set plotxy(currentfigure) $num
      ::plotxy::unset_selected_region

   }

   ## @brief get boolean existing graph
   proc exists { num } {
      global plotxy
      if {[info exists plotxy(fig$num,parent)]} {
         set baseplotxy $plotxy(fig$num,parent)
         return [winfo exists $baseplotxy]
      } else {
         return 0
      }

   }

   ## @brief get geometry properties of the figure num, formatted as {x y width height}
   proc getgeometry { num } {
      global plotxy

      if {[info exists plotxy(fig$num,parent)]} {
         set baseplotxy $plotxy(fig$num,parent)
         set geom [winfo geometry $baseplotxy]
         set a [split $geom +]
         set b [split [lindex $a 0] x]
         return [list [lindex $a 1] [lindex $a 2] [lindex $b 0] [lindex $b 1]]
      } else {
         return -code 1 "Unknown figure index"
      }

   }

   ## @brief get properties of the figure index
   proc getgcf { num } {
      global audace
      global plotxy

      set name0 fig$num
      set names [array names plotxy]
      set listoptions ""
      foreach name $names {
         set kend [string first , $name ]
         if {$kend>=0} {
            set name1 [string range $name 0 [expr $kend-1] ]
            set name2 [string range $name [expr 1+$kend] end]
            if {$name1==$name0} {
               if {[lsearch -exact $plotxy(fig0,privates) $name2]==-1} {
                  lappend listoptions [list $name2 $plotxy($name1,$name2)]
               }
            }
         }
      }
      return $listoptions
   }

   ## @brief set properties of the figure index
   proc setgcf { num listoptions } {
      global audace
      global plotxy

      set name1 fig$num
      set baseplotxy $plotxy(fig$num,parent)
      #--- case of only one option to be changed
      set n [llength $listoptions]
      if {$n==2} {
         set res [lindex [lindex 0] 1]
         if {$res==""} {
            set listoptions [list $listoptions]
         }
      }
      #--- loop over options
      foreach listoption $listoptions {
         set name2 [string tolower [lindex $listoption 0]]
         set value [lindex $listoption 1]
         if {[info exists plotxy($name1,$name2)]==1} {
            if {$name2=="position"} {
               set pos $value
               set pos [lindex $pos 2]x[lindex $pos 3]+[lindex $pos 0]+[lindex $pos 1]
               wm geometry $baseplotxy $pos
            } elseif {$name2=="bgcolor"} {
               $baseplotxy.xy configure -bg $value
            } elseif {$name2=="fgcolor"} {
               $baseplotxy.xy configure -fg $value
               $baseplotxy.xy axis configure x  -hide no -color $value -titlecolor $value
               $baseplotxy.xy axis configure x2 -hide no -color $value -titlecolor $value
               $baseplotxy.xy axis configure y -hide no -color $value -titlecolor $value
               $baseplotxy.xy axis configure y2 -hide no -color $value -titlecolor $value
            } elseif {$name2=="plotbackground"} {
               $baseplotxy.xy configure -plotbackground $value
            } elseif {$name2=="axis"} {
               if {$value!=""} {
                  $baseplotxy.xy axis configure x -min [lindex $value 0] -max [lindex $value 1]
                  $baseplotxy.xy axis configure y -min [lindex $value 2] -max [lindex $value 3]
                  $baseplotxy.xy axis configure x2 -min [lindex $value 0] -max [lindex $value 1]
                  $baseplotxy.xy axis configure y2 -min [lindex $value 2] -max [lindex $value 3]
               }
            } elseif {$name2=="ydir"} {
               if {$value=="reverse"} {
                  set yesno yes
               } else {
                  set yesno no
               }
               set texte "\$baseplotxy.xy axis configure y -descending $yesno"
               eval $texte
               set texte "\$baseplotxy.xy axis configure y2 -descending $yesno"
               eval $texte
            } elseif {$name2=="xdir"} {
               if {$value=="reverse"} {
                  set yesno yes
               } else {
                  set yesno no
               }
               set texte "\$baseplotxy.xy axis configure x -descending $yesno"
               eval $texte
               set texte "\$baseplotxy.xy axis configure x2 -descending $yesno"
               eval $texte
            } elseif {$name2=="hide"} {
               if {$value==1} {
                  wm withdraw $baseplotxy
               } else {
                  wm deiconify $baseplotxy
               }
            } elseif {$name2=="caption"} {
               wm title $baseplotxy "$value"
            } elseif {$name2=="xlabel"} {
               $baseplotxy.xy axis configure x -hide no -title "$value"
            } elseif {$name2=="ylabel"} {
               $baseplotxy.xy axis configure y -hide no -title "$value"
            } elseif {$name2=="title"} {
               $baseplotxy.xy configure -title "$value"
            }
            set plotxy($name1,$name2) $value
         }
      }
      update
   }

   # --- proc importante pour modifier les attributs d'un plot
   proc sethandler { handler {list_options ""} } {
      global audace
      global plotxy

      #--- extract the current index of the figure
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      set lastline $plotxy(fig$num,lastline)
      set n [llength $list_options]
      if {$n<=1} {
         set texte "$baseplotxy.xy element configure $handler"
         set ress ""
         set res [eval $texte]
         foreach re $res {
            if {$n==1} {
               if {[lindex $re 0]!=[lindex $list_options 0]} {
                  continue
               }
            }
            lappend ress "[lindex $re 0]"
            lappend ress "[lindex $re 3]"
         }
         return $ress
      } else {
         set texte "$baseplotxy.xy element configure $handler $list_options"
         eval $texte
      }
   }

   proc setzoom { ax } {
      global plotxy

      set num $plotxy(currentfigure)
      set plotxy(fig$num,axis) [::plotxy::axis]
      set baseplotxy $plotxy(fig$num,parent)
      zoomIn $baseplotxy.xy [lindex $ax 0] [lindex $ax 2] [lindex $ax 1] [lindex $ax 3]
   }

   proc getzoom {  } {
      global plotxy

      set num $plotxy(currentfigure)

      set plotxy(fig$num,axis) [::plotxy::axis]
      set baseplotxy $plotxy(fig$num,parent)

      set x1 [ $baseplotxy.xy axis cget x -min ]
      set x2 [ $baseplotxy.xy axis cget x -max ]
      set y1 [ $baseplotxy.xy axis cget y -min ]
      set y2 [ $baseplotxy.xy axis cget y -max ]

      if {$x1==""} {
         return [::plotxy::axis]
      } else {
         return [list $x1 $x2 $y1 $y2]
      }
   }

   proc text { x y text2plot } {
      # plotxy::plot {1 3} {0 5} r ; plotxy::text 1.0 1.0 toto
      global audace
      global plotxy

      #--- extract the current index of the figure
      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      set texte "$baseplotxy.xy marker create text -text \"$text2plot\" -coords [list $x $y]"
      lappend plotxy(fig$num,markers) [eval $texte]
   }

   #=== Matlab equivalents pour colorsymbol
   #       y     yellow        .     point
   #       m     magenta       o     circle
   #       c     cyan          x     x-mark
   #       r     red           +     plus
   #       g     green         -     solid
   #       b     blue          *     star
   #       w     white         :     dotted
   #       k     black
   #
   proc plot { { x { 0 1 2 } } { y { 0 1 4 } } { colorsymbol b+- } {sizesymbol 4} {options ""} {namehandler ""} } {
      global audace
      global plotxy

      #--- choice figure 1 for the first entrance un plot
      if {$plotxy(currentfigure)==0} {
         ::plotxy::figure 1
      }
      #--- extract the current index of the figure
      set num $plotxy(currentfigure)
      #--- retains the current figure parameters
      set plotxy(fig$num,axis) ""
      set params [::plotxy::getgcf $num]
      set mylinewidth $plotxy(fig$num,linewidth)
      set k [lsearch -exact $options -linewidth]
      if {$k>=0} {
         set mylinewidth [lindex $options [expr $k+1]]
      }
      set baseplotxy $plotxy(fig$num,parent)
      set lastline $plotxy(fig$num,lastline)
      #--- show the graph of hide=0
      if { [ winfo exists $baseplotxy ] } {
         if {$plotxy(fig$num,hide)==0} {
            wm deiconify $baseplotxy
         }
      }
      #--- decode the selected color
      set colorstring rgbk
      set colorlist {red green blue black}
      set len [string length $colorsymbol]
      set mycolor [lindex $colorlist 0]
      for {set k 0} {$k<$len} {incr k} {
         set kk [string first [string index $colorsymbol $k] $colorstring]
         if {$kk!=-1} {
            set mycolor [lindex $colorlist $kk]
         }
      }
      #--- decode the selected symbol
      set symbolstring +xo*
      set symbollist {splus scross circle diamond}
      set mysymbol [lindex $symbollist 0]
      for {set k 0} {$k<$len} {incr k} {
         set kk [string first [string index $colorsymbol $k] $symbolstring]
         if {$kk!=-1} {
            set mysymbol [lindex $symbollist $kk]
         }
      }
      #--- decode the selected line style
      set linestring -.:
      set linelist [list [list -linewidth $mylinewidth] [list -linewidth 0] \
               [list -dashes dot -linewidth $mylinewidth] ]
      set myline [lindex $linelist 0]
      for {set k 0} {$k<$len} {incr k} {
         set kk [string first [string index $colorsymbol $k] $linestring]
         if {$kk!=-1} {
            set myline [lindex $linelist $kk]
         }
      }
      #--- hold on to overplot
      set hold off
      if {$plotxy(fig$num,hold)=="on"} {
         set hold on
         incr lastline
      } else {
         for {set k 1} {$k<=$lastline} {incr k} {
            catch {$baseplotxy.xy element delete line$k }
            catch {::blt::vector delete vx_fig${num}_${lastline} }
            catch {::blt::vector delete vy_fig${num}_${lastline} }
         }
         ::plotxy::clf $num
         ::plotxy::figure $num
         ::plotxy::setgcf $num $params
         set lastline $plotxy(fig$num,lastline)
      }
      set plotxy(fig$num,lastline) $lastline
      #--- create the new vectors
      ::blt::vector create vx_fig${num}_${lastline}
      vx_fig${num}_${lastline} set $x
      ::blt::vector create vy_fig${num}_${lastline}
      vy_fig${num}_${lastline} set $y
      set isybar [lsearch $options -ybars]
      set isxbar [lsearch $options -xbars]

      if {$namehandler == "" } {
         set handler line_fig${num}_${lastline}
      } else {
         set handler $namehandler
      }
      set texte "$baseplotxy.xy element create $handler -xdata vx_fig${num}_${lastline} \
               -ydata vy_fig${num}_${lastline} -symbol $mysymbol -color $mycolor -pixel $sizesymbol"
      #--- bar option
      foreach mylin $myline {
         append texte " $mylin"
      }
      if {$isxbar>=0} {
         set bars [lindex $options [expr 1+$isxbar]]
         set nbars [llength $bars]
         set xhigh ""
         set xlow ""
         for {set k 0} {$k<$nbars} {incr k} {
            set x0 [lindex $x $k]
            set bar [lindex $bars $k]
            lappend xlow [expr $x0-$bar/2.]
            lappend xhigh [expr $x0+$bar/2.]
         }
         append texte " -errorbarwidth 1 -errorbarcolor $mycolor -xhigh \{$xhigh\} -xlow \{$xlow\}"
      }
      if {$isybar>=0} {
         set bars [lindex $options [expr 1+$isybar]]
         set nbars [llength $bars]
         set yhigh ""
         set ylow ""
         for {set k 0} {$k<$nbars} {incr k} {
            set y0 [lindex $y $k]
            set bar [lindex $bars $k]
            lappend ylow [expr $y0-$bar/2.]
            lappend yhigh [expr $y0+$bar/2.]
         }
         append texte " -errorbarwidth 1 -errorbarcolor $mycolor -yhigh \{$yhigh\} -ylow \{$ylow\}"
      }
      eval $texte
      #
      $baseplotxy.xy legend configure -hide yes
      $baseplotxy.xy axis configure -title $plotxy(fig$num,title)
      $baseplotxy.xy axis configure x -hide no -title $plotxy(fig$num,xlabel)
      $baseplotxy.xy axis configure y -hide no -title $plotxy(fig$num,ylabel)
      if {$plotxy(audace)!=1} {
         $baseplotxy.xy axis configure y2 -hide no -color $plotxy(fig$num,fgcolor)
      }
      set ly [$baseplotxy.xy axis limits y]
      $baseplotxy.xy axis configure y2 -min [lindex $ly 0] -max [lindex $ly 1]
      if {$plotxy(audace)!=1} {
         $baseplotxy.xy axis configure x2 -hide no -color $plotxy(fig$num,fgcolor)
      }
      set lx [$baseplotxy.xy axis limits x]
      $baseplotxy.xy axis configure x2 -min [lindex $lx 0] -max [lindex $lx 1]
      if {$plotxy(audace)!=1} {
         $baseplotxy.xy configure -bg $plotxy(fig$num,bgcolor)
      }
      pack $baseplotxy.xy -expand 1 -fill both

      set plotxy(fig$num,axis) [list [lindex $lx 0] [lindex $lx 1] [lindex $ly 0] [lindex $ly 1]]

      #--   gestion des crosshairs
      $baseplotxy.xy crosshairs on
      $baseplotxy.xy crosshairs configure -color red -dashes 2
      bind $baseplotxy.xy <Motion> {
         ::plotxy::viewCrosshairs %W %x %y
      }
      #--   affichage des grilles
      $baseplotxy.xy grid configure -dashes 2 -color black -hide no -minor yes

      # plotxy::plot {0 3} {0 5} r
      # .audace.plotxy1.xy marker create text -text toto -name tutu
      # .audace.plotxy1.xy marker type tutu
      # .audace.plotxy1.xy marker configure tutu -text "tytytyty"
      #$baseplotxy.xy marker create text -text toto -name tutu
      #console::affiche_resultat "$baseplotxy.xy\n"

      #--   gestion du zoom
      createBindingsZoom $baseplotxy
      ::plotxy::unset_selected_region
      return $handler
   }

   proc fileread { filename {linestoskip 0} } {
      global plotxy

      set tty [open $filename r]
      set res [read $tty]
      close $tty
      set res [split $res \n]
      set res [lrange $res $linestoskip end]
      set nrow [llength $res]
      set ncol [llength [lindex $res 0]]
      set rest ""
      for {set kc 0} {$kc<$ncol} {incr kc} {
         set col ""
         for {set kr 0} {$kr<$nrow} {incr kr} {
            lappend col "[lindex [lindex $res $kr] $kc]"
         }
         lappend rest $col
      }
      return $rest
   }

   proc writegif { filename } {
      global audace
      global plotxy

      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      #--- Determination de la dimension
      set geometry [ wm geometry $baseplotxy ]
      set deb1 0
      set fin1 [ expr [ string first x $geometry ]-1 ]
      set deb2 [expr $fin1+2]
      set fin2 [ expr [ string first + $geometry ]-1 ]
      set dimx "[ string range $geometry $deb1 $fin1 ]"
      set dimy "[ string range $geometry $deb2 $fin2 ]"
      set plotxyimage [image create photo -height $dimy -width $dimx]
      $baseplotxy.xy snap $plotxyimage
      $plotxyimage write $filename -format GIF
      image delete $plotxyimage
   }

   proc updategcf { name value } {
      global plotxy

      set num $plotxy(currentfigure)
      if {$num==0} { return }
      if {$value==""} {
         set res [::plotxy::getgcf $num]
         foreach re $res {
            if {[lindex $re 0]==$name} {
               set value [lindex $re 1]
               break
            }
         }
      } else {
         ::plotxy::setgcf $num [list [list $name $value] ]
      }
      return $value
   }

   proc xlabel { {value "" } } {
      set name xlabel
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc ylabel { {value "" } } {
      set name ylabel
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc title { {value "" } } {
      set name title
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc hide { {value "" } } {
      set name hide
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc axis { {value "" } } {
      set name axis
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc bgcolor { {value "" } } {
      set name bgcolor
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc fgcolor { {value "" } } {
      set name fgcolor
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc plotbackground { {value "" } } {
      set name plotbackground
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc ydir { {value "" } } {
      set name ydir
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc xdir { {value "" } } {
      set name xdir
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc caption { {value "" } } {
      set name caption
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc hold { {value "" } } {
      set name hold
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc position { {value "" } } {
      set name position
      set res [::plotxy::updategcf $name $value]
      return $res
   }

   proc legend { {hide yes} {position bottom} } {
      global plotxy

      set num $plotxy(currentfigure)
      set baseplotxy $plotxy(fig$num,parent)
      $baseplotxy.xy legend configure  -hide $hide -position $position \
         -font "-Helvetica-Bold-R-Normal-*-12-120-"
   }

   #########################################################################
   ## @brief affiche les crosshairs
   #  @param graph chemin du graphe
   #  @param x coordonnée x du centre de la croix
   #  @param y coordonnée y du centre de la croix
   #
   proc viewCrosshairs { graph x y } {
      $graph crosshairs configure -position @$x,$y
   }

   #########################################################################
   ## @brief bindings du zoom
   #  @param graph chemin du graphe
   #
   proc createBindingsZoom { graph } {

      bind $graph <ButtonPress-1> {
         ::plotxy::regionStart %W %x %y
      }
      bind $graph <B1-Motion> {
         ::plotxy::regionMotion %W %x %y
      }
      bind $graph <ButtonRelease-1> {
         ::plotxy::regionEnd %W %x %y
      }
      bind $graph <Double-ButtonRelease-1> {
         ::plotxy::zoomOut %W
      }
      bind $graph <ButtonPress-2> {
         ::plotxy::regionStart %W %x %y
      }
      bind $graph <B2-Motion> {
         ::plotxy::regionMotion %W %x %y
      }
      bind $graph <ButtonRelease-2> {
         ::plotxy::regionEndSelect %W %x %y
      }

   }

   #########################################################################
   ## @brief capture les coordonnées initiales de la zone à zoomer
   #  @param nom de la fenêtre
   #  @param x coordonnée x initiale
   #  @param y coordonnée y initiale
   #  @private
   #
   proc regionStart { graph x y } {
      global plotxy

      #--   transforme les coordonnees ecran en coordonnees graphique
      #--   memorise les coordonnees initiales
      set plotxy(zoomstart,x) [ $graph axis invtransform x $x ]
      set plotxy(zoomstart,y) [ $graph axis invtransform y $y ]

      #--   cree un rectangle de selection sans coordonnees
      $graph marker create line -coords {} -name myLine -dashes dash \
         -linewidth 2 -outline blue -xor yes
   }

   #########################################################################
   ## @brief trace le rectangle de sélection de la zone à zoomer
   #  @param graph nom de la fenêtre
   #  @param x coordonnée x finale courante
   #  @param y coordonnée y finale courante
   #  @private
   #
   proc regionMotion { graph x y } {
      global plotxy

      set x0 $plotxy(zoomstart,x)
      set y0 $plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   trace le rectangle de selection
      $graph marker configure myLine -coords "$x0 $y0 $x0 $y1 $x1 $y1 $x1 $y0 $x0 $y0"
   }

   #########################################################################
   ## @brief zoome dans le graphe
   #  @param graph nom de la fenêtre
   #  @param x coordonnée x finale
   #  @param y coordonnée y finale
   #  @private
   #
   proc regionEnd { graph x y } {
      global plotxy

      set x0 $plotxy(zoomstart,x)
      set y0 $plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   efface le rectangle de selection
      $graph marker delete myLine

      #--   intercepte un clic simple dans la fenetre
      if { $x0 == $x1 || $y0 == $y1 } {
         return
      }

      #--   modifie les bornes de la visualisation
      zoomIn $graph $x0 $y0 $x1 $y1
   }

   #########################################################################
   ## @brief sélectionne dans le graphe
   #  @param graph nom de la fenêtre
   #  @param x cordonnée x finale
   #  @param y cordonnée y finale
   #  @private
   #
   proc ::plotxy::regionEndSelect { graph x y } {
      global plotxy

      set x0 $plotxy(zoomstart,x)
      set y0 $plotxy(zoomstart,y)

      #--   transforme les coordonnees ecran en coordonnees graphique
      set x1 [ $graph axis invtransform x $x ]
      set y1 [ $graph axis invtransform y $y ]

      #--   efface le rectangle de selection
      $graph marker delete myLine

      #--   intercepte un clic simple dans la fenetre
      if { $x0 == $x1 || $y0 == $y1 } {
         return
      }

      #--   modifie les bornes de la visualisation
      set ::plotxy::selected_region [list $x0 $y0 $x1 $y1]
   }

   #########################################################################
   ## @brief récupère la sélection
   #  @private
   #
   proc ::plotxy::get_selected_region {  } {

      set err [ catch {set x $::plotxy::selected_region} msg]
      if {$err} {
         return -code 1 $msg
      }
      return $x
   }

   #########################################################################
   ## @brief libère la variable  unset_selected_region
   #  @private
   #
   proc ::plotxy::unset_selected_region {  } {

      set err [catch {unset ::plotxy::selected_region} ]
      return $err

   }

   #########################################################################
   ## @brief zoome dans le graphe
   #  @param graph chemin du graphe
   #  @param x0 coordonnée x du début rectangle de sélection
   #  @param y0 coordonnée y du début rectangle de sélection
   #  @param x1 coordonnées x de la fin du rectangle de selection
   #  @param y1 coordonnées y de la fin du rectangle de selection
   #
   proc zoomIn { graph x0 y0 x1 y1 } {
      #--   pushZoom
      pushZoom $graph

      #--   configure les axes du graphique
      if { $x0 > $x1 } {
         $graph axis configure x -min $x1 -max $x0
      } else {
         $graph axis configure x -min $x0 -max $x1
      }

      if { $y0 > $y1 } {
         $graph axis configure y -min $y1 -max $y0
      } else {
         $graph axis configure y -min $y0 -max $y1
      }

   }

   #########################################################################
   ## @brief mémorise la commande de retour du zoom
   #  @param graph chemin du graphe
   #  @private
   #
   proc pushZoom { graph } {
      global plotxy

      #--   identifie les coordonnees minimales et maximales
      set x1 [ $graph axis cget x -min ]
      set x2 [ $graph axis cget x -max ]
      set y1 [ $graph axis cget y -min ]
      set y2 [ $graph axis cget y -max ]

      #--   remplace la valeur indeterminee par une liste vide
      foreach val { x1 y1 x2 y2 } {
         if { [ llength [ set $val ] ] == "0" } {
            set $val [ list "" ]
         }
      }

      #--   prepare la commande qui permettra le retour
      set cmd "$graph axis configure x -min $x1 -max $x2 ;
         $graph axis configure y -min $y1 -max $y2"

      #--   memorise la commande
      lappend plotxy(zoomstack,$graph) $cmd
   }

   #########################################################################
   ## @brief commande arrière du zoom
   #  @param graph chemin du graphe
   #  @private
   #
   proc zoomOut { graph } {

      global plotxy

      #--   si le stack du zoomIn n'est pas vide
      if [ info exists plotxy(zoomstack,$graph) ] {
         eval [ popZoom $graph ]
      }

   }

   #########################################################################
   ## @brief exécute la commande de retour du zoom
   #  @param graph chemin du graphe
   #  @private
   #
   proc popZoom { graph } {
      global plotxy

      #--   recupere le precedent niveau de zoom
      set cmd [ lindex $plotxy(zoomstack,$graph) end ]

      #--   suprime la commande de la liste
      set plotxy(zoomstack,$graph) [ lreplace $plotxy(zoomstack,$graph) end end ]

      return $cmd
   }

#--fin du namespace
}

set err [catch {package require BLT} msg]
if {$err==1} {
   if {$plotxy(audace)==1} {
      ::console::affiche_erreur "Warning: $msg\n"
   }
} else {
   ::plotxy::figure 0
}

