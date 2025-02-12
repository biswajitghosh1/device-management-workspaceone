# This script will defer the Minor OS upgrade in macOS. This script will only download the installer file and notify the users.This script will be deployed across all the assignment groups except the Ring 1 and Beta Testers.

# Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")
# Check for available macOS updates
update_info=$(/usr/sbin/softwareupdate -l 2>&1)
latestminorupdates=$(echo "$update_info" | grep 'Title: macOS' | sed -e 's/,/:/g' | awk -F ': ' '{print $4}' | sort -r -V)

if [[ "$update_info" == *"No new software available"* ]]; then
  # No updates available, print message and exit
  echo "No update required."
  exit 0
else
  # Update available, force upgrade
	if [[ "$update_info" == *"Label: macOS"* ]]; then
    	pkill -f "softwareupdate" 2< /dev/null &
        /bin/launchctl asuser "$currUserUID" sudo -u "$currUser" /usr/sbin/softwareupdate --download --all &
        /usr/local/bin/hubcli notify -t "Update Version $latestminorupdates Available" -s "Recommendation To Update Now" -i "Clicking Update Now will launch macOS Software Update." -a "Update Now" -b "open "/System/Library/PreferencePanes/SoftwareUpdate.prefPane""
        echo "Found macOS Minor Update"
        return 0
	else
		/bin/launchctl asuser "$currUserUID" sudo -u "$currUser" /usr/sbin/softwareupdate --install --all --force &
        echo "Found other update and force update"
        return 0
    fi
exit 0
fi