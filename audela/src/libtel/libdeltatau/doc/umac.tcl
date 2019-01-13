
package require udp

#typedef struct EthernetCmd
#{
#	byte RequestType;
#	byte Request;
#	WORD wValue;
#	WORD wIndex;
#	WORD wLength;
#	byte bData[1492];
#}ETHERNETCMD;
#
#define ETHERNETCMDSIZE 8
#define VR_DOWNLOAD 0x40 //0xC0//0x40
#define VR_GETLINE  0xB1
#define VR_PMAC_GETBUFFER 0xc5
#define VR_PMAC_SENDLINE 0xB0
#define VR_PMAC_GETRESPONSE 0xBF
#
#	strcpy(Cmd,Commande);
#	EthCmd.RequestType = VR_DOWNLOAD;
#	EthCmd.Request     = VR_PMAC_GETRESPONSE;
#	EthCmd.wValue	   = 0;
#	EthCmd.wIndex      = 0;
#	EthCmd.wLength     = htons( (WORD)strlen(Cmd));
#	strncpy((char*)&EthCmd.bData[0],Cmd,(WORD)strlen(Cmd));
#
#		SendSocketClient((char*)&EthCmd,ETHERNETCMDSIZE+strlen(Commande));
# char ReponseUMAC[1400];
# strcpy(Reponse,ReponseUMAC);
#
# Lecture position : #1p (1=ha 2=dec 3=foc 4=filtres)
# Lecture vitesse  : #1v
# Lecture erreur   : #1f
# Stope axe        : #1k
# Ecriture position: #1j=pos (pos=(degres)*10000)
# Ecriture vitesse : #1I122=vit (vit=(degres/s)*10)

# --- ouvre et configure le socket UDP
set host 192.168.10.46
set port 1025
if {1==0} {
	set fid [udp_open]
	fconfigure $fid -remote [list $host $port]
} else {
	set fid [socket $host $port]
}
puts "UMAC connecté\n"
after 200
fconfigure $fid -blocking 0 -buffering none -translation binary -encoding binary -buffersize 50

# --- commande à envoyer
set cmd "#1v"
set cmds {M132->X:\$078200,18,1 M140->Y:\$0000C0,0,1 M231->X:\$078208,17,1 M232->X:\$078208,18,1 M240->Y:\$000140,0,1 M245->Y:\$000140,10,1 M331->X:\$078210,17,1 M332->X:\$078210,18,1 M340->Y:\$0001C0,0,1 M345->Y:\$0001C0,10,1 M440->Y:\$000240,0,1 #2p #3p #4p}

foreach cmd $cmds {
	puts "\nCOMMANDE $cmd"
	# --- mise en forme et envoi
	set lencmd [string length $cmd]
	set EthCmd "[binary format H2H2H4H4S 40 BF 0000 0000 $lencmd]$cmd"
	set lencmd [expr $lencmd+8]
	binary scan $EthCmd H* chaine
	puts -nonewline $fid $EthCmd
	puts "CHAINE $chaine envoyée"

	# --- recupere la valeur en retour
	after 1000
	set res [read -nonewline $fid]
	#puts "CHAINE $res reçue\n"
	binary scan $res H* chaine
	puts "CHAINE $chaine reçue"
	set n [string length $chaine]
	set resultat ""
	for {set k 0} {$k<$n} {set k [expr $k+2]} {
		set h [string range $chaine $k [expr $k+1]]
		if {($h=="0d")||($h=="06")} {
			break
		}
		set ligne "format %c 0x$h"
		set res [eval $ligne]
		append resultat $res
	}
	puts "CHAINE $resultat mise en forme"
		
}

# --- ferme le socket
close $fid

