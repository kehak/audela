# file: abtt_example.py

import abtt

# example 1
result = abtt.imageStack(".","image",1,2,1,".fit",".","out",1,1,".fit","ADD",None)
print ("example 1 abtt.imageStack result= %d " % (result))

# example 2
options = abtt.ImageStackOptions()
options.jpegfile_make = 0
options.jpeg_qualite = 80
options.jpegfile = "image.jpg".encode('utf8')
result = abtt.imageStack(".","image",1,2,1,".fit",".","out",1,1,".fit","ADD",options)
print ("example 2 abtt.imageStack result= %d " % (result))
