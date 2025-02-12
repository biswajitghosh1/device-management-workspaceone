# This script will extract the list of all the non-compliant items within the MSCP baseline controls list. Operation support team can view the list at the WS1 console to see which controls are failing/not compliant.

#Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

# cis v2 - Audit List
AUDIT_LIST=$(/usr/libexec/PlistBuddy -c "Print" /Library/Preferences/org.cis_lvl1custom.audit.plist | grep -B 1 "finding = true")
AUDIT_LIST_NEAT=$(echo "$AUDIT_LIST" | sed -n '/finding = true/!p' | sed -n '/--/!p' | cut -f1 -d"=" | column -t)

echo "$AUDIT_LIST_NEAT"

exit 0