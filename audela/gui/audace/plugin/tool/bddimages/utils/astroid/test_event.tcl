# source /srv/develop/audela/gui/audace/plugin/tool/bddimages/utils/ssp_yd/test_event.tcl

# but : je cherche a arreter la procedure boucleinfinie sans la MODIFIER !

proc boucleinfinie {} {
    while {1} {
       gren_info "."
    }
    return accepted
}


after 5000 set state timeout

# je lance la boucle infinie 
set state [boucleinfinie]

# Wait for something to happen
vwait state

after cancel set state timeout

# Do something based on how the vwait finished...
switch $state {
    timeout {
        gren_info "aborted"
    }
    accepted {
       gren_info "ok "
    }
}
