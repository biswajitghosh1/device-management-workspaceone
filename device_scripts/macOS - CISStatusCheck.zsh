# This script is developed to scan the MacBooks to ensure its compliant to CIS Baseline and needs to be deployed via Workspace One MDM.

# Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

#path
cischeck=/Library/Application\ Support/cis/cis_lvl1custom_compliance.sh

#trigger compliance scan
zsh $cischeck --check >/dev/null 2>/dev/null
zsh $cischeck --stats