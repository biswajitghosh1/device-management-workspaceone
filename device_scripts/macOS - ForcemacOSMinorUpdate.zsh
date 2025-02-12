# This script will force minor updates across all Macbooks in MDM. The alternative for this script would be to use "Device Updates" feature in the MDM console.

#Script Language = Zsh

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
        #/usr/local/bin/hubcli mdmcommand --osupdate --productversion "$latestminorupdates" --installaction DownloadOnly --priority high
        /usr/local/bin/hubcli notify -t "Update Version $latestminorupdates Available" -s "Installation Update In Progress" -i "Please save all your work now. The computer may automatically reboot in few minutes after installation." -a "Software Update" -b "open "/System/Library/PreferencePanes/SoftwareUpdate.prefPane""
        pkill -f "softwareupdate" 2> /dev/null &
        /bin/launchctl asuser "$currUserUID" sudo -u root /usr/sbin/softwareupdate --install --recommended --restart > /dev/null &
        #/usr/sbin/softwareupdate --install --recommended --restart > /dev/null &|
        echo "Found macOS Minor Update"
        return 0
	else
		/bin/launchctl asuser "$currUserUID" sudo -u "$currUser" /usr/sbin/softwareupdate --install --all --force &
        echo "Found other update and force update"
        return 0
    fi
exit 0
fi