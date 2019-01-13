# Script light_curve
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 10

set bufNo $audace(bufNo)

# === Body of script
if {($robobs(planif,mode)=="star_light_curve")&&($robobs(image,ffilenames)!="")} {

   # --- renomme les images en tmp1.fit à tmpn.fit
   ::robobs::log "Light curve : robobs(image,ffilenames)=$robobs(image,ffilenames)"
   set index 0
   foreach fname $robobs(image,ffilenames) {
      buf$bufNo load $fname
      set catastar [lindex [buf$bufNo getkwd CATASTAR] 1]
      if {$catastar>10} {
         incr index
         set fname "$robobs(conf,folders,rep_images,value)/tmp${index}$robobs(conf,fichier_image,extension,value)"      
         buf$bufNo save $fname
      }
   }
   set ni $index
   if {$ni>0} {
      set objename [lindex [buf$bufNo getkwd OBJENAME] 1]
      set photfiles [file join $robobs(conf,folders,rep_images,value) ${objename}]
      set tmpfiles [file join $robobs(conf,folders,rep_images,value) tmp]
      ::robobs::log "photfiles=$photfiles"
      ::robobs::log "tmpfiles=$tmpfiles"
      catch {
         file copy -force -- ${photfiles}_mes.bin ${tmpfiles}_mes.bin 
         file copy -force -- ${photfiles}_ref.bin ${tmpfiles}_ref.bin 
         file copy -force -- ${photfiles}_zmg.bin ${tmpfiles}_zmg.bin 
      }
      ::robobs::log "photrel_wcs2cat tmp $ni append"
      photrel_wcs2cat tmp $ni append
      set ra [lindex [buf$bufNo getkwd RA] 1]
      set dec [lindex [buf$bufNo getkwd DEC] 1]
      set filter [string trim [lindex [buf$bufNo getkwd FILTER] 1]]
      ::robobs::log "Compute the $filter light curve of $objename at coords [format %.5f $ra] [format %+.5f $dec]"
      ::robobs::log "photrel_cat2mes tmp $objename $ra $dec $filter"
      photrel_cat2mes tmp $objename $ra $dec $filter
      set err [catch {
         file copy -force -- ${tmpfiles}_mes.bin ${photfiles}_mes.bin 
         file copy -force -- ${tmpfiles}_ref.bin ${photfiles}_ref.bin 
         file copy -force -- ${tmpfiles}_zmg.bin ${photfiles}_zmg.bin 
         file copy -force -- ${tmpfiles}_mes.txt ${photfiles}_mes.txt
         file copy -force -- ${tmpfiles}_ref.txt ${photfiles}_ref.txt 
         file copy -force -- ${tmpfiles}_zmg.txt ${photfiles}_zmg.txt 
      } msg]
      if {$err==1} {
         ::robobs::log "$msg"
      }
      set err [catch {
         file delete -force -- ${tmpfiles}_mes.bin
         file delete -force -- ${tmpfiles}_ref.bin
         file delete -force -- ${tmpfiles}_zmg.bin
      } msg]
      # --- display results
      set f [open "$robobs(conf,folders,rep_images,value)/$objename.txt" r]
      set lignes [split [read $f] \n]
      close $f
      set jds ""
      set mags ""
      set errmags ""
      foreach ligne $lignes {
         set car [string index $ligne 0]
         set err [catch {expr $car+1} msg]
         if {($err==1)||([llength $ligne]<3)} {
            continue
         }
         lappend jds [lindex $ligne 0]
         lappend mags [lindex $ligne 1]
         lappend errmags  [lindex $ligne 2]
      }
      # --- Graphics
      ::robobs::log "Light curve contains [llength $jds] dates"
      if {[llength $jds]>1} {
         ::plotxy::figure 1
         ::plotxy::clf
         ::plotxy::caption "$objename"
         ::plotxy::plot $jds $mags or
         ::plotxy::plotbackground #FFFFFF
         ::plotxy::ydir reverse
         ::plotxy::bgcolor #FFFFFF
         ::plotxy::ylabel "relative mag"
         ::plotxy::xlabel "JD UT"
         ::plotxy::title "$objename Light-curve"
         ::robobs::log "[llength $jds] dates. Light curve $robobs(conf,folders,rep_images,value)/${objename}.gif"
         ::plotxy::writegif "$robobs(conf,folders,rep_images,value)/${objename}.gif"
      }
      
      # --- Copy the light curve for the web site
      if {$robobsconf(webserver)==1} {
         file mkdir $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)
         catch {
            file copy -force -- $robobs(conf,folders,rep_images,value)/${objename}.txt $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)/${objename}.txt
            file copy -force -- $robobs(conf,folders,rep_images,value)/${objename}.gif $robobsconf(webserver,htdocs)/rrlyr/$robobs(private,nightdate)/${objename}.gif
         }
      }      
   }
}

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 10
return ""
