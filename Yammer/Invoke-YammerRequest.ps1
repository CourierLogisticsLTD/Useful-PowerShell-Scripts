function Invoke-YammerRequest {
    <#
    .SYNOPSIS
        

    .DESCRIPTION
        

    .PARAMETER TenantId
        

    .PARAMETER ClientId
        

    .EXAMPLE
        

        PS> Invoke-YammerRequest
    #>

    [CmdletBinding()]
    [OutputType([System.Object])]

    Param (
        [Parameter(Mandatory = $false, HelpMessage = "Request Method")]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')]
        [string] $Method = 'GET',

        [Parameter(Mandatory = $true, HelpMessage = "Yammer API Path")]
        [string] $Path,

        [Parameter(Mandatory = $false, HelpMessage = "Request headers")]
        [AllowNull()]
        [System.Object] $Headers = $null,

        [Parameter(Mandatory = $false, HelpMessage = "Request body")]
        [AllowNull()]
        [System.Object] $Body = $null
    )

    Begin {
        Write-Verbose "Invoke-YammerRequest: Begin"
        Write-Verbose "Invoke-YammerRequest: Param -Method $Method"
        Write-Verbose "Invoke-YammerRequest: Param -Path $Path"
        Write-Verbose "Invoke-YammerRequest: Param -Headers '$(if($Headers) { "$(($Headers | ConvertTo-Json -Compress)[0..20] -join '')..." })'"
        Write-Verbose "Invoke-YammerRequest: Param -Body '$(if($Body) { "$(($Body | ConvertTo-Json -Compress)[0..20] -join '')..." })'"

        $BaseUri = "https://www.yammer.com/api/v1"
        $Uri = "$($BaseUri)$($Path)"

        $ApiResponse = $null
    }

    Process {
        $Params = @{
            Method  = $Method
            Uri     = $Uri
            Headers = $Headers
        }

        if ($Headers) {
            $Params['Headers'] = $Headers
        }
        else {
            $Params['Headers'] = @{
                Authorization = "Bearer $($YammerToken.AccessToken)"
            }
        }

        if ($Method -ne "GET") {
            $Params['Body'] = $Body | ConvertTo-Json -Depth 5
        }

        Try {
            $OldProgressPreference = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue'
            $Response = Invoke-WebRequest @Params -ErrorAction Stop -UseBasicParsing
            $ProgressPreference = $OldProgressPreference
            $ResponseContent = ($Response.Content | ConvertFrom-Json)
            $ApiResponse = $ResponseContent
        }
        Catch [System.Net.WebException] {
            if ($_.Exception.Response) {
                $ErrorResponse = [PSCustomObject]@{}

                $ResponseHeaders = $_.Exception.Response.Headers
                $ErrorResponse | Add-Member -MemberType NoteProperty -Name "Headers" -Value $ResponseHeaders

                $ResponseStatusCode = $_.Exception.Response.StatusCode.value__
                $ErrorResponse | Add-Member -MemberType NoteProperty -Name "StatusCode" -Value $ResponseStatusCode

                $ResponseStatusDescription = $_.Exception.Response.StatusDescription
                $ErrorResponse | Add-Member -MemberType NoteProperty -Name "StatusDescription" -Value $ResponseStatusDescription

                $ResponseStream = $_.Exception.Response.GetResponseStream()
                $StreamReader = New-Object System.IO.StreamReader($ResponseStream)
                $StreamReader.BaseStream.Position = 0
                $StreamReader.DiscardBufferedData()
                $ResponseBody = $StreamReader.ReadToEnd()
    
                $StreamReader.Close()
                $StreamReader.Dispose()

                if ($_.Exception.Response.ContentType -match "application/json") {
                    $ErrorResponse | Add-Member -MemberType NoteProperty -Name "Body" -Value ($ResponseBody | ConvertFrom-Json)
                    $ErrorResponse | Add-Member -MemberType NoteProperty -Name "BodyContentType" -Value "JSON"
                }
                else {
                    $ErrorResponse | Add-Member -MemberType NoteProperty -Name "Body" -Value ($ResponseBody.ToString())
                    $ErrorResponse | Add-Member -MemberType NoteProperty -Name "BodyContentType" -Value "String"
                }
                Write-Error $_
            }
        }
    }

    End {
        Write-Verbose "Invoke-YammerRequest: End"
        If ($?) {
            Write-Verbose "Invoke-YammerRequest: Completed Successfully"
        }
        return $ApiResponse
    }
}