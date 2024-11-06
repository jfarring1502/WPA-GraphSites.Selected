$ApplicationID = "3236a779-93fa-4553-9dd4-b4feea940456"
$TenatDomainName = "7a916015-20ae-4ad1-9170-eefd915e9272"
#$TenatDomainName = "Pfizer.onmicrosoft.com"
#$AccessSecret = Read-Host "Enter Secret of Granter App"
$AccessSecret = "1h8o.Kq4JW63-Gh.~WV3_5DgoDfq~6Yq-3"

## Client ID of app recieving the permissions and name of the app ##
$ClientId = Read-Host "Enter Application ID of Recieving App"
$AppName = Read-Host "Enter the Entra App name, starts with M365Gov" 
$siteName = Read-Host "Enter the pfizer.sharepoint.com site name. Only include the child site after pfizer.sharepoint.com"

#add the comma separated permissions for the site. Valid options are write, read, manage, or fullcontrol
$Permissions = "read, write"


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


$post_msg ='{
    "roles": [
        "$Permissions"
    ],
    "grantedToIdentities": [
        {
            "application": {
                "id": "' + $ClientId + '",
                "displayName": "' + $AppName + '"
            }
        }
    ]
}' 

$converted_post_msg = ConvertTo-Json $post_msg
$apiUrl = 'https://graph.microsoft.com/v1.0/sites/' + $siteId + '/permissions'

$val = Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)"} -Uri $apiUrl -Body $post_msg -Method post -ContentType "application/json"
$val