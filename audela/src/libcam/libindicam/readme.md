## compilation de libindicam.so
```
$ cd audela/src/libcam/libindicam/linux
$ make clean
$ make
```

##Test de libindicam.so 

1) lancer le serveur  ( cf installation du serveur ci-dessous)
`indiserver -v indi_simulator_ccd`

2) lancer audela 

3) dans la console de Audela :
```
// creer la camera
cam::create indicam "CCD Simulator" 
ou 
cam::create indicam "CCD Simulator" -serverAddress 127.0.0.1  -serverPort 7624  

// associer le buffer d'image n°1 a la camera
cam1 buf 1

// configurer le temps de pose a 5 secondes
cam1 exptime 5 

// lancer l'acquisition 
cam1 acq 

// afficher l'image dans la visu
confVisu::autovisu 1

// supprimer la camera 
cam::delete 1
```
