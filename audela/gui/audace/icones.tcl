#
## @file icones.tcl
#  @brief Définit des icônes utilisées dans les menus
#  @authors Robert DELMAS et Michel PUJOL
#  @namespace icones
#  @brief Définit des icônes utilisées dans les menus
#  $Id: icones.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::icones {

   #------------------------------------------------------------
   ## @brief charge les icônes
   #
   proc initIcones { } {
      variable private

      #--- icone pour ouvrir
      set private(openIcon) [image create photo openIcon -data {
         R0lGODlhEQAPAKEDAAAAAAL/AP//mf///yH5BAEKAAMALAAAAAARAA8AAAIx
         nI+pCr18wJCP0eYWNkB4DDLeSFJIR5biCLYXG8Sy/ArAjJvdjdMn3wuYOK5Q
         5WgoAAA7
      }]

      #--- icone pour enregistrer
      set private(saveIcon) [image create photo saveIcon -data {
         R0lGODlhEAAQAMIEAAABAQCZ/wD9/fb/9////////////////yH5BAEKAAQA
         LAAAAAAQABAAAAM6SLrcCjBK+QIYOGMgQL1aFn2haJHlAJzECpYuCrOrNUEB
         ne/87rW5W0Rnk2yIt+OvllSxWsKJY8pIAAA7
      }]

      #--- icone pour enregistrer sous
      set private(saveAsIcon) [image create photo saveAsIcon -data {
         R0lGODlhEgASAMIEAAAAAACZ/wD9/dz//////////////////yH5BAEKAAcA
         LAAAAAASABIAAANJeLrcDDBK+QIYOGMgQL1aFn2haJHlAJzLCpYuCrPKak1Q
         QB+27v87Gy4S1OE2xeGwZiEQBM6o1FMDOK3S6cMJzUapVSXFQW4kAAA7
      }]

      #--- icone pour en-tete FITS
      set private(fitsHeaderIcon) [image create photo fitsHeaderIcon -data {
         R0lGODlhDAAOAKEBAAAAAP///////////yH5BAEKAAIALAAAAAAMAA4AAAIk
         lI8Hy4sQYoRAyTkNvE1f7jVLUAnbR4ZiaqJZK1KeW8ZdggsFADs=
      }]

      #--- icone pour nouveau script
      set private(newScriptIcon) [image create photo newScriptIcon -data {
         R0lGODlhDAAOAKEBAAAAAP///////////yH+EUNyZWF0ZWQgd2l0aCBHSU1Q
         ACH5BAEKAAIALAAAAAAMAA4AAAIilI8Hy4sQYoRAyTkNvE1f7n2ZsIkVKY7l
         d64gmrbNnNRGAQA7
      }]

      #--- icone pour quitter
      set private(exitIcon) [image create photo exitIcon -data {
         R0lGODlhEQARAKEBAP8AAP///////////yH5BAEKAAIALAAAAAARABEAAAI2
         lI95wO1vnnQRhDAvqxe7vgkNyJBAVWrmKX6d16CjBrXzyrrYipomR7uFUhmP
         bEKxIZOK5qEAADs=
      }]

      #--- icone pour fermer
      set private(closeIcon) [image create photo closeIcon -data {
         R0lGODlhEQAQAKEDAAAAAACqAL//v////yH5BAEKAAMALAAAAAARABAAAAIy
         nI+pO+B8QIuwyYrczRobIITaqIDheW4RyqofOsaXKQDBjeOzmPcbaOvpOMIh
         R9bxQAoAOw==
      }]

      #--- icone pour nouvelle visu
      set private(newVisuIcon) [image create photo newVisuIcon -data {
         R0lGODlhEQAQAMIDAAAAAAAAgADh/////////////////////yH5BAEKAAAA
         LAAAAAARABAAAAM1CLrcKzBKB0S4GFPJwx5gCHqOIIpkY4Ycp6yglWWv2Eak
         fMFnyvCoz2kkHPoeQ2JpRqM4FQkAOw==
      }]

      #--- icone pour palette et fonction de transfert
      set private(swatchTransferFunction) [image create photo swatchTransferFunction -data {
         R0lGODlhEAAQAMIHAAAA//8AAP8A/7fBCuS0VgD/////AP///yH5BAEAAAcA
         LAAAAAAQABAAAANCeLrcazBKwwy5OBN6rAba1l3BBZzXgEFE4JrpoG5eGc50
         qBUXq0WEgjD3GwV7HSDNs6qEBM2HRkAVOafWxiTi6DoSADs=
      }]

      #--- icone pour plein ecran
      set private(fullScreenIcon) [image create photo fullScreenIcon -data {
         R0lGODlhEgASAKECAAAAALeurv///////yH5BAEKAAMALAAAAAASABIAAAI5
      nI+Jwe0fDJi0WiCVHpgPCHnedYkYIKTqemboCrcjHJsczdovLsgnn/LdgMId
      rkiq2DaJTjLJjBYAADs=
      }]

      #--- icone pour miroir horizontal dans le menu affichage
      set private(mirrorHDisplayIcon) [image create photo mirrorHDisplayIcon -data {
         R0lGODlhEQAPAMIDAAAAAAAAgJNj7P///////////////////yH5BAEKAAQA
         LAAAAAARAA8AAAM7SLrczuCp4GKjJOBll57CRnTZgAVCyHmDCaaYFbRulsJj
         SZ93PO2vTWdWQ4lIs5Mox/hkKo4lREKVJAAAOw==
      }]

      #--- icone pour miroir vertical dans le menu affichage
      set private(mirrorVDisplayIcon) [image create photo mirrorVDisplayIcon -data {
         R0lGODlhDwARAMIDAAAAAAAAgJNj7P///////////////////yH5BAEKAAQA
         LAAAAAAPABEAAAMvSLrcGjDK0IK4WFBn83ZEp4GM9ZEPqjJA677uKp9oMNDc
         oOOLre8g3w9YmkxkjQQAOw==
      }]

      #--- icone pour fenetrer dans le menu affichage
      set private(windowDisplayIcon) [image create photo windowDisplayIcon -data {
         R0lGODlhDQAOAKECAAAAALeurv///////yH5BAEKAAIALAAAAAANAA4AAAIm
         lI8JkQa32hOg2ntCWLpPyDibEj4jEk0n+K1ip3HQRTfZZwtujhQAOw==
      }]

      #--- icone pour vision nocturne
      set private(nightVisionIcon) [image create photo nightVisionIcon -data {
         R0lGODlhFAAVAMIFAAAAAP8AAP0BAP8GAO7xGv///////////yH5BAEKAAcA
         LAAAAAAUABUAAANReLrc/icEuGaTztYmtPJbJI0fNZ6kKQEskD4jQMyEi8GB
         TM/2deo7WwoFpAlvldyOh/Qpja/MqhWV5qjNi2LQAoS0iy4DBBKPKQoWGqJe
         uxsJADs=
      }]

      #--- icone pour rotation 90° sens horaire
      set private(rotation90dHIcon) [image create photo rotation90dHIcon -data {
         R0lGODlhDgAOAKECAABVmi69/////////yH5BAEKAAIALAAAAAAOAA4AAAIj
         lI8Jy5AGgpTrxUkdujjo03CfNY3gUlZbR5GYCZbPClvznRQAOw==
      }]

      #--- icone pour rotation 90° sens anti-horaire
      set private(rotation90dAHIcon) [image create photo rotation90dAHIcon -data {
         R0lGODlhDQAOAKECAABVmi69/////////yH5BAEKAAIALAAAAAANAA4AAAIk
         lI95wA3JgpRvgTmruZgiHjiaAI5bRDFf562YuWXKEs6fjR8FADs=
      }]

      #--- icone pour rotation 180°
      set private(rotation180dIcon) [image create photo rotation180dIcon -data {
         R0lGODlhDgARAKEDAABVmi69/zC//////yH5BAEKAAMALAAAAAAOABEAAAIv
         nI95wA06QJiTKUmDsAjn8HQOFUJeuTxnIqlkVzGv4X0gbZNlrbNxY7pBRMMi
         ogAAOw==
      }]

      #--- icone pour miroir horizontal
      set private(mirrorHIcon) [image create photo mirrorHIcon -data {
         R0lGODlhDwARAMIDAAAAAAAAgC69/////////////////////yH5BAEKAAQA
         LAAAAAAPABEAAAMvSLrcGjDK0IK4WFBn83ZEp4GM9ZEPqjJA677uKp9oMNDc
         oOOLre8g3w9YmkxkjQQAOw==
      }]

      #--- icone pour miroir vertical
      set private(mirrorVIcon) [image create photo mirrorVIcon -data {
         R0lGODlhEQAPAMIDAAAAAAAAgC69/////////////////////yH5BAEKAAQA
         LAAAAAARAA8AAAM7SLrczuCp4GKjJOBll57CRnTZgAVCyHmDCaaYFbRulsJj
         SZ93PO2vTWdWQ4lIs5Mox/hkKo4lREKVJAAAOw==
      }]

      #--- icone pour miroir diagonal
      set private(mirrorDIcon) [image create photo mirrorDIcon -data {
         R0lGODlhFQAVAMIDAAAAAAAAgC69/////////////////////yH5BAEKAAQA
         LAAAAAAVABUAAANISLrc/iTAqYKkL4yLmd6dN4xc95EMAEAnqqjsKIMEnFk4
         Xq9hyvevVW4IsQUEyGTJtzgmBcuFrfKMTpxQYARppRy7XrBX20sAADs=
      }]

      #--- icone pour re-echantillonner
      set private(resampleIcon) [image create photo resampleIcon -data {
         R0lGODlhEgASAMIDAAAAAHBqauPf3////////////////////yH5BAEKAAQA
         LAAAAAASABIAAANESLrcHBC6GYSoYbZ6bdYKF30gZ11AqgLP6QFDPMBs6KLy
         HNfmm6+hEQSW24GIxdoE+TsWjRqmTOmQQpfP2RHA7XJB4AQAOw==
      }]

      #--- icone pour convertir RVB --> R+V+B
      set private(rgb2r+g+bIcon) [image create photo rgb2r+g+bIcon -data {
         R0lGODlhEgARAMIEAAAAAP8AAABm/wD/M////////////////yH5BAEKAAcA
         LAAAAAASABEAAANEeLrc7iDK+FQMOIO6QdbPdnhfIE7iiFIj4aYrC7gEPNz4
         SaN4bu0LQO+mewVjP6MFqZIEBdBoinGKSjkjK3TaiLEq4AQAOw==
      }]

      #--- icone pour convertir R+V+B --> RVB
      set private(r+g+b2rgbIcon) [image create photo r+g+b2rgbIcon -data {
         R0lGODlhEgARAMIEAAAAAP8AAABm/wD/M////////////////yH5BAEKAAcA
         LAAAAAASABEAAANFeLrcDDBC94K9kx5w8dZcFwAK6UjSgpZothGwCQx0bb5x
         WdsSTMg72g3gk7WGRVZLldwIntBhygl9yiiAqvWDPd40YEcCADs=
      }]

      #--- icone pour la configuration du temps
      set private(timeIcon) [image create photo timeIcon -data {
         R0lGODlhEAAQAKIHAMe6kriofJR7PnBgN9Dq/ujaw/7+/v///yH5BAEAAAcA
         LAAAAAAQABAAAANeeLrWtpAZQUWLaorCC33QxAEkwFnMVgDG0ASkm22sUxgw
         KtZNMQS4gGtnGwgIweFgNRQ6As5WAegQDAgEqExKNRCOMNmhBQtgsYGpePwD
         QN/OSOv3HqxDc/sFI9lDEgA7
      }]

      #--- icone pour choisir les couleurs
      set private(colorsIcon) [image create photo colorsIcon -data {
         R0lGODlhDAALAMZbAAAAMwQEBAAAZjMAAAAAmTMAMwAAzDMAZgAA/2YAABYW
         FmYAM2YAZmYAmSIiIpkAM2YAzAAzM5kAmQAzZjMzAAAzmcwAZpkA/8wAzGYz
         AP8AZjMz//8AzJkzAABmM8wzAABmZjNmAJkz/wBmzP8zAABm/2ZmAP8zZplm
         AP8z/2Zm/8xmAACZZgCZmf9mAP9mM2aZAMxm//9mmTOZ/5mZAP9m/2aZ//98
         gADMZpmZ/wDMzP+ZM2bMAP+ZZsyZ//+Zmf+ZzP+Z/8zMAAD/mZnM/wD//2b/
         ADP/mczM///MmTP////MzP/M/5n/M2b/zJn/Zmb//5n/zJn/////AMz/mf//
         M8z/zP//Zsz/////mf//zP//////////////////////////////////////
         ////////////////////////////////////////////////////////////
         /////////////////////////////////////////////////yH5BAEKAH8A
         LAAAAAAMAAsAAAd4gAEKAwkdHyQkLzc/S4IUGSgrLjs9SUmNDhQmNEJTVVdZ
         WVqOITA8Rk1PVFRWghEeLDhDR05RUa0OESAtOkVKUFJSWK4TFSMlMzZESEiC
         AAIEBggbKjnMggUHDRAXIjE+Ps0KBQwSGBwpNUFBTNgLDxYaJzI/QEuBADs=
      }]

      #--- icone pour choisir les polices de caracteres
      set private(fontsIcon) [image create photo fontsIcon -data {
         R0lGODlhEgAQAKECAAAAAOzp2f///////yH5BAEKAAIALAAAAAASABAAAAI1
         lG+ByxKgWntQLlrtwdnSrzkVQEZTKXbME2EmAiboSta2mgb6Hm94mtHNLjPO
         C1jh6S5KQQEAOw==
      }]

      #--- icone pour camera
      set private(cameraIcon) [image create photo cameraIcon -data {
         R0lGODlhGAARAKUuAAAAAAACAQABCwAECgAAQwAATAAAVwACSgAKAQABXAAJ
         EwALCwACfQANEwAOEwAEhQADlwANWgAMfgAMgwAMhQAPdAARdAASbAARiQAP
         pgAPrAAVegATsQAWtQAdeQAZpQAciQAdnwAjeQAgvgAmiQApcgAqmAAk1ABQ
         /3SH/4eT/5ig/5Wi/+Dc3P//////////////////////////////////////
         /////////////////////////////////yH5BAEKAD8ALAAAAAAYABEAAAZ7
         wJ9wSCwaj0aAUokkChQCh1DZqraYR4DVuux2uVMvdXsVA8JVszl9/o0BAaVr
         Pveyw17XwbNJ1M1TZXIuJikPIRYuaoFdeiwZJx0UF4tuggAuJRMrGiMYlICW
         jS4gEx8MBoqhWnkEJAkVf2KMeXSqq2q5XUNxupVNwEVBADs=
      }]

      #--- icone pour telescope
      set private(telescopIcon) [image create photo telescopIcon -data {
         R0lGODlhFgAaAKU5AAAAAAAACAAACgAACwAADQAADgAAEAAAEQAAFgAAFwAA
         GQAAQQAASgAAYwAAZgAAdAAAdQAAkgAAmgAAnAAAnQAAoAAApAAApwABqAAA
         xgAAzgAA0wAA2wAA3wAA5wAA7QAA/QAA/gAA/wEB/gkJvgYH/gYI/wgK/hYV
         cxYVfRcWdjk2f0A9YUhFRT9Lxj9L/0JP/0hW/0pZ/lNj/lhp/5KLgZ6WiMW8
         r8vBsv///////////////////////////yH5BAEKAD8ALAAAAAAWABoAAAa3
         wJ9wSCwajz8Ccjk8YGJMJOIiGsGiRYVFFBKZXkTAMlERmbmn6w8gPhoo5u65
         JBNuRMaCJM4/z4RdRl1yXR0PEBwiNEJcRmdcHis3NyseIYsMIguOZiAoOC0t
         OCggIi5ibUWdKTVsNSmlGgNCqUQhICo2bDYqpR8NUSEkLGwsJF0UCbVHIhRs
         cCITBWxYGWwZzQLUWGsADhEBbMtL4uWoWOVD4ujb6tzt3GHjTObmUfX19Pjp
         8VhBADs=
      }]

      #--- icone pour sommaire de l'aide
      set private(contentsIcon) [image create photo contentsIcon -data {
         R0lGODlhEgASAOMIAAAzZgAzmQBmZgBmmQBmzEC/////APb/9///////////
         /////////////////////yH5BAEKAA8ALAAAAAASABIAAARa8MlJq60ElHsz
         GQBHeUQJiqRhlF+IAeVKyKUrkezMAsKEz6qdgHADwHS5jABBfBAOgQEwx2Nu
         nAeEIEpdEq4PWFbLrX5fh7HADEZnvW2LJ3sW+WBxe93On0QAADs=
      }]

      #--- icone pour a propos de
      set private(aboutIcon) [image create photo aboutIcon -data {
         R0lGODlhDAAQAKEDAAAzZgCamgDM/////yH5BAEKAAMALAAAAAAMABAAAAIn
         nI8Ju6ECIXAGyCWpnVXwsTmWR4FiloBoGqbdx5JuBcyqHOMsbCMFADs=
      }]

      #--- icone pour loupe 20x
      set private(magnifier20xIcon) [image create photo magnifier20xIcon -data {
         R0lGODlhEAAQAMZGAAAAAFlfYGpucGpvcHJ2d3V5eXt/gH+Cg3+DhIGEhYOH
         iIWJioaKi4eLjIiLi4mMjIuOj5KVlpOWl5OXlZmdnZuenZ6in6Smp6Snp66w
         r66xr7K0tbK1srK2srK3srS4s7e6t7i7t77AwMLDxMbHxsrMyMrNyNDRzdDS
         z9DS0NTV1dXZ0tnc1tvd2dzd2tzd3dze2d3f2uDh3uLi4OHj3+Lj4OLj4+Lk
         3+Lk4OPl4OTl4+Xn4+fo5ejp5urq6Ovr6Ovr6evs6ezs6u3t6+3t7u7u7P//
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         /////////////////////////////////////////////////yH5BAEKAH8A
         LAAAAAAQABAAAAeNgH+Cg4SFhCoRAgEFFzaGgiIGGCguJhMOL4YqBiQ+Pz03
         LB4LRIURGD5DQ0FBNCsVG4UDKTwzMrc1MBwQhQEtJ7fBMiAJhQUlN0FFy0I7
         GRKFGBMsOELWQDoHI4U2Dx8rMTk7OhQMjy8NFh0hGggMAASZhUQbEAoS2wTw
         8o+DL/rx+hH6B0/gQH0GHwUCADs=
      }]

      #--- icone pour reticule
      set private(crosshairIcon) [image create photo crosshairIcon -data {
         R0lGODlhEAAQAKEBAAAAAP///////////yH5BAEKAAIALAAAAAAQABAAAAIq
         jB+AJ2vqmoNLLooswswlrx2cIQDmiabhA3pjsH6R2071dW+gwPf+LygAADs=
      }]

      #--- icone pour zoom+
      set private(openZoomPlusIcon) [image create photo openZoomPlusIcon -data {
         R0lGODlhEAAQAMZGAAAAAFlfYGpucGpvcHJ2d3V5eXt/gH+Cg3+DhIGEhYOH
         iIWJioaKi4eLjIiLi4mMjIuOj5KVlpOWl5OXlZmdnZuenZ6in6Smp6Snp66w
         r66xr7K0tbK1srK2srK3srS4s7e6t7i7t77AwMLDxMbHxsrMyMrNyNDRzdDS
         z9DS0NTV1dXZ0tnc1tvd2dzd2tzd3dze2d3f2uDh3uLi4OHj3+Lj4OLj4+Lk
         3+Lk4OPl4OTl4+Xn4+fo5ejp5urq6Ovr6Ovr6evs6ezs6u3t6+3t7u7u7P//
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         /////////////////////////////////////////////////yH5BAEKAH8A
         LAAAAAAQABAAAAeRgH+Cg4SFhCoRAgEFFzaGgiIGGCguJhMOL4YqBiQ+Pz03
         LB4LRIURGD5DQwBBNCsVG4UDKTwzMgAyNTAcEIUBLScAwsIwIAmFBSU3QUUA
         RUI7GRKFGBMsOEIAQkA6ByOFNg8fKzE5OzoUDI8vDRYdIRoIDAAEmYVEGxAK
         Et8E9PaPBr3wVy8goYH0DB70p/BRIAA7
      }]

      #--- icone pour zoom-
      set private(openZoomMoinsIcon) [image create photo openZoomMoinsIcon -data {
         R0lGODlhEAAQAMZGAAAAAFlfYGpucGpvcHJ2d3V5eXt/gH+Cg3+DhIGEhYOH
         iIWJioaKi4eLjIiLi4mMjIuOj5KVlpOWl5OXlZmdnZuenZ6in6Smp6Snp66w
         r66xr7K0tbK1srK2srK3srS4s7e6t7i7t77AwMLDxMbHxsrMyMrNyNDRzdDS
         z9DS0NTV1dXZ0tnc1tvd2dzd2tzd3dze2d3f2uDh3uLi4OHj3+Lj4OLj4+Lk
        3+Lk4OPl4OTl4+Xn4+fo5ejp5urq6Ovr6Ovr6evs6ezs6u3t6+3t7u7u7P//
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         ////////////////////////////////////////////////////////////
         /////////////////////////////////////////////////yH5BAEKAH8A
         LAAAAAAQABAAAAeOgH+Cg4SFhCoRAgEFFzaGgiIGGCguJhMOL4YqBiQ+Pz03
         LB4LRIURGD5DQ0FBNCsVG4UDKTwzMrc1MBwQhQEtJwDBwTAgCYUFJTdBRcxC
         OxkShRgTLDhC10A6ByOFNg8fKzE5OzoUDI8vDRYdIRoIDAAEmYVEGxAKEtwE
         8fOPgy/75PkjBDDeQIL7Dj4KBAA7
      }]

   }

}

::icones::initIcones

