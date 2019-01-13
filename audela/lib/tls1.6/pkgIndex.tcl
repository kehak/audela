package ifneeded tls 1.6.1 \
    "[list source [file join $dir tls.tcl]] ; \
     [list tls::initlib $dir tls161.dll]"
