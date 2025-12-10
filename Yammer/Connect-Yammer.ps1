function Connect-Yammer {
    <#
    .SYNOPSIS
        Connect to the Yammer API.

    .DESCRIPTION
        Use this function to connect/authenticate with the Yammer API.

    .PARAMETER TenantId
        Entra ID TenantId.

    .PARAMETER ClientId
        Entra ID App registration Client ID.

    .EXAMPLE
        Connect to Yammer with a given Tenant ID and Client ID.

        PS> Connect-Yammer -TenantId $TenantId -ClientId $ClientId
    #>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory = $true, HelpMessage = "Entra ID Tenant Id")]
        [string] $TenantId,

        [Parameter(Mandatory = $true, HelpMessage = "Entra ID App registration Client ID")]
        [string] $ClientId
    )

    Begin {
        Write-Verbose "Connect-Yammer: Begin"
        Write-Verbose "Connect-Yammer: Param -TenantId $TenantId"
        Write-Verbose "Connect-Yammer: Param -ClientId $ClientId"
        $MsalToken = $null
    }

    Process {
        try {
            $MsalToken = Get-MsalToken -TenantId $TenantId -ClientId $ClientId -Interactive -Scopes 'https://api.yammer.com/access_as_user'
            $script:YammerToken = [PSCustomObject]@{
                AccessToken = $MsalToken.AccessToken
                ExpiresOn   = $MsalToken.ExpiresOn
                TenantId    = $MsalToken.TenantId
                Scopes      = $MsalToken.Scopes
                TokenType   = $MsalToken.TokenType
            }
        }
        catch {
            Write-Error "Failed to fetch Yammer Access Token: '$($_.Exception.Message)'"
            $script:YammerToken = $null
        }
    }

    End {
        Write-Verbose "Connect-Yammer: End"
        If ($?) {
            Write-Verbose "Connect-Yammer: Completed Successfully"
        }
    }
}