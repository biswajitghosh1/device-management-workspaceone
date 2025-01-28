# The script includes details for the API key and the API endpoints. The only information it's required is to get the device IDs which can be obtained from WS1.

#API Endpoint Information
$SourceApiKey = "OyeGrzrEI7RBQWVL5VcJrBqtvit2EZqGiQqyEO5Zwb8="
$body = @{
     "grant_type" = "client_credentials"
     "client_id" = "aa3a5479e7a042218df6a13bc2249138"
     "client_secret" = "986BDAEBAED0725A01A59A7FC4969C59"

}

#Script Body
$headers = @{
     "Content_Type" = "application/x-www-form-urlencoded"
}
$response = Invoke-RestMethod "https://na.uemauth.vmwservices.com/connect/token" -Method 'POST' -Headers $headers -Body $body
$token = $response.access_token
$authorizationHeader = "Bearer ${token}"

#Write-Output $authorizationHeader
$headers = @{
   'Content-Type' = 'application/json'
   'Authorization' = $authorizationHeader
   'aw-tenant-code' = $SourceApiKey
}

#Create a .csv file with the name"devicemove"
$TodaysDate = Get-Date -Format "yyyy-MM-dd"
$csvFilePath = "$PSScriptRoot\devicemove.csv"
$logFilePath = "$PSScriptRoot\devicemove-LogFile-$TodaysDate.log"
 
if (Test-Path $csvFilePath) {
    $DeviceRecords = Import-Csv -Path $csvFilePath
 
    foreach ($row in $DeviceRecords) {
        $Username = $row.username
        Write-Output "ID- $Username"
     
        $SerialNumber = $row.serialnumber
        Write-Output "Device S/N- $SerialNumber"
 
        $DeviceID = $row.deviceid
        Write-Output "DeviceModel- $DeviceID"
        try {   
                $UpdateOGUrl = "https://as63.airwatchportals.com/api/mdm/devices/$DeviceID/commands/changeorganizationgroup/603"
               
               Write-Output $UpdateOGUrl
               $changeOG = Invoke-RestMethod $UpdateOGUrl -Method PUT -Headers $headers
               Write-Output $changeOG
               
        }catch {
          $errorMessage = "Device record with ID: $Username --- Error: $_"
          Write-Host $errorMessage
          $errorMessage | Out-File -Append -FilePath $logFilePath
        }
     }
} else {
    Write-Output "CSV file not found at $csvFilePath."
}