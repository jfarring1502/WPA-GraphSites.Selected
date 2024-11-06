## Client ID and secret of app who needs access to SPO sites ##
$ApplicationID = Read-Host "Enter Application ID of Recieving App"
$AccessSecret = Read-host "Enter the application secret value"
$TenatDomainName = "7a916015-20ae-4ad1-9170-eefd915e9272"
$siteName = Read-Host "Enter the pfizer.sharepoint.com site name. Only include the child site after pfizer.sharepoint.com"


$Body = @{    
Grant_Type    = "client_credentials"
Scope         = "https://graph.microsoft.com/.default"
client_Id     = $ApplicationID
Client_Secret = $AccessSecret
} 

$ConnectGraph = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenatDomainName/oauth2/v2.0/token -Method POST -Body $Body

$token = $ConnectGraph.access_token

#GET /sites/{hostname}:/{server-relative-path}
$apiUrl = 'https://graph.microsoft.com/v1.0/sites/pfizer.sharepoint.com:/sites/' + $siteName
$val = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)"} -Uri $apiUrl -Method Get -ContentType "application/json"
$siteID = [regex]::Matches($val.id, ',([^/)]+),').value.trim(",")

## Site ID of the site you granted access for ##
## THE BELOW IS THE SITE ID FOR THE DAP SHAREPOINT ONLINE SITE ##
$apiUrl = 'https://graph.microsoft.com/v1.0/sites/' + $siteId + '/drives'
try {
    $val = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)"} -Uri $apiUrl -Method Get
    $val.value
} catch {
    Write-Host "Failed"
}


## Site ID of the site the app doesn't have access to ##
## Below ID is to 'Kyle Test' SPO Site. Only Kyle has access to it ##
$siteId='1e85ccc5-3c9d-41af-b7f3-49f8236aeb28'
$apiUrl = 'https://graph.microsoft.com/v1.0/sites/' + $siteId + '/lists'

try {
    $val = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)"} -Uri $apiUrl -Method Get
    $val.value
} catch {
    Write-Host "Failed"
}