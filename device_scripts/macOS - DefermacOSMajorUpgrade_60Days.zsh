# This script will defer the Major OS upgrade by 60 days in macOS. This script will be deployed across all the assignment groups except the Ring 1 and Beta Testers.

# Script Language = Zsh

# ----Do not modify below this line and COPY below this line to be deployed in MDM------

#!/bin/zsh

outputPath="/Library/Application Support/macOSUpdate/"
outputlog=$outputPath"daycount.txt"
softwareupdatelog=$outputPath"softwareupdate.txt"
DefaultlatestVersion=$(awk -F , '$2>max {max=$2;output=$2}END{print output}' "$softwareupdatelog" | cut -d ' ' -f3)
OSname=$(grep "$DefaultlatestVersion," "$softwareupdatelog" | awk -F ',' 'END{print substr($1,16,19)}')

datediff=$(head -1 "$outputlog")
expireday=$(expr 60 - $datediff)