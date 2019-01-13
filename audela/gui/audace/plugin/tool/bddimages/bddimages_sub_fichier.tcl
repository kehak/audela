## @file bddimages_sub_fichier.tcl
#  @brief     Fonctions de manipulation des fichiers et r&eacute;pertoires du syst&egrave;me hote (no namespace)
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_sub_fichier.tcl]
#  @endcode

# $Id: bddimages_sub_fichier.tcl 13886 2016-05-22 21:55:06Z jberthier $


proc bddimages_sauve_fich {texte} {

   global bddconf
   global entetelog

   if {[info exists entetelog]==1} {
      set texte "$entetelog:$texte"
   } else {
      set texte "entetelog:$texte"
   }
   createdir_ifnot_exist $bddconf(dirlog)
   set fichlog "$bddconf(dirlog)/lastlog.txt"
   set sizelog 0
   catch { set sizelog [file size $fichlog]}

   if {$sizelog > 1000000} {
      set listlog [glob -nocomplain $bddconf(dirlog)/log*.txt]
      set listlog [lsort -ascii $listlog]
      set last [file tail [lindex $listlog end]]
      set last [string range $last 3 7]

      set err [catch {set new [expr $last + 1]} msg]
      if {$err} {set new ""}
      set new "0000000$new"
      set ext [string range $new [expr [string length $new]-5] end ]
      catch {file rename $fichlog [file join $bddconf(dirlog) "log$ext.txt"]}
   }

   catch {
      set bddfileout [open $fichlog a]
      puts $bddfileout $texte
      close $bddfileout
   }

}

proc get_files { dir limit } {

   global maliste
   globrdk $dir $limit
   set res ""
   #::console::affiche_resultat "NB SQL : [llength $maliste]\n"
   foreach elem $maliste {
      set isd [file isdirectory $elem]
      set isf [file isfile $elem]
      if {$isd == 1} {
         ::console::affiche_erreur "repertoire : $elem \n"
         continue
      }
      if {$isf == 1} {
         lappend res $elem
      }
   }

   set maliste $res
 }

# ----------------------------------------
# globrdk
# retourne la liste recursive des fichiers d'un repertoire avec une limite de 1000 fichiers fits
# ---------------------------------------
proc globrdk { {dir .} limit } {

   global maliste
   set liste [glob -nocomplain -directory $dir *]

   foreach i $liste {
      if { [llength $maliste]==$limit && $limit!=0 } {
        break
      }
      if {[file type $i]=="directory"} {
         if {[llength $maliste]<$limit || $limit==0} {
            globrdk $i $limit
         } else {
            break
         }
      } else {
         set result [bddimages_formatfichier $i]
         set form2  [lindex $result 0]
         if { ([llength $maliste]<$limit || $limit==0) &&
              ( $form2=="fit" || $form2=="fit.gz" || $form2=="fits" || $form2=="fits.gz" || $form2=="cata.txt" || $form2=="cata.txt.gz" || $form2=="cata.xml" || $form2=="cata.xml.gz" ) } {
            lappend maliste $i
         } else {

         }
      }
   }

}

proc globrdknr { {dir .} limit } {

   global maliste

   set liste [glob -nocomplain -directory $dir *]
   foreach i $liste {
      if { [llength $maliste]==$limit && $limit!=0 } {
         break
      }

      set result [bddimages_formatfichier $i]
      set form2  [lindex $result 0]
      if { ([llength $maliste]<$limit || $limit==0) && ( $form2=="fit" || $form2=="fit.gz" || $form2=="fits" || $form2=="fits.gz" || $form2=="cata.txt" || $form2=="cata.txt.gz" || $form2=="cata.xml" || $form2=="cata.xml.gz"  ) } {
         lappend maliste $i
      } else {
      }
   }

}

proc globrd {{dir .}} {

   set res {}
   set liste [glob -nocomplain -directory $dir *]
   foreach i $liste {
      if {[file type $i]=="directory"} {
         eval lappend res [globrd $i]
      } else {
         lappend res $i
      }
   }
   return $res

}


proc globr { {dir .} } {

   set res {}
   set errnum [catch {set cur [glob $dir]} msg]

   if {$errnum==1} {
      #gren_erreur "globr: $msg \n"
   } else {
      foreach i $cur {
         if {[file type $i]=="directory"} {

         } else {
            lappend res $i
         }
      }
      eval lappend res [globrd $dir]
   }

   return $res

}


# ----------------------------------------
# numberoffile
# ---------------------------------------
proc numberoffile { dir } {

   if {[file exists $dir]==0} {
      set nbfile "Warning: $dir doesn't exist>"
   }

   set err [catch {set list_file [globr $dir]} result]
   if {$err==0} {
      set nbfile [llength $list_file]
   } else {
      set nbfile "Failed <ERR:$err> <RESULT:$result>"
   }
   return $nbfile

 }


# ----------------------------------------
# bddimages_formatfichier
# retourne le format du fichier image
# ---------------------------------------
proc bddimages_formatfichier {fichierorig} {

   set fichier [string tolower $fichierorig]
   set form3 "unknown"
   set form2 "unknown"
   set form1 0

   set form [string last fits.gz $fichier]
   if {$form>1} {
      set form2 "fits.gz"
      set form3 "img"
   }

   if {$form2=="unknown"} {
      set form [string last fits $fichier]
      if {$form>1} {
         set form2 "fits"
         set form3 "img"
      }
   }

   if {$form2=="unknown"} {
      set form [string last fit.gz $fichier]
      if {$form>1} {
         set form2 "fit.gz"
         set form3 "img"
      }
   }

   if {$form2=="unknown"} {
      set form [string last fit $fichier]
      if {$form>1} {
         set form2 "fit"
         set form3 "img"
      }
   }

   if {$form2=="unknown"} {
      set form [string last cata.txt.gz $fichier]
      if {$form>1} {
         set form2 "cata.txt.gz"
         set form3 "cata"
      } else {
         set form [string last cata.xml.gz $fichier]
         if {$form>1} {
            set form2 "cata.xml.gz"
            set form3 "cata"
         }
      }
   }

   if {$form2=="unknown"} {
      set form [string last cata.txt $fichier]
      if {$form>1} {
         set form2 "cata.txt"
         set form3 "cata"
      } else {
         set form [string last cata.xml $fichier]
         if {$form>1} {
            set form2 "cata.xml"
            set form3 "cata"
         }
      }
   }

   set racinefich "unknown"
   if { $form2!="unknown" && $form>1 } {
      set racinefich [string range $fichierorig 0 [expr $form -2]]
   }

   return [list $form2 $racinefich $form3]

}

# ---------------------------------------
# createdir_ifnot_exist
# cree un nouveau repertoire s il n existe pas
# ---------------------------------------
proc createdir_ifnot_exist {dirfilename} {

   set direxist [file exists $dirfilename]
   if {$direxist==0} {
      set errnum [catch {file mkdir $dirfilename} msg]
      if {$errnum==0} {
         bddimages_sauve_fich "createdir_ifnot_exist: Creation du repertoire : $dirfilename <$errnum>"
      } else {
         puts "createdir_ifnot_exist: Creation du repertoire $dirfilename impossible <$errnum>"
         puts "MSG = $msg"
      }
   
   }

}

# ---------------------------------------
# unzipedfilename
# renvoi le nom du fichier sans l extension .gz
# ---------------------------------------
proc unzipedfilename { filename } {

   set ext [file extension $filename]
   set long [string length $filename]
   set last [expr [string first $ext $filename [expr $long-3] ]-1]
   set filename [string range $filename 0 $last]
   return $filename

}
