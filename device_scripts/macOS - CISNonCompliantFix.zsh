# This script will fix all the non-compliant items which has been identified by "macOS - CISNonCompliantList.zsh".

#Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

#path
cisremediation=/Library/Application\ Support/cis/cis_lvl1custom_compliance.sh

#trigger compliance scan
zsh $cisremediation --fix >/dev/null 2>/dev/null

#trigger non-compliant sensor to run and collect new value after remediation
#/usr/local/bin/hubcli sensors --trigger sciscompliancestats >/dev/null 2>/dev/null

/usr/local/bin/hubcli sensors --trigger sciscompliancestats
echo CIS Remediation Fix Complete

exit 0