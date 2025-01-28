# This script is developed to scan the macbooks to ensure its compliant to CIS Baseline and needs to be deployed only via Workspace One.

#----COPY BELOW THIS LINE------

#!/bin/zsh

#path
cischeck=/Library/Application\ Support/cis/cis_lvl1custom_compliance.sh

#trigger compliance scan
zsh $cischeck --check >/dev/null 2>/dev/null
zsh $cischeck --stats