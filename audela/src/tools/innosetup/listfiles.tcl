#!/usr/local/bin/tclsh8.4
#
# Fichier : listfiles.tcl
# Description : genere un fichier texte pour Inno setup
# Auteur : Alain KLOTZ
# $Id: listfiles.tcl,v 1.33 2011-02-18 03:28:27 fredvachier Exp $
#
# source $audace(rep_install)/src/tools/innosetup/listfiles.tcl


#--- je recupere le numéro de version d'audela
set version $::audela(version)
set date [ clock format [ clock seconds ] -format "%d/%m/%Y" -timezone :UTC ]

set makes {audela}
#set makes {audela bin}
#set makes {audela bin src ros}
# potential problem with src

set rosfiles ""
if {[lsearch -exact $makes ros]>=0} {
	set base "[file normalize [file dirname [info script]]/../../../../]/"
	set rosfiles [glob -nocomplain ${base}ros*]
}
set newlist ""
foreach make $makes {
	if {[string match ros* $make]==0} {
		lappend newlist $make
	}
}
foreach rosfile $rosfiles {
	set rosfile [file tail $rosfile]
	lappend newlist $rosfile
}

set makes $newlist

proc analdir { base } {
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
            if {($make=="ros")&&(($shortname=="ros_install.log")||($shortname=="ros_install_lastconfig.tcl")||($shortname=="ros_root.tcl"))} {
               continue
            }
            if {(($make=="audela")||($make=="bin"))&&($shortname=="audace.txt")&&($level==3)} {
               continue
            }
            if {(($make=="audela")||($make=="bin"))&&($level==3)} {
                  if { $shortname=="audace.txt"
                    || $shortname=="audela.pl"
                    || $shortname=="audela.sh"
                    || $shortname=="allowio.txt"
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
                  if { $shortname=="fonction_transfert.pal"
                    || $shortname=="config.ini"
                    || $shortname=="config.bak"
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
               if {([string range $make 0 2]=="ros")} {
                  append result "\"$thisfile\" \"${make}/${name3}\"\n"
               } else {
                  append result "\"$thisfile\" \"${name3}\"\n"
               }
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
            if {(($make=="audela")||($make=="bin")) && !( ([lindex $repertoires 1]=="gui") || ([lindex $repertoires 1]=="bin") || ([lindex $repertoires 1]=="doc") || ([lindex $repertoires 1]=="lib") || ([lindex $repertoires 1]=="images") ) } {
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

#------------------------------------------------------------------------------
# met à jour la date et la revision dans le fichier audela/bin/version.tcl 
#
#
#------------------------------------------------------------------------------
proc updateVersionTclFile { } {

   set inutFileName [file join $::audela_start_dir version.tcl ]
   set hfile [open $inutFileName r]
   set data [read $hfile]
   close $hfile
   
   #--- je recupere la revision svn 
   #--- svnrevision help:
   #--- If the working copy is all at the same revision (e.g., immediately after an update), 
   #--- then that revision is printed out:
   #---  4168
   #--- For a mixed-revision working copy, the range of revisions present is printed:
   #---  4123:4168
   #--- If the working copy contains modifications, a trailing 'M' is added:
   #---  4168M
   #--- If the working copy is switched, a trailing 'S' is added:
   #---  4168S
  if { [ catch { exec svnversion --no-newline "[file join $::audela_start_dir  .. ]" } revision ] } {
      #--- si svnversion retourne une erreur , j'ignore l'erreur
      set revision ""
   } 
   
   set date [ clock format [ clock seconds ] -format "%d/%m/%Y" -timezone :UTC ]
   
   #--- je remplace les mots cles dans $data
   set data [string map [list "@REL_DATE@" $date "@REVISION@" $revision ] $data ]
   
   #--  j'enregistre $data dans version.tcl
   set outputFileName [file join $::audela_start_dir version.tcl ]
   set fid [open $outputFileName w]
   puts $fid $data
   close $fid   
}

#------------------------------------------------------------------------------
# main program
#
#------------------------------------------------------------------------------
global tab result resultfile f base0 make level

#---  je mets à jour la date et la revision dans le fichier audela/bin/version.tcl
updateVersionTclFile

foreach make $makes {

   ::console::affiche_resultat "make $make\n"
   set base "[file normalize [file dirname [info script]]/../../../]/"
   set base0 "$base"
	if {($make=="src")} {
      set base2 "[file normalize [file dirname [info script]]/../../../]/${make}/"
      set base0 "$base2"
   }
	if {([string range $make 0 2]=="ros")} {
      set base2 "[file normalize [file dirname [info script]]/../../../../]/${make}/"
      set base0 "$base2"
   }
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
		append result "AppName=AudeLA-${version}\n"
		append result "AppVerName=AudeLA-${version}\n"
		append result "AppPublisher=audela.org\n"
		append result "AppPublisherURL=http://www.audela.org\n"
		append result "AppSupportURL=http://www.audela.org\n"
		append result "AppUpdatesURL=http://www.audela.org\n"
		append result "DefaultDirName={pf}\\audela-${version}\n"
		append result "DefaultGroupName=Audela\n"
		append result "LicenseFile=licence.txt\n"
		append result "InfoBeforeFile=before.txt\n"
		append result "InfoAfterFile=after.txt\n"
		append result "UsePreviousAppDir=no\n"
		append result "PrivilegesRequired=none\n"
        append result "OutputBaseFilename=AudeLA-${version}\n"
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
      if {($make=="src")||([string range $make 0 2]=="ros")} {
         analdir $base2
      } else {
         analdir $base
      }
		file delete -force -- ${base}/src/tools/innosetup/audela_${make}-${version}.zip
		set f [open $resultfile r]
		set lignes [split [read $f] \n]
		close $f
		foreach ligne $lignes {
			if {[string length $ligne]<1} {
				continue
			}
			file mkdir [file dirname "${base}src/tools/innosetup/Output/[lindex $ligne 1]"]
			catch {file copy -force -- "[lindex $ligne 0]" "${base}src/tools/innosetup/Output/[lindex $ligne 1]"}
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


