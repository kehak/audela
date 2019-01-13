# Script load_config
# This script will be sourced in the loop
# ---------------------------------------

# === Beginning of script
::robobs::log "$caption(robobs,start_script) RobObs [info script]" 50

# === Body of script
::robobs_config::update

# === End of script
::robobs::log "$caption(robobs,exit_script) RobObs [info script]" 50
return ""
