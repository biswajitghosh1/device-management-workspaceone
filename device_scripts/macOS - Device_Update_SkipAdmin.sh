# This script will help non-admin users to bypass the admin credentials prompt while installing major updates in macOS. Minor updates to not require any admin credentials, hence this script will not be applicable

# Script Language = Bash

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/bash
sudo security authorizationdb write com.apple.ServiceManagement.daemons.modify authenticate-session-owner-or-admin
sudo security authorizationdb write com.apple.installassistant.macos authenticate-session-owner-or-admin