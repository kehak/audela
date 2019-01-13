#
## @file scopedome_driver.tcl
#  @brief driver de communication avec ScopeDome
#  @author Raymond ZACHANTKE
#  $Id: scopedome_driver.tcl 14245 2017-07-07 11:03:12Z rzachantke $
#

#---------------------------------------------------------------------------
#  brief créé le process de communication entre AudeLA et ScopeDome
#  param path chemin vers l'exécutable
#  param windowName nom de la fenêtre de ScopeDome
#  return liste de l'ID du handle tcom et connection (1=OK 0=pas connecté)
#
proc ::scopedome::createProcess { path {windowName "ScopeDome LS"} } {
   variable widget

   set progID "ASCOM.ScopeDomeUSBDome.DomeLS"

   set comobj [tcom::ref createobject -local $progID]
   tcom::configure -concurrency apartmentthreaded
   set connect 1
   set connected [::scopedome::connect $comobj $connect]

   #--   Debug
   #::console::disp "[tcom::info interface $comobj]\n"
   #::scopedome::getAscomMethodsProperties $comobj
   #::scopedome::getSupportedActions $comobj

   #set progid "IDomeV2"
   #set clsid [twapi::progid_to_clsid $progID]
   #set progid [twapi::clsid_to_progid $clsid]
   #set pid [twapi::get_process_ids -name $widget(scopedome,fileName)]
   #::console::disp "CLSID $clsid\nProgID $progid\npid $pid\n"

   #::scopedome::activateWindow "ScopeDome LS"

   return [list $comobj $connected]
}

#---------------------------------------------------------------------------
#  brief connecte/déconnecte le driver
#  param comobj ID du handler tcom
#  param connect 0 = false 1 = true
#  return message
#
proc ::scopedome::connect { comobj connect } {
   variable widget

   if {$connect ne "[$comobj Connected]"} {
      $comobj Connected $connect
   }
   set widget(combobj) $comobj
   return  [$comobj Connected]
}

#---------------------------------------------------------------------------
#  brief ferme la liaison avec ScopeDome LS s'il existe et tue le handler tcom
#
proc ::scopedome::killCom { } {
   variable widget

   if {[info exists widget(comobj)] ==1} {
      catch { $widget(comobj) Dispose }
      unset widget(comobj)
   }
}

#---------------------------------------------------------------------------
## @brief écrit le fichier de synchronisation entre le télescope et ScopeDome LS
#  @remark la structure du fichier "C:/ScopeDome/ScopeDomeCurrentTelescopeStatus.txt" doit être (par ligne)
#  -#   [header]
#  -#   telescop_name = "name" ; # nom du télescope
#  -#   [Telescope]
#  -#   Alt=5.6        ; # en degrés
#  -#   Az=340         ; # en degrés
#  -#   Ra=3.3         ; # en heurés
#  -#   Dec=4.5        ; # en degrés
#  -#   SideOfPier=1   ; # {-1=unknown | 0=E | 1=W}
#  -#   Slewing=false  ; # { true | false }
#  -#   AtPark=true    ; # { true | false }
#  @param cycle durée (ms) entre deux écritures du fichier
#
proc ::scopedome::writeFileSystem { cycle } {
   variable widget

   set telNo $::audace(telNo)
   #--   Evite une erreur
   if {$telNo == 0} {return}

   if {$conf(scopedome,connectScope) ==1 && $telNo == 1 && $widget(domNo) ==1} {

      lassign [tel$telNo radec coord -equinox now] rahms decdms
      set radeg [mc_angle2deg $rahms]
      set rah [expr { $radeg/15 }]
      set decdeg [mc_angle2deg $decdms]
      set home $conf(posobs,observateur,gps)
      set datetu [mc_date2iso8601 [::audace::date_sys2ut now]]
      set date [mc_date2jd $datetu]
      lassign [mc_radec2altaz $radeg $decdeg $home $date] azdeg altdeg
      set azdeg [expr {fmod($azdeg+180,360)}] ; # le dome prend Az =0 pour le Nord
      set side [string map [list E 0 W 1] [tel$telNo german]]

      set slewing true
      set motorState [tel$telNo radec state]
      if {$motorState ne "tracking"} {
         set slewing false
      }

      #--   Write file "C:/ScopeDome/ScopeDomeCurrentTelescopeStatus.txt"
      set fid [open $widget(filesystem) w]
      puts $fid "\[header\]"
      puts $fid "program_name = \"$::conf(telescope)\""
      puts $fid "\[Telescope\]"
      puts $fid "Alt=$altdeg"
      puts $fid "Az=$azdeg"
      puts $fid "Ra=$rah"
      puts $fid "Dec=$decdeg"
      puts $fid "SideOfPier=$side"
      puts $fid "Slewing=$slewing"
      puts $fid "AtPark=false"
      catch {close $fid}
   }

   set widget(afterID) [after $cycle "::scopedome::writeFileSystem $cycle"]
}

#------------------------------------------------------------
## @brief arrête/lance l'écriture du fichier de synchro
#  @param action refresh ou stop ou "" (ne fait rien)
#
proc ::scopedome::onChangeScope { {action ""} } {
   variable widget

   set cycle 5000 ;# ms

   if {$action eq "refresh"} {
      ::scopedome::writeFileSystem $cycle
  } elseif {$action eq "stop" && [info exists widget(afterID)] == 1} {
      #--   Arrete l'ecriture du fichier
      after cancel "::scopedome::writeFileSystem $cycle"
      unset widget(afterID)
   }
}

#---------------------------------------------------------------------------
## @brief commande globale associée aux combobox de la fenêtre d'équipement de ScopeDome
#  @details le nom de la variable sélectionnée est dans \$widget(${type}
#  @param type type de commande (action, switch, cmd ou property)
#
proc ::scopedome::cmd { type } {
   variable widget

   set comobj $widget(comobj)
   set do $widget(${type})
   set widget(propertyResult) ""

   if {[catch {
      switch -exact $type {
         action   {  if {$do in [list AbortSlew CloseShutter FindHome OpenShutter Park]} {
                        $comobj $do
                     } else {
                        $comobj Action $do [::tcom::null]
                     }
                  }
         switch   {  set value $widget(switchValue)
                     if {$do eq "Slaved"} {
                        #--   Ascom command Slaved (pas de toggle)
                        $comobj -set $do $value
                     } else {
                        set value [string map [list Off 0 On 1 Toggle 2] $value]
                        $comobj CommandString "$do $value"
                     }
                  }
         cmd      {  set value $widget(cmdValue)
                     ::console::disp "$type value $value\n"
                     #--   Verify input
                     if {$do in $widget(cmdList)} {
                        switch -exact $do {
                           SlewToAltitude {set max 99}
                           default        {set max 360}
                        }
                        if {[string is double -strict $value] ==1 && \
                           $value >= 0 && $value <= $max} {
                        } elseif {$do eq "Dome_Relative_Rotate"} {
                        } else {
                           ::scopedome::errorBox limite
                           set widget(ok) 0
                           return $widget(ok)
                        }
                     }
                     if {$do in [list SlewToAzimuth SyncToAzimuth SlewToAltitude]} {
                        #--   Ascom command
                        $comobj $do $value
                     } elseif {$do in [list GoTo Enc_GoTo Dome_Relative_Rotate]} {
                        set string "$do $value"
                        ::console::disp "$comobj CommandString \"string\" \n"
                        #--   Other command
                        $comobj CommandString \"$string\"
                     }
                  }
         property {  set widget(propertyResult) [::scopedome::readProperty $do] }
      }
   } msg] == 1} {
      ::console::disp "$do : $msg\n"
   }
}

#---------------------------------------------------------------------------
#  brief lit un paramètre
#  param comobj tcom handler
#  param propertyName nom du paramètre à lire
#  return valeur formatée
#
proc ::scopedome::readProperty { propertyName } {
    variable widget

   set comobj $widget(comobj)

   if {[catch {
      if {$propertyName in [list Azimuth AtHome AtPark Connected Slaved Slewing ShutterStatus]} {
         set result [$comobj -get $propertyName]
      } else {
         #--   Variables utilisant CommandString
         set result "[$comobj -get CommandString $propertyName]"
         #--   Convertit en valeur numerique
         regsub "," $result "." result
      }
   } msg] ==1} {
      ::console::disp "$msg\n"
   }

   #--   Format = degres
   set listDeg [list Azimuth Dome_Scope_Ra Dome_Scope_Dec \
      Dome_Scope_Alt Dome_Scope_Az Wind_Direction]

   #--   Format = °C
   set listCelsius [list Dew_Point Temperature_In_Dome Temperature_Outside_Dome \
      Temperature_Humidity_Sensor Temperature_In_From_Weather_Station \
      Temperature_Out_From_Weather_Station]

   #--   Format = boolean
   set listBool [list Card_Power_Get_State AtHome AtPark Connected Dome_Error \
      Dome_Scope_Is_Connected Slaved Slewing Cloud_Sensor_Rain \
      Rel_Scope_Get_State Rel_CCD_Get_State \
      Rel_Light_Get_State Rel_Fan_Get_State \
      Rel_REL_1_Get_State Rel_REL_2_Get_State \
      Rel_REL_3_Get_State Rel_REL_4_Get_State \
      Rel_Shutter_1_Open_Get_State Rel_Shutter_1_Close_Get_State \
      Rel_Shutter_2_Open_Get_State Rel_Shutter_2_Close_Get_State \
      Rel_Dome_CW_Get_State Rel_Dome_CCW_Get_State \
      Internal_Sensor_Dome_At_Home Internal_Sensor_Observatory_Safe \
      Internal_Sensor_Power_Failure]

   #--   Format tristate {0|1|-1}
   set listTriState [list Cloud_Sensor_Rain Cloud_Sensor_Day_Night Cloud_Sensor_Clear_Cloudy]

   #--    Format = %
   set listPercent [list Humidity_Humidity_Sensor Shutter_Link_Strength]

   #--   Format = V(olts)
   set listVolt [list Analog_Input_Shutter Analog_Input_Main]

   #--   Formate/Transcode le resultat
   if {$propertyName in $listBool} {
      #-- reponse False/No ou True/yes
      set result [string map [list 0 No False 0 1 Yes True 1] $result]
   } elseif {$propertyName in "$listTriState"} {
      set result [string map [list 0 No 1 Yes -1 ?] $result]
   } elseif {$propertyName in $listDeg} {
      set result [format "%.2f °" $result]
   } elseif {$propertyName in $listCelsius} {
      set result [format "%.1f °C" $result]
   } elseif {$propertyName in $listVolt} {
      set result [format "%.2f V" $result]
   } elseif {$propertyName in $listPercent} {
      append result " %"
   } elseif {$propertyName eq "Wind_Speed"} {
      set result [format "%s km/h" $result]
   } elseif {$propertyName eq "Pressure"} {
      set result [format "%s hPa" $result]
   } elseif {$propertyName eq "ShutterStatus"} {
      set result [string map [list 0 Open 1 Closed 3 "In progress" 4 "Error"] $result]
   } else {
      #-- renvoie la réponse non decodee
      #-- pour "Internal_Sensor_Dome_Encoder_Counter Internal_Sensor_Dome_Roatate_Counter"
      #-- ou pour toute valeur non specifie
      set result $result
   }

   return $result
}

#---------------------------------------------------------------------------
#  brief commande de switch
#  param do nom du switch
#  param value valeur
#
proc ::scopedome::switchTo { do value } {
   variable widget

   set comobj $widget(comobj)

   if {$do in [list Scope_Sync Wind_Sync Sky_Sync Weather_Protect]} {
      set value [string map [list Off 0 On 1 Toggle 2] $value]
      $comobj CommandString "$do $value"
   } elseif {$do eq "Slaved"} {
      $comobj -set $do $value
   }
}

#---------------------------------------------------------------------------
#  brief commande d'action
#  param action name
#
proc ::scopedome::action { do } {
    variable widget

   set comobj $widget(comobj)

   if {$do in [list AbortSlew CloseShutter Dome_Find_Home OpenShutter Park]} {
      $comobj $do
   } else {
      $comobj Action $do [::tcom::null]
   }
}

#---------- not used or only for debug -------------------

#---------------------------------------------------------------------------
#  brief
#  details pour débug
#  param comobj objet COM
#
proc ::scopedome::getAscomMethodsProperties { comobj } {

   ::console::disp "AscomMethodsProperties\n\n"
   set interfacehandle [tcom::info interface $comobj]
   ::console::disp "comobj $comobj\ninterfacehandle $interfacehandle"

   foreach c [list name iid methods properties] {
      set content [$interfacehandle $c]
      for {set i 0} {$i < [llength $content]} {incr i} {
         ::console::disp "$c : [lindex $content $i]\n"
      }
   }
   ::console::disp "\n"
}

#---------------------------------------------------------------------------
#  brief inventorie les actions supportées
#  details liste des actions dans un fichier "supportedActionsLS.txt"
#  localisé dans le répertoire de ScopeDome
#  warning à utiliser lors d'un changement de version de ScopeDome
#  param comobj objet COM
#
proc ::scopedome::getSupportedActions { comobj } {

   set supportedActions [list ]
   set handle [$comobj SupportedActions]
   if {$handle ne ""} {
      for {set i 0} {$i < [$handle Count]} {incr i} {
         set cmd [$handle Item $i]
         lappend supportedActions $cmd
      }
   }

   #--    Debug
   set fid [open [file join "C:/" ScopeDome supportedActionsLS.txt] w]
   foreach cmd $supportedActions {
      puts $fid $cmd
   }
   close $fid

   return $supportedActions
}

#----------------------------   Non utilises - en reserve ------------------

#---------------------------------------------------------------------------
#  brief get focus on the driver
#  param windowName nom de la fenêtre (eg ScopeDome LS)
#  return hwin
#
proc ::scopedome::activateWindow { windowName } {

   set hwind ""
   while {$hwind eq ""} {
      lassign [twapi::find_windows -text "$windowName" -match glob -toplevel 1] hwin HWND
      after 500
   }
   ::console::disp "hwin $hwin\n"

   twapi::show_window $hwin -sync -activate
   twapi::set_foreground_window $hwin
   twapi::move_window $hwin 800 400 -sync
   twapi::set_focus $hwin

   after 2000
   twapi::show_window $hwin 4

   return $hwin
}


#---------------------------------------------------------------------------
#  brief exécute un script .vbs
#  details non utilisé
#  param scriptFile chemin du fichier vbs
#
proc ::scopedome::executeVBSScript { scriptFile } {

   if {[catch {exec wscript.exe $scriptFile} msg] !=0} {
      ::console::disp "$msg\n"
   }
}

#---------------------------------------------------------------------------
#  brief créé, exécute et détruit un fichier .bat
#  details compmande d'un bouton "Script BAT", non utilisé
#
proc ::scopedome::writeScriptBat { }  {
   variable widget

   set cmdBat [file join [file dirname $widget(fileAccess)] test.bat]
   set cmd $widget(actionsParam)

   #--   Cree le fichier de commande test.bat
   set fid [open $cmdBat w]
   puts $fid "$widget(fileAccess) $cmd"
   close $fid

   if {[catch {exec $cmdBat} msg] ==0} {
      ::console::disp "$cmd OK\n"
   } else {
      ::console::disp "$msg\n"
   }
   file delete -force $cmdBat
}

