puts "--------------------------------"
puts "-   Base de donnees d'images   -"
puts "-   Traitements automatises    -"
puts "--------------------------------"

set err [catch {wm withdraw .} msg]
if {$err==1} {
   set withtk 0
   puts "TK: Non actif"
} else {
   set withtk 1
   puts "TK: Actif"
}

set audelaLibPath [file join [file join [file dirname [file dirname [info nameofexecutable]] ] lib]]
puts "audelaLibPath=$audelaLibPath"

if { [lsearch $::auto_path $audelaLibPath] == -1 } {
   lappend ::auto_path $audelaLibPath
}
puts "::auto_path=$::auto_path"

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

# Monter l environnement

   set err [catch {package require Thread} msg]
   if {$err} {
      puts "Multithread : No "
   } else {
      puts "Multithread : Yes (version = $msg)"
   }


# arriver a faire cette commande !
# buf1 load monimage



# Fin

if {$withtk==1} {
   exit
}
puts "Sortie du programme"

