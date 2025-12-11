function Format-UriParams {
    <#
    .SYNOPSIS
        Format a URI parameter string.

    .DESCRIPTION
        This function accepts a hashtable of URI parameters and returns a formatted string.

    .PARAMETER UriParams
        URI Request parameters as a hashtable.
    
    .EXAMPLE
        Format URI params for '$top' and '$skip'.

        PS> Format-UriParams -UriParams @{ '$top' = '5'; '$skip' = '1' }
        PS> "?$top=5&$skip=1"

    .EXAMPLE
        Format URI params for '$select' and '$expand'.

        PS> $UriParams = @{ '$select' = 'Id,FirstName,LastName,DisplayName,EmailAddress,Number,Groups'; '$expand' = 'Groups($select=GroupId,Name,Rights)' }
        PS> Format-UriParams -UriParams $UriParams
        PS> "?$select=Id%2CFirstName%2CLastName%2CDisplayName%2CEmailAddress%2CNumber%2CGroups&$expand=Groups(%24select%3DGroupId%2CName%2CRights)"
    #>

    [CmdletBinding()]
    [OutputType([string])]

    Param (
        [Parameter(mandatory = $true, HelpMessage = "URL parameters hashtable")]
        [hashtable]$UriParams
    )

    Begin {
        Write-Verbose "Format-UriParams: Begin"
        Write-Verbose "Format-UriParams: Param -UriParams '$($UriParams)'"

        $Count = 0
        $UriParamsCount = ($UriParams.Keys).Count
        $ParamStr = "?"
    }

    Process {
        foreach ($UriParam in $UriParams.GetEnumerator()) {
            $Count++
            $ParamStr += $UriParam.Name
            $ParamStr += '='
            $ParamStr += [uri]::EscapeDataString($UriParam.Value)
            if ($Count -lt $UriParamsCount) {
                $ParamStr += '&'
            }
        }
    }

    End {
        Write-Verbose "Format-UriParams: End"
        If ($?) {
            Write-Verbose "Format-UriParams: Completed Successfully."
        }
        Return $ParamStr
    }
}