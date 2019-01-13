#
# Fichier : searchport.tcl
# Description : Recherche des ports COMs disponibles
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: searchport.tcl 11220 2015-01-02 10:44:49Z michelpujol $
#

#------------------------------------------------------------
#  searchPorts
#     recherche les ports com disponible sur le PC
#
#  return rien
#------------------------------------------------------------
proc ::searchPorts { mainThreadNo { port_exclus "" } } {
   variable private
   global conf

   #--- Recherche le ou les ports COM exclus
   set kd ""
   set nbr_port_exclus [ llength $port_exclus ]
   if { $nbr_port_exclus == "1" } {
      set kd [string index $port_exclus [expr [string length $port_exclus]-1]]
   } else {
      for { set i 0 } { $i < $nbr_port_exclus } { incr i } {
         set a [ lindex $port_exclus $i ]
         set kdd [string index $a [expr [string length $a]-1]]
         lappend kd $kdd
         set kd [ lsort $kd ]
      }
   }

   #--- Suivant l'OS
   if { $::tcl_platform(os) == "Linux" } {
      set port_com     "/dev/ttyS"
      set port_com_usb "/dev/ttyUSB"
      set port_com_ama "/dev/ttyAMA"
      set kk  "0"
      set kkt "20"
   } else {
      set port_com "//./COM"
      set kk  "1"
      set kkt "20"
   }

   #--- Recherche des ports com
   set comlist            ""
   set comlist_usb        ""
   set comlist_ama        ""
   set private(portsList) ""

   set i "0"
   for { set k $kk } { $k < $kkt } { incr k } {
      if { $k != "[ lindex $kd $i]" } {
         set errnum [ catch { open $port_com$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist $k
            close $msg
         }
      } else {
         incr i
      }
   }
   set long_com [ llength $comlist ]

   for { set k 0 } { $k < $long_com } { incr k } {
      lappend private(portsList) "$port_com[ lindex $comlist $k ]"
   }

   if { $::tcl_platform(os) == "Linux" } {

      for { set k $kk } { $k < 20 } { incr k } {
         set errnum [ catch { open $port_com_usb$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist_usb $k
            close $msg
         }
      }
      set long_com_usb [ llength $comlist_usb ]
      for { set k 0 } { $k < $long_com_usb } { incr k } {
         lappend private(portsList) "$port_com_usb[ lindex $comlist_usb $k ]"
      }

      for { set k $kk } { $k < 5 } { incr k } {
         set errnum [ catch { open $port_com_ama$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist_ama $k
            close $msg
         }
      }
      set long_com_ama [ llength $comlist_ama ]
      for { set k 0 } { $k < $long_com_ama } { incr k } {
         lappend private(portsList) "$port_com_ama[ lindex $comlist_ama $k ]"
      }

   }
   thread::send $mainThreadNo "set ::serialport::private(portList) \"$private(portsList)\" "
}

