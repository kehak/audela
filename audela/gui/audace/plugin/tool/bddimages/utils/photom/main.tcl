#source [ file join $audace(rep_plugin) tool bddimages utils photom main.tcl]
global bddconf


set visui $::audace(visuNo)
set visuc [::confVisu::create]
gren_info "visus = $visui $visuc\n"

loadima img $visui
loadima img $visuc

set bufi [::confVisu::getBufNo $visui]
set bufc [::confVisu::getBufNo $visuc]
gren_info "buffers = $bufi $bufc\n"


set xcent 459.99
set ycent 245.92
set radius 100
set offset -2
set xref [expr int($xcent - $radius) + $offset ]
set yref [expr int($ycent - $radius) + $offset ]
set rect [list [expr int($xcent - $radius)-1] [expr int($ycent - $radius)-1] \
           [expr int($xcent + $radius)+1] [expr int($ycent + $radius)+1] ]
gren_info "rect = $rect\n"
set sizex [expr [lindex $rect 2]-[lindex $rect 0] +1]
set sizey [expr [lindex $rect 3]-[lindex $rect 1] +1]

gren_info "size = $sizex $sizey\n"

set r [buf$bufc fitgauss $rect]
gren_info "r = $r\n"
set xm [format "%.3f" [lindex $r 1] ]
set ym [format "%.3f" [lindex $r 5] ]
gren_info "xm ym = $xm $ym\n"



buf$bufc window $rect
::audace::autovisu $visuc

set rect [list 0 0 $sizex $sizey ]
set r [buf$bufc fitgauss $rect]
gren_info "r = $r\n"
set xmc [expr [lindex $r 1] + $xref]
set ymc [expr [lindex $r 5] + $yref]

gren_info "xmc ymc = $xmc $ymc\n"

set xdiff [format "%.3f" [expr $xmc - $xm ] ]
set ydiff [format "%.3f" [expr $ymc - $ym ] ]

gren_info "xdiff ydiff = $xdiff $ydiff\n"

buf$bufc synthegauss [list 50 50 10000 5. 5.] 50000


# AD Déc. : 194.126959 2.201550
# AD Déc. : 12h56m30s47 +02d12m05s57

# AD Déc. : 194.111256 2.213437
# AD Déc. : 12h56m26s70 +02d12m48s37


return





