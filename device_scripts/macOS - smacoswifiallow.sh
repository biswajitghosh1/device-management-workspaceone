# This script grants authorization for standard users to access and modify network preferences through the system preferences interface. With this permission, users can customize their network settings to suit their specific needs and preferences.

# Script Language = Bash

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/bash

/usr/bin/security authorizationdb write system.preferences.network allow
/usr/bin/security authorizationdb write system.services.systemconfiguration.network allow
/usr/bin/security authorizationdb write com.apple.wifi allow