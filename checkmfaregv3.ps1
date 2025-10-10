# This script checks every user in the tenant to find any users that have 'microsoftAuthenticatorAuthenticationMethod' or
# 'softwareOathAuthenticationMethod' as an authentication method (i.e. users with MFA). It then adds/removes users from a
# group (which enforces the MFA) as needed.

# To use this script create a Entra ID App Registration with the following permissions:
# GroupMember.ReadWrite.All, User.Read.All, UserAuthenticationMethod.Read.All
# Then create a secret and copy/store the secret value as you will need to enter it below

# Enter the ClientId, ClientSecret, TenantId, and GroupId below then run the script

$ApplicationClientId = 'CLIENT_ID'
$ApplicationClientSecret = 'CLIENT_SECRET'
$TenantId = 'TENANT_ID'
$GroupId = 'GROUP_ID'

$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome

$MgContext = Get-MgContext | Select-Object AppName, AuthType, Scopes
Write-Host "Connected to '$($MgContext.AppName)' with auth type '$($MgContext.AuthType)' using scopes '$($MgContext.Scopes -join ", ")'"

$Users = Get-MgUser -All

$MsAuthEnabledUsers = @()

foreach ($User in $Users) {
    Write-Host "Processing '$($User.DisplayName)'..." -ForegroundColor Yellow

    $UserAuthMethods = Get-MgUserAuthenticationMethod -UserId $User.Id
    Write-Host "    Found $($UserAuthMethods.Length) authentication methods for user"

    foreach ($UserAuthMethod in $UserAuthMethods) {
        Write-Host "    Processing $($UserAuthMethod.Id)..." -ForegroundColor Yellow
        $HasMSAuthenticator = $false
        Switch ($UserAuthMethod.AdditionalProperties["@odata.type"]) {
            "#microsoft.graph.emailAuthenticationMethod" {
                Write-Host "        User has 'email' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false
            } 
            "#microsoft.graph.fido2AuthenticationMethod" { 
                Write-Host "        User has 'FIDO2' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false
            }    
            "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { 
                Write-Host "        User has 'Microsoft Authenticator' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $true
            }    
            "#microsoft.graph.passwordAuthenticationMethod" {              
                Write-Host "        User has 'password' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false              
            }     
            "#microsoft.graph.phoneAuthenticationMethod" { 
                Write-Host "        User has 'phone' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false
            }   
            "#microsoft.graph.softwareOathAuthenticationMethod" { 
                Write-Host "        User has 'Third-Party Authenticator' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $true
            }           
            "#microsoft.graph.temporaryAccessPassAuthenticationMethod" { 
                Write-Host "        User has 'temporary password' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false
            }           
            "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" { 
                Write-Host "        User has 'Windows Hello for Business' authentication method"
                $AuthMethodKeys = ($UserAuthMethod | Select-Object -ExpandProperty AdditionalProperties).Keys | Where-Object { $_ -ne "@odata.type" }
                foreach ($AuthMethodKey in $AuthMethodKeys) {
                    Write-Host "            $($AuthMethodKey): $($UserAuthMethod[$AuthMethodKey])"
                }
                $HasMSAuthenticator = $false
            } 
        }
        if ($HasMSAuthenticator) {
            if ( -not ($MsAuthEnabledUsers -contains $User.Id)) {
                $MsAuthEnabledUsers += $User.Id
            }
        }
    }
    Write-Host " "
}

Write-Host " "

$Group = Get-MgGroup -GroupId $GroupId
$ExistingGroupMembers = Get-MgGroupMember -GroupId $GroupId | Select-Object -ExpandProperty Id

Write-Host "Processing group '$($Group.DisplayName)..." -ForegroundColor Yellow
Write-Host "    $($ExistingGroupMembers.Length) existing group member(s)"
Write-Host "    $($MsAuthEnabledUsers.Length) proposed new group member(s)"

Write-Host "    Removing duplicate users from existing and proposed group members"
# https://stackoverflow.com/questions/6368386/comparing-two-arrays-get-the-values-which-are-not-common
$UsersToAdd = @($MsAuthEnabledUsers | Where-Object { $ExistingGroupMembers -NotContains $_ })
Write-Host "    Removed $($ExistingGroupMembers.Length - $UsersToAdd.Length) duplicate users from proposed new group member(s)"

Write-Host "    $($UsersToAdd.Length) user(s) to add to '$($Group.DisplayName)'" -ForegroundColor Yellow
foreach ($UserToAdd in $UsersToAdd) {
    $UserDetails = Get-MgUser -UserId $UserToAdd | Select-Object Id, DisplayName, Mail
    Write-Host "        DisplayName: $($UserDetails.DisplayName) - Mail: $($UserDetails.Mail)"
    $NewGroupMemberParams = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$($UserDetails.Id)}"
    }
    New-MgGroupMemberByRef -GroupId $GroupId -BodyParameter $NewGroupMemberParams
}

Write-Host " "

Write-Host "    Filtering for users to remove from group"
$UsersToRemove = @($ExistingGroupMembers | Where-Object { $MsAuthEnabledUsers -NotContains $_ })

Write-Host "    $($UsersToRemove.Length) user(s) to remove from '$($Group.DisplayName)'" -ForegroundColor Yellow
foreach ($UserToRemove in $UsersToRemove) {
    $UserDetails = Get-MgUser -UserId $UserToRemove | Select-Object Id, DisplayName, Mail
    Write-Host "        DisplayName: $($UserDetails.DisplayName) - Mail: $($UserDetails.Mail)"
    Remove-MgGroupMemberDirectoryObjectByRef -GroupId $GroupId -DirectoryObjectId $UserDetails.Id
}

Write-Host " "

Read-Host -Prompt "Press enter to exit..." | Out-Null
