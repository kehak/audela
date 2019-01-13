global ros

source [file join $::audela_start_dir ros_install.tcl]

#
# Robotic Observatory Control
# Mise à jour $Id: ros.tcl,v 1.12 2011-02-20 16:02:35 fredvachier Exp $
#
puts "--------------------------------"
puts "- Robotic Observatory Software -"
puts "-       primaries logs"
puts "--------------------------------"

#--- Add audela/lib directory to ::auto_path if it doesn't already exist
set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
puts "audelaLibPath=$audelaLibPath"

if { [lsearch $::auto_path $audelaLibPath] == -1 } {
   lappend ::auto_path $audelaLibPath
}
puts "::auto_path=$::auto_path"

set err [catch {wm withdraw .} msg]
if {$err==1} {
   set ros(withtk) 0
   puts "TK: Non actif"
} else {
   set ros(withtk) 1
   puts "TK: Actif"
}

set name [file tail [file rootname [info nameofexecutable]]]
puts "Prog=$name"
set k [string first _ "$name"]
if {$k>0} {
   set k [expr $k-1]
} else {
   set k end
}
set name [string range $name 0 $k]
puts "name=$name"


set ros(ros_install,audelabin) $::audela_start_dir
puts "audelabin=$ros(ros_install,audelabin)"
cd $ros(ros_install,audelabin)

if {$name=="audela"} {
   puts "log= Demarrage de l install automatique"
   puts "pwd= [pwd]"
   puts "Lancement= source [file join $::audela_start_dir ros_install.tcl]"

   # Verification de l existance d une fenetre tk
   set err [catch {wm withdraw .} msg]
   if {$err==1} {
      set ros(withtk) 0
   } else {
      set ros(withtk) 1
   }

   # lancement de l installation
   set errno [ catch { ::ros_install::run } msg ]

} else {
   puts "log= Initialisation du programme"
   set errno [catch { ::ros_install::get_root } msg]
   if {$errno==0} {
      puts "on se met dans le repertoire $ros(root,ros) !"
      cd [file join $ros(root,ros) src $name]
      puts "log= Demarrage du programme"
      set errno [catch {source $name.tcl} msg]
      if {$ros(withtk)==1&&$errno==0} {
         puts "log= Fin sauvage du programme"
         destroy .
         exit
      }
   }
}


puts "errno=$errno"
puts "msg=$msg"

if {$errno==1} {
   puts "log= Erreur grave"
   # se met dans bin
   cd $::audela_start_dir
   set f [open ros_check_error.txt a]
   puts $f "==============================\n[mc_date2iso8601 now] :"
   puts $f $msg
   close $f
   if {$ros(withtk)==1} {
      tk_messageBox -icon error -message $msg
   } else {
      puts "error : $msg"
   }
}
if {$ros(withtk)==1} {
   exit
}
puts "eject"

