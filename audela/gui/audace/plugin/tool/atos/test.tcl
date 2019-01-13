#------------------------------------------------------------------
# source [ file join $audace(rep_plugin) tool atos test.tcl
#------------------------------------------------------------------
#
# Fichier        : test.tcl
# Description    : Procedure de test pour le developpement en cours
# Auteur         : Frederic Vachier
# Mise à jour $Id: test.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#



namespace eval ::testprocedure {

   global audace
   global bddconf
   global conf
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""

   if { [ package require dom ] == "2.6" } {
      interp alias {} ::dom::parse {} ::dom::tcl::parse
      interp alias {} ::dom::selectNode {} ::dom::tcl::selectNode
      interp alias {} ::dom::node {} ::dom::tcl::node
   }


   proc run {  } {

      test2
   }






proc test1 { } {

   global conf audace

 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n° 1\n"
 ::console::affiche_resultat "---------------------------\n"
::atos_tools::avi_next_image

 set rect [ ::confVisu::getBox 1 ]
 ::console::affiche_resultat "rect $rect\n"

 if { [info exists $rect] } {
    return
 }
 #set rect { [lindex $rect 0] [lindex $rect 1] [lindex $rect 2] [lindex $rect 3] }

 ::console::affiche_resultat "visu \n"

 buf1 window $rect
 buf1 mirrory
# buf1 save ocr.png
set stat  [buf1 stat]
 ::console::affiche_resultat "stat = $stat \n"

buf1 savejpeg ocr.jpg 100 [lindex $stat 3] [lindex $stat 0]

set err [ catch {set result [exec jpegtopnm ocr.jpg | gocr -C 0-9 -f UTF8 ]} msg ]

 ::console::affiche_resultat "err = $err \n"
 ::console::affiche_resultat "msg = $msg \n"




}






proc test2 { } {

global audace


 ::console::affiche_resultat "---------------------------\n"
 ::console::affiche_resultat " Test n° 2\n"
 ::console::affiche_resultat "---------------------------\n"

# source [ file join $audace(rep_plugin) .. vo_tools.tcl ]
 miriade_ephemcc "ceres" "" 2453002.24128009239 5 "1d" "UTC" "@500" "INPOP" 1 1 "html" "--iso,--rv" 0 "Audela"

# http://vo.imcce.fr/webservices/miriade/ephemcc_query.php?
# -name=a:ceres&
# -type=&
# -ep=2453002.24128009239&
# -nbd=5&
# -step=1d&
# -tscale=UTC&
# -observer=@500&
# -theory=INPOP&
# -teph=1&
# -tcoor=1&
# -mime=html&
# -output=--iso,--rv&
# -extrap=0&
# -from=MiriadeDoc

}

}
# fin du namespace

