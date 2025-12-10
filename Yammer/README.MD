# Yammer

## App Registration

Create an Entra ID App registration

Add 2 Redirect URIs:

- Public client/native (mobile & desktop) - <https://login.microsoftonline.com/common/oauth2/nativeclient>
- Public client/native (mobile & desktop) - <http://localhost>

Grant it API Permissions for:

- Yammer - access_as_user

If you have the [Microsoft.Graph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0)
PowerShell module installed use the code below to automatically create the app registration:

```ps
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Applications

Connect-MgGraph -Scopes "Application.ReadWrite.All"

$App = New-MgApplication -DisplayName "YammerAdministration"
$AppId = $App.Id

$BodyParameters = @{
    RequiredResourceAccess = @(
        @{
            ResourceAppId = "00000005-0000-0ff1-ce00-000000000000"
            ResourceAccess = @(
                @{
                    Id = "8e5870bb-8808-44dc-8e10-c509ed919ddd"
                    Type = "Scope"
                }
            )
        }
    )
}
Update-MgApplication -ApplicationId $AppId -BodyParameter $BodyParameters

$RedirectURI = @()
$RedirectURI += "https://login.microsoftonline.com/common/oauth2/nativeclient"
$RedirectURI += "https://localhost:3000"
$PublicClient = @{
    RedirectUris = @($RedirectURI)
}
Update-MgApplication -ApplicationId $AppId -IsFallbackPublicClient -PublicClient $PublicClient
```

## MSAL.PS

The PowerShell module 'MSAL.PS' is required to gain an access token to authenticate with the Yammer API:

Install it by running:

```ps
Install-Module -Name MSAL.PS -RequiredVersion '4.37.0.0' -AllowClobber -Force
```

## Using the module

```ps
Import-Module 'Full\Path\to\YammerManagement.psm1'

# You will need your Tenant ID and the Client (Application) ID of the App registration we created above
$TenantId = ""
$ClientId = ""
# Connect to the Yammer API and get an Access Token
Connect-Yammer -TenantId $TenantId -ClientId $ClientId

# Get the current Yammer user
Get-YammerUser -Current
```
