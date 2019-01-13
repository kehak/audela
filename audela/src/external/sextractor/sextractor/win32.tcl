#!/usr/local/bin/tclsh8.0
#
# Fichier : win32.tcl
# Description : Correction des fichiers sextractor pour compilation Win32 VC++
# Auteur : Alain KLOTZ
# Date de MAJ : 15 Juin 2002
#

   proc analdir { base } {
      global tab result resultfile f
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
               set shortname [file tail $thisfile]
               set sizename [expr 1+int([file size $thisfile]/1000)]
               set datename [file mtime $thisfile]
               if {$datename==-1} {
                  set datename 0000-00-00T00:00:00
               } else {
                  set datename [clock format [file mtime $thisfile] -format %Y-%m-%dT%H:%M:%S ]
               }
               for {set k 0} {$k<$tab} {incr k} {
                  append result " "
               }
               append result "$shortname"
               set a [string length $shortname]
               set a [expr 20-$a]
               if {$a<0} {
                  set a 0
               }
               for {set k 0} {$k<$a} {incr k} {
                  append result " "
               }
               append result "$datename ($sizename Ko)\n"
               set extension [file extension $thisfile ]
               if {($extension==".c")||($extension==".h")||($extension==".cpp")||($extension==".tcl")||($extension==".ini")||($extension==".txt")} {
                  set fichier "$thisfile"
                  set f [open $fichier "r"]
                  set toutletexte [read $f]
                  close $f
                  regsub -all wcsset "$toutletexte" wcssett toutletexte2
                  regsub -all wcsrev "$toutletexte2" wcsrevv toutletexte
                  set f [open $fichier "w"]
                  puts -nonewline $f "$toutletexte"
                  close $f
                  #puts stdout "convert $fichier"
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
               incr tab 1
               set shortname [file tail $thisfile]
               set datename [file mtime $thisfile]
               if {$datename==-1} {
                  set datename 0000-00-00T00:00:00
               } else {
                  set datename [clock format [file mtime $thisfile] -format %Y-%m-%dT%H:%M:%S ]
               }
               append result "\n"
               for {set k 0} {$k<$tab} {incr k} {
                  append result " "
               }
               append result "Directory of $thisfile\n"
               analdir $thisfile
               incr tab -1
            }
         }
         set f [open $resultfile a]
         puts -nonewline $f "$result"
         close $f
         set result ""
      }
   }

      set base ./src
      global tab result resultfile f
      set tab 0
      if {$base=="."} {
         set base [pwd]
      }
      set resultfile "files.txt"
      set result "Directory of $base\n"
      set f [open $resultfile w]
      puts -nonewline $f "$result"
      close $f
      set result ""
      analdir $base

