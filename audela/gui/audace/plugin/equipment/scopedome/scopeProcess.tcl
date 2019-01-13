#
# file scopeProcess.tcl
# brief proc spécifiques pour un thread
# author Raymond ZACHANTKE
# $Id: scopeProcess.tcl 13981 2016-06-11 07:26:13Z rzachantke $
#

#---------------------------------------------------------------------------
#  action
#  parameter do nom de l'action
#
proc action { do } {
   global comobj

   if {$do in [list AbortSlew CloseShutter Dome_Find_Home OpenShutter Park]} {
      $comobj $do
   } else {
      $comobj Action $do [::tcom::null]
   }
}

#---------------------------------------------------------------------------
#  parameter action name
#  parameter value valeur en degrés
#  return { 0 | 1=error }
#
proc cmd { action value } {
   global comobj

   #--   Verify input
   set max 360
   if {$action eq "SlewToAltitude"} {
      set max 99
   }

   if {[string is double -strict $value] ==1 && \
      $value >= 0 && $value <= $max} {
   } elseif {$action ne "Dome_Relative_Rotate"} {
      return 1
   }

   if {$action in [list SlewToAzimuth SyncToAzimuth SlewToAltitude]} {
       #--   Ascom command
       $comobj $action $value
   } elseif {$action in [list GoTo Enc_GoTo Dome_Relative_Rotate]} {
       $comobj CommandString "$action $value"
   }

   return 0
}

#---------------------------------------------------------------------------
#  parameter propertyName nom du paramètre à lire
#  return : formated value
#
proc readProperty2 { propertyName } {
   global comobj

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
      Internal_Sensor_Dome_At_Home \
      Internal_Sensor_Observatory_Safe \
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
      set result [string map [list 0 No False No 1 Yes True 1] $result]
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
      #-- renvoie la eéponse non decodee
      #-- pour "Internal_Sensor_Dome_Encoder_Counter Internal_Sensor_Dome_Roatate_Counter"
      #-- ou pour toute valeur non specifie
      set result $result
   }

   return $result
}

#---------------------------------------------------------------------------
#  parameter do nom du switch
#  parameter value valeur ( Off | On | Toggle }
#
proc switchTo { do value } {
   global comobj

   if {$do in [list Scope_Sync Wind_Sync Sky_Sync Weather_Protect]} {
       set value [string map [list Off 0 On 1 Toggle 2] $value]
       $comobj CommandString "$do $value"
   } elseif {$do eq "Slaved"} {
       $comobj -set $do $value
   }
}

package require tcom

global comobj

set progID "ASCOM.ScopeDomeUSBDome.DomeLS"
set comobj [tcom::ref createobject -local $progID]
