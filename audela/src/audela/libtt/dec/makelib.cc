rm *.o
cc -c ../src/tt2/*.c -I.
cc -c ../src/fitsio2/*.c -I.
cc -c ../src/jpeg/*.c -I.
ld -shared -o ../../../binunix/libtt.so *.o -lm -lc

