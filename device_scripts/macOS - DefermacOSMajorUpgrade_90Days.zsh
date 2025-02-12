# This script will defer the Major OS upgrade by 90 days in macOS. This script will be deployed across all the assignment groups except the Ring 1 and Beta Testers.

# Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

outputPath="/Library/Application Support/macOSUpdate/"
outputlog=$outputPath"daycount.txt"
softwareupdatelog=$outputPath"softwareupdate.txt"
DefaultlatestVersion=$(awk -F , '$2>max {max=$2;output=$2}END{print output}' "$softwareupdatelog" | cut -d ' ' -f3)
OSname=$(grep "$DefaultlatestVersion," "$softwareupdatelog" | awk -F ',' 'END{print substr($1,16,19)}')

datediff=$(head -1 "$outputlog")
expireday=$(expr 90 - $datediff)

if [ "$datediff" -lt 0 ]; then
echo "Error : Date count in negative"
exit 1
fi

if [ -d "/Applications/Install macOS $OSname.app" ]; then 
echo "Installer Found"
/usr/local/bin/hubcli notify -t "Reminder" -s "Please upgrade your macOS in $expireday days." -i "Click Upgrade Now" -a "Upgrade Now" -b "/usr/local/bin/hubcli mdmcommand --osupdate --productversion "$DefaultlatestVersion" --installaction InstallASAP" -c "Update Later"
else 
/usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "$DefaultlatestVersion" &|
echo "Installer Not Found,Download the installer now" 
fi