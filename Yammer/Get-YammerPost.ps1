function Get-YammerPost {
    <#
    .SYNOPSIS
        Get visible posts for the current Yammer user.

    .DESCRIPTION
        Use this function fetch the posts visible to the current Yammer user.

    .PARAMETER IncludeSuspended
        Include networks the user is suspended in

    .PARAMETER ExcludeOwn
        Exclude the user's own messages from the unseen count

    .EXAMPLE
        Fetch the Yammer posts for the current user.

        PS> Get-YammerPost
    #>

    [CmdletBinding()]
    [OutputType([System.Object])]

    Param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Post thread type. false returns all posts, true returns only top-level posts, extended returns top-level posts and the two most recent messages"
        )]
        [ValidateSet("true", "false", "extended")]
        [string]
        $Threaded = "false",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Limit the number of posts returned"
        )]
        [int]
        $Limit,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Returns messages older than the message ID specified as a numeric string"
        )]
        [int]
        $OlderThan,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Returns messages newer than the message ID specified as a numeric string."
        )]
        [int]
        $NewerThan
    )

    Begin {
        Write-Verbose "Get-YammerPost: Begin"
        Write-Verbose "Get-YammerPost: Param -Threaded $Threaded"
        Write-Verbose "Get-YammerPost: Param -Limit $Limit"
        Write-Verbose "Get-YammerPost: Param -OlderThan $OlderThan"
        Write-Verbose "Get-YammerPost: Param -NewerThan $NewerThan"

        if (-not ($YammerToken)) {
            Write-Error "No token found. Call 'Connect-Yammer' to fetch an access token."
            break
        }
        if ((Get-Date) -ge $YammerToken.ExpiresOn.DateTime) {
            Write-Error "Access token expired. Call 'Connect-Yammer' to fetch an access token."
            break
        }
        $Response = $null
    }

    Process {
        $RequestParams = @{}
        if ($Threaded) {
            $RequestParams['threaded'] = $Threaded
        }
        if ($Limit) {
            $RequestParams['limit'] = $Limit
        }
        if ($OlderThan) {
            $RequestParams['older_than'] = $OlderThan
        }
        if ($NewerThan) {
            $RequestParams['newer_than'] = $NewerThan
        }
        $UriParamsStr = Format-UriParams -UriParams $RequestParams
        # https://learn.microsoft.com/en-us/rest/api/yammer/networkscurrentjson
        $ApiResponse = Invoke-YammerRequest -Path "/messages.json$($UriParamsStr)"
        $Response = Convert-PsObjectKeys -InputObject ($ApiResponse.Messages) -Depth 10
    }

    End {
        Write-Verbose "Get-YammerPost: End"
        If ($?) {
            Write-Verbose "Get-YammerPost: Completed Successfully"
        }
        return $Response
    }
}