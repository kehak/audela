# test fait par Alain avec HEQ5 Pro 

# --- Init de la monture tube à l'ouest, pole nord, limites 2 2
# --- On fait un premier goto : tel1 hadec goto {11h 70} -blocking 0
# --- On attends la fin de ce pointage et puis on lance le script suivant:

proc af { } {
	set j1 [tel1 putread :j1]
	set j2 [tel1 putread :j2]
	set coords [tel1 hadec coord]
	set deci1 [tel1 decode $j1]
	set deci2 [tel1 decode $j2]
	set a2 [tel1 putread :a2]
	set adeci2 [tel1 decode $a2 +]
	set pole [expr $adeci2/4] 
	if {$deci2<$pole} {
		set tube Ouest
	} else {
		set tube Est
	}
	console::affiche_resultat "j1 = $j1 = $deci1 = [lindex $coords 0]    j2 = $j2 = $deci2 = [lindex $coords 1] ($tube)\n"
	return [list $j1 $j2]
}
set res [tel1 hadec coord]
console::affiche_resultat "Start Goto $res\n"
af
set res [tel1 hadec goto {1h 20} -blocking 0]
set j120 ""
set sortie 0
while {$sortie==0} {
	set j12 [af]
	after 500
	if {$j12==$j120} { 
		break
	}
	set j120 $j12
}
set res [tel1 hadec coord]
console::affiche_resultat "End Goto $res\n"

# Start Goto 11h00m00s00 +70d00m00s0
# j1 = 4043FA = -376000 = 11h00m00s00    j2 = D5122A = 2757333 = +70d00m00s0 (Est)
# j1 = B746FA = -375113 = 11h00m15s25    j2 = A2102A = 2756770 = +70d02m23s2 (Est)
# j1 = 797BFA = -361607 = 11h02m39s02    j2 = 60E229 = 2744928 = +70d34m28s8 (Est)
# j1 = 812EFB = -315775 = 11h10m28s40    j2 = A83C29 = 2702504 = +72d24m11s1 (Est)
# j1 = 1115FC = -256751 = 11h20m57s55    j2 = 784028 = 2637944 = +75d01m28s4 (Est)
# j1 = E115FD = -191007 = 11h30m22s68    j2 = 485527 = 2577736 = +77d22m47s6 (Est)
# j1 = 71FCFD = -131983 = 11h39m47s80    j2 = C86E26 = 2518728 = +79d44m04s4 (Est)
# j1 = 01E3FE = -72959 = 11h50m05s93    j2 = 388825 = 2459704 = +82d21m24s1 (Est)
# j1 = D1E3FF = -7215 = 11h59m42s23    j2 = 788724 = 2393976 = +84d42m40s9 (Est)
# j1 = 41CA00 = 51777 = 12h09m07s36    j2 = E8A023 = 2334952 = +87d04m00s1 (Est)
# j1 = E1B001 = 110817 = 12h18m32s48    j2 = 58BA22 = 2275928 = +89d25m14s6 (Est)
# j1 = E1B602 = 177889 = 00h29m14s66    j2 = 58B421 = 2208856 = +87d54m12s6 (Ouest)
# j1 = 819D03 = 236929 = 00h38m39s94    j2 = C8CD20 = 2149832 = +85d32m53s4 (Ouest)
# j1 = F18304 = 295921 = 00h48m05s06    j2 = 38E71F = 2090808 = +83d11m41s2 (Ouest)
# j1 = 416505 = 353601 = 00h56m51s12    j2 = C8EB1E = 2026440 = +80d37m34s5 (Ouest)
# j1 = ADA805 = 370861 = 00h59m18s22    j2 = 28051E = 1967400 = +78d16m17s7 (Ouest)
# j1 = 16B705 = 374550 = 00h59m48s16    j2 = A81E1D = 1908392 = +75d55m00s8 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 18381C = 1849368 = +73d33m44s0 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 88511B = 1790344 = +71d12m27s1 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = F86A1A = 1731320 = +68d51m10s3 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 688419 = 1672296 = +66d29m53s4 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = A88318 = 1606568 = +63d52m36s1 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 089D17 = 1547528 = +61d31m16s9 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 78B616 = 1488504 = +59d10m02s4 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 88B015 = 1421448 = +56d29m29s7 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = F8C914 = 1362424 = +54d08m12s8 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 78E313 = 1303416 = +51d46m56s0 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 48E712 = 1238856 = +49d09m36s3 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 18FC11 = 1178648 = +46d48m14s9 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 881511 = 1119624 = +44d27m02s6 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = F82E10 = 1060600 = +41d49m40s7 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 382E0F = 994872 = +39d28m26s1 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = A8470E = 935848 = +37d07m09s3 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 18610D = 876824 = +34d45m52s4 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 48600C = 811080 = +32d08m32s8 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = C8790B = 752072 = +29d47m13s6 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 38930A = 693048 = +27d25m56s8 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = B89709 = 628664 = +24d51m52s4 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 18B108 = 569624 = +22d30m35s6 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 98F107 = 520600 = +20d40m46s4 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = BCB607 = 505532 = +20d08m35s3 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = DCAA07 = 502492 = +20d02m15s6 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 56A607 = 501334 = +20d00m00s0 (Ouest)
# j1 = C0BC05 = 376000 = 01h00m00s00    j2 = 56A607 = 501334 = +20d00m00s0 (Ouest)
# End Goto 01h00m00s00 +20d00m00s0

A noter que dans ce cas là il y a retournement et les 2 montures répondent donc différemment.

A titre de comparaison, avec le tube de préférnece à l'est:
# --- Init de la monture tube à l'est, pole nord, limites 2 2
# --- On fait un premier goto : tel1 hadec goto {11h 70} -blocking 0
# --- On attends la fin de ce pointage et puis on lance le script suivant:

# Start Goto 11h00m00s00 +70d00m00s0
# j1 = 4043FA = -376000 = 11h00m00s00    j2 = D5122A = 2757333 = +70d00m00s0 (Est)
# j1 = CB3FFA = -376885 = 10h59m44s72    j2 = 08152A = 2757896 = +69d57m36s8 (Est)
# j1 = 150BFA = -390379 = 10h57m21s11    j2 = 48432A = 2769736 = +69d25m31s5 (Est)
# j1 = 2D58F9 = -436179 = 10h49m32s34    j2 = 18E92A = 2812184 = +67d35m48s1 (Est)
# j1 = AD71F8 = -495187 = 10h38m50s16    j2 = 68EA2B = 2878056 = +64d55m15s4 (Est)
# j1 = AD6BF7 = -562259 = 10h29m25s04    j2 = A8D52C = 2938280 = +62d33m58s5 (Est)
# j1 = 1D85F6 = -621283 = 10h19m59s92    j2 = 38BC2D = 2997304 = +60d12m41s7 (Est)
# j1 = 7D9EF5 = -680323 = 10h09m42s09    j2 = C8A22E = 3056328 = +57d35m22s0 (Est)
# j1 = CD9DF4 = -746035 = 10h00m05s33    j2 = 98A32F = 3122072 = +55d14m02s9 (Est)
# j1 = FDB1F3 = -806403 = 09h50m27s49    j2 = 588F30 = 3182424 = +52d49m33s0 (Est)
# j1 = 6DCBF2 = -865427 = 09h40m09s82    j2 = E87531 = 3241448 = +50d12m15s7 (Est)
# j1 = 9DCAF1 = -931171 = 09h30m33s06    j2 = A87632 = 3307176 = +47d50m58s8 (Est)
# j1 = 0DE4F0 = -990195 = 09h21m07s93    j2 = 385D33 = 3366200 = +45d29m44s2 (Est)
# j1 = 8DFDEF = -1049203 = 09h11m43s12    j2 = A84334 = 3425192 = +43d08m32s0 (Est)
# j1 = 3D07EF = -1112259 = 09h01m39s23    j2 = 183A35 = 3488280 = +40d37m29s2 (Est)
# j1 = AD20EE = -1171283 = 08h52m13s96    j2 = A82036 = 3547304 = +38d16m14s6 (Est)
# j1 = 1D3AED = -1230307 = 08h42m48s83    j2 = 280737 = 3606312 = +35d54m57s8 (Est)
# j1 = 9D3EEC = -1294691 = 08h32m32s39    j2 = B80238 = 3670712 = +33d20m51s1 (Est)
# j1 = 1D58EB = -1353699 = 08h23m07s27    j2 = 38E938 = 3729720 = +30d59m34s3 (Est)
# j1 = 7D71EA = -1412739 = 08h13m42s14    j2 = D8CF39 = 3788760 = +28d38m19s7 (Est)
# j1 = ED8AE9 = -1471763 = 08h04m17s02    j2 = 58B63A = 3847768 = +26d17m00s6 (Est)
# j1 = 5DA4E8 = -1530787 = 07h54m51s90    j2 = E89C3B = 3906792 = +23d55m43s7 (Est)
# j1 = CDBDE7 = -1589811 = 07h45m26s77    j2 = 78833C = 3965816 = +21d34m26s9 (Est)
# j1 = 2DD7E6 = -1648851 = 07h36m01s80    j2 = A8073D = 3999656 = +20d22m49s3 (Est)
# j1 = 1DDBE5 = -1713379 = 07h25m32s34    j2 = AD293D = 4008365 = +20d04m59s8 (Est)
# j1 = EDEFE4 = -1773587 = 07h16m07s22    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 5D09E4 = -1832611 = 07h06m42s09    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = CD22E3 = -1891635 = 06h56m24s89    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 3D27E2 = -1956035 = 06h47m00s53    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = AD40E1 = -2015059 = 06h37m35s40    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 1D5AE0 = -2074083 = 06h27m17s58    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 5D59DF = -2139811 = 06h17m40s82    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = CD72DE = -2198835 = 06h08m15s85    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 4D8CDD = -2257843 = 05h58m50s57    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = BD90DC = -2322243 = 05h48m34s13    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 2DAADB = -2381267 = 05h39m09s00    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 9DC3DA = -2440291 = 05h29m44s03    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 1DC8D9 = -2504675 = 05h19m27s44    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 8DE1D8 = -2563699 = 05h10m02s32    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = EDFAD7 = -2622739 = 05h00m37s19    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 6D14D7 = -2681747 = 04h51m12s07    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = DD2DD6 = -2740771 = 04h41m46s49    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 4D47D5 = -2799795 = 04h32m21s82    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = AD60D4 = -2858835 = 04h22m56s85    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 9D64D3 = -2923363 = 04h12m27s39    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 5D79D2 = -2983587 = 04h03m02s26    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = DD92D1 = -3042595 = 03h53m36s99    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 4DACD0 = -3101619 = 03h43m19s32    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 8DABCF = -3167347 = 03h33m42s71    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = DDC4CE = -3226403 = 03h24m17s58    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 6DDECD = -3285395 = 03h14m52s46    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = ADDDCC = -3351123 = 03h04m23s00    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 1DF7CB = -3410147 = 02h54m57s72    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 8D10CB = -3469171 = 02h45m32s90    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = FD14CA = -3533571 = 02h35m16s46    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 5D2EC9 = -3592611 = 02h25m51s34    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = ED47C8 = -3651603 = 02h16m26s21    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 5D61C7 = -3710627 = 02h07m01s09    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = BD7AC6 = -3769667 = 01h57m35s97    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 1D94C5 = -3828707 = 01h48m10s69    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = ADADC4 = -3887699 = 01h38m45s57    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 8DB1C3 = -3952243 = 01h28m16s26    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 4DC6C2 = -4012467 = 01h18m51s13    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = BDDFC1 = -4071491 = 01h09m26s16    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = CD28C1 = -4118323 = 01h02m07s42    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = 35F0C0 = -4132811 = 01h00m27s55    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = B9E6C0 = -4135239 = 01h00m05s23    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = C0E3C0 = -4136000 = 01h00m00s00    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# j1 = C0E3C0 = -4136000 = 01h00m00s00    j2 = AA323D = 4010666 = +20d00m00s0 (Est)
# End Goto 01h00m00s00 +20d00m00s0

A noter que dans ce cas là il n'y a pas de retournement et les 2 montures marchent bien.

==============================================================================================
Rappel de ce qui est vu par Jerome:

## pointage ok, mais pas les coordonnees:
##  quand arrive vers 14h+, passe a 2h+ et monte jusqu'a 11h
##  les coordonnees finales sont correctes

tel1 hadec goto {1h 20} -blocking 0

tel1 hadec coord
# 11h16m05s36 +73d46m08s3
tel1 hadec coord
# 11h26m45s56 +76d26m11s3
tel1 hadec coord
# 11h36m07s46 +78d46m39s8
tel1 hadec coord
# 11h44m48s86 +80d57m00s8
tel1 hadec coord
# 11h54m10s76 +83d17m29s3
tel1 hadec coord
# 07h44m38s66 +85d32m51s8
tel1 hadec coord
# 07h53m40s46 +87d48m14s3
tel1 hadec coord
# 20h03m02s06 +89d51m17s1
tel1 hadec coord
# 20h11m23s36 +87d45m57s6
tel1 hadec coord
# 20h20m45s26 +85d25m33s6
tel1 hadec coord
# 20h29m26s66 +83d15m08s1
tel1 hadec coord
# 20h37m49s19 +81d04m47s1
tel1 hadec coord
# 20h40m56s21 +78d59m00s6
tel1 hadec coord
# 20h41m26s40 +76d48m35s1
tel1 hadec coord
# 20h41m26s40 +74d43m15s6
tel1 hadec coord
# 20h41m26s40 +72d37m24s6

#...

tel1 hadec coord
# 20h41m26s40 +20d00m00s0

## pointage ok, mais pas les coordonnees:

