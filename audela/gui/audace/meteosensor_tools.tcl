#
## @file meteosensor_tools.tcl
#  @brief Read data from various meteo sensors
#  @author Alain KLOTZ
#  $Id: meteosensor_tools.tcl 14267 2017-10-19 23:26:34Z alainklotz $
#  @todo compléter la doxygénation des procs
#

#  source "$audace(rep_install)/gui/audace/meteosensor_tools.tcl"
#

# This tool is based on three basic actions: open, get data, close
#
# --- Reference guide
# meteosensor_open $type $port $name ?$parameters?
#    type : AAG WXT520 ARDUINO1 VANTAGEPRO BOLTWOOD BOLTWOOD_DIRECT LACROSSE SENTINEL_SKYMONITOR SENTINEL ARDUINO2 SIMULATION
#    port : com1, etc.
#    name : a word to identify the connection opened
#  return the name if opening is OK
# meteosensor_list
#  return lists of opened devices. For each list element:
#    index 0 : Name of the device
#    index 1 : Type of the device
#    index 2 : Port of the device
# meteosensor_get $name
#    name : identifier of the connection opened
#  return a list of measurements. For each list element:
#    index 0 : Name of the parameter measured
#    index 1 : Value of the parameter measured
#    index 2 : Units of the parameter measured
#    index 3 : Comment of the parameter measured
# meteosensor_getstandard $name
#    name : identifier of the connection opened
#  return a list of measurements as for meteosensor_get
#  but elements are the same whatever the meteo sensor.
#  Some elements can be undefined.
# meteosensor_close $name
#    name : identifier of the connection opened
#  return nothing is closing is OK
#
# --- Example 1
# meteosensor_open AAG com1 cs1
# # cs1
# meteosensor_get cs1
# # {SkyTemperature 20.83 Celsius {Sky temperature measured by an infrared sensor}} {SkyCover VeryCloudy text {A word that describes sky conditions}} {CloudSensorTemperature 24.73 Celsius Warm} {LDR 1535.3 kohms {Light Dependent Resistor}} {Brightness Light text {A word that describes brightness conditions}} {RainSensorTemperature 26.24 Warm} {PrecipitableWater Dry text {Rain or Wet or Dry}}
# meteosensor_close cs1
# #
#
# --- Example 2
# meteosensor_open ARDUINO com4 myarduino1
# # myarduino1
# meteosensor_get myarduino1
# # {RainSensorTime 2011-11-04T17:58:57.965 ISO8601 "Date"} {Rain 1 logical "1=Dry 0=Rain"} {RainAnalog 0.64 V ""} {RainState Dry text ""} {RainLastChange 32.00 sec ""} {RainLastState Unknown text "Symbol of the previous state"} {RainLastReboot 32.00 sec ""} {RainAnalogADU 132 ADU ""} {SensorModel Kemo_M152 text "Sensor model"}
# meteosensor_close myarduino1
# #

proc meteosensor_open { type port name {parameters ""} } {
   global audace
   if {[info exists audace(meteosensor,private,$name,channel)]==1} {
      catch { meteosensor_close }
   }
   set typeu [string trim [string toupper $type]]
   set portu [string trim [string toupper $port]]
   if {[lindex $portu 0]=="SOCKET"} {
      lassign $portu typeport ip_dev port_dev
   } else {
      set typeport "SERIAL_COM"
      set key [string range $portu 0 2]
      if {($key=="COM")&&($::tcl_platform(os) == "Linux")} {
         # on teste les /dev/...
         set nu [string range $portu 3 end]
         set portu2 /dev/ttyS[expr $nu-1]
         if {[file exists $portu2]==0} {
            set portu2 /dev/ttyUSB[expr $nu-1]
         } else {
            set portu2 $portu
         }
         set portu $portu2
      }
   }
   set audace(meteosensor,private,$name,portu) $portu
   set audace(meteosensor,private,$name,tempo) 100
   set audace(meteosensor,private,$name,typeport) $typeport
   if {$typeu=="AAG"} {
      if {$typeport=="SOCKET"} {
         set f [socket $ip_dev $port_dev]
         fconfigure $f -blocking 0 -buffering none -translation {binary binary}
      } else {
         set f [open $port w+]
         fconfigure $f  -mode 9600,n,8,1 -buffering none -blocking 0
      }
      set audace(meteosensor,private,$name,channel) $f
      set audace(meteosensor,private,$name,typeu) $typeu
      set audace(meteosensor,private,$name,tempo) 200
   } elseif {$typeu=="ARDUINO1"} {
      if {$typeport=="SOCKET"} {
         set f [socket $ip_dev $port_dev]
         fconfigure $f -blocking 0 -buffering none -translation {binary binary}
      } else {
         set f [open $port w+]
         fconfigure $f  -mode 9600,n,8,1 -buffering none -blocking 0
      }
      set audace(meteosensor,private,$name,channel) $f
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="WXT520"} {
      set baudrates {1200 2400 4800 9600 19200 38400 57600 115200}
      set baudrate 19200
      set k 0
      foreach parameter $parameters {
         if {$parameter=="-baudrate"} {
            set b [lindex $parameters [expr $k+1]]
            if {[lsearch -exact $baudrates $b]>=0} {
               set baudrate $b
            }
         }
         incr k
      }
      if {$typeport=="SOCKET"} {
         set f [socket $ip_dev $port_dev]
         fconfigure $f -blocking 0 -buffering none -translation {binary binary}
      } else {
         set f [open $port w+]
         fconfigure $f  -mode ${baudrate},n,8,1 -buffering none -translation {binary binary} -blocking 0
      }
      after 500
      catch {wxt520_envoi $f "0XU,M=P"} ; # set to polled mode
      set audace(meteosensor,private,$name,channel) $f
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="VANTAGEPRO"} {
      if {$typeport=="SOCKET"} {
         set f [socket $ip_dev $port_dev]
         fconfigure $f -blocking 0 -buffering none -translation {binary binary}
      } else {
         set f [open $port w+]
         fconfigure $f  -mode 19200,n,8,1 -buffering none -translation {binary binary} -blocking 0
      }
      set audace(meteosensor,private,$name,channel) $f
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="BOLTWOOD"} {
      set filename_clarity "C:/Program Files (x86)/Boltwood Systems/Clarity II/ClarityII.exe"
      set filename_data "[pwd]/cloud_monitor.dat"
      set k 0
      foreach parameter $parameters {
         if {$parameter=="-filename_clarity"} {
            set b [lindex $parameters [expr $k+1]]
            set filename_clarity $b
         }
         if {$parameter=="-filename_data"} {
            set b [lindex $parameters [expr $k+1]]
            set filename_data $b
         }
         incr k
      }
      boltwood_open $filename_clarity $name
      set audace(meteosensor,private,$name,channel) $filename_data
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {($typeu=="BOLTWOOD_DIRECT")||($typeu=="BOLTWOOD_DIRECT1")} {
      set t0 [clock milliseconds]
      if {($typeu=="BOLTWOOD_DIRECT")} {
         # --- Open reading for the new protocol
         if {$typeport=="SOCKET"} {
            set f [socket $ip_dev $port_dev]
            fconfigure $f -blocking 0 -buffering none -translation {binary binary}
         } else {
            set f [open $port w+]
            fconfigure $f -mode 4800,n,8,1 -buffering line -blocking 0 -translation {binary binary}
            after 500
         }
         set audace(meteosensor,private,$name,channel) $f
         set audace(meteosensor,private,$name,typeu) $typeu
         set audace(meteosensor,private,$name,tempo) 200
         # --- Init flush the reading for the new protocol
         flush $f
         set sortie 0
         for {set k 0} {$k<10} {incr k} {
            set hexas {01}
            set hexa_outs [boltwood_direct_putread $f $hexas]
            # console::affiche_resultat "[expr [clock milliseconds]-$t0] k=$k <$hexas> ==> <$hexa_outs>\n"
            if {$hexa_outs==" 02 50 0A"} {
               set sortie 1
               break
            }
            after $audace(meteosensor,private,$name,tempo)
         }
      } else {
         set sortie 0
      }
      # console::affiche_resultat "[expr [clock milliseconds]-$t0] sortie=$sortie\n"
      if ($sortie==1) {
         # --- Init the new protocol
         set hexas {02 6D 63 35 43 43 35 0A}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         after $audace(meteosensor,private,$name,tempo)
         set hexas {01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         after $audace(meteosensor,private,$name,tempo)
         # --- Read 1st (MT) T=Threshold
         set audace(meteosensor,private,$name,Clear_Cloudy) -12.0
         set audace(meteosensor,private,$name,Cloudy_VC) -9.0
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         set ack [lindex $hexa_outs 0]
         if {$ack=="02"} {
            set msg [string range [meteosensor_hexa2ascii $hexa_outs] 1 end]
            set key [lindex $msg 0]
            if {$key=="MT"} {
               #                                                             1                                       
               #        1     2     3   4     5     6      7       8     9   0    1      2   3     4     5  6       7
               # MT 01394 00065 06287 -12.0  -9.0  15.1   29.9    12   100   1   235   325   5 41005 22633  0   18BBC
               set Clear_Cloudy [lindex $msg  4]
               set Cloudy_VC    [lindex $msg  5]
               set Calm_Windy   [lindex $msg  6] ; # kph
               set Windy_VW     [lindex $msg  7]
               set Dark_Light   [lindex $msg 11]
               set Light_VL     [lindex $msg 12]
               set Rain         [lindex $msg  8]
               set Wet          [lindex $msg  9]
               set SerNumWC_SC  [lindex $msg  1]
               set Firmw_V      [lindex $msg  2]
               set audace(meteosensor,private,$name,Clear_Cloudy) $Clear_Cloudy
               set audace(meteosensor,private,$name,Cloudy_VC) $Cloudy_VC
            }
         }
         after $audace(meteosensor,private,$name,tempo)
         # --- Read 1st (MK)
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         after $audace(meteosensor,private,$name,tempo)
         # --- Read 1st (MW)
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         after $audace(meteosensor,private,$name,tempo)
         # --- Read 1st (MC)
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         after $audace(meteosensor,private,$name,tempo)
         # --- Read 1st (MD)
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         # console::affiche_resultat "<$hexas> ==> <$hexa_outs>\n"
         # console::affiche_resultat "[meteosensor_hexa2ascii $hexa_outs]\n"
         after $audace(meteosensor,private,$name,tempo)
         set audace(meteosensor,private,$name,protocol_version) 2
      } else {
         set typeu BOLTWOOD_DIRECT
         # --- try the old protocol
         catch {close $f}
         if {$typeport=="SOCKET"} {
            set f [socket $ip_dev $port_dev]
            fconfigure $f -blocking 0 -buffering none -translation {binary binary}
         } else {
            set f [open $port w+]
            fconfigure $f -mode 300,n,8,1 -buffering line -blocking 0 -translation {binary binary}
            after 500
         }
         set audace(meteosensor,private,$name,protocol_version) 1
         set audace(meteosensor,private,$name,tempo) 200
         set audace(meteosensor,private,$name,Clear_Cloudy) -25
         set audace(meteosensor,private,$name,Cloudy_VC) -10
         # console::affiche_resultat "[expr [clock milliseconds]-$t0] f=$f\n"
         set err2 [catch {
            set response [boltwood_direct_read $f $name]
         } msg2]
         # console::affiche_resultat "[expr [clock milliseconds]-$t0] response=$response\n"
         if {$err2==1} {
            catch {close $f}
            error "Problem during init: $response"
         }
         set audace(meteosensor,private,$name,channel) $f
         set audace(meteosensor,private,$name,typeu) $typeu
      }
   } elseif {$typeu=="LACROSSE"} {
      fetch3600_open $port
      set audace(meteosensor,private,$name,channel) undefined
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="SENTINEL_SKYMONITOR"} {
      sentinel_skymonitor_open
      sentinel_skymonitor_gain
      set audace(meteosensor,private,$name,channel) undefined
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="SENTINEL"} {
      if {$typeport=="SOCKET"} {
         set f [socket $ip_dev $port_dev]
         fconfigure $f -blocking 0 -buffering none -translation {binary binary}
      } else {
         set f [open $port w+]
         set audace(meteosensor,private,$name,channel) $f
         fconfigure $f -mode 115200,n,8,1 -buffering none -blocking 0 -translation {binary binary}
      }
      set audace(meteosensor,private,$name,typeu) $typeu
      after 1000
      sentinel_initialize $f $name
   } elseif {$typeu=="ARDUINO2"} {
      arduino arduino open
      set audace(meteosensor,private,$name,channel) auto
      set audace(meteosensor,private,$name,typeu) $typeu
   } elseif {$typeu=="SIMULATION"} {
      simulationmeteo_open
      set audace(meteosensor,private,$name,channel) undefined
      set audace(meteosensor,private,$name,typeu) $typeu
   } else {
      error "Type not supported. Valid types are: AAG, WXT520, ARDUINO1, VANTAGEPRO, BOLTWOOD, BOLTWOOD_DIRECT, LACROSSE, SENTINEL_SKYMONITOR, SENTINEL, SIMULATION"
   }
   return $name
}

proc meteosensor_list { } {
   global audace
   set array_names [array names audace]
   set res ""
   foreach array_name $array_names {
      set keys [split $array_name ,]
      set key1 [lindex $keys 0]
      set key2 [lindex $keys 1]
      set key3 [lindex $keys 3]
      if {($key1=="meteosensor")&&($key2=="private")&&($key3=="typeu")} {
         set name [lindex $keys 2]
         set typeu $audace(meteosensor,private,$name,typeu)
         set port "undefined"
         if {[info exists audace(meteosensor,private,$name,portu)]==1} {
            set port audace(meteosensor,private,$name,portu)
         }
         lappend res [list $name $typeu $port]
      }
   }
   return $res
}

proc meteosensor_channel { name } {
   global audace
   if {[info exists audace(meteosensor,private,$name,channel)]==0} {
      error "Cloudsensor connection not opened. Use meteosensor_open before"
   }
   set ress $audace(meteosensor,private,$name,channel)
   return $ress
}

proc meteosensor_type { name } {
   global audace
   if {[info exists audace(meteosensor,private,$name,channel)]==0} {
      error "Device connection not opened. Use meteosensor_open before"
   }
   return $audace(meteosensor,private,$name,typeu)
}

proc meteosensor_get { name } {
   global audace
   if {[info exists audace(meteosensor,private,$name,channel)]==0} {
      error "Cloudsensor connection not opened. Use meteosensor_open before"
   }
   set typeu $audace(meteosensor,private,$name,typeu)
   if {$typeu=="AAG"} {
      set res [aag_read $audace(meteosensor,private,$name,channel) $name]
   } elseif {$typeu=="WXT520"} {
      set res [wxt520_read $audace(meteosensor,private,$name,channel)]
   } elseif {$typeu=="ARDUINO1"} {
      set res [arduino1_rainsensor_read $audace(meteosensor,private,$name,channel)]
   } elseif {$typeu=="VANTAGEPRO"} {
      set res [vantagepro_read $audace(meteosensor,private,$name,channel) $name]
   } elseif {$typeu=="BOLTWOOD"} {
      set res [boltwood_read $audace(meteosensor,private,$name,channel) $name]
   } elseif {$typeu=="BOLTWOOD_DIRECT"} {
      set res [boltwood_direct_read $audace(meteosensor,private,$name,channel) $name]
   } elseif {$typeu=="LACROSSE"} {
      set res [fetch3600_read]
   } elseif {$typeu=="SENTINEL_SKYMONITOR"} {
      set res [sentinel_skymonitor_read]
   } elseif {$typeu=="SENTINEL"} {
      set res [sentinel_read $audace(meteosensor,private,$name,channel) $name]
   } elseif {$typeu=="ARDUINO2"} {
      set res [arduino2_read]
   } elseif {$typeu=="SIMULATION"} {
      set res [simulationmeteo_read]
   }
   return $res
}

proc meteosensor_getstandard { name } {
   global audace
   set ps [meteosensor_get $name]
   set keystandards "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Humidity        Water"
   set typeu $audace(meteosensor,private,$name,typeu)
   if {$typeu=="AAG"} {
      set keys      "SkyCover          SkyTemperature CloudSensorTemperature  -      -        -               PrecipitableWater"
   } elseif {$typeu=="WXT520"} {
      set keys      "-                 -              OutsideTemp             WinDir WinSpeed OutsideHumidity PrecipitableWater"
   } elseif {$typeu=="ARDUINO1"} {
      set keys      "-                 -              -                       -      -        -               RainState"
   } elseif {$typeu=="VANTAGEPRO"} {
      set keys      "-                 -              OutsideTemp             WinDir WinSpeed OutsideHumidity PrecipitableWater"
   } elseif {$typeu=="BOLTWOOD"} {
      set keys      "CloudSkyCondition CloudSkyTemp   CloudOutsideTemp        -      -        -               CloudWetFlag"
   } elseif {$typeu=="BOLTWOOD_DIRECT"} {
      set keys      "CloudSkyCondition CloudSkyTemp   CloudOutsideTemp        -      Cloudwind   -            CloudWetFlag"
   } elseif {$typeu=="LACROSSE"} {
      set keys      "-                 -              OutsideTemp             WinDir WinSpeed OutsideHumidity PrecipitableWater"
   } elseif {$typeu=="SENTINEL_SKYMONITOR"} {
      set keys      "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Humidity        RainState"
   } elseif {$typeu=="SENTINEL"} {
      set keys      "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Humidity        RainState"
   } elseif {$typeu=="ARDUINO2"} {
      set keys      "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Humidity        RainState"
   } elseif {$typeu=="SIMULATION"} {
      set keys      "SkyCover          SkyTemp        OutTemp                 WinDir WinSpeed Humidity        Water"
   }
   set restot ""
   set k1 0
   foreach keystandards $keystandards {
      set key [lindex $keys $k1]
      set val undefined
      set unit undefined
      set com undefined
      if {$key=="-"} {
         set key undefined
      } else {
         foreach p $ps {
            set keyp [lindex $p 0]
            if {$keyp==$key} {
               set val [lindex $p 1]
               set unit [lindex $p 2]
               set com [lindex $p 3]
               break
            }
         }
      }
      lappend restot [list $keystandards $val $unit $com]
      incr k1
   }
   return $restot
}

proc meteosensor_close { name } {
   global audace
   if {[info exists audace(meteosensor,private,$name,channel)]==0} {
      error "Cloudsensor connection not opened. Use meteosensor_open before"
   }
   set typeu $audace(meteosensor,private,$name,typeu)
   if {($typeu=="AAG")||($typeu=="WXT520")||($typeu=="ARDUINO1")||($typeu=="SENTINEL")||($typeu=="VANTAGEPRO")||($typeu=="BOLTWOOD_DIRECT")} {
      close $audace(meteosensor,private,$name,channel)
      unset audace(meteosensor,private,$name,channel)
      unset audace(meteosensor,private,$name,typeu)
   }
   if {($typeu=="BOLTWOOD")||($typeu=="LACROSSE")||($typeu=="SENTINEL_SKYMONITOR")||($typeu=="ARDUINO2")||($typeu=="SIMULATION")} {
      unset audace(meteosensor,private,$name,channel)
      unset audace(meteosensor,private,$name,typeu)
   }
   catch {
      set names [array names audace]
      foreach name $names {
         set keys [split $name ,]
         set key1 [lindex $keys 0]
         set key2 [lindex $keys 2]
         if {($key1=="meteosensor")&&($key2==$name)} {
            unset audace($name)
         }
      }
   }
}

proc meteosensor_convert_base { nombre basein baseout } {
   set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}
   # --- conversion vers la base decimale
   if {$basein=="ascii"} {
      set nombre [string index $nombre 0]
      if {$nombre==""} {
         set nombre " "
      }
      for {set k 0} {$k<256} {incr k} {
         set car [format %c $k]
         if {$car==$nombre} {
            set integ_decimal $k
         }
      }
   } else {
      set nombre [regsub -all " " $nombre ""]
      set symbins [lrange $symbols 0 [expr $basein-1]]
      set n [expr [string length $nombre]-1]
      set integ_decimal 0
      for {set k $n} {$k>=0} {incr k -1} {
         set mult [expr pow($basein,$n-$k)]
         set digit [string index $nombre $k]
         set kk [lsearch -exact $symbins $digit]
         if {$kk==-1} {
            break
         } else {
            set digit $kk
         }
         #::console::affiche_resultat "nombre=$nombre k=$k n-k=$n-$k digit=$digit mult=$mult\n"
         set integ_decimal [expr $integ_decimal+$digit*$mult]
      }
   }
   # --- conversion vers la base de sortie
   set symbols {0 1 2 3 4 5 6 7 8 9 A B C D E F}
   set integ [expr abs(int($integ_decimal))]
   if {$baseout=="ascii"} {
      if {$integ>255} {
         set integ 255
      }
      set bb [format %c $integ]
   } else {
      set sortie 0
      set bb ""
      set k 0
      while {$sortie==0} {
         set b [expr int(floor($integ/$baseout))]
         set reste [lindex $symbols [expr $integ-$baseout*$b]]
         #::console::affiche_resultat "bb=$bb\n"
         set bb "${reste}${bb}"
         #::console::affiche_resultat "integ=$integ base=$base => b=$b reste=$reste bb=$bb\n"
         set integ $b
         if {$b<1} {
            set sortie 1
            break
         }
         incr k
      }
      if {($baseout==16)&&([string length $bb]%2==1)} {
         set bb "0${bb}"
      }
   }
   return $bb
}

proc meteosensor_ascii2hexa { msg } {
   set cars ""
   set n [string length $msg]
   for {set k 0} {$k<$n} {incr k} {
      set car [string index $msg $k]
      append cars " [meteosensor_convert_base $car ascii 16]"
   }
   return $cars
}

proc meteosensor_hexa2ascii { hexas } {
   set cars ""
   foreach hexa $hexas {
      append cars [meteosensor_convert_base $hexa 16 ascii]
   }
   return $cars
}

proc meteosensor_tempo { name {ms ""} } {
   global audace
   if {$ms!=""} {
      set audace(meteosensor,private,$name,tempo) $ms
   }
   return $audace(meteosensor,private,$name,tempo)
}

# ===========================================================================
# ===========================================================================
# ====== AAG Cloudwatcher
# ===========================================================================
# ===========================================================================

proc aag_ascii2num { ascii } {
   for { set k 0 } { $k<256 } {incr k} {
      if {$ascii==[format %c $k]} {
         return $k
      }
   }
   return -1
}

proc aag_send { channel commande {tempo 50} } {
   set response [read -nonewline $channel]
   after 10
   puts -nonewline $channel "${commande}!"
   set car [string index $commande 0]
   if {$car=="C"} { set tempo [expr $tempo+100] }
   if {$car=="D"} { set tempo [expr $tempo+100] }
   if {$car=="E"} { set tempo [expr $tempo+300] }
   after $tempo
   set response [read -nonewline $channel]
   if {$response==""} {
      error "Pb connection for command $commande\n"
   }
   set ress ""
   set sortie 0
   set k1 0
   while {$sortie==0} {
      set k2 [expr $k1+14]
      set resp [string range $response $k1 $k2]
      set begininfo [string range $resp 0 0]
      if {$begininfo!="!"} {
         error "Pb first ! not found for command $commande"
      }
      set key [string index $resp 1]
      #console::affiche_resultat "resp=<$resp>\n"
      if {$key==[format %c 17]} {
         break
      } elseif {$key=="K"} {
         set infocontent [string range $resp 2 13]
         lappend ress [list SerialNumber [string trim $infocontent]]
      } elseif {$key=="M"} {
         set kc 2
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/100.]
         lappend ress [list ZenerVoltage $val]
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/1.]
         lappend ress [list LDRMaxResistance $val]
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/10.]
         lappend ress [list LDRPullUpResistance $val]
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/1.]
         lappend ress [list RainBeta $val]
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/10.]
         lappend ress [list RainResAt25 $val]
         set c1 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set c2 [aag_ascii2num [string index $resp $kc]] ; incr kc
         set val [expr (256*$c1+$c2)/10.]
         lappend ress [list RainPullUpResistance $val]
      } else {
         set infonature [string range $resp 1 2]
         set infocontent [string range $resp 3 14]
         lappend ress [list [string trim $infonature] [string trim $infocontent]]
      }
      set k1 [expr $k2+1]
      if {$k1>100} { break }
   }
   return $ress
}

proc aag_read { channel name} {
   global audace
   set tempo $audace(meteosensor,private,$name,tempo)
   set ress [aag_send $channel M $tempo]
   if {$ress==""} {
      # --- retry (useful for the first access)
      set ress [aag_send $channel M $tempo]
   }
   foreach res $ress {
      set key [lindex $res 0]
      set val [lindex $res 1]
      set aag($key) $val
      #console::affiche_resultat "aag($key) = $val\n"
   }
   set ress ""
   # --- SkyTemp (small size sensor)
   set res [aag_send $channel S $tempo]
   set val [lindex [lindex $res 0] 1]
   set val [expr $val/100.]
   if {$val<-8} {
      set com Clear
   } elseif {$val<0} {
      set com Cloudy
   } else {
      set com VeryCloudy
   }
   set units Celsius
   lappend ress [list SkyTemperature $val $units "Sky temperature measured by an infrared sensor"]
   lappend ress [list SkyCover $com text "A word that describes sky conditions"]
   # --- SensorTemp (small size sensor)
   set res [aag_send $channel T $tempo]
   set val [lindex [lindex $res 0] 1]
   set val [expr $val/100.]
   if {$val<10} {
      set com Cold
   } elseif {$val<30} {
      set com Warm
   } elseif {$val<40} {
      set com Hot
   } else {
      set com VeryHot
   }
   set units Celsius
   lappend ress [list CloudSensorTemperature $val $units "$com"]
   # --- Light Dependent Resistor (medium size sensor)
   set res [aag_send $channel C $tempo]
   set val [lindex [lindex $res 1] 1]
   if {$val>1022} { set val 1022 }
   if {$val<1} { set val 1 }
   set LDR [expr $aag(LDRPullUpResistance) / ( (1023./$val)-1 )]
   if {$LDR>2000} {
      set com Dark
   } elseif {$LDR>6} {
      set com Light
   } else {
      set com VeryLight
   }
   set units kohms
   lappend ress [list LDR [format %.1f $LDR] $units "Light Dependent Resistor"]
   lappend ress [list Brightness $com text "A word that describes brightness conditions"]
   # --- Ambiant temperature from the rain sensor (large sensor)
   set val [lindex [lindex $res 2] 1]
   if {$val>1022} { set val 1022 }
   if {$val<1} { set val 1 }
   set r [expr $aag(RainPullUpResistance) / ( (1023./$val)-1 )]
   set r [expr log($r/$aag(RainResAt25))]
   set ABSZERO 273.15
   set TRain [expr 1. / ($r / $aag(RainBeta) + 1. / ( $ABSZERO + 25 )) - $ABSZERO]
   if {$TRain<10} {
      set com Cold
   } elseif {$TRain<30} {
      set com Warm
   } elseif {$TRain<40} {
      set com Hot
   } else {
      set com VeryHot
   }
   set units Celsius
   lappend ress [list RainSensorTemperature [format %.2f $TRain] "$com"]
   # --- Rain (large sensor)
   set res [aag_send $channel E $tempo]
   set val [lindex [lindex $res 0] 1]
   if {$val<400} {
      set com Unknown
   } elseif {$val<1700} {
      set com Rain
   } elseif {$val<2000} {
      set com Wet
   } else {
      set com Dry
   }
   lappend ress [list Precipitable $com text "Rain or Wet or Dry"]
   set units Frequency
   lappend ress [list RainSensorFrequency $val $units "Rain frequency counter"]
   # --- return results
   return $ress
}

# ===========================================================================
# ===========================================================================
# ====== Vaisala WXT520
# ===========================================================================
# ===========================================================================

proc wxt520_envoi { channel msg } {
   set f $channel
   puts -nonewline $f "$msg[format %c 13][format %c 10]" ; after 10 ; flush $f
   #::console::affiche_resultat "ENVOIE <$msg>\n"
   set t0 [clock seconds]
   set msgtot ""
   set sortie 0
   while {$sortie==0} {
      after 100
      set msg [read $f]
      set n [string length $msg]
      if {$n>0} {
         append msgtot $msg
      }
      set k [string first [format %c 10] $msgtot]
      if {$k>=0} {
         set sortie 1
         break
      }
      set dt [expr [clock seconds]-$t0]
      if {$dt>5} {
         set sortie 2
         break
      }
   }
   set msg $msgtot
   set k [string first [format %c 13] $msg]
   if {$k<0} {set k 1 }
   set msg [string range $msg 0 [expr $k-1]]
   #::console::affiche_resultat "RECOIT <$msg>\n"
   return $msg
}

proc wxt520_decode { reponse } {
   set ress [split $reponse ,]
   #::console::affiche_resultat "ress <$ress>\n"
   set reps ""
   foreach res $ress {
      set res [split $res =]
      set key [lindex $res 0]
      set val [lindex $res 1]
      set v [string trimleft [string range $val 0 end-1] 0]
      if {$v==""} { set v 0 }
      set u [string range $val end end]
      if {$val==""} {
         continue
      }
      # ---
      if {$key=="A"} {lappend reps "Address $val"}
      if {$key=="M"} {lappend reps "Protocol $val"}
      if {$key=="T"} {lappend reps "Test-param $val"}
      if {$key=="C"} {
         set val1 "Unknown"
         if {$val=="1"} { set val1 SDI-12 }
         if {$val=="2"} { set val1 RS-232 }
         if {$val=="3"} { set val1 RS-485 }
         if {$val=="4"} { set val1 RS-422 }
         lappend reps "Interface $val1"
      }
      if {$key=="I"} {lappend reps "Repet-interval $val"}
      if {$key=="B"} {lappend reps "Baud $val"}
      if {$key=="D"} {lappend reps "Data-bits $val"}
      if {$key=="P"} {lappend reps "Parity $val"}
      if {$key=="S"} {lappend reps "Stop-bits $val"}
      if {$key=="L"} {lappend reps "RS-485-Line-delay $val"}
      if {$key=="N"} {lappend reps "Name $val"}
      if {$key=="V"} {lappend reps "Software-version $val"}
      # --- M1
      if {$key=="Dn"} {lappend reps "Wind_dir_mini $v $u"}
      if {$key=="Dx"} {lappend reps "Wind_dir_maxi $v $u"}
      if {$key=="Dm"} {lappend reps "Wind_dir_mean $v $u"}
      if {$key=="Sn"} {lappend reps "Wind_vel_mini $v $u"}
      if {$key=="Sx"} {lappend reps "Wind_vel_maxi $v $u"}
      if {$key=="Sm"} {lappend reps "Wind_vel_mean $v $u"}
      # --- M2
      if {$key=="Ta"} {lappend reps "Temperature_ext $v $u"}
      if {$key=="Tp"} {lappend reps "Temperature_int $v $u"}
      if {$key=="Ua"} {lappend reps "Humidity $v $u"}
      if {$key=="Pa"} {lappend reps "Pressure $v $u"}
      # --- M3
      if {$key=="Rc"} {lappend reps "Cumulative_rain $v $u"}
      if {$key=="Rd"} {lappend reps "Duration_rain $v $u"}
      if {$key=="Ri"} {lappend reps "Rate_rain $v $u"}
      if {$key=="Hc"} {lappend reps "Cumulative_hail $v $u"}
      if {$key=="Hd"} {lappend reps "Duration_hail $v $u"}
      if {$key=="Hi"} {lappend reps "Rate_hail $v $u"}
      if {$key=="Rp"} {lappend reps "MaxRate_rain $v $u"}
      if {$key=="Hp"} {lappend reps "MaxRate_hail $v $u"}
      # --- M5
      if {$key=="Th"} {lappend reps "Temp_heating $v $u"}
      if {$key=="Vh"} {lappend reps "Voltage_heating $v $u"}
      if {$key=="Vs"} {lappend reps "Voltage_power $v $u"}
      if {$key=="Vr"} {lappend reps "Voltage_reference $v $u"}
   }
   return $reps
}

proc wxt520_read { channel } {
   set commande "?"
   set res [wxt520_envoi $channel $commande]
   if {$res!="0"} {
      error "Pb connection\n"
   }
   set commande "0R1"
   set res0 [wxt520_envoi $channel $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Wind_dir_mean]
   if {$k>=0} { set dirvent [lindex [lindex $res $k] 1] }
   if {[catch {expr $dirvent}]==1} {
      error "Pb dirvent=$dirvent ($res)"
   }
   set k [lsearch -regexp $res Wind_vel_mean]
   if {$k>=0} { set vitvent [lindex [lindex $res $k] 1] }
   set commande "0R2"
   set res0 [wxt520_envoi $channel $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Temperature_ext]
   if {$k>=0} { set tempext [lindex [lindex $res $k] 1] ; set tempint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Temperature_int]
   if {$k>=0} { set tempint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Humidity]
   if {$k>=0} { set humext [lindex [lindex $res $k] 1] ; set humint [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Pressure]
   if {$k>=0} { set pression [lindex [lindex $res $k] 1] }
   set commande "0R3"
   set res0 [wxt520_envoi $channel $commande]
   set res [wxt520_decode $res0]
   set k [lsearch -regexp $res Rate_rain]
   if {$k>=0} { set rainrate [lindex [lindex $res $k] 1] }
   set k [lsearch -regexp $res Rate_hail]
   if {$k>=0} { set hailrate [lindex [lindex $res $k] 1] }
   # --- calcule de la temperature de rosee par la formule de Magnus-Tetens
   set humidity_taux [expr $humext/100.]
   set f [expr 17.271*$tempext/(237.7+$tempext) + log($humidity_taux)]
   set dewtemp [expr 237.7*$f/(17.271-$f)]
   #set dewtemp [expr pow($humext/100.,1./8.)*(112.+(0.9*$tempext))+(0.1*$tempext)-112.]
   if {$dirvent<22.5} {
      set pcard "N"
   } elseif { $dirvent< 67.5} {
      set pcard "NE"
   } elseif { $dirvent<112.5} {
      set pcard "E"
   } elseif { $dirvent<157.5} {
      set pcard "SE"
   } elseif { $dirvent<202.5} {
      set pcard "S"
   } elseif { $dirvent<247.5} {
      set pcard "SW"
   } elseif { $dirvent<292.5} {
      set pcard "W"
   } elseif { $dirvent<337.5} {
      set pcard "NW"
   } else {
      set pcard "N"
   }
   #set dirvent [expr $dirvent+180]
   #if {$dirvent>360} {
   #   set dirvent [expr $dirvent-360]
   #}
   set resultat ""
   set er [catch {
      set res [mc_date2ymdhms now]
      set month [lindex $res 1]
      set day [lindex $res 2]
      set year [lindex $res 0]
      set hour [lindex $res 3]
      set min [lindex $res 4]
      set sec [expr int(floor([lindex $res 5]))]
      set res "$month $day $year $hour $min $sec"
      set date "[format %04d $year]-[format %02d $month]-[format %02d $day]T[format %02d $hour]:[format %02d $min]:[format %02d $sec]"
      lappend resultat [list StationTime $date ISO8601 "Date of the last measurement"]
      lappend resultat [list OutsideTemp [format %.1f $tempext] Celsius ""]
      lappend resultat [list InsideTemp [format %.1f $tempint] Celsius ""]
      lappend resultat [list OutsideHumidity [format %.1f $humext] Percent ""]
      lappend resultat [list HailRate [format %.1f $hailrate] impatcs/hour ""]
      lappend resultat [list Barometer [format %.1f $pression] mbar ""]
      lappend resultat [list RainRate  [format %.1f $rainrate] mm/hour ""]
      lappend resultat [list WindSpeed [format %.1f $vitvent] m/s ""]
      lappend resultat [list WindDir [format %.1f $dirvent] deg "N=0, E=90"]
      lappend resultat [list WindDirCardinal $pcard text "Cadinal symbol of wind direction"]
      lappend resultat [list DewPt [format %.1f $dewtemp] Celsius "Dew point"]
   } ms ]
   if {$er==1} {
      error "Meteo problem ($ms)"
   }
   #gren_info "[mc_date2iso8601 now] $thisproc : resultat=$resultat"
   return $resultat
}

# --- Native command to change parameters.
# e.g. to change baud rate from 19200 to 4800 bauds
#  meteosensor_open WXT520 COM3 wxt {-baudrate 19200}
#  wxt520_native [meteosensor_channel wxt] "0XU,B=4800"
proc wxt520_native { channel cmd } {
   set commande "?"
   set res [wxt520_envoi $channel $commande]
   if {$res!="0"} {
      error "Pb connection\n"
   }
   set commande "$cmd"
   set res0 [wxt520_envoi $channel $commande]
   set res [wxt520_decode $res0]
}

# ===========================================================================
# ===========================================================================
# ====== Arduino rainsensors (Vaisala DRD11 or Kemo M152)
# ===========================================================================
# ===========================================================================
# The following code is programmed in the Arduino
# /*
#  * detecteur de pluie KEMO_M152 ou VAISALA_DRD11 en fonction du #define
#  *
# # code Tcl qui fait marcher tout cela
# set f [open com4 w+]
# fconfigure $f  -mode 9600,n,8,1 -buffering none -blocking 0
# puts -nonewline $f get\n ; after 200 ; read -nonewline $f
# close $f
#  */
#
# // --- LEDs that indicate rain or not
# int ledPinRed =  7;    // RED LED connected to digital pin 7
# int ledPinGreen =  6;    // GREEN LED connected to digital pin 6
#
# // --- wire from/to sensor
# int sensorPin = 5; // analog pin 5
# int rainPin =  2;  // digital pin 2
#
# #define KEMO_M152
# // Sensor : Kemo M152
# // Analog pin 5 : white (dry<5V, wet=5V)
# // GND pin : yellow
# // Vin pin : brown (12V DC)
# // 5V pin : green
#
# //#define VAISALA_DRD11
# // Sensor : Vaiasala DRD11A
# // Analog pin 5 : yellow (dry=3V, wet=1V, off<0.5V) analog pin 5
# // Digital pin 2 : blue (Rain) digital pin 2
# // GND pin : black and brown
# // Vin pin : red (12V DC)
#
# float sensorValue = 0;
# int rainValue = 0;
# int mode = 0; //=0 normal =1 debug
# char command[128];
# int command_complete = 0;
# int stateLedRed = 0;
# unsigned long time = 0;
# unsigned long time0 = 0;
# char state0[20];
# char state00[20];
# unsigned long time1 = 0;
# char state[20];
#
# void setup()                    // run once, when the sketch starts
# {
#   // initialize the digital pin as an output or input
#   pinMode(ledPinRed, OUTPUT);
#   pinMode(ledPinGreen, OUTPUT);
#   pinMode(rainPin, INPUT);
#   mode = 0;
#   command_complete = 0;
#   strcpy(command,"");
#   stateLedRed = 0;
#   time0 = millis();
#   time1 = 0;
#   strcpy(state0,"");
#   strcpy(state00,"Unknown");
#   digitalWrite(ledPinRed, LOW);   // set the RED LED off
#   digitalWrite(ledPinGreen, LOW);   // set the GREEN LED off
#   Serial.begin(9600);           // set up Serial library at 9600 bps
#   Serial.println("");
# }
#
# void loop()
#  {
#   int val;
#   char key;
#   double dt=0,dtboot=0;
#   rainValue = digitalRead(rainPin);
#   val = analogRead(sensorPin);
#   sensorValue = val/1024.*5.;
#   time = millis();
#   if (time<time0) {
#     time1=time1+pow(2,32)/1000;
#     time0=0;
#   }
#   if (mode==0) {
# #if defined KEMO_M152
#     /* --- KEMO_M152 rainsensor ---*/
#     if (val<1020) {
#       rainValue=1;
#       digitalWrite(ledPinRed, LOW);   // set the red LED off
#       digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#       strcpy(state,"Dry");
#     } else {
#       rainValue=0;
#       digitalWrite(ledPinRed, HIGH);   // set the red LED on
#       digitalWrite(ledPinGreen, LOW);   // set the green LED off
#       strcpy(state,"Rain");
#     }
# #endif
# #if defined VAISALA_DRD11
#     /* --- Vaisala rainsensor ---*/
#     if ((sensorValue<1.2)&&(rainValue==1)) {
#       digitalWrite(ledPinRed, HIGH);   // set the red LED on
#       digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#       strcpy(state,"Problem");
#     } else {
#       if ((sensorValue>2.5)&&(rainValue==0)) {
#           digitalWrite(ledPinRed, LOW);   // set the red LED off
#           digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#           strcpy(state,"Drying...");
#        } else {
#           if ((rainValue==1)&&(sensorValue>2.5)) {
#             digitalWrite(ledPinRed, LOW);   // set the red LED off
#             digitalWrite(ledPinGreen, HIGH);   // set the green LED on
#             strcpy(state,"Dry");
#        } else {
#           digitalWrite(ledPinRed, HIGH);   // set the red LED on
#           digitalWrite(ledPinGreen, LOW);   // set the green LED off
#           strcpy(state,"Rain");
#         }
#       }
#     }
# #endif
#     if (strcmp(state0,state)!=0) {
#       strcpy(state00,state0);
#       time0=time;
#       strcpy(state0,state);
#     }
#   }
#   dt=((time-time0)/1000)+time1;
#   dtboot=(time/1000)+time1;
#   while (Serial.available()) {
#      key = Serial.read();
#      if ((key=='\n')||(key=='\r')) {
#         command_complete=-1;
#         if (strcmp(command,"?")==0) {
#           mode = 0;
#           Serial.println("Flag_rain(0=Rain) Voltage(Volts) State(Dry|Rain|Problem) Last_change(sec) Previous_State(Dry|Rain|Problem|Unknown) Last_boot(sec) Voltage(ADU)");
#         } else if (strcmp(command,"get")==0) {
#           mode = 0;
#           if (strcmp(state00,"")==0) {
#             strcpy(state00,"Unknown");
#           }
#           Serial.print(rainValue);
#           Serial.print(" ");
#           Serial.print(sensorValue);
#           Serial.print(" ");
#           Serial.print(state);
#           Serial.print(" ");
#           Serial.print(dt);
#           Serial.print(" ");
#           Serial.print(state00);
#           Serial.print(" ");
#           Serial.print(dtboot);
#           Serial.print(" ");
#           Serial.print(val);
# #if defined VAISALA_DRD11
#           Serial.print(" Vaisala_DRD11A");
# #endif
# #if defined KEMO_M152
#           Serial.print(" Kemo_M152");
# #endif
#           Serial.println(" ");
#         } else if (strcmp(command,"red 0")==0) {
#           mode = 1;
#           digitalWrite(ledPinRed, LOW);   // set the red LED off
#           Serial.println("Debug : red led off");
#         } else if (strcmp(command,"red 1")==0) {
#           mode = 1;
#           digitalWrite(ledPinRed, HIGH);   // set the red LED off
#           Serial.println("Debug : red led on");
#         } else if (strcmp(command,"green 0")==0) {
#           mode = 1;
#           digitalWrite(ledPinGreen, LOW);   // set the green LED off
#           Serial.println("Debug : green led off");
#         } else if (strcmp(command,"green 1")==0) {
#           mode = 1;
#           digitalWrite(ledPinGreen, HIGH);   // set the green LED off
#           Serial.println("Debug : green led on");
#         } else if (strcmp(command,"")!=0) {
#           Serial.print("commande ");
#           Serial.print(command);
#           Serial.println(" non reconnue parmi ?, get, red 0, red 1, green 0, green 1.");
#         }
#         Serial.flush();
#         strcpy(command,"");
#         command_complete=0;
#      } else {
#         command[command_complete]=key;
#         command_complete++;
#         command[command_complete]='\0';
#      }
#    }
# }
# ===========================================================================

proc arduino1_rainsensor_envoi { channel msg } {
   flush $channel
   puts -nonewline $channel "$msg\n"
   after 200
   set msg [read -nonewline $channel]
   return $msg
}

proc arduino1_rainsensor_read { channel } {
   set reponse [arduino1_rainsensor_envoi $channel get]
   if {$reponse==""} {
      error "Pb connection"
   }
   set rep ""
   lappend rep "RainSensorTime [mc_date2iso8601 now] ISO8601 \"Date\""
   set SensorModel [lindex $reponse 7]
   set RainAnalog [lindex $reponse 1]
   set RainLastChange [lindex $reponse 3]
   set RainLastReboot [lindex $reponse 5]
   set Pluie [lindex $reponse 0]
   if {$SensorModel=="Vaisala_DRD11A"} {
      if {($RainAnalog>2.9)&&($RainLastChange>180)} {
         # --- ruse pour eviter de voir de la pluie quand il n'y en a pas !!!
         set Pluie 1
      }
   } else {
      if {($Pluie==1)&&($RainLastChange<120)&&($RainLastReboot>120)} {
         # --- Temporisation dans le cas d'une pluie goutte à goutte
         set Pluie 0
      }
   }
   lappend rep "Rain $Pluie logical \"1=Dry 0=Rain\""
   lappend rep "RainAnalog [lindex $reponse 1] V \"\""
   lappend rep "RainState [lindex $reponse 2] text \"\""
   lappend rep "RainLastChange [lindex $reponse 3] sec \"\""
   lappend rep "RainLastState [lindex $reponse 4] text \"Symbol of the previous state\""
   lappend rep "RainLastReboot [lindex $reponse 5] sec \"\""
   lappend rep "RainAnalogADU [lindex $reponse 6] ADU \"\""
   lappend rep "SensorModel [lindex $reponse 7] text \"Sensor model\""
   return $rep
}

# ===========================================================================
# ===========================================================================
# ====== Arduino2 (RG11 and DHT22)
# ===========================================================================
# ===========================================================================
proc arduino2_read { } {
   set rain_sate [rain]
   set dht_state [dht]
   if {$rain_sate=="dry"} {
      set RainState Dry
   } else {
      set RainState Rain
   }
   set sky_state [sky]
   set valid [lindex $sky_state 2]
   set ambiant [lindex $sky_state 5]
   set tempsky [lindex $sky_state 8]
   set SkyTemp -50
   set SkyCover Clear
   if {$valid==1} {
      set SkyTemp $tempsky
      if {$tempsky>7} {
         set SkyCover VeryCloudy
      } elseif {$tempsky>0} {
         set SkyCover Cloudy
      }
   }
   set OutTemp [lindex $dht_state 1]
   set Humidity [lindex $dht_state 0]
   set WinDir 0
   set WinSpeed 0
   set res ""
   lappend rep "SkyCover $SkyCover text \"Sky conditions\""
   lappend rep "SkyTemp $SkyTemp float \"degC\""
   lappend rep "OutTemp $OutTemp float \"degC\""
   lappend rep "WinDir $WinDir float \"deg\""
   lappend rep "WinSpeed $WinSpeed float \"m/s\""
   lappend rep "Humidity $Humidity percent \"Relative humidity\""
   lappend rep "RainState $RainState text \"Dry Rain\""
   return $rep
}

# ===========================================================================
# ===========================================================================
# ====== Vantage Pro serial port
# ===========================================================================
# ===========================================================================
# vantagepro_open VantagePro com5

proc vantagepro_read { f name} {
   global audace
   set tempo $audace(meteosensor,private,$name,tempo)
   puts -nonewline $f "\r" ; flush $f ; after 50 ; set res [read -nonewline $f] ; flush $f ; set n [string length $res]
   if {$n==0} {
      puts -nonewline $f "\r" ; flush $f ; after $tempo ; set res [read -nonewline $f] ; flush $f
   }
   puts -nonewline $f "LOOP 1\n" ; after $tempo ; set res [read -nonewline $f]
   set hexa [meteosensor_ascii2hexa $res]
   #set hexa "  06 4C 4F 4F 00 00 41 00 BA 73 A0 02 0C 59 02 0D 0A 00 00 FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF 17 FF FF FF FF FF FF FF 00 00 FF FF 7F 00 00 FF FF 00 00 00 00 B0 00 00 00 00 00 14 00 FF FF FF FF FF FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 26 03 03 C0 0C 04 1F 00 0A 0D C7 1A"
   # --- Verify the integrity of the returned packet
   set key [lrange $hexa 0 3]
   if {$key!="06 4C 4F 4F"} {
      set key [lrange $hexa 0 0]
      if {$key!="06"} {
         error "Problem communication with meteo station (no ACK. key=$key). <$hexa>"
      } else {
         error "Problem communication with meteo station (no LOO. key=$key). <$hexa>"
      }
   }
   set hexa [lrange $hexa 1 end] ; # keep only the 99 bytes of the LOOP format
   set n [llength $hexa]
   if {$n!=99} {
      error "Problem communication with meteo station ($n != 99 bytes). <$hexa>"
   }
   # checksum by CRC method described page 32-34
   # set hexa {C6 CE A2 03} ; # for test CRC described page 34
   set crc_table ""
   append crc_table "0x0000 0x1021 0x2042 0x3063 0x4084 0x50a5 0x60c6 0x70e7 "
   append crc_table "0x8108 0x9129 0xa14a 0xb16b 0xc18c 0xd1ad 0xe1ce 0xf1ef "
   append crc_table "0x1231 0x0210 0x3273 0x2252 0x52b5 0x4294 0x72f7 0x62d6 "
   append crc_table "0x9339 0x8318 0xb37b 0xa35a 0xd3bd 0xc39c 0xf3ff 0xe3de "
   append crc_table "0x2462 0x3443 0x0420 0x1401 0x64e6 0x74c7 0x44a4 0x5485 "
   append crc_table "0xa56a 0xb54b 0x8528 0x9509 0xe5ee 0xf5cf 0xc5ac 0xd58d "
   append crc_table "0x3653 0x2672 0x1611 0x0630 0x76d7 0x66f6 0x5695 0x46b4 "
   append crc_table "0xb75b 0xa77a 0x9719 0x8738 0xf7df 0xe7fe 0xd79d 0xc7bc "
   append crc_table "0x48c4 0x58e5 0x6886 0x78a7 0x0840 0x1861 0x2802 0x3823 "
   append crc_table "0xc9cc 0xd9ed 0xe98e 0xf9af 0x8948 0x9969 0xa90a 0xb92b "
   append crc_table "0x5af5 0x4ad4 0x7ab7 0x6a96 0x1a71 0x0a50 0x3a33 0x2a12 "
   append crc_table "0xdbfd 0xcbdc 0xfbbf 0xeb9e 0x9b79 0x8b58 0xbb3b 0xab1a "
   append crc_table "0x6ca6 0x7c87 0x4ce4 0x5cc5 0x2c22 0x3c03 0x0c60 0x1c41 "
   append crc_table "0xedae 0xfd8f 0xcdec 0xddcd 0xad2a 0xbd0b 0x8d68 0x9d49 "
   append crc_table "0x7e97 0x6eb6 0x5ed5 0x4ef4 0x3e13 0x2e32 0x1e51 0x0e70 "
   append crc_table "0xff9f 0xefbe 0xdfdd 0xcffc 0xbf1b 0xaf3a 0x9f59 0x8f78 "
   append crc_table "0x9188 0x81a9 0xb1ca 0xa1eb 0xd10c 0xc12d 0xf14e 0xe16f "
   append crc_table "0x1080 0x00a1 0x30c2 0x20e3 0x5004 0x4025 0x7046 0x6067 "
   append crc_table "0x83b9 0x9398 0xa3fb 0xb3da 0xc33d 0xd31c 0xe37f 0xf35e "
   append crc_table "0x02b1 0x1290 0x22f3 0x32d2 0x4235 0x5214 0x6277 0x7256 "
   append crc_table "0xb5ea 0xa5cb 0x95a8 0x8589 0xf56e 0xe54f 0xd52c 0xc50d "
   append crc_table "0x34e2 0x24c3 0x14a0 0x0481 0x7466 0x6447 0x5424 0x4405 "
   append crc_table "0xa7db 0xb7fa 0x8799 0x97b8 0xe75f 0xf77e 0xc71d 0xd73c "
   append crc_table "0x26d3 0x36f2 0x0691 0x16b0 0x6657 0x7676 0x4615 0x5634 "
   append crc_table "0xd94c 0xc96d 0xf90e 0xe92f 0x99c8 0x89e9 0xb98a 0xa9ab "
   append crc_table "0x5844 0x4865 0x7806 0x6827 0x18c0 0x08e1 0x3882 0x28a3 "
   append crc_table "0xcb7d 0xdb5c 0xeb3f 0xfb1e 0x8bf9 0x9bd8 0xabbb 0xbb9a "
   append crc_table "0x4a75 0x5a54 0x6a37 0x7a16 0x0af1 0x1ad0 0x2ab3 0x3a92 "
   append crc_table "0xfd2e 0xed0f 0xdd6c 0xcd4d 0xbdaa 0xad8b 0x9de8 0x8dc9 "
   append crc_table "0x7c26 0x6c07 0x5c64 0x4c45 0x3ca2 0x2c83 0x1ce0 0x0cc1 "
   append crc_table "0xef1f 0xff3e 0xcf5d 0xdf7c 0xaf9b 0xbfba 0x8fd9 0x9ff8 "
   append crc_table "0x6e17 0x7e36 0x4e55 0x5e74 0x2e93 0x3eb2 0x0ed1 0x1ef0 "
   set oldcrc_dec 0
   foreach hex [lrange $hexa 0 end-2] {
      # console::affiche_resultat "--------------------------------\n"
      set oldcrc_hexa [meteosensor_convert_base $oldcrc_dec 10 16]
      set nzero [expr 4-[string length $oldcrc_hexa]]
      set oldcrc_hexa 0x[string repeat 0 $nzero]${oldcrc_hexa}
      # console::affiche_resultat "oldcrc_hexa = $oldcrc_hexa\n"
      set oldcrchi_hexa 0x[string range $oldcrc_hexa 2 3]
      set databyte_hexa 0x${hex}
      set tableindex [expr $oldcrchi_hexa ^ $databyte_hexa]
      # console::affiche_resultat "tableindex = $oldcrchi_hexa ^ $databyte_hexa = 0x[meteosensor_convert_base $tableindex 10 16]\n"
      set tablevalue [lindex $crc_table $tableindex]
      # console::affiche_resultat "tablevalue = $tablevalue\n"
      set oldcrclo_hexa 0x[string range $oldcrc_hexa 4 5]00
      set newcrc [expr $oldcrclo_hexa ^ $tablevalue]
      # console::affiche_resultat "newcrc = $oldcrclo_hexa ^ $tablevalue = 0x[meteosensor_convert_base $newcrc 10 16]\n"
      set oldcrc_dec $newcrc
   }
   set computed_crc_hexa [meteosensor_convert_base $newcrc 10 16]
   set nzero [expr 4-[string length $computed_crc_hexa]]
   set computed_crc_hexa 0x[string repeat 0 $nzero]${computed_crc_hexa}
   set received_crc_hexa 0x[lindex $hexa 97][lindex $hexa 98]
   #puts "received_crc_hexa = $received_crc_hexa computed_crc_hexa = $computed_crc_hexa"
   if {$computed_crc_hexa!=$received_crc_hexa} {
      error "Problem communication with meteo station (Final CRC = $received_crc_hexa instead of $computed_crc_hexa). <$hexa>"
   }
   # --- pressure (hPa)
   set val1 [meteosensor_convert_base [lindex $hexa 7] 16 10]
   set val2 [meteosensor_convert_base [lindex $hexa 8] 16 10]
   set val [expr 256*$val2+$val1]
   set val [expr $val/1000.*25.4/760*1013.25]
   set pression $val

   # --- inside temp (degC)
   set val1 [meteosensor_convert_base [lindex $hexa 9] 16 10]
   set val2 [meteosensor_convert_base [lindex $hexa 10] 16 10]
   set val [expr 256*$val2+$val1]
   set val [expr ($val/10.-32.)*5./9.]
   set tempint $val

   # --- inside humidity (percent)
   set val [meteosensor_convert_base [lindex $hexa 11] 16 10]
   set humint $val

   # --- outside temp (degC)
   set val1 [meteosensor_convert_base [lindex $hexa 12] 16 10]
   set val2 [meteosensor_convert_base [lindex $hexa 13] 16 10]
   set val [expr 256*$val2+$val1]
   set val [expr ($val/10.-32.)*5./9.]
   set tempext $val

   # --- wind speed (m/s)
   set val [meteosensor_convert_base [lindex $hexa 14] 16 10]
   set val [expr $val*1609/3600.]
   set vitvent $val

   # --- wind direction (degC) 90=East 360=North
   set val1 [meteosensor_convert_base [lindex $hexa 16] 16 10]
   set val2 [meteosensor_convert_base [lindex $hexa 17] 16 10]
   set val [expr 256*$val2+$val1]
   set dirvent $val

   # --- outside humidity (percent)
   set val [meteosensor_convert_base [lindex $hexa 33] 16 10]
   set humext $val

   # --- rain rate (mm/h)
   set val1 [meteosensor_convert_base [lindex $hexa 41] 16 10]
   set val2 [meteosensor_convert_base [lindex $hexa 42] 16 10]
   set val [expr 256*$val2+$val1]
   # - 256 = 2.56 inch/hour
   set val [expr $val/100./2.54*10]
   set rainrate $val

   set er [catch {
      set dewtemp [expr pow($humext/100.,1./8.)*(112.+(0.9*$tempext))+(0.1*$tempext)-112.]
      set dirvent [expr $dirvent+180]
      if {$dirvent>360} {
         set dirvent [expr $dirvent-360]
      }
      if {$dirvent<22.5} {
         set pcard "N"
      } elseif { $dirvent< 67.5} {
         set pcard "NE"
      } elseif { $dirvent<112.5} {
         set pcard "E"
      } elseif { $dirvent<157.5} {
         set pcard "SE"
      } elseif { $dirvent<202.5} {
         set pcard "S"
      } elseif { $dirvent<247.5} {
         set pcard "SW"
      } elseif { $dirvent<292.5} {
         set pcard "W"
      } elseif { $dirvent<337.5} {
         set pcard "NW"
      } else {
         set pcard "N"
      }
      #set dirvent [expr $dirvent+180]
      #if {$dirvent>360} {
      #   set dirvent [expr $dirvent-360]
      #}
   } ms ]
   if {$er==1} {
      error "Bad read ($ms)"
   }
   set resultat ""
   set er [catch {
      set date [mc_date2iso8601 now]
      lappend resultat [list StationTime $date ISO8601 "Date of the last measurement"]
      lappend resultat [list OutsideTemp [format %.1f $tempext] Celsius ""]
      lappend resultat [list InsideTemp [format %.1f $tempint] Celsius ""]
      lappend resultat [list OutsideHumidity [format %.1f $humext] Percent ""]
      lappend resultat [list InsideHumidity [format %.1f $humint] Percent ""]
      lappend resultat [list Barometer [format %.1f $pression] mbar ""]
      lappend resultat [list RainRate [format %.1f $rainrate] "mm/h" ""]
      lappend resultat [list WindSpeed [format %.2f $vitvent] m/s ""]
      lappend resultat [list WindDir [format %.1f $dirvent] deg "N=0, E=90"]
      lappend resultat [list WindDirCardinal $pcard text "Cadinal symbol of wind direction"]
      lappend resultat [list DewPt [format %.1f $dewtemp] Celsius "Dew point"]
   } ms ]
   if {$er==1} {
      error "Bad date ($ms)"
   }
   return $resultat
}

# ===========================================================================
# ===========================================================================
# ====== Boltwood Cloud Sensor driven by Clarity.exe
# ===========================================================================
# ===========================================================================
# Install the software Clarity.exe and configure it to generate a text file
# filename examples:
# C:/Program Files/BoltwoodSystems/Clarity/Clarity.exe
# C:/Program Files (x86)/Boltwood Systems/Clarity II/ClarityII.exe
# -------------------------------------
proc boltwood_open { filename name} {
   global audace
   set process_name [file tail $filename]
   set path [file dirname $filename]
   if {($::tcl_platform(os) != "Linux")} {
      package require twapi
      set res [twapi::get_process_ids -glob -name "$process_name"]
      set msg "$res"
      if {[llength $res]==0} {
         after 100
         set priority normal
         set texte "eval \{package require twapi ;  set path \"${path}\" ; set res \[twapi::create_process \"\${path}/$process_name\" -startdir \"\${path}\" -detached 1 -showwindow normal -priority $priority \]\}"
         set err [catch {eval $texte} msg]
      }
      set audace(meteosensor,private,$name,clarity_version) 1
      if {$process_name=="ClarityII.exe"} {
         set audace(meteosensor,private,$name,clarity_version) 2
      }
   } else {
      set audace(meteosensor,private,$name,clarity_version) 2
      set msg ""
   }
   return $msg
}

proc boltwood_read { filename name } {
   global audace
   set err [catch {file copy -force -- "$filename" cloudsensor.txt} msg]
   if {$err==1} {
      error $msg
   }
   set err [catch {
      set f [open cloudsensor.txt r]
      set datas [read $f]
      close $f
   } msg ]
   if {$err==0} {
      if {$audace(meteosensor,private,$name,clarity_version)==1} {
         # 2008-10-11 10:30:15 C  -22.6  23.4  30.4   0 0 00004 039732.43767 1
         # set datas {2008-10-14 20:30:30 C  -19.1  12.2  16.1   3 0 00004 039735.85451 2}
         #gren_info "[mc_date2iso8601 now] $thisproc : datas=$datas"
         set textes ""
         set texte "CloudStationTime [lindex $datas 0]T[lindex $datas 1] ISO8601 \"Date of the last measurement\""
         lappend textes $texte
         set texte "CloudSkyTemp [lindex $datas 3] Celsius \"\""
         lappend textes $texte
         set texte "CloudInsideTemp [lindex $datas 4] Celsius \"\""
         lappend textes $texte
         set texte "CloudOutsideTemp [lindex $datas 5] Celsius \"\""
         lappend textes $texte
         set texte "Heater [lindex $datas 6] percent \"\""
         lappend textes $texte
         if {[lindex $datas 7]==0} {
            set texte "CloudWetFlag Wet text \"A word that describes water conditions\""
         } else {
            set texte "CloudWetFlag Dry text \"A word that describes water conditions\""
         }
         lappend textes $texte
         set res [string trimleft [lindex $datas 8] 0]
         if {$res==""} {
            set res 0
         }
         set texte "CloudSinceValid $res logical \"=1 if data are valid\""
         lappend textes $texte
         set skycond [lindex $datas 10]
         if {$skycond==0} {
            set texte "CloudSkyCondition Unknown text \"A word that describes sky conditions\""
         } elseif {$skycond==1} {
            set texte "CloudSkyCondition Clear text \"A word that describes sky conditions\""
         } elseif {$skycond==2} {
            set texte "CloudSkyCondition Cloudy text \"A word that describes sky conditions\""
         } elseif {$skycond==3} {
            set texte "CloudSkyCondition VeryCloudy text \"A word that describes sky conditions\""
         } elseif {$skycond==4} {
            set texte "CloudSkyCondition Rain text \"A word that describes sky conditions\""
         }
         lappend textes $texte
         set msg $textes
         set err 0
      } else {
         if {([llength $datas]>8)} {
            #                     0           1 2 3    4      5      6      7     8    9     0 1 2     3      4       5 6 7 8 9
            #            2017-04-12 21:46:29.33 C K   -7.8   25.2   33.1    3.5  81   21.7   0 0 0 00002 042837.90728 3 1 1 3 1
            #            2017-06-29 11:22:58,10 C m  -10,5   18,9   26,2    5,1  50    8,2   0 0 0 00002 042915,47428 2 2 1 3 1
            # set datas {2017-04-12 21:46:29.33 C K   -7.8   25.2   33.1    3.5  81   21.7   0 0 0 00002 042837.90728 3 1 1 3 1}
            set datas [regsub -all , $datas .]
            #gren_info "[mc_date2iso8601 now] $thisproc : datas=<$datas>"
            set textes ""
            set texte "CloudStationTime [lindex $datas 0]T[lindex $datas 1]"
            lappend textes $texte
            set texte "CloudSkyTemp [lindex $datas 4] Celsius \"\""
            lappend textes $texte
            set texte "CloudAmbiantTemp [lindex $datas 5] Celsius \"\""
            lappend textes $texte
            set texte "CloudHeater [lindex $datas 6] percent"
            lappend textes $texte
            set vel [lindex $datas 7]
            if {[lindex $datas 3]=="K"} {
               set vel [format %.2f [expr $vel/3.6]]
            }
            set texte "CloudWind $vel m/s \"\""
            lappend textes $texte
            set texte "CloudHumidity [lindex $datas 8] percent \"\""
            lappend textes $texte
            set texte "CloudDew [lindex $datas 9] Celsius \"\""
            lappend textes $texte
            set texte "CloudRainFlag [lindex $datas 11] int \"rain flag, =0 for dry, =1 for rain in the last minute, =2 for rain right now\""
            lappend textes $texte
            set texte "CloudWetFlag [lindex $datas 12] int \"wet flag, =0 for dry, =1 for wet in the last minute, =2 for wet right now\""
            lappend textes $texte
            set texte "CloudRainCond [lindex $datas 17] int \"Dry=1 Wet=2 Rain=3\""
            lappend textes $texte
            set res [string trimleft [lindex $datas 13] 0]
            if {$res==""} {
               set res 0
            }
            set texte "CloudSinceValid $res \"=1 if data are valid\""
            lappend textes $texte
            set skycond [lindex $datas 15]
            if {$skycond==0} {
               set texte "CloudSkyCondition Unknown \"A word that describes sky conditions\""
            } elseif {$skycond==1} {
               set texte "CloudSkyCondition Clear \"A word that describes sky conditions\""
            } elseif {$skycond==2} {
               set texte "CloudSkyCondition Cloudy \"A word that describes sky conditions\""
            } elseif {$skycond==3} {
               set texte "CloudSkyCondition VeryCloudy \"A word that describes sky conditions\""
            } elseif {$skycond==4} {
               set texte "CloudSkyCondition Rain \"A word that describes sky conditions\""
            }
            lappend textes $texte
            set msg $textes
            set err 0
         } else {
            set err 1
            set textes ""
         }
      }
   }
   return $textes
}

# ===========================================================================
# ===========================================================================
# ====== Boltwood Cloud Sensor direct connection
# ===========================================================================
# ===========================================================================

proc boltwood_direct_putread { channel hexas } {
   set err [catch {
      set msg [meteosensor_hexa2ascii $hexas]
      puts -nonewline $channel $msg
      flush $channel
      set hexa_outs ""
      set k 0
      set sortie 0
      while {$sortie==0} {
         incr k
         if {$k>50} {
            error $hexa_outs
         }
         after 100
         set err2 [catch {
            set response [read $channel]
         } msgerr2]
         if {$err2==1} {
            continue
         }
         set hexa_out [meteosensor_ascii2hexa $response]
         append hexa_outs $hexa_out
         set hexa_last [lindex $hexa_out end]
         if {$hexa_last=="0A"} {
            set sortie 1
         }
      }
   } msgerr]
   if {$err==1} {
      return "ERREUR $msgerr\n"
   }
   return $hexa_outs
}

proc boltwood_direct_read {f name} {
   global audace
   set version $audace(meteosensor,private,$name,protocol_version)
   # console::affiche_resultat "ETAPE 1 version=$version name=$name\n"
   if {$version==1} {
      # version 1
      # console::affiche_resultat "ETAPE 2\n"
      set hexa_outs [boltwood_direct_read_v1 $f]
      # console::affiche_resultat "ETAPE 3 hexa_outs=$hexa_outs\n"
      set key [lindex $hexa_outs 0]
      # console::affiche_resultat "ETAPE 3b key=$key\n"
      if {$key=="ERREUR"} {
         error "Meteo problem ($hexa_outs)"
      }
      # console::affiche_resultat "ETAPE 3c\n"
      set res [boltwood_direct_decode1 $hexa_outs]
      # console::affiche_resultat "ETAPE 4\n"
      lassign $res firmwr skydeg sendeg ambdeg heaper frame
      set CloudWetFlag 0
      set CloudRainCond 1
      # ------------------------------------------------------
      set resultat ""
      set er [catch {
         set res [mc_date2ymdhms now]
         set month [lindex $res 1]
         set day [lindex $res 2]
         set year [lindex $res 0]
         set hour [lindex $res 3]
         set min [lindex $res 4]
         set sec [expr int(floor([lindex $res 5]))]
         set res "$month $day $year $hour $min $sec"
         set date "[format %04d $year]-[format %02d $month]-[format %02d $day]T[format %02d $hour]:[format %02d $min]:[format %02d $sec]"
         lappend resultat [list CloudStationTime $date ISO8601 "Date of the last measurement"]
         lappend resultat [list CloudSkyTemp [format %.1f $skydeg] Celsius ""]
         lappend resultat [list CloudAmbiantTemp [format %.1f $ambdeg] Celsius ""]
         lappend resultat [list CloudHeater [format %.1f $heaper] percent ""]
         lappend resultat [list CloudWetFlag $CloudWetFlag int "Dry=0 Wet or Rain=1"]
         set SkyAmbTemp $skydeg
         if {$SkyAmbTemp<=-998} {
            set CloudRainCond 3
         }
         lappend resultat [list CloudRainCond $CloudRainCond int "Dry=1 Wet=2 Rain=3"]
         set Clear_Cloudy $audace(meteosensor,private,$name,Clear_Cloudy)
         set Cloudy_VC $audace(meteosensor,private,$name,Cloudy_VC)
         if {$SkyAmbTemp>=$Cloudy_VC} {
            lappend resultat [list CloudSkyCondition VeryCloudy string "A word that describes sky conditions"]
         } elseif {$SkyAmbTemp>=$Clear_Cloudy} {
            lappend resultat [list CloudSkyCondition Cloudy string "A word that describes sky conditions"]
         } elseif {$SkyAmbTemp>-998} {
            lappend resultat [list CloudSkyCondition Clear string "A word that describes sky conditions"]
         } else {
            lappend resultat [list CloudSkyCondition VeryCloudy string "A word that describes sky conditions"]
         }
         set err 0
      } ms ]
      if {$er==1} {
         error "Meteo problem ($ms)"
      }
      #gren_info "[mc_date2iso8601 now] $thisproc : resultat=$resultat"
      return $resultat
   } else {
      # version 2
      set tempo $audace(meteosensor,private,$name,tempo)
      # --- Then now only MD are provided
      set t0 [clock seconds]
      set timeout_sec 10
      set sortie 0
      while {$sortie==0} {
         set dt [expr [clock seconds]-$t0]
         if {$dt>$timeout_sec} {
            break
         }
         # --- Read (MD) D=Data
         set hexas {02 61 0A 01}
         set hexa_outs [boltwood_direct_putread $f $hexas]
         set ack [lindex $hexa_outs 0]
         if {$ack=="02"} {
            set msg [string range [meteosensor_hexa2ascii $hexa_outs] 1 end]
            set key [lindex $msg 0]
            if {$key!="MD"} {
               continue
            }
            #                                   1                                              2                                                 3
            #    1 2 3 4 5 6    7     8     9   0 1  2   3      4     5   6   7  8     9       0     1     2   3   4    5    6    7    8    9    0   1    2  3     4        5
            # sec
            # MD 0 1 1 1 1 0  -17.0  12.2   2.5 N N  82   9.1  19.8   0 -99.9 0 23.9  19.9     2   -59   -66 000 045 0129 0579 0940 1023 0276 0282   0.0 099 11827 1 0252A5E2
            # pluie
            # MD 0 0 0 3 4 1 -998.0  11.9  -2.0 w r  81   8.7  27.3   0 -99.9 0 23.9  20.5     2    21   -66 000 045 0161 0494 0940 1023 0273 0280   0.0 098 11733 1 025032BC
            set CloudRainCond [lindex $msg  4] ; # Dry=1 Wet=2 Rain=3
            set SkyAmbTemp    [lindex $msg  7] ; # -998 if rain
            set AmbientTemp   [lindex $msg  8]
            set Wind          [lindex $msg  9] ; # kph
            set Humidity      [lindex $msg 12]
            set DewTemp       [lindex $msg 13]
            set CloudHeater   [lindex $msg 14]
            if {$CloudRainCond==1} {
               set CloudWetFlag 0
            } else {
               set CloudWetFlag 1
            }
            # ------------------------------------------------------
            set resultat ""
            set er [catch {
               set res [mc_date2ymdhms now]
               set month [lindex $res 1]
               set day [lindex $res 2]
               set year [lindex $res 0]
               set hour [lindex $res 3]
               set min [lindex $res 4]
               set sec [expr int(floor([lindex $res 5]))]
               set res "$month $day $year $hour $min $sec"
               set date "[format %04d $year]-[format %02d $month]-[format %02d $day]T[format %02d $hour]:[format %02d $min]:[format %02d $sec]"
               lappend resultat [list CloudStationTime $date ISO8601 "Date of the last measurement"]
               lappend resultat [list CloudSkyTemp [format %.1f $SkyAmbTemp] Celsius ""]
               lappend resultat [list CloudAmbiantTemp [format %.1f $AmbientTemp] Celsius ""]
               lappend resultat [list CloudHeater [format %.1f $CloudHeater] percent ""]
               lappend resultat [list CloudWind [format %.1f $Wind] m/s ""]
               lappend resultat [list CloudHumidity [format %.1f $Humidity] percent ""]
               lappend resultat [list CloudDew [format %.1f $DewTemp] Celsius "Dew point"]
               lappend resultat [list CloudWetFlag $CloudWetFlag int "Dry=0 Wet or Rain=1"]
               if {$SkyAmbTemp<=-998} {
                  set CloudRainCond 3
               }
               lappend resultat [list CloudRainCond $CloudRainCond int "Dry=1 Wet=2 Rain=3"]
               set Clear_Cloudy $audace(meteosensor,private,$name,Clear_Cloudy)
               set Cloudy_VC $audace(meteosensor,private,$name,Cloudy_VC)
               if {$SkyAmbTemp>=$Cloudy_VC} {
                  lappend resultat [list CloudSkyCondition VeryCloudy string "A word that describes sky conditions"]
               } elseif {$SkyAmbTemp>=$Clear_Cloudy} {
                  lappend resultat [list CloudSkyCondition Cloudy string "A word that describes sky conditions"]
               } elseif {$SkyAmbTemp>-998} {
                  lappend resultat [list CloudSkyCondition Clear string "A word that describes sky conditions"]
               } else {
                  lappend resultat [list CloudSkyCondition VeryCloudy string "A word that describes sky conditions"]
               }
               set err 0
            } ms ]
            if {$er==1} {
               error "Meteo problem ($ms)"
            }
            #gren_info "[mc_date2iso8601 now] $thisproc : resultat=$resultat"
            return $resultat
         }
         after $tempo
      }
   }
   return "ERROR timeout $timeout_sec sec.\n"
}

proc boltwood_direct_read_v1 { channel } {
   set err [catch {
      set err2 [catch {
         set response [read $channel]
      } msgerr2]
      flush $channel
      set hexa_outs ""
      set k 0
      set sortie 0
      while {$sortie==0} {
         after 100
         incr k 100
         if {$k>10000} {
            error $hexa_outs
         }
         set err2 [catch {
            set response [read $channel]
         } msgerr2]
         # console::affiche_resultat "ETAPE 10 k=$k response=$response\n"
         if {$err2==1} {
            continue
         }
         set hexa_out [meteosensor_ascii2hexa $response]
         append hexa_outs $hexa_out
         set k1 [string first 0A $hexa_outs]
         set k2 [string  last 0A $hexa_outs]
         # console::affiche_resultat "ETAPE 15 k1=$k1 k2=$k2\n"
         if {$k2>0} {
            if {$k2>$k1} {
               set hexa_outs [string range $hexa_outs [expr $k1+3] end]
               set sortie 1
            }
         }
      }
   } msgerr]
   if {$err==1} {
      return "ERREUR $msgerr\n"
   }
   return $hexa_outs
}

proc boltwood_direct_decode1 { hexa_outs } {
   set texte ""
   foreach hexa_out $hexa_outs {
      set c [format %c 0x$hexa_out]
      append texte "$c"
   }
   set firmwr [string range $texte  0  0].[string range $texte  1  2]
   set skyadu [string trimleft [string range $texte  3  5] 0] ; if {$skyadu==""} { set skyadu 0 }
   set ambadu [string trimleft [string range $texte  9 11] 0] ; if {$ambadu==""} { set senadu 0 }
   set senadu [string trimleft [string range $texte  6  8] 0] ; if {$senadu==""} { set ambadu 0 }
   set heaadu [string trimleft [string range $texte 16 17] 0] ; if {$heaadu==""} { set heaadu 0 }
   # DegC = -0.155000*adu + 5.000000
   # DegC = -8.657102e-007*adu^3 + 9.579509e-004*adu^2 + -4.464389e-001*adu + 91.625789
   # DegC = -2.310704e-007*adu^3 + 3.548579e-004*adu^2 + -2.688307e-001*adu + 99.244667
   # Percent = 0.668427*adu + -0.187008
   set skydeg [expr -0.155000*$skyadu + 5.000000]
   set ambdeg [expr -8.657102e-007*$ambadu*$ambadu*$ambadu + 9.579509e-004*$ambadu*$ambadu + -4.464389e-001*$ambadu + 91.625789]
   set sendeg [expr -2.310704e-007*$senadu*$senadu*$senadu + 3.548579e-004*$senadu*$senadu + -2.688307e-001*$senadu + 99.244667]
   set heaper [expr 0.668427*$heaadu + -0.187008]
   set skydeg [format %.2f $skydeg]
   set sendeg [format %.2f $sendeg]
   set ambdeg [format %.2f $ambdeg]
   set heaper [format %.0f $heaper]
   set res [list $firmwr $skydeg $sendeg $ambdeg $heaper $texte]
}

# ===========================================================================
# ===========================================================================
# ====== Lacrosse driver by fetch3600
# ===========================================================================
# ===========================================================================
# Install the software fetch3600 in the bin folder of AudeLA

proc fetch3600_open { port } {
   global audace
   package require twapi
   set ext .exe
   if {($::tcl_platform(os) != "Linux")} {
      # --- We kill the instance of the software HeavyWeather if it exists
      set pids [twapi::get_process_ids]
      set exe "HeavyWeather.exe"
      foreach pid $pids {
         set res [twapi::get_process_info $pid -name]
         set name [lindex $res 1 end]
         set k [lsearch -exact "${exe}" $name]
         if {$k>=0} {
            twapi::end_process $pid -force
            ::console::affiche_resultat "[mc_date2iso8601 now] : Delete $exe (PID=$pid)"
         }
      }
   }
   # === On rempli la liste ros(gardien,private,val_status)
   # --- meteo
   if { $::tcl_platform(os) == "Linux" } {
      set ext ""
   }
   #
   set textes ""
   append textes "# open3600.conf\n"
   append textes "#\n"
   append textes "# Configuration files for open3600 weather station tools\n"
   append textes "#\n"
   append textes "# Default locations in which the programs will search for this file: \n"
   append textes "# Programs search in this sequence:\n"
   append textes "#  1. Path to config file including filename given as parameter (not supported by all tools)\n"
   append textes "#  2. ./open3600.conf (current working directory)\n"
   append textes "#  3. /usr/local/etc/open3600.conf (typical Linux location)\n"
   append textes "#  4. /etc/open3600.conf (typical Linux location)\n"
   append textes "#\n"
   append textes "# All names are case sensitive!!!\n"
   append textes "\n"
   append textes "\n"
   append textes "# Set to your serial port and time zone\n"
   append textes "# For Windows use COM1, COM2, COM2 etc\n"
   append textes "# For Linux use /dev/ttyS0, /dev/ttyS1 etc\n"
   append textes "\n"
   append textes "SERIAL_DEVICE                 $port        # /dev/ttyS0, /dev/ttyS1, COM1, COM2, etc\n"
   append textes "TIMEZONE                      1           # Hours Relative to UTC. East is positive, west is negative\n"
   append textes "\n"
   append textes "\n"
   append textes "# Units of measure (set them to your preference)\n"
   append textes "# The units of measure are ignored by wu3600 and cw3600 because both requires specific units\n"
   append textes "\n"
   append textes "WIND_SPEED                    km/h        # select MPH (miles/hour), m/s or km/h\n"
   append textes "TEMPERATURE                   C           # Select C or F\n"
   append textes "RAIN                          mm          # Select mm or IN\n"
   append textes "PRESSURE                      hPa         # Select hPa, mb or INHG\n"
   append textes "\n"
   append textes "# Debug level\n"
   append textes "LOG_LEVEL                     1           # 0 - no debug output, 5 - most debug output\n"
   append textes " \n"
   append textes "#### Citizens Weather variables (used only by cw3600)\n"
   append textes "# Format for latitude is\n"
   append textes "# \[2 digit degrees\]\[2 digit minutes\].\[2 decimals minutes - NOT seconds\]\[N for north or S for south\]\n"
   append textes "# Format for longitude is\n"
   append textes "# \[3 digit degrees\]\[2 digit minutes\].\[2 decimals minutes - NOT seconds\]\[E for east or W for west\]\n"
   append textes "# Use leading zeros to get the format ####.##N (lat) and #####.##E (long)\n"
   append textes "\n"
   append textes "#CITIZEN_WEATHER_ID            CW0000      # CW0000 should be replaced by HAM call or actual CW number\n"
   append textes "#CITIZEN_WEATHER_LATITUDE      5540.12N    # DDMM.mmN or S - example 55 deg, 40.23 minutes north\n"
   append textes "#CITIZEN_WEATHER_LONGITUDE     01224.60E   # DDDMM.mmE or W - example 12 deg, 24.60 minutes east\n"
   append textes "\n"
   append textes "#APRS_SERVER   aprswest.net         23     # These are the APRS servers and ports for\n"
   append textes "#APRS_SERVER   indiana.aprs2.net    23     # Citizens Weather reporting.\n"
   append textes "#APRS_SERVER   newengland.aprs2.net 23     # They they are tried in the entered order\n"
   append textes "#APRS_SERVER   aprsca.net           23     # you may enter up to 5 alternate servers\n"
   append textes "\n"
   append textes "\n"
   append textes "#### WEATHER UNDERGROUND variables (used only by wu3600)\n"
   append textes "\n"
   append textes "#WEATHER_UNDERGROUND_ID        WUID        # ID received from Weather Underground\n"
   append textes "#WEATHER_UNDERGROUND_PASSWORD  WUPASSWORD  # Password for Weather Underground\n"
   append textes "\n"
   append textes "\n"
   append textes "### MYSQL Settings (only used by mysql3600)\n"
   append textes "\n"
   append textes "MYSQL_HOST              localhost         # Localhost or IP address/host name\n"
   append textes "MYSQL_USERNAME          open3600          # Name of the MySQL user that has access to the database\n"
   append textes "MYSQL_PASSWORD          mysql3600         # Password for the MySQL user\n"
   append textes "MYSQL_DATABASE          open3600          # Named of your database\n"
   append textes "MYSQL_PORT              0                 # TCP/IP Port number. Zero means default\n"
   append textes "\n"
   append textes "#PGSQL_CONNECT    hostaddr='127.0.0.1'dbname='open3600'user='postgres'password='sql' # Connection string\n"
   append textes "#PGSQL_TABLE      weather           # Table name\n"
   append textes "#PGSQL_STATION    open3600          # Unique station id\n"
   append textes "   \n"
   set f [open $audace(rep_install)/open3600.conf w]
   puts -nonewline $f $textes
   close $f
   return ""
}

proc fetch3600_read { } {
   global audace
   package require twapi
   set ext .exe
   # --- We kill the current instance of the software fetch if needed
   if {($::tcl_platform(os) != "Linux")} {
      set pids [twapi::get_process_ids]
      set exe "fetch3600${ext}"
      foreach pid $pids {
         set res [twapi::get_process_info $pid -name]
         set name [lindex $res 1 end]
         set k [lsearch -exact "${exe}" $name]
         if {$k>=0} {
            twapi::end_process $pid -force
            ::console::affiche_resultat "[mc_date2iso8601 now] : Delete $exe (PID=$pid)"
         }
      }
   }
   #
   set exe $audace(rep_install)/bin/fetch3600${ext}
   set err [catch {exec $exe} msg]
   set msg1 [lindex [split $msg "\n"] 1]
  ### ::console::disp "msg = |$msg1| \n"
  ### ::console::disp "err = |$err| \n"
   if {$msg1=="Unable to open serial device"} {
      ::console::disp "Error: $msg1 \n"
      return ""
   }
   set keyword [lindex $msg 0]
   if {$keyword=="Date"} {
      set err 0
   }
   if {($err==0)&&($msg!="")} {
      set lignes [split $msg \n]
      set textes ""
      set liste $ros(gardien,private,desc_status)
      foreach desc_status $liste {
         set meteo [lindex $desc_status 1]
         if {$meteo!="meteo"} {
            continue
         }
         set desc [lindex $desc_status 0]
         foreach ligne $lignes {
            set keyword [lindex $ligne 0]
            set value [lindex $ligne 1]
            if {$keyword=="Tendency"} {
               set ligne [lrange $ligne 1 end]
               set keyword [lindex $ligne 0]
               set value [lindex $ligne 1]
            }
            #gren_info "key=$keyword value=$value"
            if {($keyword=="Date")&&($desc=="StationTime")} {
               regsub -all -- "-" "${value}" " " date
               set j [string trimleft [lindex $date 0] 0]
               set m [string trimleft [lindex $date 1] 0]
               set a [lindex $date 2]
               if {$m=="Jan"} { set mm 1 }
               if {$m=="Feb"} { set mm 2 }
               if {$m=="Mar"} { set mm 3 }
               if {$m=="Apr"} { set mm 4 }
               if {$m=="May"} { set mm 5 }
               if {$m=="Jun"} { set mm 6 }
               if {$m=="Jul"} { set mm 7 }
               if {$m=="Aug"} { set mm 8 }
               if {$m=="Sep"} { set mm 9 }
               if {$m=="Oct"} { set mm 10 }
               if {$m=="Nov"} { set mm 11 }
               if {$m=="Dec"} { set mm 12 }
               set texte "StationTime [format %04d $a]-[format %02d $mm]-[format %02d $j]"
               continue
            }
            if {($keyword=="Time")&&($desc=="StationTime")} {
               append texte "T${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="Ti")&&($desc=="InsideTemp")} {
               set texte "InsideTemp ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="DTimin")&&($desc=="InsideTemp")} {
               if {$value=="00-00-2000"} {
                  set n [llength $textes]
                  set newkey [lindex [lindex $textes [expr $n-1]] 0]
                  set textes [lrange $textes 0 [expr $n-2]]
                  set texte "$newkey -1"
                  lappend textes $texte
                  break
               }
            }
            if {($keyword=="To")&&($desc=="OutsideTemp")} {
               set texte "OutsideTemp ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="DTomin")&&($desc=="OutsideTemp")} {
               if {$value=="00-00-2000"} {
                  set n [llength $textes]
                  set newkey [lindex [lindex $textes [expr $n-1]] 0]
                  set textes [lrange $textes 0 [expr $n-2]]
                  set texte "$newkey -1"
                  lappend textes $texte
                  break
               }
            }
            if {($keyword=="RHi")&&($desc=="InsideHumidity")} {
               set texte "InsideHumidity ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="DRHimin")&&($desc=="InsideHumidity")} {
               if {$value=="00-00-2000"} {
                  set n [llength $textes]
                  set newkey [lindex [lindex $textes [expr $n-1]] 0]
                  set textes [lrange $textes 0 [expr $n-2]]
                  set texte "$newkey -1"
                  lappend textes $texte
                  break
               }
            }
            if {($keyword=="RHo")&&($desc=="OutsideHumidity")} {
               set errv [catch {expr -1*$value} msgv ]
               if {$errv==1} {
                  set value 50 ; # for tests
               } else {
                  if {($value<0)||($value>100)} {
                     set value 50 ; # for tests
                  }
               }
               set texte "OutsideHumidity ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="DRHomin")&&($desc=="OutsideHumidity")} {
               if {$value=="00-00-2000"} {
                  set n [llength $textes]
                  set newkey [lindex [lindex $textes [expr $n-1]] 0]
                  set textes [lrange $textes 0 [expr $n-2]]
                  set texte "$newkey -1"
                  lappend textes $texte
                  break
               }
            }
            if {($keyword=="WS")&&($desc=="WindSpeed")} {
               # x=[153 256 356] ; y=[1.4 5.0 9.3] ; p=polyfit(x,y,1)
               set errv [catch {expr 0.0389*$value-4.6853} msgv ]
               if {$errv==1} {
                  set value 0 ; # for tests
               } else {
                  set value $msgv
                  if {$value<0} {
                     set value 0
                  }
               }
               set texte "WindSpeed ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="DIRtext")&&(($desc=="WindDir")||($desc=="WindDirCardinal"))} {
               set wind_dir "Unknown"
               if {$value=="N"}   { set wind_dir 0 }
               if {$value=="NNE"} { set wind_dir [expr 360./16*1] }
               if {$value=="NE"}  { set wind_dir [expr 360./16*2] }
               if {$value=="ENE"} { set wind_dir [expr 360./16*3] }
               if {$value=="E"}   { set wind_dir [expr 360./16*4] }
               if {$value=="ESE"} { set wind_dir [expr 360./16*5] }
               if {$value=="SE"}  { set wind_dir [expr 360./16*6] }
               if {$value=="SSE"} { set wind_dir [expr 360./16*7] }
               if {$value=="S"}   { set wind_dir [expr 360./16*8] }
               if {$value=="SSW"} { set wind_dir [expr 360./16*9] }
               if {$value=="SW"}  { set wind_dir [expr 360./16*10] }
               if {$value=="WSW"} { set wind_dir [expr 360./16*11] }
               if {$value=="W"}   { set wind_dir [expr 360./16*12] }
               if {$value=="WNW"} { set wind_dir [expr 360./16*13] }
               if {$value=="NW"}  { set wind_dir [expr 360./16*14] }
               if {$value=="NNW"} { set wind_dir [expr 360./16*15] }
               if {($desc=="WindDir")} {
                  set texte "WindDir $wind_dir"
                  lappend textes $texte
                  break
               }
               if {($desc=="WindDirCardinal")} {
                  set texte "WindDirCardinal ${value}"
                  lappend textes $texte
                  break
               }
            }
            if {($keyword=="RP")&&($desc=="Barometer")} {
               set texte "Barometer ${value}"
               lappend textes $texte
               break
            }
            if {($keyword=="R1h")&&($desc=="RainRate")} {
               set texte "RainRate ${value}"
               lappend textes $texte
               break
            }
         }
      }
      #set value 0
      #set texte "RainRate ${value}"
      #lappend textes $texte
      set msg $textes
      #gren_info "textes=$textes"
      set err 0
   }
   return $msg
}

# ===========================================================================
# ===========================================================================
# ====== Sentinel driven by SkyMonitor.exe
# ===========================================================================
# ===========================================================================
# Install the software SkyMonitor.exe and configure it to generate a text file

proc sentinel_skymonitor_open { } {
   global env
   package require twapi
   set pgm_tolaunch "SkyMonitor.exe"
   set folder_tolaunch [ file join Shelyak Sentinel ]
   set pidfore 0
   set pids [twapi::get_process_ids]
   foreach pid $pids {
      catch {set name [twapi::get_process_name $pid]}
      if {$name==$pgm_tolaunch} {
         set pidfore $pid
         ::console::disp "$pgm_tolaunch already launched.\n"
         return ""
      }
   }
   if {$pidfore==0} {
      if {[catch {set env_program_files $env(ProgramFiles)}]==1} {
         set env_program_files [ file join C: "Program Files" ]
      }
      set fic [file normalize [ file join ${env_program_files} ${folder_tolaunch} ${pgm_tolaunch} ]]
      if {[file exists $fic]==1} {
         twapi::create_process $fic
         after 2000
         ::console::disp "$pgm_tolaunch launched.\n"
         return ""
      } else {
         ::console::disp "$pgm_tolaunch not found.\n"
      }
   }
}

proc sentinel_skymonitor_gain { {value ""} } {
   global audace
   if {[info exists audace(meteosensor_sentinel_skymonitor,gain)]==0} {
      set audace(meteosensor_sentinel_skymonitor,gain) 762
   }
   if {$value!=""} {
      set audace(meteosensor_sentinel_skymonitor,gain) $value
   }
   return $audace(meteosensor_sentinel_skymonitor,gain)
}

proc sentinel_skymonitor_read { {filename ""} } {
   global audace
   global env
   #if {$filename==""} {
   #   set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
   #   set env_documents [ file normalize $mesDocuments ]
   #   set fic [ file join $env_documents Sentinel Datas infodata.txt ]
   #}
   if {$filename==""} {
      if {[catch {set env_documents $env(HOME)}]==1} {
         set env_documents C:/Users/
      }
      set dossiers [glob -nocomplain [file normalize "$env_documents/*"]]
      foreach dossier $dossiers {
         set k [string first Documents $dossier]
         if {$k>0} {
            break
         }
      }
      if {$k==-1} {
         return ""
      }
      set fic "${dossier}/Sentinel/Datas/infodata.txt"
   } else {
      set fic $filename
   }
   if {[file exists $fic]==0} {
      return ""
   }
   set err [catch {
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
   } msg ]
   set textes ""
   if {$err==0} {
      set y 2000
      set m 1
      set d 1
      set hh 0
      set mm 0
      set ss 0
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set val [lindex $ligne 2]
         if {[string compare $key "DateYear"]==0} { set y $val }
         if {[string compare $key "DateMonth"]==0} { set m $val }
         if {[string compare $key "DateDay"]==0} { set d $val }
         if {[string compare $key "DateHour"]==0} { set hh $val }
         if {[string compare $key "DateMin"]==0} { set mm $val }
         if {[string compare $key "DateSec"]==0} { set ss $val }
      }
      set texte [mc_date2iso8601 [list $y $m $d $hh $mm $ss]]
      lappend textes $texte
      set temp_ext 10
      # Un gain est appliqué à la mesure interne du capteur; ce gain
      # peut être modifié dans l'onglet de configuration; les valeurs
      # typiques sont entre 400 et 800. Si vous sentez que la courbe de
      # mesure des nuages est trop corrélée avec celle de la mesure de
      # température extérieure, vous pouvez baisser la valeur de gain.
      # Si elle est anti-corrélée, vous pouvez l'augmenter.
      set gain [sentinel_skymonitor_gain]
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set kequal [lsearch -exact $ligne =]
         if {$kequal==-1} {
            continue
         }
         set val [lindex $ligne [expr $kequal+1]]
         if {[string compare $key "TempExt"]==0} {
            set temp_ext $val
         }
      }
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set kequal [lsearch -exact $ligne =]
         if {$kequal==-1} {
            continue
         }
         set val [lindex $ligne [expr $kequal+1]]
         set unit [lrange $ligne 1 [expr $kequal-1]]
         regsub -all \\( $unit "" a ; set unit $a
         regsub -all \\) $unit "" a ; set unit $a
         regsub -all C $unit "Celsius" a ; set unit $a
         regsub -all  $unit "degrees" a ; set unit $a
         regsub -all % $unit "percent" a ; set unit $a
         regsub -all %RH $unit "percent" a ; set unit $a
         set texte ""
         if {[string compare $key "TempSkyIR"]==0} {
            set valraw [expr ($val*1000./762)]
            set valcor [format %.2f [expr ($valraw*$gain/1000.-$temp_ext)]]
            set texte "SkyTemp $valcor $unit"
            lappend textes $texte
            if {$valcor<-20} {
               set texte "SkyCover Clear text"
            } elseif {$valcor<-7} {
               set texte "SkyCover Cloudy text"
            } else {
               set texte "SkyCover VeryCloudy text"
            }
            lappend textes $texte
         }
         if {[string compare $key "TempExt"]==0} {
            set texte "OutTemp $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "WinDirection"]==0} {
            set texte "WinDir $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "WindSpeedGust"]==0} {
            set texte "WinSpeed $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "Humidity"]==0} {
            set texte "Humidity $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "RainFall"]==0} {
            if {$val=="No"} {
               set valcor Dry
            } else {
               set valcor Rain
            }
            set texte "RainState $valcor" ; lappend texte $unit
            lappend textes $texte
         }
         set texte "$key $val" ; lappend texte $unit
         lappend textes $texte
      }
      set texte "Gain $gain" ; lappend texte "/1000"
      lappend textes $texte
   }
   return $textes
}

proc sentinel_skymonitor_read_standard { {filename ""} } {
   global audace caption
   global env
   if {$filename==""} {
      set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
      set env_documents [ file normalize $mesDocuments ]
      set fic [ file join $env_documents Sentinel Datas infodata.txt ]
   } else {
      set fic $filename
   }
   if {[file exists $fic]==0} {
      return ""
   }
   set err [catch {
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
   } msg ]
   set textes ""
   if {$err==0} {
      set y 2000
      set m 1
      set d 1
      set hh 0
      set mm 0
      set ss 0
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set val [lindex $ligne 2]
         if {[string compare $key "DateYear"]==0} { set y $val }
         if {[string compare $key "DateMonth"]==0} { set m $val }
         if {[string compare $key "DateDay"]==0} { set d $val }
         if {[string compare $key "DateHour"]==0} { set hh $val }
         if {[string compare $key "DateMin"]==0} { set mm $val }
         if {[string compare $key "DateSec"]==0} { set ss $val }
      }
      set texte [mc_date2iso8601 [list $y $m $d $hh $mm $ss]]
      lappend textes $texte
      set temp_ext 10
      # Un gain est appliqué à la mesure interne du capteur; ce gain
      # peut être modifié dans l'onglet de configuration; les valeurs
      # typiques sont entre 400 et 800. Si vous sentez que la courbe de
      # mesure des nuages est trop corrélée avec celle de la mesure de
      # température extérieure, vous pouvez baisser la valeur de gain.
      # Si elle est anti-corrélée, vous pouvez l'augmenter.
      set gain [sentinel_skymonitor_gain]
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set kequal [lsearch -exact $ligne =]
         if {$kequal==-1} {
            continue
         }
         set val [lindex $ligne [expr $kequal+1]]
         if {[string compare $key "TempExt"]==0} {
            set temp_ext $val
         }
      }
      foreach ligne $lignes {
         set key [lindex $ligne 0]
         set kequal [lsearch -exact $ligne =]
         if {$kequal==-1} {
            continue
         }
         set val [lindex $ligne [expr $kequal+1]]
         set unit [lrange $ligne 1 [expr $kequal-1]]
         regsub -all \\( $unit "" a ; set unit $a
         regsub -all \\) $unit "" a ; set unit $a
         regsub -all C $unit "$caption(meteosensor_tools,celsius)" a ; set unit $a
         regsub -all  $unit "$caption(meteosensor_tools,degres)" a ; set unit $a
         regsub -all % $unit "$caption(meteosensor_tools,pourcent)" a ; set unit $a
         regsub -all %RH $unit "$caption(meteosensor_tools,pourcent)" a ; set unit $a
         set texte ""
         if {[string compare $key "TempSkyIR"]==0} {
            #set valcor [format %.2f [expr ($val*$gain/1000.-$temp_ext)]]
            set valcor [format %.2f [expr ($val-$temp_ext)]]
            set texte "SkyTemp $valcor $unit"
            lappend textes $texte
            if {$valcor<-20} {
               set texte "SkyCover Clear text"
            } elseif {$valcor<-7} {
               set texte "SkyCover Cloudy text"
            } else {
               set texte "SkyCover VeryCloudy text"
            }
            lappend textes $texte
         }
         if {[string compare $key "TempExt"]==0} {
            set texte "OutTemp $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "WinDirection"]==0} {
            set texte "WinDir $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "WindSpeedGust"]==0} {
            set texte "WinSpeed $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "Humidity"]==0} {
            set texte "Humidity $val" ; lappend texte $unit
            lappend textes $texte
         }
         if {[string compare $key "RainFall"]==0} {
            if {$val=="No"} {
               set valcor Dry
            } else {
               set valcor Rain
            }
            set texte "RainState $valcor" ; lappend texte $unit
            lappend textes $texte
         }
         set texte "$key $val" ; lappend texte $unit
         lappend textes $texte
      }
      set texte "Gain $gain" ; lappend texte "/1000"
      lappend textes $texte
   }
   return $textes
}

# ===========================================================================
# ===========================================================================
# ====== Sentinel port com direct (Linux compatible)
# ===========================================================================
# ===========================================================================

proc sentinel_putget { f trame_hexas } {
   set n [llength $trame_hexas]
   set ascii ""
   set checksum 0
   set h ""
   set trame_hexa_in $trame_hexas
   for {set k 0} {$k<$n} {incr k} {
      set hexa [lindex $trame_hexas $k]
      append h "$hexa "
      append ascii [meteosensor_convert_base $hexa 16 ascii]
      set decimal [meteosensor_convert_base $hexa 16 10]
      incr checksum $decimal
   }
   set decimal [expr $checksum%256]
   append ascii [meteosensor_convert_base $decimal 10 ascii]
   set hexa [meteosensor_convert_base $decimal 10 16]
   append h "$hexa"
   #::console::affiche_resultat "ENVOIE <$h>\n"
   puts -nonewline $f "$ascii" ; flush $f
   after 60
   set msg [read $f]
   set n [string length $msg]
   #::console::affiche_resultat "RECOIT $n caractères\n"
   set trame_hexas ""
   set trame_decimals ""
   set checksum 0
   for {set k 0} {$k<$n} {incr k} {
      set ascii [string index $msg $k]
      set hexa [meteosensor_convert_base $ascii ascii 16]
      append trame_hexas "$hexa "
      set decimal [meteosensor_convert_base $ascii ascii 10]
      append trame_decimals "$decimal "
      if {($k>=0)&&($k<=[expr $n-2])} {
         incr checksum $decimal
      }
   }
   set decimal [expr $checksum%256]
   # --- check the integrity of the returned message
   set err 0
   set key [lindex $trame_hexas 0]
   if {$key!="1F"} {
      set err [expr $err+1]
   }
   set ndata [lindex $trame_decimals 1]
   set nlong [llength [lrange $trame_hexas 2 end]]
   if {$ndata!=$nlong} {
      set err [expr $err+2]
   }
   set checksum [lindex $trame_decimals end]
   if {$decimal!=$checksum} {
      set err [expr $err+4]
   }
   if {$err>0} {
      error "Sentinel error. Send $trame_hexas. Read $msg. Error no $err."
   }
   return [list $trame_hexas $trame_decimals]
}

# Conversion of 4 bytes (byteA, byteB, byteC, byteD) to a 32 bits integer (valint):
proc sentinel_valint { byteD byteC byteB byteA } {
   set valint [expr ((($byteD*256)+$byteC*256)+$byteB*256)+$byteA]
   return $valint
}

# Conversion of an integer (valint) to a tension expressed in Volts (tensionV):
proc sentinel_tensionV { valint } {
   set tensionV [expr ($valint/4096./16.) * 5.0]
   return $tensionV
}

# Conversion of a tension (tensionV) to a temperature expressed in Celsius (tempC):
proc sentinel_tempC { tensionV } {
   # From AK
   set a 44.49
   set b -61.19
   set tempC [expr $a*$tensionV+$b]
   # From CC
   set tempC [expr ($tensionV-1.375) / (0.0225)]
   # From AK 2016/07 calibrated with Vantage Pro 2
   set a 25.57
   set b -31.15
   set tempC [expr $a*$tensionV+$b]
   return $tempC
}

# Conversion of a tension (tensionV) to an infrared temperature expressed in Celsius (tempskyC):
proc sentinel_tempskyC { tensionV } {
   # From AK
   set a 89.34
   set b -87.10
   set tempskyC [expr $a*$tensionV+$b]
   # - From CC
   set t1 -17
   set v1 [expr 1.2+1]
   set t2 23.12
   set v2 [expr 2.930+1]
   set asl [expr ($t2-$t1)/($v2-$v1)]
   set bsl [expr $t1-($asl*$v1)]
   set tempskyC [expr ($asl*$tensionV) + $bsl]
   # From AK 2015/09
   set a 98.5652
   set b -62.4458
   set c -31.5279
   set tempskyC [expr $a*$tensionV*$tensionV+$b*$tensionV+$c]
   return $tempskyC
}

# Conversion of a tension (tensionV) to an sky temperature expressed in Celsius (tempIRC):
proc sentinel_tempIRC { tensionV } {
   # From AK
   set a 85.63
   set b -63.38
   set tempIRC [expr $a*$tensionV+$b]
   # - From CC
   set B   3964
   set Ro  30000
   set R1  30000
   set T0  25.0
   set ta  273.15
   set Gain 1.9
   set vp [expr 2.806+0.5]
   set vm [expr 0.447+0.5]
   return 0
   set A [ expr log( 1./$Ro * (((($vp-$vm)*$R1)/(($tensionV/$Gain)-$vm))-$R1)) ]
   set tempIRC [expr $B / ( $A + ($B/($T0+$ta)) ) - $ta ]
   # From AK 2015/09
   set a 98.5652
   set b -62.4458
   set c -31.5279
   set tempIRC [expr $a*$tensionV*$tensionV+$b*$tensionV+$c]
   return $tempIRC
}

# Conversion of a tension (tensionV) to a humidity expressed in percents (humidity):
proc sentinel_humidity { tensionV } {
   # From AK sur CC 04/2014
   set a 101.01
   set b -25.61
   # From AK 04/2014
   set a 209.97
   set b -74.49
   set humidity [expr $a*$tensionV+$b]
   # From AK 16/09/2014
   set a 159.5197
   set b -23.9676
   set c  10.0000
   set humidity [expr $a*$tensionV*$tensionV+$b*$tensionV+$c]
   # - From CC
   set gainRH 1.25 ; #  (gain ampli)
   set v1RH  4     ; #  (100% = 4V)
   set v0RH  0.8   ; #  (0% = 0.8V)
   set humidity [ expr ( $tensionV/$gainRH - $v0RH ) / ($v1RH - $v0RH) * 100]
   # From AK 09/2015
   set a 108.1873
   set b -32.4658
   # From AK 07/2016 calibrated with Vantage Pro 2
   set a 61.24
   set b 32.24
   set humidity [expr $a*$tensionV+$b]
   return $humidity
}

# Conversion of a tension (tensionV) to a power level expressed in Volts ? (power):
proc sentinel_power { tensionV } {
   # From CC validated by AK
   set power [expr $tensionV*3*1.07]
   return $power
}

proc sentinel_dirwind { valint } {
   return [expr $valint*22.5]
}

proc sentinel_speedms { valint } {
   return [expr $valint*0.1]
}

proc sentinel_initialize { f name } {
   global audace
   # --- 1A
   set res [sentinel_putget $f { 1D 02 1A }]
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   set audace(meteosensor,private,$name,maj_firmware) [lindex $datas 0]
   set audace(meteosensor,private,$name,min_firmware) [lindex $datas 1]
   set pointeur_eeprom [expr ([lindex $datas 2]*256+[lindex $datas 3])*256+[lindex $datas 4]]
   set audace(meteosensor,private,$name,eeprom_pointer) $pointeur_eeprom
   set flag_debordement [lindex $datas 5]
   set audace(meteosensor,private,$name,flag_overflow) $flag_debordement
   set temps_intervalle [expr [lindex $datas 7]*256+[lindex $datas 6]]
   set audace(meteosensor,private,$name,delay_acquisition) $temps_intervalle
   set temps_ecoule_boot [expr ((([lindex $datas 8])*256+[lindex $datas 9])*256+[lindex $datas 10])*256+[lindex $datas 11]]
   set audace(meteosensor,private,$name,seconds_since_last_boot) $temps_ecoule_boot
}

proc sentinel_read { f name } {
   global audace
   set textes ""
   # --- 1B
   set res [sentinel_putget $f { 1D 02 1B }]
   #console::affiche_resultat "1B res = $res\n"
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   #console::affiche_resultat "1B datas = $datas\n"
   set ext_temp_volt [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 1] [lindex $datas 0] ] ]
   set texte "Voltage_ext_temp [format %.3f $ext_temp_volt]" ; lappend texte "Volts"
   lappend textes $texte
   set ext_temp  [sentinel_tempC    [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 1] [lindex $datas 0] ] ] ]
   set power     [sentinel_power    [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 3] [lindex $datas 2] ] ] ]
   set humidity_volt [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 5] [lindex $datas 4] ] ]
   set texte "Voltage_humidity [format %.3f $humidity_volt]" ; lappend texte "Volts"
   lappend textes $texte
   set humidity  [sentinel_humidity [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 5] [lindex $datas 4] ] ] ]
   set ss [meteosensor_convert_base [lindex $datas 6] 10 16]
   set mm [meteosensor_convert_base [lindex $datas 7] 10 16]
   set hh [meteosensor_convert_base [lindex $datas 8] 10 16]
   set d [meteosensor_convert_base [lindex $datas 9] 10 16]
   set m [meteosensor_convert_base [lindex $datas 10] 10 16]
   set y [expr 2000+[meteosensor_convert_base [lindex $datas 11] 10 16]]
   set date [mc_date2iso8601 [list $y $m $d $hh $mm $ss]]
   #console::affiche_resultat "Date = $date\n"
   set rain_temp [sentinel_tempC    [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 13] [lindex $datas 12] ] ] ]
   #
   set sky_temp_volt [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 15] [lindex $datas 14] ] ]
   set texte "Voltage_sky_temp [format %.3f $sky_temp_volt]" ; lappend texte "Volts"
   lappend textes $texte
   set sky_temp  [sentinel_tempskyC $sky_temp_volt ]
   ## probleme de log negatif dans la conversion
   set can_volt [sentinel_tensionV [sentinel_valint 0 0 [lindex $datas 17] [lindex $datas 16] ] ]
   set texte "Voltage_can [format %.3f $can_volt]" ; lappend texte "Volts"
   lappend textes $texte
   set can_temp  [sentinel_tempIRC $can_volt ]
   ##console::affiche_resultat "Temperature of the sky detector = [format %.2f $can_temp] C\n"
   set rain [lindex $datas 18]
   set texte "OutTemp [format %.2f $ext_temp]" ; lappend texte "Celsius"
   lappend textes $texte
   set texte "Voltage [format %.2f $power]" ; lappend texte "Volts"
   lappend textes $texte
   set texte "Humidity [format %.2f $humidity]" ; lappend texte "percent"
   lappend textes $texte
   set texte "Date $date" ; lappend texte "ISO8601"
   lappend textes $texte
   set texte "RainTemp [format %.2f $rain_temp]" ; lappend texte "Celsius"
   lappend textes $texte
   set texte "SkyTemp [format %.2f $sky_temp]" ; lappend texte "Celsius"
   lappend textes $texte
   set valcor $sky_temp
   if {$valcor<-28} {
      set texte "SkyCover Clear text"
   } elseif {$valcor<-18} {
      set texte "SkyCover Cloudy text"
   } else {
      set texte "SkyCover VeryCloudy text"
   }
   lappend textes $texte
   ##set texte "IRSensorTemp [format %.2f $can_temp]" ; lappend texte "Celsius"
   ##lappend textes $texte
   set texte "Rain $rain" ; lappend texte "boolean"
   lappend textes $texte
   if {$rain==0} {
      set rain_state Rain
   } else {
      set rain_state Dry
   }
   set texte "RainState $rain_state" ; lappend texte "Dry | Rain"
   lappend textes $texte
   # --- 23
   set res [sentinel_putget $f { 1D 02 23 }]
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   set valid [sentinel_valint 0 0 [lindex $datas 2] [lindex $datas 1] ]
   set texte "Wind_valid $valid" ; lappend texte "Integer"
   lappend textes $texte
   if {$valid<32767} {
      #console::affiche_resultat "\ndatas = $datas\n"
      set valint [sentinel_valint 0 0 0 [lindex $datas 11] ]
      set dirwind [sentinel_dirwind $valint]
      set texte "Integer_dirwind $valint" ; lappend texte "Integer"
      lappend textes $texte
      set valint [sentinel_valint 0 0 [lindex $datas 13] [lindex $datas 12] ]
      set speedms [sentinel_speedms $valint ]
      set texte "Integer_speedwind $valint" ; lappend texte "Integer"
      lappend textes $texte
   } else {
      # --- 33
      set res [sentinel_putget $f { 1D 02 33 }]
      set decimals [lindex $res 1]
      set datas [lrange $decimals 2 end]
      set valint [sentinel_valint 0 0 [lindex $datas 1] [lindex $datas 0] ]
      set speed_raw $valint
      set texte "Integer_speedwind $valint" ; lappend texte "Integer"
      lappend textes $texte
      set valint [sentinel_valint 0 0 [lindex $datas 3] [lindex $datas 2] ]
      set dir_raw   $valint
      set texte "Integer_dirwind $valint" ; lappend texte "Integer"
      lappend textes $texte
      set Max_cd 15373
      set Min_Value [expr 4./20*$Max_cd]
      set Scale_speed 30.0 ; # (this is the maximum speed at 20mA in m/s)
      set Scale_dir 360.0  ; # (this is the direction at 20mA)
      if {$speed_raw > [expr $Min_Value*0.9]} {
         set speedms [expr 1.*($speed_raw  $Min_Value) / ($Max_cd  $Min_Value) * $Scale_speed]
      } else {
         set speedms 0
      }
      if {$dir_raw > [expr $Min_Value*0.9]} {
         set dirwind [expr 1.*($dir_raw  $Min_Value) / ($Max_cd  $Min_Value) * $Scale_dir]
      } else {
         set dirwind 0
      }
   }
   set texte "WinDir $dirwind" ; lappend texte "degrees"
   lappend textes $texte
   set texte "WinSpeed $speedms" ; lappend texte "m/s"
   lappend textes $texte
   # --- 22
   set res [sentinel_putget $f { 1D 02 22 }]
   #console::affiche_resultat "22 res = $res\n"
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   #console::affiche_resultat "22 datas = $datas\n"
   set light_raw1     [sentinel_valint [lindex $datas 0] [lindex $datas 1] [lindex $datas 2] [lindex $datas 3] ]
   set light_gain1    [sentinel_valint 0 0 0 [lindex $datas 4] ]
   set light_freqdiv1 [sentinel_valint 0 0 0 [lindex $datas 5] ]
   #console::affiche_resultat "22 light_gain1 = $light_gain1\n"
   #console::affiche_resultat "22 light_freqdiv1 = $light_freqdiv1\n"
   set ms 1000 ; # idealement il faut intergrer plusieurs dizaines de secondes la nuit
   after $ms
   set res [sentinel_putget $f { 1D 02 22 }]
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   set light_raw2     [sentinel_valint [lindex $datas 0] [lindex $datas 1] [lindex $datas 2] [lindex $datas 3] ]
   set light_gain2    [sentinel_valint 0 0 0 [lindex $datas 4] ]
   set light_freqdiv2 [sentinel_valint 0 0 0 [lindex $datas 5] ]
   set valid 0
   if {($light_gain2==$light_gain1)&&($light_freqdiv2==$light_freqdiv1)} {
      #console::affiche_resultat "($light_raw2 - $light_raw1) / ($ms/1000.) * $light_freqdiv1 / $light_gain1\n"
      # -- nb ticks chaque 1/100 seconde
      # gain = 1 10 100
      # freqdiv = 1 2 10 100
      set light_ticks [expr ($light_raw2 - $light_raw1) / ($ms/1000.) / (1. * $light_freqdiv1 / $light_gain1) ]
      set texte "light_ticks [format %.4f $light_ticks]" ; lappend texte "tick/100s"
      lappend textes $texte
      if {$light_ticks>0} {
         set dark_ticks 0.0025
         if {$light_ticks<=$dark_ticks} {
            set light_ticks [expr 1./$light_freqdiv1]
         }
         set logflux [expr log10( $light_ticks - $dark_ticks)]
         if {$logflux>=-5} {
            set mag0 12.4
            set mag [expr $mag0 - 2.5*$logflux]
            set valid 1
         }
      }
   }
   if {$valid==1} {
      set texte "SkyBrightness [format %.2f $mag]" ; lappend texte "mag/arcsec2"
      lappend textes $texte
   }
   # --- 27
   set res [sentinel_putget $f { 1D 02 27 }]
   set decimals [lindex $res 1]
   set datas [lrange $decimals 2 end]
   set val [sentinel_valint 0 0 0 [lindex $datas 3] ]
   set texte "HeatingPower $val" ; lappend texte "percent"
   lappend textes $texte
   set val [sentinel_valint 0 0 0 [lindex $datas 13] ]
   set texte "RainStatus $val" ; lappend texte "boolean"
   lappend textes $texte
   set val [sentinel_valint 0 0 0 [lindex $datas 14] ]
   set texte "RainClean $val" ; lappend texte "boolean"
   lappend textes $texte
   set val [sentinel_valint 0 0 0 [lindex $datas 15] ]
   set texte "DefrostEnabled $val" ; lappend texte "boolean"
   lappend textes $texte
   set val [sentinel_valint 0 0 0 [lindex $datas 16] ]
   set texte "RelayClosed $val" ; lappend texte "boolean"
   lappend textes $texte
   # ---
   set val $audace(meteosensor,private,$name,delay_acquisition)
   set texte "DelayAcquisition $val" ; lappend texte "seconds"
   lappend textes $texte
   # ---
   return $textes
}

# ===========================================================================
# ===========================================================================
# ====== Simulation
# ===========================================================================
# ===========================================================================
proc simulationmeteo_open { } {
   global audace
   set keys [list SkyCover SkyTemp OutTemp WinDir WinSpeed Humidity Water]
   set values [list Clear -20 10 0 2 60 Dry]
   set ranges [list {Clear Cloudy VeryCloudy} {real number} {real number} {real number 0 to 360. 0=N, 90=E} {real positive number} {real number 0 to 100} {Dry Wet Rain}]
   set comments [list "Sky cover" "Sky temperature" "Outside temperature" "0=North 90=east" "Wind speed" "Humidity" "Dry or Wet or Rain"]
   set units [list text Celsius Celsius deg m/s Percent text]
   set superkeys [list keys values ranges comments units]
   set n [llength $superkeys]
   for {set k 0} {$k<$n} {incr k} {
      set superkey [lindex $superkeys $k]
      set toeval "set v \$${superkey}"
      set audace(meteosensor,simulation,params,$superkey) [eval $toeval]
   }
   return ""
}

proc simulationmeteo_set { {key ""} {value ""} } {
   global audace
   set keys $audace(meteosensor,simulation,params,keys)
   set comments $audace(meteosensor,simulation,params,comments)
   set values $audace(meteosensor,simulation,params,values)
   set ranges $audace(meteosensor,simulation,params,ranges)
   set kk [lsearch -exact $keys $key]
   if {$kk==-1} {
      return $keys
   }
   if {$value==""} {
      set value [lindex $values $kk]
      return $value
   }
   if {$value=="?"} {
      set range [lindex $ranges $kk]
      return $range
   }
   set values [lreplace $values $kk $kk $value]
   return $value
}

proc simulationmeteo_read { } {
   global audace
   set keys $audace(meteosensor,simulation,params,keys)
   set values $audace(meteosensor,simulation,params,values)
   set units $audace(meteosensor,simulation,params,units)
   set comments $audace(meteosensor,simulation,params,comments)
   set textes ""
   set n [llength $keys]
   for {set k 0} {$k<$n} {incr k} {
      set key [lindex $keys $k]
      set value [lindex $values $k]
      set unit [lindex $units $k]
      set comment [lindex $comments $k]
      set texte "$key \"$value\" \"$unit\" \"$comment\""
      lappend textes $texte
   }
   return $textes
}

# ===========================================================================
## @brief extract usefull parameters from realtime.txt file
#  @pre If your AWS (Automatique Weather Station) is supported (@ http://wiki.sandaysoft.com/a/Supported_Devices)
#  - install the free software cumulus @ http://sandaysoft.com/products/cumulus
#  - configure cumulus to write realtime.txt file
#  @remarks used by ::station_meteo and ::collector
#  @param fileName (default) ""
#  @return list of date JD, temperatur, humidity, windspeed, wind direction, atmospheric pressure
#  @code
#  readCumulus
#  # 2457433.1699074074 {5.7 C} {99 %} {5.6 C} {0 km/h} {180 } {98950.0 Pa}
#  @endcode
#
proc readCumulus { {fileName ""} } {

   #--   Cumulus works only on Windows platform
   if {$::tcl_platform(os) == "Linux" || $::tcl_platform(os) == "Darwin"} {
      return
   }

   if {$fileName eq ""} {
      package require twapi
      set dir ""
      foreach pid [twapi::get_process_ids] {
         if {[twapi::process_exists $pid -name cumulus.exe] == 1} {
            set dir [file dirname [twapi::get_process_path $pid]]
            break
         }
      }
      if {$dir ne ""} {
         set fileName [file join $dir realtime.txt]
      }
   }

   set msg [list answer example {27/11/12 10:47:27} {5.8 C} {89 %} {4.1 C} {1.0 m/s} {315 } {99970.0 Pa}]
   if {[catch {set fileID [open $fileName r]} ErrInfo]} {
      return "$ErrInfo"
   }
   gets $fileID realTimeData
   close $fileID

   #--   realTimeData example : 18/10/08 16:03:45 8.4 84 5.8 24.2 33.0 261 0.0 1.0 999.7 W 6 mph C mb mm 146.6 +0.1 85.2 588.4 11.6 20.3 57 3.6 -0.7 10.9 12:00 7.8 14:41 37.4 14:38 44.0 14:28 999.8 16:01 998.4 12:06 1.8.2 448 36.0 10.3 10.5 13 0.2 14 260 2.3 13 1 0 NNW 2040 ft 12.3 11.1 420.1 1
   #  Field Example Description
   #  1 18/10/08 date (always dd/mm/yy)
   #  2 16:03:45 time(always hh:mm:ss)
   #  3 8.4 outside temperature
   #  4 84 relative humidity
   #  5 5.8 dewpoint
   #  6 24.2 wind speed (average)
   #  7 33.0 latest wind speed reading
   #  8 261 wind bearing (degrees)
   #  9 0.0 current rain rate
   #  10 1.0 rain today
   #  11 999.7 barometer
   #  12 W wind direction
   #  13 6 wind speed (beaufort)
   #  14 mph wind units
   #  15 C temperature units
   #  16 mb pressure units
   #  17 mm rain units
   #  18 146.6 wind run (today)
   #  19 +0.1 pressure trend value
   #  20 85.2 monthly rainfall
   #  25 3.6 wind chill
   #  26 -0.7 temperature trend value
   #--   see Cumulus Help, realtime.txt section, for more

   #--   extracting some interesting values
   lassign $realTimeData date time outsidetemp outsidehumidity dewpoint -> \
      windspeed windbearing -> -> pressure -> -> \
      windUnits tempUnits pressureUnits

   regsub -all "/" $date " " date
   lassign $date DateDay DateMonth DateYear
   set DateYear [expr { $DateYear+2000}]
   regsub -all ":" $time " " time
   lassign $time DateHour DateMin DateSec
   set horodate [mc_date2jd [list $DateYear $DateMonth $DateDay $DateHour $DateMin $DateSec]]

   #--   values and units formating
   if {$tempUnits eq "C"} {
      set tempUnits "°C"
   }

   #-- Cumulus permet de fixer le SUD = 0°C, donc cette converion est inutile
   #set windbearing [expr { int(fmod($windbearing+180,360)) }]
   set windBearingUnits "°"
   if {$pressureUnits eq "hPa"} {
      set pressure [expr { $pressure*100 }] ; #-- Pa
      set pressureUnits Pa
   }

   set msg {}
   lappend msg $horodate                              ; #--   Time Stamp
   lappend msg [list $outsidetemp $tempUnits]         ; #--   Outside temmperature
   lappend msg [list $outsidehumidity "%"]            ; #--   Outside Relative Humidity
   lappend msg [list $dewpoint $tempUnits]            ; #--   DewPoint
   lappend msg [list $windspeed $windUnits]           ; #--   Wind speed
   lappend msg [list $windbearing $windBearingUnits]  ; #--   Wind bearing
   lappend msg [list $pressure $pressureUnits]        ; #--   Atmospheric pressure

   return $msg
}

# ===========================================================================
## @brief read ../Sentinel/Datas/infodata.txt and extract usefull parameters
#  @pre installation of Sentinel
#  @remarks used by ::station_meteo
#  @return list of date JD, temperatur, humidity, windspeed, wind direction, atmospheric pressure with units
#
proc readSentinelFile { {fileName ""} } {

   if {$fileName eq ""} {
      set mesDocuments [ ::registry get "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders" Personal ]
      set env_documents [ file normalize $mesDocuments ]
      set fileName "[file join $env_documents Sentinel Datas infodata.txt]"
   }

   if {[catch {set fileID [open $fileName r]} ErrInfo]} {
      return "$ErrInfo"
   }
   set sentineldata [split [read $fileID] \n]
   close $fileID

   #--   sentinelData example :
   #Fileversion          = 1.01
   #DateYear             = 2013
   #DateMonth            = 4
   #DateDay              = 30
   #DateHour             = 23
   #DateMin              = 59
   #DateSec              = 42
   #TempExt (C)          = 16.58
   #Humidity (%RH)       = 70.9
   #DewPoint (C)         = 11.24
   #TempRainSensor (C)   = 24.23
   #TempSkyIR   (C)      = 5.70
   #TempDetectorIR (C)   = 27.64
   #RainFall             = No
   #WindSpeedGust (km/h) = 2.2
   #WinDirection ()      = 23
   #PowerDry (%)         = 0
   #PowerIn (V)          = 13.71
   #LighLevel (Log a.u)  = -1.233
   #LighLevel (Mag/sec)  = 15.48

   foreach data $sentineldata {
      lassign [split $data "="] title value
      lassign [split $title " "] title units
      set title [string trim $title]
      set $title $value
      if {$units ne ""} {
         regsub -all {[\(\)]} $units "" units
         set ${title}Units $units

      }
   }

   #--   format gregorien
   set horodate [mc_date2jd [list $DateYear $DateMonth $DateDay $DateHour $DateMin $DateSec]]

   set windBearingUnits   "°"
   set WindSpeedGust      [format %0.1f $WindSpeedGust]
   set WindSpeedGustUnits "km/s"
   set WinDirection       [expr { $WinDirection+180 } ]
   set WinDirection       [expr { int(fmod($WinDirection,360)) } ]

   set msg {}
   lappend msg $horodate                                  ; #--   Time Stamp
   lappend msg [list $TempExt $TempExtUnits]              ; #--   Outside temmperature
   lappend msg [list $Humidity $HumidityUnits]            ; #--   Outside Relative Humidity
   lappend msg [list $DewPoint $DewPointUnits]            ; #--   DewPoint
   lappend msg [list $WindSpeedGust $WindSpeedGustUnits]  ; #--   Wind speed
   lappend msg [list $WinDirection $WinDirectionUnits]    ; #--   Wind bearing
   lappend msg [list 101325 Pa]                           ; #--   Atmospheric pressure

   return $msg
}

