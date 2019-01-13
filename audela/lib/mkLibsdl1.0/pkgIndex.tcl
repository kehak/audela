
switch $::tcl_platform(platform) {
  windows { regsub {^} $::env(PATH) "[file nativename $dir];" ::env(PATH) }
  unix    { regsub {^} $::env(PATH) "[file nativename $dir]:" ::env(PATH) }
  default { return }
}

package ifneeded mkLibsdl 1.0 [list load [file join [set dir] mkLibsdl10[info sharedlibextension]]]

