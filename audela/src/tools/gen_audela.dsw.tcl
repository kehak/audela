set audela [list \
audela		audela \
libak		libak \
libaudela	libaudela \
libgsltcl	libgsltcl \
libgzip		libgzip \
libjm		libjm \
libmc		libmc \
libsext		libsext \
librgb		librgb \
libtt		libtt \
]

set libcam [list \
libandor	libandor \
libaudine	libaudine \
libaudinet	libaudinet \
libcamth	libcamth \
libcookbook	libcookbook \
libethernaude	libethernaude \
libfingerlakes	libfingerlakes \
libhisis	libhisis \
libk2		libk2 \
libkitty	libkitty \
libquicka	libquicka \
libsbig		libsbig \
libstarlight	libstarlight \
libsynonyme	libsynonyme \
libwebcam	libwebcam \
]

set libtel [list \
libaudecom	libaudecom \
libavrcom	libavrcom \
libcompad	libcompad \
liblx200	liblx200 \
liblxnet	liblxnet \
libmcmt		libmcmt \
libouranos	libouranos \
libtelcom	libtelcom \
libtemma	temma \
]

set contrib [list \
ethernaude	CCD_Driver \
libgs		libgs \
quicka		quicka \
]

set f [open "audela.dsw" w]

puts $f "Microsoft Developer Studio Workspace File, Format Version 6.00"
puts $f "# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!"
puts $f ""
puts $f "###############################################################################"

foreach {i j} $audela {
puts $f ""
puts $f "Project: \"$i\"=\".\\audela\\$i\\vc60\\$j.dsp\" - Package Owner=<4>"
puts $f ""
puts $f "Package=<5>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "Package=<4>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "###############################################################################"
}

foreach {i j} $libcam {
puts $f ""
puts $f "Project: \"$i\"=\".\\libcam\\$i\\vc60\\$j.dsp\" - Package Owner=<4>"
puts $f ""
puts $f "Package=<5>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "Package=<4>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "###############################################################################"
}

foreach {i j} $libtel {
puts $f ""
puts $f "Project: \"$i\"=\".\\libtel\\$i\\vc60\\$j.dsp\" - Package Owner=<4>"
puts $f ""
puts $f "Package=<5>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "Package=<4>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "###############################################################################"
}

foreach {i j} $contrib {
puts $f ""
puts $f "Project: \"$i\"=\".\\contrib\\$i\\vc60\\$j.dsp\" - Package Owner=<4>"
puts $f ""
puts $f "Package=<5>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "Package=<4>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "###############################################################################"
}

puts $f ""
puts $f "Global:"
puts $f ""
puts $f "Package=<5>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "Package=<3>"
puts $f "{{{"
puts $f "}}}"
puts $f ""
puts $f "###############################################################################"
puts $f ""

close $f

