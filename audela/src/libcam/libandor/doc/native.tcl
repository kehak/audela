#
# source $audace(rep_install)/src/libcam/libandor/doc/native.tcl
#
# EXPNETTYPE unsigned int WINAPI GetDDGExternalOutputTime(at_u32 uiIndex, at_u64 * puiDelay, at_u64 * puiWidth);

set fname "$audace(rep_install)/src/external/include/Atmcd32d.h"
set f [open "$fname" r]
set lignes [split [read $f] \n]
close $f

set texte "\n"
append texte "   found=1;\n"
append texte "   if (argc>2) \{\n"
set texte_fonctions ""
set lfonctions ""
set nbf 0
foreach ligne $lignes {
	set n [regsub -all \{ $ligne "!" a]
	set ligne $a
	set key [lindex $ligne 0]
	if {$key!="EXPNETTYPE"} {
		continue
	}
	# --- fonction complete avec le ; final
	# "EXPNETTYPE unsigned int WINAPI "
	set n [regsub -all "EXPNETTYPE unsigned int WINAPI " $ligne "" fonction]
	set k [string last \; $fonction]
	if {$k<=0} {
		continue
	}
	# --- fonction complete sans le ; final
	set fonction [string range $fonction 0 [expr $k-1]]
	set fonc $fonction
	# --- decode les arguments
	set k1 [string first ( $fonc]
	if {$k1<=0} {
		continue
	}
	set fonction_name [string range $fonc 0 [expr $k1-1]]
	if {$fonction_name=="SetIsolatedCropModeEx"} {
		continue
	}
	::console::affiche_resultat "FONCTION $fonction_name\n"
	incr nbf
	if {$nbf>2000} {
		break
	}
	set fonc [string range $fonc [expr $k1+1] end]
	set sortie 0
	if {$nbf==1} {
		set texte0 ""
	} else {
		set texte0 "\} else "
	}
	append texte "      ${texte0}if (strcmp(argv\[2\],\"$fonction_name\")==0) \{\n"
	set pointeurs ""
	set typeargus ""
	set typeargu_inputs ""
	set typeargu_outputs ""
	set type_inpout ""
	set type_ninp 0
	set type_nout 0
	set valid 1
	while {$sortie==0} {
		set k2 [string first , $fonc]
		if {$k2<0} {
			set k2 [string first ) $fonc]
		}
		if {$k2<0} {
			break
		}
		set argu [string range $fonc 0 [expr $k2-1]]
		# --- typeargu est-il un pointeur ?
		set pointeur 0
		set kp [regsub -all {\*} $argu "" a]
		set argu $a
		if {$kp>0} {
			set pointeur 1
		}
		# --- typeargu: int void, etc
		set n [llength $argu]
		if {$n==1} { set n 2 }
		set typeargu [lrange $argu 0 [expr $n-2]]
::console::affiche_resultat "  typeargu=$typeargu\n"
		# --- on affiche le resultat
		if {$typeargu=="at_32"} {
			set typeargu "long"
		}
		if {$typeargu=="at_u32"} {
			set typeargu "unsigned long"
		}
		if {$typeargu=="at_u64"} {
			set typeargu "unsigned long long"
		}
		if {($typeargu=="void")&&($pointeur==1)} {
			set valid 0
		}
		if {($typeargu=="HWND")||($typeargu=="HANDLE")} {
			set valid 0
		}
		lappend pointeurs $pointeur
		lappend typeargus $typeargu
		if {($pointeur==0)||($typeargu=="char")||($typeargu=="void")} {
			set texte0 ""
			if {($typeargu=="char")} {
				set texte0 *
			}
			lappend typeargu_inputs "${typeargu}$texte0"
			lappend typeargu_outputs "-"
			lappend type_inpout "inp"
			incr type_ninp
			::console::affiche_resultat "  p=$pointeur ($typeargu) INP=$type_ninp\n"
		} else {
			lappend typeargu_inputs "-"
			lappend typeargu_outputs "${typeargu}"
			lappend type_inpout "out"
			incr type_nout
			::console::affiche_resultat "  p=$pointeur ($typeargu) OUT=$type_nout\n"
		}
		# fin de boucle
		set fonc [string range $fonc [expr $k2+1] end]
	}
	if {$valid==0} {
		continue
	}
	append texte_fonctions "$fonction_name "
	lappend lfonctions "$fonction_name"
	# === on traite la fonction en C
	set n [llength $typeargus]
	if {($type_ninp==1)&&([lindex $typeargus 0]=="void")&&([lindex $pointeurs 0]==0)} {
		append texte "         ${fonction_name}();\n"
	} else {
		set texte0 ""
		if ($type_ninp>=0) {
			# --- cas où le nb d'arguments en entree est insuffisant
			for {set k 0} {$k<$n} {incr k} {
				if {[lindex $type_inpout $k]=="out"} {
					continue
				}
				append texte0 "[lindex $typeargu_inputs $k] "
			}
			append texte "         if (argc<[expr 3+$type_ninp]) \{\n"
			append texte "            sprintf(ligne,\"Usage: %s %s %s $texte0\",argv\[0\],argv\[1\],argv\[2\]);\n"
			append texte "            Tcl_SetResult(interp,ligne,TCL_VOLATILE);\n"
			append texte "            return TCL_ERROR;\n"
			append texte "         \} else \{\n"
			# --- cas où le nb d'arguments en entree est suffisant
			append texte "            strcpy(ligne,\"\");\n"
			set kk 2
			set params ""
			for {set k 0} {$k<$n} {incr k} {
				set typeargu [lindex $typeargus $k]
				if {[lindex $type_inpout $k]=="inp"} {
					incr kk
					if {$typeargu=="int"} {
						append texte "            param_int\[$k\]=(int)atoi(argv\[$kk\]);\n"
						append params "param_int\[$k\]"
					} elseif {$typeargu=="long"} {
						append texte "            param_long\[$k\]=(long)atol(argv\[$kk\]);\n"
						append params "param_long\[$k\]"
					} elseif {$typeargu=="unsigned long"} {
						append texte "            param_ulong\[$k\]=(unsigned long)atol(argv\[$kk\]);\n"
						append params "param_ulong\[$k\]"
					} elseif {$typeargu=="float"} {
						append texte "            param_float\[$k\]=(float)atof(argv\[$kk\]);\n"
						append params "param_float\[$k\]"
					} elseif {$typeargu=="DWORD"} {
						append texte "            param_DWORD\[$k\]=(DWORD)atoi(argv\[$kk\]);\n"
						append params "param_DWORD\[$k\]"
					} elseif {$typeargu=="unsigned short"} {
						append texte "            param_ushort\[$k\]=(unsigned short)atoi(argv\[$kk\]);\n"
						append params "param_ushort\[$k\]"
					} elseif {$typeargu=="ColorDemosaicInfo"} {
						append texte "            param_cdemo\[$k\]=(ColorDemosaicInfo)atoi(argv\[$kk\]);\n"
						append params "param_cdemo\[$k\]"
					} elseif {$typeargu=="WORD"} {
						append texte "            param_WORD\[$k\]=(WORD)atoi(argv\[$kk\]);\n"
						append params "param_WORD\[$k\]"
					} elseif {$typeargu=="BYTE"} {
						append texte "            param_BYTE\[$k\]=(BYTE)atoi(argv\[$kk\]);\n"
						append params "param_BYTE\[$k\]"
					} elseif {$typeargu=="WhiteBalanceInfo"} {
						append texte "            param_wbal\[$k\]=(WhiteBalanceInfo)atoi(argv\[$kk\]);\n"
						append params "param_wbal\[$k\]"
					} elseif {$typeargu=="AndorCapabilities"} {
						append texte "            param_acap\[$k\]=(AndorCapabilities)atoi(argv\[$kk\]);\n"
						append params "param_acap\[$k\]"
					} elseif {$typeargu=="char"} {
						append texte "            strcpy(param_char\[$k\],argv\[$kk\]);\n"
						append params "param_char\[$k\]"
					} elseif {$typeargu=="const char"} {
						append texte "            strcpy(param_char\[$k\],argv\[$kk\]);\n"
						append params "param_char\[$k\]"
					} elseif {$typeargu=="double"} {
						append texte "            param_double\[$k\]=(double)atof(argv\[$kk\]);\n"
						append params "param_double\[$k\]"
					} elseif {$typeargu=="SYSTEMTIME"} {
						append texte "            param_stime\[$k\]=(SYSTEMTIME)atof(argv\[$kk\]);\n"
						append params "param_stime\[$k\]"
					} elseif {$typeargu=="void"} {
						append texte "            param_int\[$k\]=(int)atoi(argv\[$kk\]);\n"
						append params "(void)param_stime\[$k\]"
					} elseif {$typeargu=="unsigned char"} {
						append texte "            strcpy(param_uchar\[$k\],argv\[$kk\]);\n"
						append params "param_uchar\[$k\]"
					} elseif {$typeargu=="short"} {
						append texte "            param_short\[$k\]=(short)atoi(argv\[$kk\]);\n"
						append params "param_short\[$k\]"
					} else {
						append texte "            param_int\[$k\]=(int)atoi(argv\[$kk\]);\n"
						append params "param_int\[$k\]"
					}
				} else {
					if {$typeargu=="int"} {
						append params "&param_int\[$k\]"
					} elseif {$typeargu=="long"} {
						append params "&param_long\[$k\]"
					} elseif {$typeargu=="unsigned long"} {
						append params "&param_ulong\[$k\]"
					} elseif {$typeargu=="float"} {
						append params "&param_float\[$k\]"
					} elseif {$typeargu=="DWORD"} {
						append params "&param_DWORD\[$k\]"
					} elseif {$typeargu=="unsigned short"} {
						append params "&param_ushort\[$k\]"
					} elseif {$typeargu=="ColorDemosaicInfo"} {
						append params "&param_cdemo\[$k\]"
					} elseif {$typeargu=="WORD"} {
						append params "&param_WORD\[$k\]"
					} elseif {$typeargu=="BYTE"} {
						append params "&param_BYTE\[$k\]"
					} elseif {$typeargu=="WhiteBalanceInfo"} {
						append params "&param_wbal\[$k\]"
					} elseif {$typeargu=="AndorCapabilities"} {
						append params "&param_acap\[$k\]"
					} elseif {$typeargu=="char"} {
						append params "&param_char\[$k\]"
					} elseif {$typeargu=="double"} {
						append params "&param_double\[$k\]"
					} elseif {$typeargu=="SYSTEMTIME"} {
						append params "&param_stime\[$k\]"
					} elseif {$typeargu=="void"} {
						append params "(void*)&param_int\[$k\]"
					} elseif {$typeargu=="unsigned char"} {
						append params "param_uchar\[$k\]"
					} elseif {$typeargu=="short"} {
						append params "&param_short\[$k\]"
					} else {
						append params "&param_int\[$k\]"
					}
				}
				if {$k<[expr $n-1]} {
					append params ","
				}
			}
			append texte "            res=${fonction_name}(${params});\n"
			append texte "            if (res!=DRV_SUCCESS) \{\n"
			append texte "               sprintf(ligne,\"Error %d. %s\",res,get_status(res));\n"
			append texte "               Tcl_SetResult(interp,ligne,TCL_VOLATILE);\n"
			append texte "               return TCL_ERROR;\n"
			append texte "            \} else \{;\n"
			# --- decode les parametres de retour ---*/
			set texte0 "sprintf(ligne,\""
			set texte1 ""
			for {set k 0} {$k<$n} {incr k} {
				set typeargu [lindex $typeargus $k]
				if {$typeargu=="int"} {
					append texte0 "%d "
					append texte1 ",param_int\[$k\]"
				} elseif {$typeargu=="long"} {
					append texte0 "%ld "
					append texte1 ",param_long\[$k\]"
				} elseif {$typeargu=="unsigned long"} {
					append texte0 "%ld "
					append texte1 ",param_ulong\[$k\]"
				} elseif {$typeargu=="float"} {
					append texte0 "%f "
					append texte1 ",param_float\[$k\]"
				} elseif {$typeargu=="DWORD"} {
					append texte0 "%d "
					append texte1 ",param_DWORD\[$k\]"
				} elseif {$typeargu=="unsigned short"} {
					append texte0 "%d "
					append texte1 ",param_ushort\[$k\]"
				} elseif {$typeargu=="ColorDemosaicInfo"} {
					append texte0 "%p "
					append texte1 ",&param_cdemo\[$k\]"
				} elseif {$typeargu=="WORD"} {
					append texte0 "%d "
					append texte1 ",param_WORD\[$k\]"
				} elseif {$typeargu=="BYTE"} {
					append texte0 "%d "
					append texte1 ",param_BYTE\[$k\]"
				} elseif {$typeargu=="WhiteBalanceInfo"} {
					append texte0 "%p "
					append texte1 ",&param_wbal\[$k\]"
				} elseif {$typeargu=="AndorCapabilities"} {
					append texte0 "%p "
					append texte1 ",&param_acap\[$k\]"
				} elseif {$typeargu=="char"} {
					append texte0 "%s "
					append texte1 ",param_char\[$k\]"
				} elseif {$typeargu=="double"} {
					append texte0 "%lf "
					append texte1 ",param_double\[$k\]"
				} elseif {$typeargu=="SYSTEMTIME"} {
					append texte0 "%p "
					append texte1 ",&param_stime\[$k\]"
				} elseif {$typeargu=="void"} {
					append texte0 "%p "
					append texte1 ",(void*)&param_int\[$k\]"
				} elseif {$typeargu=="unsigned char"} {
					append texte0 "%s "
					append texte1 ",param_uchar\[$k\]"
				} elseif {$typeargu=="short"} {
					append texte0 "%d "
					append texte1 ",param_short\[$k\]"
				} else {
					append texte0 "%d "
					append texte1 ",param_int\[$k\]"
				}
			}
			append texte0 "\"${texte1})"
			append texte "               ${texte0};\n"
			append texte "               Tcl_SetResult(interp,ligne,TCL_VOLATILE);\n"
			append texte "               return TCL_OK;\n"
			append texte "            \};\n"
			#
			append texte "         \}\n"
		}
	}
}
append texte "      \} else \{\n"
append texte "         found=0;\n"
append texte "      \}\n"
append texte "   \} else \{\n"
append texte "      found=0;\n"
append texte "   \}\n"
append texte "   if (found==0) \{\n"
append texte "      Tcl_SetResult(interp,\"Available functions are: \",TCL_VOLATILE);\n"
set n [llength $lfonctions]
for {set k 0} {$k<$n} {incr k} {
	append texte "      Tcl_AppendResult(interp,\"[lindex $lfonctions $k] \",NULL);\n"
}
append texte "      return TCL_ERROR;\n"
append texte "   \}\n"

set fname "$audace(rep_install)/src/libcam/libandor/doc/native.c"
set f [open "$fname" w]
puts -nonewline $f $texte
close $f
