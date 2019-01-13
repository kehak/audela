#
## @file vo_vtp_tools.tcl
#  @brief Outil pour l'Observatoire Virtuel
#  @author A. Klotz according to S. Barthelmy C code
#  @par Ressource
#  $Id: alpy600_tools.tcl 13599 2016-04-04 10:24:37Z alainklotz $
#  @warning En cours de développement...
#  @todo traiter pour Doxygen

# ######################################################################################################
#
# source [file join $audace(rep_install) gui audace vo_vtp_tools.tcl]
# set t [vo_vtp_main_thread]
# ::thread::release $t
#
# ######################################################################################################
# This script is adapted from voevent_client_demo.c originally written by S. Barthelmy (NASA)
#
#  USAGE:
#      Launch vo_vtp_main
#
#      Default server is 209.208.78.170 and default port is 8099
#
#  DESCRIPTION:
#      INTRO:  This Tcl script is based on a translation of the 
#      voevent_client_demo.c. Read the file voevent_client_demo.c
#      to understand the details. Read also the following URL:
#
#      http://gcn.gsfc.nasa.gov/tech_describe.html
#
#      The scripts uses the VOEvent Transport Protocol is described at:
#      http://www.ivoa.net/Documents/Notes/VOEventTransport/
#
#      Set a VOEvent socket connection to GCN/TAN and write VOEvent files on local computer
#
#  FILES:
#      voevent_client_demo.log // A logfile of all packets received and program actions & errors.
#      voevent_YYYYMMDDThhmmss.xml // XML formated files that contain reveived VOEvents.
#
#  LIST OF PROCS:
#      vo_vtp_establish_server_conn   // Establish a connection to the server
#      vo_vtp_ut_ctime                // Convert TimeStruct into yy/mm/dd hh:mm:ss string
#      vo_vtp_build_imalive_response  // Build an Imalive Response Message to receiving an imalive message
#      vo_vtp_build_voevent_response  // Build an VOEvent Response Message to receiving a voevent message
#      vo_vtp_extract_ivorn           // Extract Ivorn from voevent message
#      vo_vtp_print                   // vo_vtp_print to the display and in the log file
#      vo_vtp_main                   // vo_vtp_print to the display and in the log file
# 
#  SEE ALSO:
#      xml_socket_demo.c      // The VOEvent XML messages, but uses the GCN protocol
#      socket_demo.c          // The original 160-byte binary GCN packet protocol
#      voevent_client_demo.c  // The original VOEvent client demo
#
#  AUTHOR:
#      Alain Klotz             IRAP-UPS-CNRS               
#
# ######################################################################################################

# display results
proc vo_vtp_print { msg } {
   global VOEventTransportProtocol
   if {[catch {open "$VOEventTransportProtocol(path)/voevent_client_demo.log" "a"} lg] == 0} {
      puts -nonewline $lg $msg
      close $lg
   }
   if {[info commands console::affiche_resultat]==""} {
		catch {
			puts -nonewline $msg
		}
   } else { 
      console::affiche_resultat $msg
   }
}

# /* convert TimeStruct into yy/mm/dd hh:mm:ss string */
proc vo_vtp_ut_ctime { } {
   return [clock format [clock seconds] -gmt 1 -format "%a %d %h %y %H:%M:%S UT"]
}

# /*---------------------------------------------------------------------------*/
# // The "ack" response to an iamalive message is different than to a regular VOEvent.
# // This is because 'iamalives' are considered to be 'transport' messages,
# // and not real/regular VOEvent messages.
# // See http://www.ivoa.net/Documents/Notes/VOEventTransport/
# /* Build Iamalive Response */
proc vo_vtp_build_iamalive_response { } {
   global VOEventTransportProtocol

   # The ivorn of the subscriber (something that IDs you)
   set ack_subivo "ivo://voevent_subscriber_name#"
   set ack_contact "\"yourname@your.email.address\"";       # Your contact email address

   # Get the system time for the notice timestamp
   set tim [clock format [clock seconds] -gmt 1 -format "%y-%m-%dT%H:%M:%S"]

   set ack_buf ""
   append ack_buf "<?xml version='1.0' encoding='UTF-8'?>\n"
   append ack_buf "<trn:Transport role=\"iamalive\" version=\"1.0\"\nxmlns:trn=\"http://telescope-networks.org/schema/Transport/v1.1\"\nxmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\nxsi:schemaLocation=\"http://telescope-networks.org/schema/Transport/v1.1\nhttp://telescope-networks.org/schema/Transport-v1.1.xsd\">\n"
   append ack_buf "<Origin>ivo://nasa.gsfc.gcn/GCN#</Origin>\n"
   append ack_buf "<Response>$VOEventTransportProtocol(ack_subivo)</Response>\n"
   append ack_buf "<TimeStamp>20${tim}</TimeStamp>\n"
   append ack_buf "<Meta>\n"
   append ack_buf "<Param name=\"IPAddr\" value=$VOEventTransportProtocol(ack_ipaddr)/>\n"
   append ack_buf "<Param name=\"Contact\" value=$VOEventTransportProtocol(ack_contact)/>\n"
   append ack_buf "</Meta>\n"
   append ack_buf "</trn:Transport>"

   return $ack_buf
}

# /*---------------------------------------------------------------------------*/
# /* Build VOEvent Message Response */
proc vo_vtp_build_voevent_response { buf } {
   global VOEventTransportProtocol

   # // Origin is the IVORN of the just received VOEvent message 
   set ack_ivorn [vo_vtp_extract_ivorn $buf]
   # vo_vtp_print "ack_ivorn=$ack_ivorn\n"

   #Get the system time for the notice timestamp
   set tim [clock format [clock seconds] -gmt 1 -format "%y-%m-%dT%H:%M:%S"]

   # // Buffer to hold the complete voevent message response
   set ack_buf ""
   append ack_buf "<?xml version='1.0' encoding='UTF-8'?>\n"
   append ack_buf "<trn:Transport role=\"ack\" version=\"1.0\"\nxmlns:trn=\"http://telescope-networks.org/schema/Transport/v1.1\"\nxmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\nxsi:schemaLocation=\"http://telescope-networks.org/schema/Transport/v1.1\nhttp://telescope-networks.org/schema/Transport-v1.1.xsd\">\n"
   append ack_buf "<Origin>$ack_ivorn</Origin>\n"
   append ack_buf "<Response>$VOEventTransportProtocol(ack_subivo)</Response>\n"
   append ack_buf "<TimeStamp>20${tim}</TimeStamp>\n"
   append ack_buf "<Meta>\n"
   append ack_buf "<Param name=\"IPAddr\" value=$VOEventTransportProtocol(ack_ipaddr)/>\n"
   append ack_buf "<Param name=\"Contact\" value=$VOEventTransportProtocol(ack_contact)/>\n"
   append ack_buf "<Result>$VOEventTransportProtocol(ack_result_mesg)</Result>\n"
   append ack_buf "</Meta>\n"
   append ack_buf "</trn:Transport>"

   return $ack_buf
}

# /*---------------------------------------------------------------------------*/
# // The ivorn in the VOEvent Message is contained between double quotes after the phrase ivorn=
# /* Extract Ivorn from voevent message */
proc vo_vtp_extract_ivorn { buf } {               
   global VOEventTransportProtocol
   #Get the system time for the notice timestamp
   set tim [clock format [clock seconds] -gmt 1 -format "%y-%m-%dT%H:%M:%S"]
   set p [string first "ivorn=" $buf]
   if {$p==-1} {
      vo_vtp_print "[vo_vtp_ut_ctime]  ERR: vo_vtp_extract_ivorn(): Could not find Ivorn in the VOEvent Message buf=$buf.\n"
      set ivornbuf ""
   } else {
      set ivornbuf [string range $buf [expr $p+7] end] 
      # // Check for either single or double quote mark
      set p [string first "\'" $ivornbuf]
      if {$p==-1} {
         set p [string first "\"" $ivornbuf]
      }
   }
   return $ivornbuf
}

# /*---------------------------------------------------------------------------*/
# /* Establish a connection to the server */
proc vo_vtp_establish_server_conn { } {
   global VOEventTransportProtocol
   catch {close $ssd}
   set errno [catch { 
      set ssd [socket $VOEventTransportProtocol(host_ip) $VOEventTransportProtocol(port)] 
   } strerror]
   if {$errno==0} {
      vo_vtp_print "Client connected to server. ssd=$ssd\n"
      # // Make the connection non-blocking:
      fconfigure $ssd -blocking 0 -buffering none -translation binary -encoding binary
   } else {
      vo_vtp_print "ERR: client: can NOT open stream socket. errno=$strerror.\n"
      set ssd ""
   }
   return $ssd
}

# /*---------------------------------------------------------------------------*/
# main equivalent

proc vo_vtp_main { {vo_vtp_path ""} {ip_address 209.208.78.170} {port_num 8099} } {
   global VOEventTransportProtocol

   #set ip_address 209.208.78.170
   #set port_num 8099
   
   if {$vo_vtp_path==""} {
      set vo_vtp_path [ file join $::audace(rep_userCatalog) voevents]
   }
   catch {file mkdir $vo_vtp_path}

   set version "voevent_client_demo     Ver: 1.01   09 Feb 2013"

   # **************************************************************************************
   # THESE NEXT 4 ITEMS NEED TO BE ASSIGNED VALUES APPROPRIATE TO THE LOCAL USER:

   set ack_subivo "ivo://voevent_subscriber_name#";         # The ivorn of the subscriber (something that IDs you)
   set ack_ipaddr "\"subscibers_ip_addr:123.123.123.123\""; # Your IP number where this client is running
   set ack_contact "\"yourname@your.email.address\"";       # Your contact email address
   # The ack_result_mesg may be filled with whatever message you would like to send back to the server.
   # You could modify this code to create a different response for different (good vs bad) conditions. 
   set ack_result_mesg "Message received.";                 # Whatever response information you want to send back
   # **************************************************************************************

   set got_voe 0;           # Flag indicating received a VO message (imalive or VOEvent)

   # define a Tcl array for global variables
   set VOEventTransportProtocol(version) $version
   set VOEventTransportProtocol(host_ip) $ip_address
   set VOEventTransportProtocol(port) $port_num
   set VOEventTransportProtocol(ack_subivo) $ack_subivo
   set VOEventTransportProtocol(ack_ipaddr) $ack_ipaddr
   set VOEventTransportProtocol(ack_contact) $ack_contact
   set VOEventTransportProtocol(ack_result_mesg) $ack_result_mesg
   set VOEventTransportProtocol(path) $vo_vtp_path

   set last_nowtime [clock seconds]

   # Write the banner and timestamp to the logfile:
   vo_vtp_print "\n===================== New Session ========================\n"
   vo_vtp_print "Start Time: [vo_vtp_ut_ctime]    Program: $version\n"
   vo_vtp_print "host_ip=$VOEventTransportProtocol(host_ip), port=$VOEventTransportProtocol(port)\n"
   vo_vtp_print "Log file $VOEventTransportProtocol(path)/voevent_client_demo.log\n"

   # Set up the client connection to the server:
   vo_vtp_print "vo_vtp_establish_server_conn\n"
   set ssd [vo_vtp_establish_server_conn] ; # // Establish a connection to the server

   # An infinite loop for reading the socket (the voevents & the imalives), 
   # and handling the reconnection if there is a break.
   # Also, near the end of this loop is your site/instrument-specific code (if you want).
   while {1} {
      # vo_vtp_print "Checking for data.   (or  Possibly checking for connection.)\n"
      set got_voe 0 ; # Initialize the got-something flag

      # If socket is connected, read the socket for any xml_message;
      # if the socket does not have a message, continue to loop.
      if {$ssd == ""} {
         # Not connected
         # If the sock descriptor is zero or less, the socket connection has been broken.
         # Try to re-establish the socket.
         vo_vtp_print "[vo_vtp_ut_ctime] Detected disconnect.  Attempting to reconnect.\n"
         set ssd [vo_vtp_establish_server_conn] ; # // Re-establish a connection to the server
      } else {
         # Connected
         # Two read() calls to rcv: (1) a 4-byte length, (2) then the xml message.
         
         # -- a loop to wait for the 1st read until 4 bytes
         vo_vtp_print "[vo_vtp_ut_ctime] Waiting for the 1st read of 4 bytes...\n"
         set netpktlen ""
         set bytes1 0
         set k 0
         while {$bytes1<4} {
            set errno [catch {            
               set res [read $ssd [expr 4-$bytes1]]
            } strerror ]
            if {($errno==1)||([eof $ssd])} {
               close $ssd
               set ssd ""
               set bytes1 0 
               vo_vtp_print "[vo_vtp_ut_ctime]  ERR: 1st read() returned -1.  errno=${errno}=${strerror}.\n"
               break
            }
            if {[string length $res]>0} {
               append netpktlen $res
               incr bytes1 [string length $res]
               #vo_vtp_print "[vo_vtp_ut_ctime] 1st read: read [string length $res] bytes at loop=$k. bytes1=$bytes1\n"
            }
            after 10; # Give the CPU a rest
            catch {update} ; # refresh the Tk GUI if exists
            incr k
         }
         binary scan $netpktlen I* pktlen ; # Convert it from network byte order to local host byte order      
         vo_vtp_print "[vo_vtp_ut_ctime] 1st read: bytes=${bytes1}, pktlen=${pktlen}, loops=$k.\n"

         # The 1st read was successful
         if {$bytes1 == 4} { 
            after 500; # Sleep 0.5 sec (give time for the xml message to show up)
            set last_nowtime [clock seconds]; # Record the time we got this packet         
            # -- a loop to wait for the 2nd read until pktlen bytes
            set netxmlbuf ""
            set bytes2 0
            set k 0
            while {$bytes2<$pktlen} {
               set errno [catch {            
                  set res [read $ssd [expr $pktlen-$bytes2]]
               } strerror ]
               if {($errno==1)||([eof $ssd])} {
                  close $ssd
                  set ssd ""
                  set bytes2 0 
                  vo_vtp_print "[vo_vtp_ut_ctime]  ERR: 2nd read() returned -1.  errno=${errno}=${strerror}.\n"
                  break
               }
               if {[string length $res]>0} {
                  append netxmlbuf $res
                  #vo_vtp_print "[vo_vtp_ut_ctime] 2nd read: read [string length $res] bytes at loop=$k. bytes2=$bytes2\n"
                  incr bytes2 [string length $res]
               }
               after 10; # Give the CPU a rest
               catch {update} ; # refresh the Tk GUI if exists
               incr k
            }
            if {$errno==1} {
               break
            }
            binary scan $netxmlbuf a* xmlbuf ; # Convert it from network byte order to local host byte order
            vo_vtp_print "[vo_vtp_ut_ctime]  2nd read: Reading bytes from sd=${ssd}...${bytes2} bytes.\n"
            vo_vtp_print "[vo_vtp_ut_ctime]  Got a new xml message from VOEvent server.\n"
            set got_voe 1;

            # The single full read (or the two partial reads) yielded a voevent 
            if {$got_voe} {
               # vo_vtp_print the xml messages and send back the ack (sorry, no checking, so no nack capability).
               #vo_vtp_print "${xmlbuf}\n"
               # If we got an imalive, then reply with the special imalive ack:
               if { ([string first "iamalive" $xmlbuf]>=0) || ([string first "imalive" $xmlbuf]>=0) } {
                  # Allow both spellings of imalive
                  # The "ack" for an iamalive is different than an ack for a regular voevent:
                  set ackima [vo_vtp_build_iamalive_response]
                  vo_vtp_print "\nResponse:\n${ackima}\n"
                  set pktlen [string length $ackima]
                  set netpktlen [binary format I $pktlen] ; # // Convert from local host order to network byte order
                  vo_vtp_print "pktlen=$pktlen\n"
                  set errno [catch {            
                     puts -nonewline $ssd $netpktlen
                     flush $ssd
                  } strerror ]
                  if {($errno==1)||([eof $ssd])} {
                     catch {close $ssd}
                     set ssd ""
                     vo_vtp_print "[vo_vtp_ut_ctime]  ERR: Socket writing.  errno=${errno}=${strerror}.\n"
                     continue
                  }
                  vo_vtp_print "[vo_vtp_ut_ctime] Ack: Iamalive response pktlen written.\n"
                  set errno [catch {            
                     puts -nonewline $ssd $ackima
                     flush $ssd
                  } strerror ]
                  if {($errno==1)||([eof $ssd])} {
                     catch {close $ssd}
                     set ssd ""
                     vo_vtp_print "[vo_vtp_ut_ctime]  ERR: Socket writing.  errno=${errno}=${strerror}.\n"
                     continue
                  }
                  vo_vtp_print "[vo_vtp_ut_ctime] Ack: Iamalive response ack written.\n"
               } else {
                  # Else reply with the regular ack:
                  # If this demo program implemented validation, it would go here.
                  set ackbuf [vo_vtp_build_voevent_response $xmlbuf]
                  vo_vtp_print "\nResponse:\n${ackbuf}\n"
                  set pktlen [string length $ackbuf]
                  set netpktlen [binary format I $pktlen] ; # // Convert from local host order to network byte order
                  vo_vtp_print "pktlen=$pktlen\n"
                  set errno [catch {            
                     puts -nonewline $ssd $netpktlen
                     flush $ssd
                  } strerror ]
                  if {($errno==1)||([eof $ssd])} {
                     catch {close $ssd}
                     set ssd ""
                     vo_vtp_print "[vo_vtp_ut_ctime]  ERR: Socket writing.  errno=${errno}=${strerror}.\n"
                     continue
                  }
                  vo_vtp_print "[vo_vtp_ut_ctime] Ack: VOEvent response pktlen written.\n"
                  set errno [catch {            
                     puts -nonewline $ssd $ackbuf
                     flush $ssd
                  } strerror ]
                  if {($errno==1)||([eof $ssd])} {
                     catch {close $ssd}
                     set ssd ""
                     vo_vtp_print "[vo_vtp_ut_ctime]  ERR: Socket writing.  errno=${errno}=${strerror}.\n"
                     continue
                  }
                  vo_vtp_print "[vo_vtp_ut_ctime] Ack: VOEvent response ack written.\n"

                  # THIS IS THE LOCATION WERE YOU CAN PARSE AND USE THE VOEVENT MESSAGE.
                  ################## ${xmlbuf}
                  set date [clock format [clock seconds] -format "%Y%m%dT%H%M%S"]
                  set fname "voevent_${date}.xml"
                  vo_vtp_print "Generate $vo_vtp_path/$fname\n"
                  set f [open $vo_vtp_path/$fname w]
                  puts -nonewline $f ${xmlbuf}
                  close $f

               }

            } ; # end of got_voe

         } ; # end of the read-something
          
         # end of the start of the reading sequence
      }

      # // Check to see if regularly receiving imalive from TAN server (reset connection if not):
      set nowtime [clock seconds]
      
      if {[expr $nowtime - $last_nowtime] > 200} { 
         # 3 times the imalive interval(60sec) plus 20 sec
         vo_vtp_print "WARN: It has been greater than 200 sec since the last (=[expr $nowtime - $last_nowtime]).\n"
         set last_nowtime [clock seconds]; # Reset it so we don't get a million error statements
         # Close connection & cause the program to re-establish the connection
         catch {close $ssd}
         set ssd ""
      }

      # This "after" is ONLY for this demo program.  It should not be included
      # in your site's application code as it most definitely adds up to 1 sec
      # to the response time to the socket/packet servicing.
      after 100; # Give the CPU a rest
      catch {update} ; # refresh the Tk GUI if exists

   }  ; #end while(1) loop

   close $ssd
}

# source [file join $audace(rep_install) gui audace vo_vtp_tools.tcl]
# set t [vo_vtp_main_thread]
proc vo_vtp_main_thread { {vo_vtp_path ""} {ip_address 209.208.78.170} {port_num 8099} } {
	set threadName [thread::create {
		thread::wait
	}]
	global audace
	set a [array get audace]
   if {$a==""} {
      global ros
      set audace(rep_gui) [file join $ros(root,audela) gui]
      set a [array get audace]
   }
	::thread::send $threadName [list array set audace $a]
	::thread::send $threadName [list uplevel #0 source \"[ file join $audace(rep_gui) audace vo_vtp_tools.tcl ]\"] msg
	::thread::send -async $threadName [list vo_vtp_main $vo_vtp_path $ip_address $port_num]
	#::thread::release $threadName
	return $threadName
}
