Create your own LUT colors for vizualisation
with AudeLA.

Example to use the predefined rainbow palette
(try from the Aud'ACE interface) :

visu1 pal palette/rainbow

N.B. Don't write .pal at the end of the name
of the palette you want to import.

If you want to create a new palette :

1) Edit a text empty file
2) Each line contain three number between 0 and 255
   First number is the red level
   Second number is the green level
   Third number is the blue level
3) Write 256 lines corresponding to the 256
   color levels that are displayed in a visu
   object of AudeLA.
4) Save the text file with the .pal extension.

N.B. It is easy to create such a file from a simple Tcl script.

# - create a linear gray scale palette
set f [open palette/mypal.pal w]
for {set k 0} {$k<256} {incr k} {
   puts $f "$k $k $k"
}
close $f
# - end of script
