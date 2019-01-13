#
## @file eshel.tcl
#  @brief Outil de fabrication des fichier Kit et de déploiement des plugin
#  @author Michel Pujol
#  $Id: eshel.tcl 13443 2016-03-20 15:06:25Z rzachantke $
#

## namespace eshel
#  @brief Outil de fabrication des fichier Kit et de déploiement des plugin
#  @remark Point d'entrée principal ::eshel::processgui::run
#

namespace eval ::eshel {
   global caption
   package provide eshel 2.4

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] eshel.cap ]
}

#------------------------------------------------------------
#  ::eshel::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#
proc ::eshel::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
# getPluginOS
#    Retourne le ou les OS de fonctionnement du plugin
#
# Parametres :
#    Aucun
# Return :
#    La liste des OS supportes par le plugin
#------------------------------------------------------------
proc ::eshel::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le repertoire de plugin
#
proc ::eshel::getPluginDirectory { } {
   return "eshel"
}

#------------------------------------------------------------
# getPluginHelp
#     retourne le nom du fichier d'aide principal
#
proc ::eshel::getPluginHelp { } {
   return "eshel.htm"
}

#------------------------------------------------------------
#  ::eshel::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
proc ::eshel::getPluginTitle { } {
   global caption

   return $caption(eshel,title)
}

#------------------------------------------------------------
#  ::eshel::getPluginType
#     retourne le type de plugin
#
proc ::eshel::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
#  deletePluginInstance
#     suppprime l'instance du plugin
#
proc ::eshel::deletePluginInstance { visuNo } {
   variable private

   #--- j'arrete les acquisitions en cours
   ::eshel::stopAcquisition $visuNo
   #--- je ferme le fichier de trace
   closeLogFile

   #--- je ferme le panneau
   destroy $private($visuNo,frm)
}

#------------------------------------------------------------
# createPluginInstance
#  cree une instance l'outil
#  initialise les variables globales et locales par defaut
#  affiche les widgets dans le panneau de l'outil
#
proc ::eshel::createPluginInstance { base { visuNo 1 } } {
   global audace caption conf
   variable private

   if { [llength [info commands eshel_*]] == 0 } {
      #--- si c'est la premiere instance, je charge le code TCL
      package require Tablelist
      set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
      source [ file join $dir process.tcl ]
      source [ file join $dir processgui.tcl ]
      source [ file join $dir processoption.tcl ]
      source [ file join $dir instrument.tcl ]
      source [ file join $dir instrumentgui.tcl ]
      source [ file join $dir session.tcl ]
      source [ file join $dir acquisition.tcl ]
      source [ file join $dir wizard.tcl ]
      source [ file join $dir eshelfile.tcl]
      source [ file join $dir visu.tcl]
      source [ file join $dir response.tcl]
      source [ file join $dir makeseries.tcl ]
      if { [file exists [ file join $dir libeshel.dll]]  } {
         set catchResult [ catch {
            load [ file join $dir libeshel.dll]
         } ]
         if { $catchResult == 1 } {
            ::console::affiche_erreur "$::errorInfo\n"
         }
      }
   }

   #--- je cree les variables globales si elles n'existaient pas
   if { ! [ info exists conf(eshel,mainDirectory) ] }     { set conf(eshel,mainDirectory)      "$::audace(rep_images)" }
   if { ! [ info exists conf(eshel,masterDirectory) ] }   { set conf(eshel,masterDirectory)    "$::audace(rep_images)/master" }
   if { ! [ info exists conf(eshel,rawDirectory) ] }      { set conf(eshel,rawDirectory)       "$::audace(rep_images)/raw" }
   if { ! [ info exists conf(eshel,referenceDirectory)]}  { set conf(eshel,referenceDirectory) "$::audace(rep_images)/reference" }
   if { ! [ info exists conf(eshel,tempDirectory) ] }     { set conf(eshel,tempDirectory)      "$::audace(rep_images)/temp" }
   if { ! [ info exists conf(eshel,archiveDirectory) ] }  { set conf(eshel,archiveDirectory)   "$::audace(rep_images)/archive" }
   if { ! [ info exists conf(eshel,processedDirectory)]}  { set conf(eshel,processedDirectory) "$::audace(rep_images)/processed" }
   if { ! [ info exists conf(eshel,scriptFileName) ] }    { set conf(eshel,scriptFileName)     "process.tcl" }
   if { ! [ info exists conf(eshel,currentSequenceId) ] } { set conf(eshel,currentSequenceId)  "object"}
   if { ! [ info exists conf(eshel,expnb) ] }             { set conf(eshel,expnb)              1 }
   if { ! [ info exists conf(eshel,exptime) ] }           { set conf(eshel,exptime)            1 }
   if { ! [ info exists conf(eshel,objectList) ] }        { set conf(eshel,objectList)         "" }
   if { ! [ info exists conf(eshel,instrume) ] }          { set conf(eshel,instrume)           "eShel #001" }
   if { ! [ info exists conf(eshel,processAuto) ] }       { set conf(eshel,processAuto)        1 }
   if { ! [ info exists conf(eshel,binning) ] }           { set conf(eshel,binning)            "1x1" }
   if { ! [ info exists conf(eshel,repeat) ] }            { set conf(eshel,repeat)             1 }
   if { ! [ info exists conf(eshel,showProfile) ] }       { set conf(eshel,showProfile)        1 }
   if { ! [ info exists conf(eshel,enabledLogFile) ] }    { set conf(eshel,enabledLogFile)     1 }
   if { ! [ info exists conf(eshel,enableComment) ] }     { set conf(eshel,enableComment)      1 }
   if { ! [ info exists conf(eshel,enableGuidingUnit) ]}  { set conf(eshel,enableGuidingUnit)  1 }
   if { ! [ info exists conf(eshel,logFileName) ] }       { set conf(eshel,logFileName)        "eshellog.html" }
   if { ! [ info exists conf(eshel,keywordConfigName) ] } { set conf(eshel,keywordConfigName)  "default" }

   if { ! [ info exists conf(eshel,currentInstrument) ] } { set conf(eshel,currentInstrument)  "default" }

   #--- Parametres instrument par defaut
   set prefix "eshel,instrument,config,default"
   if { ! [ info exists conf($prefix,configName) ] }      { set conf($prefix,configName)       "default" }
   #------ Spectographe
   if { ! [ info exists conf($prefix,spectroName) ] }     { set conf($prefix,spectroName)      "eshel" }
   if { ! [ info exists conf($prefix,alpha) ] }           { set conf($prefix,alpha)            62.2 }
   if { ! [ info exists conf($prefix,beta) ] }            { set conf($prefix,beta)             0 }
   if { ! [ info exists conf($prefix,gamma) ] }           { set conf($prefix,gamma)            5.75 }
   if { ! [ info exists conf($prefix,grating) ] }         { set conf($prefix,grating)          79.0 }
   if { ! [ info exists conf($prefix,focale) ] }          { set conf($prefix,focale)           85.0 }
   if { ! [ info exists conf($prefix,distorsion) ] }      { set conf($prefix,distorsion)       "" }
   if { ! [ info exists conf($prefix,spectrograhLink) ] } { set conf($prefix,spectrograhLink)  "" }
   if { ! [ info exists conf($prefix,mirror,bit) ] }      { set conf($prefix,mirror,bit)       1 }
   if { ! [ info exists conf($prefix,led,bit) ] }         { set conf($prefix,led,bit)          2 }
   if { ! [ info exists conf($prefix,thar,bit) ] }        { set conf($prefix,thar,bit)         3 }
   if { ! [ info exists conf($prefix,tungsten,bit) ] }    { set conf($prefix,tungsten,bit)     4 }
   #------ Telescope
   if { ! [ info exists conf($prefix,telescopeName) ] }   { set conf($prefix,telescopeName)    "default telescope" }
   #------ Camera
   if { ! [ info exists conf($prefix,cameraName) ] }      { set conf($prefix,cameraName)       "Audine Kaf 400" }
   if { ! [ info exists conf($prefix,cameraLabel) ] }     { set conf($prefix,cameraLabel)      "Audine" }
   if { ! [ info exists conf($prefix,cameraNamespace)] }  { set conf($prefix,cameraNamespace)  "audine" }
   if { ! [ info exists conf($prefix,binning)] }          { set conf($prefix,binning)          [list 1 1 ] }
   if { ! [ info exists conf($prefix,pixelSize) ] }       { set conf($prefix,pixelSize)        0.009 }
   if { ! [ info exists conf($prefix,width) ] }           { set conf($prefix,width)            1530 }
   if { ! [ info exists conf($prefix,height) ] }          { set conf($prefix,height)           1020 }
   if { ! [ info exists conf($prefix,x1) ] }              { set conf($prefix,x1)               1 }
   if { ! [ info exists conf($prefix,y1) ] }              { set conf($prefix,y1)               1 }
   if { ! [ info exists conf($prefix,x2) ] }              { set conf($prefix,x2)               $conf($prefix,width) }
   if { ! [ info exists conf($prefix,y2) ] }              { set conf($prefix,y2)               $conf($prefix,height) }
   #------ Traitement
   if { ! [ info exists conf($prefix,quickProcess) ] }    { set conf($prefix,quickProcess)     1 }
   if { ! [ info exists conf($prefix,boxWide) ] }         { set conf($prefix,boxWide)          25 }
   if { ! [ info exists conf($prefix,wideOrder) ] }       { set conf($prefix,wideOrder)        12 }
   if { ! [ info exists conf($prefix,threshold) ] }       { set conf($prefix,threshold)        100 }
   if { ! [ info exists conf($prefix,minOrder) ] }        { set conf($prefix,minOrder)         33 }
   if { ! [ info exists conf($prefix,maxOrder) ] }        { set conf($prefix,maxOrder)         44 }
   if { ! [ info exists conf($prefix,refNum) ] }          { set conf($prefix,refNum)           34 }
   if { ! [ info exists conf($prefix,refX) ] }            { set conf($prefix,refX)             978 }
   if { ! [ info exists conf($prefix,refY) ] }            { set conf($prefix,refY)             826 }
   if { ! [ info exists conf($prefix,refLambda) ] }       { set conf($prefix,refLambda)        6583.906 }
   if { ! [ info exists conf($prefix,calibIter) ] }       { set conf($prefix,calibIter)        4 }
   if { ! [ info exists conf($prefix,hotPixelEnabled)] }  { set conf($prefix,hotPixelEnabled)  0 }
   if { ! [ info exists conf($prefix,hotPixelList) ] }    { set conf($prefix,hotPixelList)     [list ] }
   if { ! [ info exists conf($prefix,cosmicEnabled)] }    { set conf($prefix,cosmicEnabled)    0 }
   if { ! [ info exists conf($prefix,cosmicThreshold)] }  { set conf($prefix,cosmicThreshold)  400 }
   if { ! [ info exists conf($prefix,flatFieldEnabled)] } { set conf($prefix,flatFieldEnabled) 0 }
   if { ! [ info exists conf($prefix,responseOption)] }   { set conf($prefix,responseOption)   "NONE" }  ;# MANUAL , AUTO, NONE
   if { ! [ info exists conf($prefix,responseFileName)] } { set conf($prefix,responseFileName) "" }
   if { ! [ info exists conf($prefix,responsePerOrder)] } { set conf($prefix,responsePerOrder) 1 }      ; # 0=FULL spectrum 1=per order
   if { ! [ info exists conf($prefix,saveObjectImage)] }  { set conf($prefix,saveObjectImage)  1 }      ; # enregistre l'image 2D de l'OBJET dans le fichier de sortie
   if { ! [ info exists conf($prefix,debugLog)] }         { set conf($prefix,debugLog)         0 }      ; # set debug log
   #--- liste des mots clefs a mettre dans les acquisitions
   set conf(keyword,visu1,check) "1,check,IMAGETYP 1,check,SERIESID 1,check,DETNAM 1,check,TELESCOP 1,check,OBSERVER 1,check,OBJNAME 1,check,EXPOSURE 1,check,INSTRUME 1,check,SWCREATE 1,check,SITENAME 1,check,SITELONG 1,check,SITELAT 1,check,SITEELEV"

   if { ! [ info exists conf($prefix,orderDefinition) ] } {
      set conf($prefix,orderDefinition) { \
         { 30 25  1510 0.0 } \
         { 31 30  1510 0.0 } \
         { 32 35  1510 0.0 } \
         { 33 40  1510 0.0 } \
         { 34 50  1480 0.0 } \
         { 35 60  1470 0.0 } \
         { 36 75  1455 0.0 } \
         { 37 90  1440 0.0 } \
         { 38 105 1425 0.0 } \
         { 39 120 1410 0.0 } \
         { 40 135 1395 0.0 } \
         { 41 150 1380 0.0 } \
         { 42 165 1365 0.0 } \
         { 43 180 1350 0.0 } \
         { 44 195 1335 0.0 } \
         { 45 210 1320 0.0 } \
         { 46 225 1305 0.0 } \
         { 47 240 1290 0.0 } \
         { 48 260 1270 0.0 } \
         { 49 280 1250 0.0 } \
         { 50 300 1230 0.0 } \
         { 51 300 1230 0.0 } \
         { 52 300 1230 0.0 } \
         { 53 300 1230 0.0 } \
         { 54 300 1230 0.0 } \
      }
   }

   if { ! [ info exists conf($prefix,cropLambda) ] } {
     set conf($prefix,cropLambda) { \
         { 31 7110 7408 } \
         { 32 6891 7126 } \
         { 33 6684 6906 } \
         { 34 6490 6699 } \
         { 35 6307 6503 } \
         { 36 6133 6319 } \
         { 37 5969 6145 } \
         { 38 5814 5981 } \
         { 39 5666 5824 } \
         { 40 5525 5676 } \
         { 41 5392 5535 } \
         { 42 5264 5401 } \
         { 43 5143 5273 } \
         { 44 5027 5151 } \
         { 45 4922 5035 } \
         { 46 4809 4930 } \
         { 47 4713 4817 } \
         { 48 4610 4721 } \
         { 49 4516 4617 } \
         { 50 4426 4523 } \
         { 51 4370 4433 } \
         { 52 4257 4376 } \
      }
   }

   if { ! [ info exists conf($prefix,lineList) ] } {
      set conf($prefix,lineList) { \
         3786.382 \
         3789.168 \
         3790.795 \
         3798.103 \
         3803.075 \
         3809.456 \
         3818.686 \
         3823.068 \
         3828.384 \
         3830.774 \
         3834.679 \
         3840.800 \
         3842.897 \
         3845.406 \
         3846.888 \
         3850.581 \
         3852.135 \
         3868.528 \
         3879.644 \
         3886.916 \
         3891.979 \
         3895.419 \
         3898.437 \
         3903.102 \
         3911.909 \
         3914.768 \
         3916.418 \
         3919.023 \
         3923.800 \
         3933.661 \
         3946.392 \
         3950.395 \
         3956.691 \
         3959.300 \
         3962.420 \
         3967.392 \
         3974.477 \
         3979.356 \
         3990.492 \
         4001.894 \
         4005.093 \
         4008.210 \
         4012.495 \
         4019.129 \
         4024.803 \
         4027.009 \
         4032.595 \
         4039.864 \
         4042.894 \
         4045.965 \
         4052.921 \
         4054.526 \
         4059.253 \
         4063.407 \
         4067.451 \
         4072.385 \
         4075.503 \
         4081.368 \
         4083.469 \
         4086.520 \
         4094.747 \
         4100.341 \
         4103.912 \
         4116.714 \
         4127.412 \
         4131.002 \
         4134.068 \
         4135.480 \
         4142.701 \
         4156.086 \
         4162.509 \
         4165.766 \
         4170.533 \
         4181.883 \
         4184.138 \
         4194.936 \
         4201.972 \
         4204.041 \
         4208.411 \
         4210.923 \
         4214.828 \
         4217.431 \
         4220.065 \
         4222.637 \
         4228.158 \
         4230.427 \
         4235.464 \
         4241.095 \
         4248.391 \
         4253.538 \
         4256.254 \
         4258.520 \
         4260.333 \
         4262.612 \
         4269.943 \
         4276.807 \
         4278.323 \
         4286.229 \
         4288.670 \
         4291.810 \
         4297.306 \
         4300.650 \
         4304.957 \
         4307.176 \
         4311.799 \
         4315.254 \
         4318.416 \
         4320.274 \
         4325.274 \
         4328.915 \
         4330.844 \
         4332.030 \
         4338.895 \
         4340.895 \
         4342.444 \
         4345.168 \
         4348.064 \
         4367.870 \
         4375.954 \
         4379.667 \
         4385.057 \
         4408.883 \
         4426.001 \
         4433.838 \
         4448.879 \
         4458.001 \
         4474.759 \
         4481.810 \
         4493.333 \
         4510.733 \
         4515.118 \
         4522.323 \
         4530.552 \
         4545.052 \
         4555.813 \
         4561.348 \
         4570.972 \
         4579.350 \
         4589.898 \
         4592.666 \
         4598.763 \
         4609.567 \
         4628.441 \
         4633.766 \
         4637.233 \
         4657.901 \
         4663.203 \
         4668.172 \
         4669.984 \
         4673.661 \
         4676.055 \
         4686.195 \
         4695.038 \
         4702.316 \
         4703.990 \
         4723.438 \
         4726.868 \
         4732.053 \
         4735.906 \
         4764.865 \
         4766.601 \
         4778.294 \
         4789.387 \
         4806.020 \
         4808.134 \
         4813.896 \
         4826.700 \
         4840.849 \
         4847.810 \
         4863.172 \
         4865.477 \
         4872.917 \
         4879.863 \
         4889.042 \
         4894.955 \
         4904.752 \
         4919.816 \
         4933.209 \
         4939.642 \
         4943.064 \
         4945.458 \
         4965.080 \
         4972.160 \
         4982.487 \
         4985.373 \
         4993.749 \
         5002.097 \
         5009.334 \
         5017.163 \
         5019.806 \
         5028.656 \
         5039.320 \
         5044.720 \
         5047.043 \
         5059.861 \
         5062.037 \
         5067.974 \
         5090.545 \
         5096.485 \
         5100.621 \
         5115.045 \
         5125.765 \
         5141.783 \
         5145.308 \
         5151.612 \
         5154.243 \
         5158.604 \
         5162.285 \
         5165.773 \
         5187.746 \
         5195.814 \
         5199.164 \
         5211.230 \
         5213.349 \
         5219.110 \
         5221.271 \
         5231.160 \
         5247.655 \
         5252.788 \
         5258.360 \
         5260.104 \
         5266.710 \
         5296.279 \
         5300.523 \
         5317.495 \
         5326.976 \
         5343.581 \
         5360.150 \
         5362.575 \
         5374.822 \
         5379.110 \
         5384.301 \
         5386.611 \
         5390.440 \
         5394.761 \
         5407.653 \
         5410.769 \
         5417.486 \
         5421.352 \
         5424.008 \
         5431.112 \
         5439.989 \
         5457.416 \
         5464.205 \
         5467.170 \
         5495.874 \
         5499.255 \
         5504.302 \
         5506.113 \
         5509.994 \
         5514.873 \
         5524.957 \
         5539.262 \
         5548.176 \
         5554.070 \
         5558.702 \
         5579.358 \
         5587.026 \
         5595.063 \
         5597.476 \
         5606.733 \
         5615.319 \
         5650.704 \
         5665.180 \
         5677.053 \
         5681.900 \
         5685.192 \
         5691.661 \
         5700.917 \
         5707.103 \
         5720.183 \
         5725.388 \
         5739.519 \
         5741.829 \
         5753.026 \
         5760.551 \
         5763.529 \
         5768.181 \
         5772.114 \
         5773.946 \
         5789.645 \
         5800.829 \
         5804.141 \
         5812.972 \
         5815.422 \
         5832.370 \
         5834.263 \
         5860.310 \
         5863.718 \
         5882.624 \
         5888.584 \
         5891.451 \
         5912.085 \
         5914.671 \
         5928.813 \
         5938.825 \
         5942.668 \
         5944.647 \
         5973.665 \
         5987.302 \
         5991.007 \
         5994.129 \
         5998.999 \
         6021.036 \
         6025.150 \
         6032.127 \
         6037.697 \
         6043.223 \
         6049.051 \
         6059.373 \
         6088.030 \
         6090.785 \
         6098.803 \
         6114.923 \
         6145.441 \
         6151.993 \
         6155.238 \
         6169.822 \
         6182.622 \
         6188.125 \
         6191.905 \
         6198.223 \
         6203.493 \
         6207.220 \
         6212.503 \
         6215.938 \
         6224.527 \
         6234.855 \
         6243.120 \
         6248.405 \
         6261.418 \
         6274.117 \
         6296.872 \
         6303.251 \
         6307.657 \
         6342.859 \
         6348.737 \
         6355.910 \
         6364.894 \
         6369.575 \
         6371.844 \
         6376.931 \
         6384.717 \
         6403.013 \
         6406.446 \
         6411.899 \
         6416.307 \
         6431.555 \
         6457.282 \
         6462.595 \
         6466.553 \
         6483.083 \
         6490.737 \
         6512.364 \
         6531.342 \
         6538.112 \
         6554.160 \
         6577.214 \
         6583.906 \
         6588.540 \
         6591.484 \
         6598.678 \
         6604.853 \
         6632.084 \
         6643.698 \
         6662.269 \
         6666.359 \
         6677.282 \
         6684.293 \
         6698.876 \
         6719.218 \
         6727.458 \
         6752.833 \
         6766.612 \
         6780.125 \
         6791.235 \
         6818.260 \
         6827.249 \
         6834.925 \
         6861.269 \
         6871.289 \
         6879.582 \
         6911.226 \
         6937.664 \
         6943.600 \
         6951.478 \
         6960.250 \
         6989.655 \
         7000.804 \
         7018.567 \
         7030.251 \
         7084.169 \
         7107.478 \
         7125.820 \
         7130.185 \
         7131.359 \
         7140.462 \
         7147.042 \
         7150.284 \
         7153.588 \
         7156.942 \
         7159.947 \
         7162.557 \
         7168.895 \
         7173.373 \
         7191.133 \
         7206.980 \
         7208.006 \
         7212.690 \
         7220.981 \
         7225.110 \
         7229.939 \
         7233.537 \
         7240.185 \
         7246.128 \
         7255.354 \
         7258.177 \
         7265.172 \
         7270.664 \
         7272.936 \
         7284.903 \
         7296.266 \
         7305.404 \
         7311.716 \
         7316.005 \
         7324.807 \
         7329.491 \
         7335.577 \
         7339.604 \
         7341.152 \
         7350.814 \
         7353.293 \
         7361.347 \
         7372.118 \
         7376.877 \
         7380.426 \
         7386.345 \
         7402.252 \
         7412.337 \
         7422.312 \
         7425.294 \
         7428.941 \
         7435.368 \
         7444.749 \
         7447.849 \
         7455.208 \
         7461.875 \
         7471.164 \
         7481.355 \
         7487.974 \
         7503.869 \
         7514.652 \
         7525.508 \
         7536.436 \
         7549.314 \
         7567.742 \
         7589.315 \
         7607.823 \
         7616.682 \
         7627.175 \
         7635.106 \
         7647.379 \
         7653.828 \
         7658.325 \
         7670.058 \
         7676.220 \
         7685.308 \
         7704.817 \
         7713.938 \
         7723.761 \
         7731.739 \
         7742.563 \
         7762.732 \
         7771.947 \
         7782.317 \
         7788.934 \
         7793.133 \
         7817.767 \
         7834.458 \
         7847.539 \
         7861.910 \
         7865.970 \
         7872.632 \
         7886.283 \
         7891.075 \
         7916.442 \
         7937.734 \
         7948.176 \
         7954.592 \
         7972.596 \
         7974.159 \
         7978.973 \
         7987.973 \
         7993.681 \
      }
   }

   #--- je verifie que toutes les configurations ont bien toutes les parametres ((en cas d'evolution de eShel))
   #--- si ce n'est pas le cas, je cree la variable avec la valeur de la configuration "defaut"
   foreach configPath [array names ::conf eshel,instrument,config,*,orderDefinition] {
      set configId [lindex [split $configPath "," ] 3]
      #--- je verifie que tous les parametres existent (necessaires pour les parametres qui seront ajoutes dans les futures versions)
      foreach paramFullName  [array names ::conf eshel,instrument,config,default,*] {
         set paramName [string range $paramFullName [string length "eshel,instrument,config,default,"] end]
         if { [ info exists ::conf(eshel,instrument,config,$configId,$paramName) ] == 0 } {
            #--- j'ajoute le parametre s'il n'existe pas
            if { $paramName == "configName" } {
               #--- je cree le nom s'il n'existe pas (evolution de la version 1.9 ajout du parametre configName)
               #--- je prends la valeur du configId de cette meme configuration
               set ::conf(eshel,instrument,config,$configId,configName) $configId
            } else {
               #--- je prends la valeur du parametres de la configuration "default"
               set ::conf(eshel,instrument,config,$configId,$paramName) $::conf(eshel,instrument,config,default,$paramName)
            }
         }
      }
   }

   if { ! [ info exists conf($prefix,currentSequence) ] }  { set conf($prefix,currentSequence)   "Reference"   }

   #--- je cree deux exemples de sequences de reference
   if { [array names ::conf  eshel,instrument,reference,* ] == "" } {
      set ::conf(eshel,instrument,reference,reference_debut,name)           "Reference debut"
      set ::conf(eshel,instrument,reference,reference_debut,state)          1
      set ::conf(eshel,instrument,reference,reference_debut,actionList)     [list [list biasSerie [list expNb 5]] [list darkSerie [list expTime 15 expNb 5]]  [list darkSerie [list expTime 600 expNb 4]] [list ledSerie [list expTime 15 expNb 8]] [list wait [list expTime 8 ]] [list tharSerie [list expTime 60 expNb 2]] ]
      set ::conf(eshel,instrument,reference,reference_flat_thar,name)       "Reference flat thar"
      set ::conf(eshel,instrument,reference,reference_flat_thar,state)      0
      set ::conf(eshel,instrument,reference,reference_flat_thar,actionList) [list [list ledSerie [list expTime 10 expNb 5]] [list tharSerie [list expTime 10 expNb 5]] ]
   }

   #--- je cree les variables locales
   set private($visuNo,frm)           "$base.eshel"
   set private($visuNo,objname)       ""
   set private($visuNo,sequenceState) ""
   set private($visuNo,status)        ""
   set private(comment)               ""

   #--- Petit raccourci bien pratique
   set frm $private($visuNo,frm)

   #--- Frame principale de l'outil
   frame $frm -borderwidth 1 -relief groove

   #--- Logo
   image create photo eshelLogo -file [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory] "logoshelyak.gif"  ]
   Button $frm.logo -borderwidth 0 -image "eshelLogo" -command "::audace::Lance_Site_htm http://www.shelyak.com"
   pack $frm.logo  -side top -fill x
   DynamicHelp::add $frm.logo -text "http://www.shelyak.com"

   #--- Frame Acquisition
   TitleFrame $frm.acq -borderwidth 2 -relief groove -text "$caption(eshel,acquisition)"
      #--- bouton session
      button $frm.acq.session -text "$caption(eshel,session)" -height 2 \
         -borderwidth 3 -pady 6 -command "::eshel::session::run $private($visuNo,frm) $visuNo"
      pack $frm.acq.session -in [$frm.acq getframe] -side top -fill x

###      #--- Liste des sequences d'acquisition
###      ComboBox $frm.acq.sequence \
###         -width 4 -height [ llength $private($visuNo,sequenceNames) ] \
###         -relief sunken -borderwidth 1 -editable 0 \
###         -modifycmd "::eshel::adaptPanel $visuNo" \
###         -values $private($visuNo,sequenceNames)
###      pack $frm.acq.sequence -in [$frm.acq getframe] -side top -fill x
###      #--- je selectionne le mode
###      $frm.acq.sequence setvalue "@$::conf(eshel,currentSequenceNo)"

      #--- Liste des sequences d'acquisition (voir ::eshel::setSequenceList)
      ComboBox $frm.acq.sequence \
         -width 4  \
         -relief sunken -borderwidth 1 -editable 0 \
         -modifycmd "::eshel::adaptPanel $visuNo"
      pack $frm.acq.sequence -in [$frm.acq getframe] -side top -fill x

      #--- Nom de l'objet
      frame $frm.acq.object -borderwidth 2 -relief ridge
         label $frm.acq.object.lab1 -text $caption(eshel,objname) -justify left -anchor w
         pack  $frm.acq.object.lab1 -side left -fill none -padx 2
         ComboBox $frm.acq.object.combo \
            -width 10 -height [ llength $::conf(eshel,objectList) ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::eshel::private($visuNo,objname) \
            -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 1 68 ::eshel::private(error,objname) } \
            -modifycmd "::eshel::onModifyObject $visuNo" \
            -values $::conf(eshel,objectList)
         ###$frm.acq.object.combo.e configure -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 1 70 ::eshel::private(error,objname) }
          bind $frm.acq.object.combo.e <FocusOut> "::eshel::onModifyObject $visuNo"
         pack $frm.acq.object.combo -side left  -fill x -expand 1
      pack $frm.acq.object -in [$frm.acq getframe] -side top -fill x -expand 1
      #--- je selectionne la premiere valeur par defaut
      $frm.acq.sequence setvalue first

      #--- Temps de pose
      frame $frm.acq.exptime -borderwidth 2 -relief ridge
         label $frm.acq.exptime.lab1 -text $caption(eshel,exptime) -justify left -anchor w
         pack  $frm.acq.exptime.lab1 -side left -fill x -padx 2 -expand 1
         set list_combobox {0 0.5 1 3 5 10 15 30 60 120 180 300 600 900 }
         ComboBox $frm.acq.exptime.combo \
            -width 6  -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,exptime) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s double 0 10000 ::eshel::private(error,exptime) } \
            -values $list_combobox
         pack $frm.acq.exptime.combo -side left -fill none -expand 0
      pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x

      #--- Nombre de poses
      frame $frm.acq.expnb -borderwidth 2 -relief ridge
         label $frm.acq.expnb.lab1 -text $caption(eshel,expnb) -justify left -anchor w
         pack  $frm.acq.expnb.lab1 -side left -fill x -padx 2 -expand 1
         set list_combobox [list 1 2 3 5 10 15 20 ]
         ComboBox $frm.acq.expnb.combo \
            -width 6 -height [ llength $list_combobox ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,expnb) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 0 10000 ::eshel::private(error,expnb) } \
            -values $list_combobox
         pack $frm.acq.expnb.combo -side left  -fill none -expand 0
      pack $frm.acq.expnb -in [$frm.acq getframe] -side top -fill x

      #--- Binning
      frame $frm.acq.binning -borderwidth 2 -relief ridge
         label $frm.acq.binning.label -text $caption(eshel,binning) -justify left  -anchor w
         pack  $frm.acq.binning.label -side left -fill x -padx 2 -expand 1
         set binningList [list 1x1 ]
         ComboBox $frm.acq.binning.combo \
            -width 6  -height [ llength $binningList ] \
            -relief sunken -borderwidth 1 -editable 0 \
            -textvariable ::conf(eshel,binning) \
            -values $binningList
         pack $frm.acq.binning.combo -side left  -fill none -expand 0
      pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x

      #--- repeter
      frame $frm.acq.repeat -borderwidth 2 -relief ridge
         label $frm.acq.repeat.label -text $caption(eshel,repeat) -justify left -anchor w
         pack  $frm.acq.repeat.label -side left -fill x -padx 2 -expand 1
         set repeatList [list 1 2 3 5 10 20 100 1000 ]
         ComboBox $frm.acq.repeat.combo \
            -width 6  -height [ llength $repeatList ] \
            -relief sunken -borderwidth 1 -editable 1 \
            -textvariable ::conf(eshel,repeat) \
            -validate all -validatecommand { ::eshel::validateNumber %W %V %P %s integer 1 10000 ::eshel::private(error,repeat) } \
            -values $repeatList
         pack $frm.acq.repeat.combo -side right -fill none -expand 0
      pack $frm.acq.repeat -in [$frm.acq getframe] -side top -fill x

      #--- commentaire
      frame $frm.acq.comment -borderwidth 2 -relief ridge
         label $frm.acq.comment.label -text $caption(eshel,comment) -justify left -anchor w
         pack  $frm.acq.comment.label -side left -fill none -padx 2 -expand 0
         entry $frm.acq.comment.entry -textvariable ::eshel::private(comment) \
            -width 6 \
            -validate all -validatecommand { ::eshel::validateString %W %V %P %s fits 0 68 ::eshel::private(error,comment) }
         pack $frm.acq.comment.entry -side left -fill x -expand 1
      pack $frm.acq.comment -in [$frm.acq getframe] -side top -fill x

      #--- checkbox traitement automatique
      checkbutton $frm.acq.auto -text "$caption(eshel,processAuto)" \
         -variable ::conf(eshel,processAuto) \
         -command "::eshel::setProcessAuto"
      pack $frm.acq.auto -in [$frm.acq getframe] -fill x -padx 0 -pady 0

      #--- bouton go
      button $frm.acq.go -text "$caption(eshel,acq,go)" -height 2 \
        -borderwidth 3 -pady 6 -command "::eshel::onStartAcquisition $visuNo"
      pack $frm.acq.go -in [$frm.acq getframe] -fill x -padx 0 -pady 0

      #--- status
      label $frm.acq.status -textvariable ::eshel::private($visuNo,status)  -borderwidth 2 -relief ridge
      pack $frm.acq.status -in [$frm.acq getframe] -fill x -padx 0 -pady 0

   pack $frm.acq -side top -fill x -padx 2

   #--- Frame du traitement
   TitleFrame $frm.process -borderwidth 2 -relief groove -text "$caption(eshel,process)"
      button $frm.process.go -text "$caption(eshel,goProcess)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::processgui::run [winfo toplevel $private($visuNo,frm)] $visuNo"
      pack $frm.process.go -in [$frm.process getframe] -fill x -padx 0 -pady 0 -expand true

      #--- Profils
      button $frm.process.spectra -text "Images" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::showProfile"
      pack $frm.process.spectra -in [$frm.process getframe] -fill x -padx 2 -pady 2 -expand true
      #--- Aide
      button $frm.process.help -text "$caption(eshel,help)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command {
              ::audace::showHelpPlugin [::audace::getPluginTypeDirectory [::eshel::getPluginType]] \
                 [::eshel::getPluginDirectory] [::eshel::getPluginHelp]
           }
      pack $frm.process.help -in [$frm.process getframe] -fill x -padx 2 -pady 2 -expand true
   pack $frm.process -side top -fill x -padx 2

   TitleFrame $frm.config -borderwidth 2 -relief groove -text "Administration"
      #--- Parametres instrument
      #button $frm.config.wizard -text "Assistant" -height 1 \
      #    -borderwidth 1 -padx 2 -pady 2 -command "::eshel::startWizard $visuNo"
      #pack $frm.config.wizard -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
      #--- Parametres instrument
      button $frm.config.instrument -text "$caption(eshel,instrument)" -height 1 \
        -borderwidth 1 -padx 2 -pady 2 -command "::eshel::instrumentgui::run [winfo toplevel $private($visuNo,frm)] $visuNo"
      pack $frm.config.instrument -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
      label $frm.config.version -text "eShel-[package present eshel]"
     pack $frm.config.version -in [$frm.config getframe] -fill x -padx 2 -pady 2 -expand true
   pack $frm.config -side bottom -fill x -padx 2

   #--- j'affiche la liste des sequences
   ::eshel::setSequenceList $visuNo

   #--- je mets a jour les widgets en fonction de la sequence courante
   ::eshel::adaptPanel $visuNo

   #--- je verifie les valeurs initiales
   $frm.acq.object.combo.e  validate
   $frm.acq.exptime.combo.e validate
   $frm.acq.expnb.combo.e   validate
   $frm.acq.comment.entry   validate
   $frm.acq.repeat.combo.e  validate

   #---
   return $private($visuNo,frm)
}

proc ::eshel::startWizard { visuNo } {
   variable private
   set dir [ file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [getPluginType]] [getPluginDirectory]]
   source "[ file join $dir wizard.tcl ]"
   source "[ file join $dir visu.tcl ]"
   source "[ file join $dir eshelfile.tcl ]"
   ::eshel::wizard::run [winfo toplevel $private($visuNo,frm)] $visuNo
}

#------------------------------------------------------------
# startTool
#    affiche la fenetre de l'outil
#
proc ::eshel::startTool { visuNo } {
   variable private

   #--- je m'abonne a la surveillance des changements de camera
   ::confVisu::addCameraListener $visuNo "::eshel::adaptPanel $visuNo"

   #--- Je selectionne les mots cles selon les exigences de l'outil
   ::eshel::configToolKeywords $visuNo

}

#------------------------------------------------------------
# stopTool
#    masque la fenetre de l'outil
#
proc ::eshel::stopTool { visuNo } {
   #--- je supprime la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $::conf(eshel,keywordConfigName) ""

   #--- je supprime l'abonnement a la surveillance des changements de camera
   ::confVisu::removeCameraListener $visuNo "::eshel::adaptPanel $visuNo"

}

#------------------------------------------------------------
# getNameKeywords
#    definit le nom de la configuration des mots cles FITS de l'outil
#    uniquement pour les outils qui configurent les mots cles selon des
#    exigences propres a eux
#
proc ::eshel::getNameKeywords { visuNo configName } {
   #--- Je definis le nom
   set ::conf(eshel,keywordConfigName) $configName
}

#------------------------------------------------------------
# configToolKeywords
#    configure les mots cles FITS de l'outil
#
proc ::eshel::configToolKeywords { visuNo { configName "" } } {
   #--- Je traite la variable configName
   if { $configName == "" } {
      set configName $::conf(eshel,keywordConfigName)
   }

   #--- je selectionne les mots clefs optionnel a ajouter dans les images
   ::keyword::selectKeywords $visuNo $configName [list CRPIX1 CRPIX2 IMAGETYP OBJNAME SERIESID DETNAM INSTRUME TELESCOP CONFNAME OBSERVER SITENAME SITELONG SITELAT SWCREATE]

   #--- je selectionne la liste des mots clefs non modifiables
   ::keyword::setKeywordState $visuNo $configName [list CRPIX1 CRPIX2 IMAGETYP OBJNAME SERIESID DETNAM INSTRUME TELESCOP CONFNAME ]

}

#------------------------------------------------------------
#  ::eshel::getLabel
#  retourne le nom de la fenetre de configuration
#
proc ::eshel::getLabel { } {
   global caption

   return "$caption(eshel,title)"
}

#------------------------------------------------------------
#  adaptPanel
#    Cette procedure est appellee automatiquement quand on change de sequence dans la combobox
#      memorise l'index de la sequence selectionnee
#      affiche les widgets necessaire pour saisir les parametres de la sequence
#  param : aucun
#
proc ::eshel::adaptPanel { visuNo args } {
   variable private

   #--- je recupere l'index de la sequence
   set index [$private($visuNo,frm).acq.sequence getvalue]
   #--- je recupere le type de la sequence
   set sequenceType [lindex [lindex $private($visuNo,sequenceList) $index ] 0]
   #--- je recupere l'indentifiant de la sequence
   set sequenceId   [lindex [lindex $private($visuNo,sequenceList) $index ] 1]
   #--- je recupere le nom de la sequence
   set ::conf(eshel,currentSequenceId) $sequenceId

   set frm  $private($visuNo,frm)
   set sequenceUseBinning 0

   #--- l'utilisateur peut choisir une autre sequence
   $frm.acq.sequence.e configure -state normal
   $frm.acq.sequence.a configure -state normal

   switch $sequenceType {
      objectSequence  {
         #--- l'utilisateur peut choisir le nom, le temps de pose, le nombre de poses
         pack $frm.acq.object  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.expnb   -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         pack $frm.acq.repeat  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
         set sequenceUseBinning 0
      }
      referenceSequence  {
         #--- l'utilisateur peut choisir rien
         pack forget $frm.acq.object
         pack forget $frm.acq.exptime
         pack forget $frm.acq.expnb
         pack forget $frm.acq.repeat
         set sequenceUseBinning 0
      }
      previewSequence {
         switch $sequenceId  {
            objectPreview  {
               #--- l'utilisateur peut choisir le nom, le temps de pose et le binning
               pack $frm.acq.object  -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.expnb
               set sequenceUseBinning 1
               pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.repeat
            }
            darkPreview -
            ledPreview -
            tharPreview -
            tungstenPreview {
               #--- l'utilisateur peut choisir le temps de pose et le binning
               pack forget $frm.acq.object
               pack $frm.acq.exptime -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
               pack forget $frm.acq.expnb
               pack forget $frm.acq.repeat
               set sequenceUseBinning 1
            }
            biasPreview {
               #--- l'utilisateur peut choisir le binning
               pack forget $frm.acq.object
               pack forget $frm.acq.exptime
               pack forget $frm.acq.expnb
               pack forget $frm.acq.repeat
               set sequenceUseBinning 1
            }
            default {
               #--- l'utilisateur peut choisir rien
               pack forget $frm.acq.object
               pack forget $frm.acq.exptime
               pack forget $frm.acq.repeat
               set sequenceUseBinning 0
            }
         }
      }
   }

   if { $sequenceUseBinning == 1 } {
      #--- je recupere la liste des binning de la camera
      set camItem [::confVisu::getCamItem $visuNo]
      #--- widget de binning
      if { [ ::confCam::getPluginProperty $camItem hasBinning ] == 1 } {
         set binningList [ ::confCam::getPluginProperty $camItem binningList ]
         $private($visuNo,frm).acq.binning.combo configure -values $binningList -height [llength $binningList ]

         #--- je verifie que le binning preselectionne existe dans la liste
         if { [lsearch $binningList $::conf(eshel,binning)] == -1 } {
            #--- si le binning n'existe pas je selectionne la premiere valeur par defaut
            set  ::conf(eshel,binning) [lindex $binningList 0]
         }
         #--- j'affiche la frame du binning
         pack $frm.acq.binning -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
      } else {
         #--- je masque la frame du binning
         pack forget $frm.acq.binning
      }
   } else {
      #--- je masque la frame du binning
      pack forget $frm.acq.binning
   }

   if { $::conf(eshel,enableComment)== 1 } {
      #--- j'affiche la zone de saisie des commentaires
      pack $frm.acq.comment -in [$frm.acq getframe] -side top -fill x -before $frm.acq.auto
   } else {
      #--- je masque la frame du binning
      pack forget $frm.acq.comment
   }

}

#------------------------------------------------------------
#  onModifyObject
#    ajoute le nom de l'objet selectionne en tete dans la liste de la combobox
#    et supprime le onzieme objet si necessaire
#    cette procedure est appellee automatiquement quand on change le nom d'objet dans la combobox
#  param visuNo numéro de la visu
#
proc ::eshel::onModifyObject { visuNo } {
   variable private

   set index [$private($visuNo,frm).acq.object.combo getvalue]

   #--- j'ajoute cet objet en tete de liste si c'est un nouvel objet
   if { $index == -1 && $private($visuNo,objname) != "" } {
      set ::conf(eshel,objectList) [linsert $::conf(eshel,objectList) 0 $private($visuNo,objname)]
   }

   if { [llength $::conf(eshel,objectList) ] > 10 } {
      #--- je supprime le dernier element s'il y a plus de 10 elements
      set ::conf(eshel,objectList) [lreplace $::conf(eshel,objectList) end end]
   }
   $private($visuNo,frm).acq.object.combo configure -values $::conf(eshel,objectList)
   ###console::disp "objname= $private($visuNo,objname)  \n"
   $private($visuNo,frm).acq.object.combo.e validate

}

#------------------------------------------------------------
#  onStartAcquisition
#    Cette procedure est appelee quand l'utilsateur clique sur le bouton GO
#    lance la sequence d'acquisition
#    param visuNo numéro de la visu
#
proc ::eshel::onStartAcquisition { visuNo args } {
   variable private

   #--- je recupere l'index de la sequence
   set index [$private($visuNo,frm).acq.sequence getvalue]
   #--- je recupere le nom et le type de la sequence
   set sequenceType [lindex [lindex $private($visuNo,sequenceList) $index ] 0]
   set sequenceId   [lindex [lindex $private($visuNo,sequenceList) $index ] 1]
   set sequenceName [lindex [lindex $private($visuNo,sequenceList) $index ] 2]

   #--- j'assemble les series de la sequence
   set actionList ""
   set binning    ""
   set repeat     1
   set comment    ""
   switch $sequenceType {
      objectSequence {
         #--- je verifie que le nom de l'objet est renseigne
         #if {  $private($visuNo,objname) == "" } {
         #    console::affiche_erreur "$::caption(eshel,acquisition,errorObject) \n"
         #   tk_messageBox -message "$::caption(eshel,acquisition,errorObject)" -icon error -title $::caption(eshel,title)
         #   return
         #}

         #--- je verifie que le nom de l'obet est correct
         if { [info exists ::eshel::private(error,objname)] } {
            set errorMessage "$::caption(eshel,objname): $private(error,objname)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         #--- j'ajoute une serie de plusieurs images
         set actionType  "objectSerie"
         set actionParam [list expTime $::conf(eshel,exptime) expNb $::conf(eshel,expnb) objectName $private($visuNo,objname) binning [::eshel::instrument::getConfigurationProperty "binning"] ]
         set actionList  [list [list $actionType $actionParam]]
         set repeat $::conf(eshel,repeat)
         set sequenceName $private($visuNo,objname)

         #--- je verifie le temps de pose
         if { [info exists ::eshel::private(error,exptime)] } {
            set errorMessage "$::caption(eshel,exptime): $private(error,exptime)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         #--- je verifie le nombre de poses
         if { [info exists ::eshel::private(error,expnb)] } {
            set errorMessage "$::caption(eshel,expnb): $private(error,expnb)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }
         #--- je verifie le nombre de repetitions
         if { [info exists ::eshel::private(error,repeat)] } {
            set errorMessage "$::caption(eshel,repeat): $private(error,repeat)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }
      }
      referenceSequence {
         #--- je recupere la liste des actions predefinie
         set actionList  $::conf(eshel,instrument,reference,$sequenceId,actionList)
      }
      previewSequence {
         set binning [list [string range $::conf(eshel,binning) 0 0] [string range $::conf(eshel,binning) 2 2]]

         #--- je verifie le temps de pose
         if { [info exists ::eshel::private(error,exptime)] } {
            set errorMessage "$::caption(eshel,exptime): $private(error,exptime)"
            tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
            return
         }

         switch $sequenceId  {
            objectPreview {
               #--- je verifie que le nom de l'obet est correct
               if { [info exists ::eshel::private(error,objname)] } {
                  set errorMessage "$::caption(eshel,objname): $private(error,objname)"
                  tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
                  return
               }

               #--- j'ajoute une serie d'une image avec le temps de pose et le nom de l'objet choisi par l'utilisateur
               set actionType  "objectSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 objectName $private($visuNo,objname) binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            darkPreview {
               set actionType  "darkSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            flatfieldPreview {
               set actionType  "flatfieldSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $::conf(eshel,binning) ]
               set actionList  [list [list $actionType $actionParam]]
            }
            ledPreview {
               set actionType  "ledSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $::conf(eshel,binning) ]
               set actionList  [list [list $actionType $actionParam]]
            }
            tharPreview {
               set actionType  "tharSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            tungstenPreview {
               #--- j'ajoute une serie d'une image avec le temps de pose choisi par l'utilisateur
               set actionType  "tungstenSerie"
               set actionParam [list expTime $::conf(eshel,exptime) expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
            biasPreview {
               #--- j'ajoute une serie d'une image
               set actionType  "biasSerie"
               set actionParam [list expTime 0 expNb 1 saveFile 0 binning $binning ]
               set actionList  [list [list $actionType $actionParam]]
            }
         } ;#--- fin switch sequenceName
      }
   } ;#--- fin switch sequenceType

   if { $::conf(eshel,enableComment)== 1  } {
      #--- je verifie que le commentaire est correct
      if { [info exists ::eshel::private(error,comment)] } {
         set errorMessage "$::caption(eshel,comment): $private(error,comment)"
         tk_messageBox -message $errorMessage -icon error -title $::caption(eshel,title)
         return
      }
      set comment $private(comment)
   }

   #--- je verrouille les widgets de la fenetre principale
   $private($visuNo,frm).acq.session configure -state disabled
   $private($visuNo,frm).acq.sequence.e configure -state disabled
   $private($visuNo,frm).acq.sequence.a configure -state disabled
   $private($visuNo,frm).acq.object.combo.e configure -state disabled
   $private($visuNo,frm).acq.object.combo.a configure -state disabled
   $private($visuNo,frm).acq.exptime.combo.e configure -state disabled
   $private($visuNo,frm).acq.exptime.combo.a configure -state disabled
   $private($visuNo,frm).acq.expnb.combo.e configure -state disabled
   $private($visuNo,frm).acq.expnb.combo.a configure -state disabled
   $private($visuNo,frm).acq.binning.combo.e configure -state disabled
   $private($visuNo,frm).acq.binning.combo.a configure -state disabled
   $private($visuNo,frm).acq.comment.entry configure -state disabled
   $private($visuNo,frm).acq.repeat.combo.e configure -state disabled
   $private($visuNo,frm).acq.repeat.combo.a configure -state disabled
      #--- je transforme le bouton GO en bouton STOP
   $private($visuNo,frm).acq.go configure -text $::caption(eshel,acq,stop) -command "::eshel::stopAcquisition $visuNo"
   #--- J'associe la commande d'arret a la touche ESCAPE
   bind all <Key-Escape> "::eshel::stopAcquisition $visuNo"

   #--- je lance la sequence d'acquisition
   set private($visuNo,sequenceState) "busy"

   set catchResult [ catch {
      ::eshel::acquisition::startSequence $visuNo $actionList $sequenceName $repeat $comment
   }]

   if { $catchResult != 0 } {
      if { $::errorCode != 5 } {
         ::tkutil::displayErrorInfo $::caption(eshel,title)
      }
   }

   set private($visuNo,sequenceState) ""

   #--- je deverrouille les widgets de la fenetre principale
   $private($visuNo,frm).acq.session configure -state normal
   $private($visuNo,frm).acq.sequence.e configure -state normal
   $private($visuNo,frm).acq.sequence.a configure -state normal
   $private($visuNo,frm).acq.object.combo.e configure -state normal
   $private($visuNo,frm).acq.object.combo.a configure -state normal
   $private($visuNo,frm).acq.exptime.combo.e configure -state normal
   $private($visuNo,frm).acq.exptime.combo.a configure -state normal
   $private($visuNo,frm).acq.expnb.combo.e configure -state normal
   $private($visuNo,frm).acq.expnb.combo.a configure -state normal
   $private($visuNo,frm).acq.binning.combo.e configure -state normal
   $private($visuNo,frm).acq.binning.combo.a configure -state normal
   $private($visuNo,frm).acq.comment.entry configure -state normal
   $private($visuNo,frm).acq.repeat.combo.e configure -state normal
   $private($visuNo,frm).acq.repeat.combo.a configure -state normal
   ::eshel::adaptPanel $visuNo
   #--- Je supprime l'association de la commande d'arret avec la touche ESCAPE
   bind all <Key-Escape> ""
   #--- je transforme le bouton STOP en bouton GO
   $private($visuNo,frm).acq.go configure -text $::caption(eshel,acq,go) -state normal -command "::eshel::onStartAcquisition $visuNo"
   set private($visuNo,sequenceState) ""
}

#------------------------------------------------------------
# stopAcquisition
#    Cette procedure est appelee quand l'utilsateur clique sur le bouton STOP
#    interrompt les acquisitions
#
proc ::eshel::stopAcquisition { visuNo  } {
   variable private

   if { $private($visuNo,sequenceState) != "" } {
      #--- je desactive le bouton en attendant que l'aquisition soit completement terminee
      $private($visuNo,frm).acq.go configure -state disabled
      ::eshel::acquisition::stopSequence $visuNo
   } else {
      set private($visuNo,sequenceState) ""
   }
}

#------------------------------------------------------------
#  setStatus
#    affiche le status
#  Parameters
#    visuNo : numero de la visu
#    value  : valeur a afficher
#
proc ::eshel::setStatus { visuNo value} {
   variable private

   set private($visuNo,status) $value
}

#------------------------------------------------------------
#  setSequenceList
#    affiche les sequences dasn la combobox
#      avec les 7 sequences predefinies et les sequences de reference
#
#  la variable private($visuNo,sequenceList) contient une liste de triplets :
#     [list  [list sequenceType sequenceId sequenceName ] [list sequenceType sequenceId sequenceName] ... ]
#  Parameters
#    visuNo : numero de la visu
#    value  : valeur a afficher
#
proc ::eshel::setSequenceList { visuNo } {
   variable private

   #---- je construis la liste des sequences  (type sequence, nom sequence)
   set private($visuNo,sequenceList) ""

   #--- j'ajoute la sequence "object"
   lappend private($visuNo,sequenceList) [list "objectSequence" "object" $::caption(eshel,acquisition,objectSequence) ]

   #--- j'ajoute les sequences de reference
   foreach sequencePath [array names ::conf eshel,instrument,reference,*,name] {
      set sequenceId [lindex [split $sequencePath "," ] 3]
      set sequenceName   $::conf(eshel,instrument,reference,$sequenceId,name)
      set sequenceState  $::conf(eshel,instrument,reference,$sequenceId,state)
      if { $sequenceState == 1 } {
         lappend private($visuNo,sequenceList) [list "referenceSequence" $sequenceId $sequenceName  ]
      }

      #--- je remplace "flatSerie" par "ledSerie"
      set ::conf(eshel,instrument,reference,$sequenceId,actionList) [string map { "flatSerie" "ledSerie" } $::conf(eshel,instrument,reference,$sequenceId,actionList)]

   }

   #--- j'ajoute les sequences "preview"
   foreach sequenceId [list objectPreview tharPreview ledPreview darkPreview biasPreview tungstenPreview]  {
      lappend private($visuNo,sequenceList) [list "previewSequence" $sequenceId $::caption(eshel,acquisition,$sequenceId)]
   }

   #--- je prepare la liste des noms des sequences
   set indexCurrentSequence -1
   set counter 0
   set nameList ""
   foreach item $private($visuNo,sequenceList) {
      #--- je recupere le nom de la sequence
      lappend nameList [lindex $item 2]
      #--- je repere l'index correspondant a l'indentifiant de la sequence courante
      if { [lindex $item 1] == $::conf(eshel,currentSequenceId) } {
         set indexCurrentSequence $counter
      }
      incr counter
   }
   #--- je copie la liste des noms des sequences dans la combobox
   $private($visuNo,frm).acq.sequence configure -values $nameList -height $counter

   #--- je selectionne le nom de la sequence courante
   if { $indexCurrentSequence != -1 } {
      #--- je selectionne la sequence courante
      $private($visuNo,frm).acq.sequence setvalue "@$indexCurrentSequence"
   } else {
      #--- la sequence courante n'existe pas dans la liste
      #--- je selectionne le premier item
      $private($visuNo,frm).acq.sequence setvalue "@0"
   }
}

#------------------------------------------------------------
#  setProcessAuto
#     lance le traitement automatique
#
proc ::eshel::setProcessAuto { } {

   ::eshel::processgui::setProcessAuto
}

#------------------------------------------------------------
# checkDirectory
#   verifie l'existance des repertoires
#
proc ::eshel::checkDirectory { } {

   #--- je verifie que le repertoire des fichiers bruts existe
   if {  [file exists $::conf(eshel,rawDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,rawDirectory)]
   }

   if {  [file exists $::conf(eshel,referenceDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,referenceDirectory)]
   }

   if {  [file exists $::conf(eshel,masterDirectory)] == 0 } {
         error [format $::caption(eshel,directoryNotFound) $::conf(eshel,masterDirectory)]
   }

   if {  [file exists $::conf(eshel,tempDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,tempDirectory)]
   }

   if {  [file exists $::conf(eshel,archiveDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,archiveDirectory)]
   }

   if {  [file exists $::conf(eshel,processedDirectory)] == 0 } {
      error [format $::caption(eshel,directoryNotFound) $::conf(eshel,processedDirectory)]
   }
}

#------------------------------------------------------------
# showRawDirectory
#   affiche le repertoire des images brutes
#
proc ::eshel::showRawDirectory { } {

   #--- je verifie que le repertoire des images brutes existe
   ::eshel::checkDirectory

   set visuDir [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   confVisu::selectTool $visuDir ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($visuDir,directory)  $::conf(eshel,rawDirectory)
   #--- j'affiche le contenu du repertoire
   ::eshelvisu::localTable::fillTable $visuDir
}

#------------------------------------------------------------
# showProfile
#   affiche une fenetre pour afficher des profils
#
proc ::eshel::showProfile { } {
   #--- j'ouvre une fenetre pour afficher des profils
   ##set profileNo [::profilegui::run ]
   set visuDir [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   #confVisu::selectTool $visuDir ::visio2
   #--- je selectionne l'outil eShel Visu
   confVisu::selectTool $visuDir ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($visuDir,directory) $::conf(eshel,mainDirectory)
   #--- j'affiche le contenu du repertoire
   ::eshelvisu::localTable::fillTable $visuDir
}

#------------------------------------------------------------
## @brief affiche le profil P_FULL d'un objet dans une nouvelle visu
#  @details le fichier est recherché dans le répertoire des profils traités.
#  @param fileName nom du fichier
#  @public
#
proc ::eshel::showObjectProfile { fileName } {
   #--- j'ouvre une fenetre pour afficher des profils
   set profileVisu [::confVisu::create]
   #--- je selectionne l'outil visionneuse bis
   #confVisu::selectTool $profileVisu ::visio2
   #--- je selectionne l'outil eShel Visu
   confVisu::selectTool $profileVisu ::eshelvisu
   #--- je pointe le repertoire des images brutes
   set ::eshelvisu::localTable::private($profileVisu,directory) $::conf(eshel,processedDirectory)
   #--- j'affiche le contenu du fichier
   :::eshelvisu::localTable::refresh $profileVisu $fileName "P_1C_FULL"
}

#------------------------------------------------------------
## @brief sélectionne le répertoire des images de la session
#  et créé les sous réperoires raw, temp, archive reference et processed
#  s'ils n'exitent pas déjà
#  @param mainDirectory  répertoire principal
#
proc ::eshel::setSessionDirectory { mainDirectory } {

   if { $mainDirectory != "" } {
      #--- je normalise le nom du repertoire
      set mainDirectory [file normalize $mainDirectory]

      #--- je cree les sous repertoires
      set catchResult [ catch {
         set rawDirectory "$mainDirectory/raw"
         set tempDirectory "$mainDirectory/temp"
         set archiveDirectory "$mainDirectory/archive"
         set referenceDirectory "$mainDirectory/reference"
         set processedDirectory "$mainDirectory/processed"

         file mkdir "$mainDirectory"
         file mkdir "$rawDirectory"
         file mkdir "$tempDirectory"
         file mkdir "$archiveDirectory"
         file mkdir "$referenceDirectory"
         file mkdir "$processedDirectory"

         #--- je memorise les noms des sous repertoires
         set ::conf(eshel,mainDirectory)        $mainDirectory
         set ::conf(eshel,rawDirectory)         $rawDirectory
         set ::conf(eshel,referenceDirectory)   $referenceDirectory
         set ::conf(eshel,processedDirectory)   $processedDirectory
         set ::conf(eshel,archiveDirectory)     $archiveDirectory
         set ::conf(eshel,tempDirectory)        $tempDirectory
         }]

      if { $catchResult == 1 } {
         error $::errorInfo
      }
   } else {
      error $::caption(eshel,session,directoryError)
   }
}

#------------------------------------------------------------
## @brief ajoute une trace dans le fichier de trace
#  @param message
#  @param color
#  @public
#  @todo commenter les paramètres
#
proc ::eshel::logFile { message color } {
   variable hLogFile

   if { $::conf(eshel,enabledLogFile) == 0 } {
      return
   }

   set catchResult [ catch {
      set fileName [file join $::conf(eshel,mainDirectory) $::conf(eshel,logFileName) ]
      set hLogFile [open $fileName "a+" ]

      #--- j'ajoute la trace dans le fichier
      set date [clock format [clock seconds] -timezone :UTC -format "%Y-%m-%dT%H:%M:%S"]
      puts $hLogFile  "<font color=$color>"
      #--- je remplce les retours chariots par <BR>
      set message [string map { "\n" "<BR>\n" } $message]
      puts $hLogFile "$date $message"
      puts $hLogFile  "</font>"
      close  $hLogFile
   } ]

   if { $catchResult == 1 } {
      error $::errorInfo
   }
}

#------------------------------------------------------------
## @brief ouvre le fichier de trace
#  @return rien (remonte les exceptions)
#  @public
#
proc ::eshel::openLogFile { } {
   variable private

   #--- j'ouvre le fichier de tarce
   #set fileName [file join $::conf(eshel,mainDirectory) $::conf(eshel,logFileName) ]
   #set private(hLogFile) [open $fileName "a+" ]
}

#------------------------------------------------------------
## @brief ferme le fichier de trace
#  @return rien (remonte les exceptions)
#  @public
#
proc ::eshel::closeLogFile { } {
   variable private

}

#--------------------------------------------------------------
## @brief vérifie la valeur saisie dans un widget
#  @details cette vérification est activée avec l'option  -validatecommand { ::eshel::validateNumber ... }
#  @code
#  -validatecommand { ::eshel::validateNumber %W %V %P %s  "numRef" integer -360 360 }
#  @endcode
#  @param  win chemin Tk du widget
#  @param  event évènement sur le widget (key, focusout)
#  @param  X    valeur après l'évènement
#  @param  oldX valeur avant l'évènement
#  @param  class classe de nombre
#  @param  min valeur minimale
#  @param  max valeur maximale
#  @param errorVariable (optionnel) nom de la variable d'erreur associée au widget
#  @return
#   - 1 si OK
#   - 0 si erreur
#  @public
#
proc ::eshel::validateNumber { win event X oldX class min max { errorVariable "" }} {
   variable widget

   if { $event == "key" || $event == "focusout" || $event == "forced"  } {
      set weakCheck [expr [string is $class -failindex charIndex $X] ]
      # if weak check fails, continue with old value
      if {! $weakCheck} {
         set strongCheck $weakCheck
         if { $errorVariable != "" } {
            set $errorVariable  [format $::caption(eshel,badCharacter) "\"$X\"" "\"[string range $X $charIndex $charIndex]\"" ]
         }
      } else {
         # Make sure min<=max
         if {$min > $max} {
            set tmp $min; set min $max; set max $tmp
         }
         ###set strongCheck [expr {$weakCheck && ($X >= $min) && ($X <= $max)}]
         #--- je verifie la plage
         if {  $X < $min } {
            if { $errorVariable != "" } {
               set $errorVariable  [format $::caption(eshel,numberTooSmall) $X $min ]
            }
         } elseif {  $X > $max } {
            if { $errorVariable != "" } {
               set $errorVariable  [format $::caption(eshel,numberTooGreat) $X $max ]
            }
         } else {
            if { $errorVariable != "" } {
               if { [info exists $errorVariable] } {
                  unset $errorVariable
               }
            }
         }
         set strongCheck [expr {$weakCheck && ($X >= $min) && ($X <= $max)}]
      }
      if { $strongCheck == 0 } {
         #--- j'affiche en inverse video
         ###$win configure -bg $::audace(color,entryTextColor) -fg $::audace(color,entryBackColor)
         $win configure -bg $::audace(color,entryBackColor2) -fg $::audace(color,entryTextColor)
      } else {
         #--- j'affiche normalement
         $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
      return 1
   } else {
      return 1
   }

}

#----------------------------------------------------------------------------
## @brief vérifie une suite de caractères saisie dans  un widget
#  @details cette vérification est activée avec l'option  -validatecommand { ::eshel::validateString ... }
#  @code exemple
#  -validatecommand { ::eshel::validateFloat %W %V %P %s  "numRef" integer -360 360 }
#  @endcode
#  @param  win chemin Tk du widget
#  @param  event évènement sur le widget (key, focusout)
#  @param  X  valeur après  l'évènement
#  @param  oldX valeur avant  l'évènement
#  @param  class classe de la valeur attendue (fits, )
#  @param  minLength longueur minimale de la chaîne
#  @param  maxLength longueur maximale de la chaîne
#  @param  errorVariable  nom de la variable d'erreur associée au widget
#  @return
#   - 1 si OK
#   - 0 si erreur
#  @private
#
proc ::eshel::validateString { win event X oldX class minLength maxLength errorVariable} {
   variable widget

   if { $event == "key" || $event == "focusout" || $event == "forced" } {
      if { $class == "fits" } {
         set weakCheck [expr [string is ascii -failindex charIndex $X] ]
         ###set weakCheck [expr [[regexp -all {[\u0000-\u0029]|[\u007F-\u00FF]} $X ] != 0 ] ]
      } else {
         set weakCheck [expr [string is $class -failindex charIndex $X] ]
      }
      # if weak check fails, continue with old value
     if {! $weakCheck} {
         set strongCheck $weakCheck
         set $errorVariable  [format $::caption(eshel,badCharacter) "\"$X\"" "\"[string range $X $charIndex $charIndex]\"" ]
      } else {
         # Make sure min<=max
         if {$minLength > $maxLength} {
            set tmp $minLength; set minLength $maxLength; set maxLength $tmp
         }
         #--- je verifie la longueur
         set xLength [string length $X]
         if {  $xLength < $minLength } {
            set $errorVariable [format $::caption(eshel,stringTooShort) "\"$X\"" $minLength]
            set strongCheck 0
         } elseif {  $xLength > $maxLength } {
            set $errorVariable [format $::caption(eshel,stringTooLarge) "\"$X\"" $maxLength]
            set strongCheck 0
         } else {
            if { [info exists  $errorVariable] } {
               unset $errorVariable
            }
            set strongCheck 1
         }
      }

      if { $strongCheck == 0 } {
         #--- j'affiche en inverse video
         ##$win configure -bg $::audace(color,entryTextColor) -fg $::audace(color,entryBackColor)
         $win configure -bg $::audace(color,entryBackColor2) -fg $::audace(color,entryTextColor)
      } else {
         #--- j'affiche normalement
         $win configure -bg $::audace(color,entryBackColor) -fg $::audace(color,entryTextColor)
      }
      return 1
   } else {
       return 1
   }

}

