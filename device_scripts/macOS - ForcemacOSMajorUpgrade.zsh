# This script will force major updates across all Macbooks in MDM. The alternative for this script would be to use "Device Updates" feature in the MDM console.

#Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

currUser=$(ls -l /dev/console | awk '{print $3}')
currUserUID=$(id -u "$currUser")
#DefaultlatestVersion=$(/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" softwareupdate --list-full-installers | awk -F , '$2>max {max=$2;output=$2}END{print output}' | cut -d ' ' -f3)
#OSname=$(/bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" softwareupdate --list-full-installers | grep "$DefaultlatestVersion" | awk -F ',' 'END{print substr($1,16,19)}'

outputPath="/Library/Application Support/macOSUpdate/"
outputlog=$outputPath"daycount.txt"
softwareupdatelog=$outputPath"softwareupdate.txt"
DefaultlatestVersion=$(awk -F , '$2>max {max=$2;output=$2}END{print output}' "$softwareupdatelog" | cut -d ' ' -f3)
OSname=$(grep "$DefaultlatestVersion," "$softwareupdatelog" | awk -F ',' 'END{print substr($1,16,19)}')

acPowerWaitTimer="180"

dlCheck() {

    # Checking for macOS update installer
    if [ -d "/Applications/Install macOS $OSname.app" ]; then 
        echo "Installer Found"
    else 
        /usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "$DefaultlatestVersion" &
    fi

}

kill_process() {
    processPID="$1"
    if /bin/ps -p "$processPID" > /dev/null ; then
        /bin/kill "$processPID"
        wait "$processPID" 2> /dev/null
    fi
}

wait_for_ac_power() {
    local PowerPID
    PowerPID="$1"
    ## Loop for "acPowerWaitTimer" seconds until either AC Power is detected or the timer is up
    /bin/echo "Waiting for AC power..."
    while [[ "$acPowerWaitTimer" -gt "0" ]]; do
        if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
            /bin/echo "Power Check: OK - AC Power Detected"
            kill_process "$PowerPID"
            return
        fi
        /bin/sleep 1
        ((acPowerWaitTimer--))
    done
    kill_process "$PowerPID"
    sysRequirementErrors+=("Is connected to AC power")
    /bin/echo "Power Check: ERROR - No AC Power Detected"
    dlCheck
    echo "Request Download Update Only"
    exit 1
}

validate_power_status() {
    ## Check if device is on battery or ac power
    ## If not, and our acPowerWaitTimer is above 1, allow user to connect to power for specified time period
    CurrentBatteryLevel=$(/usr/bin/pmset -g ps | grep '%' | awk '{print $3}' | sed -e 's/%;//g')
    ACPowerCheck=$(/usr/bin/pmset -g ps | /usr/bin/grep "AC Power" < /dev/null)
    if [[ "$ACPowerCheck" == "AC Power" ]] || [[ "$CurrentBatteryLevel" -gt 50 ]]; then
        /bin/echo "Power Check: OK - AC Power Detected/Battery power over 50%"
    else
        if [[ "$acPowerWaitTimer" -gt 0 ]]; then
            alertText="Waiting for AC Power Connection"
            alertMessage="Please plug in AC power adapter.\n \n Upgrade process will continue once AC power is detected."
            /bin/launchctl asuser "$currUserUID" sudo -iu "$currUser" /usr/bin/osascript -e "display dialog \"$alertMessage\" with title \"$alertText\" with icon caution buttons {\"Close\"}" &
            wait_for_ac_power "$!"

        else
            sysRequirementErrors+=("Is connected to AC power")
            /bin/echo "Power Check: ERROR - No AC Power Detected"
            dlCheck
            echo "Request Download Update Only"
            exit 1
        fi
    fi
}



/usr/local/bin/hubcli notify -t "Upgrade to macOS $OSname" -s "This may take up to 1 hour." -i "Your machine will restart automatically. You will be notified when your device will be restarted."
sleep 10
validate_power_status
echo "Continue Upgrade"
/usr/local/bin/hubcli mdmcommand --osupdate --productversion "$DefaultlatestVersion" --installaction InstallASAP
/usr/local/bin/hubcli sync
exit 0