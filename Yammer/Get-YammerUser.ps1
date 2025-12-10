function Get-YammerUser {
    <#
    .SYNOPSIS
        Get Yammer user(s).

    .DESCRIPTION
        Use this function fetch the current user's Yammer profile, a Yammer user by ID or email,
        or fetch all Yammer users in minimal or full modes.

    .PARAMETER Id
        Yammer User ID

    .PARAMETER Email
        Yammer User Email

    .PARAMETER Current
        Current Yammer User

    .PARAMETER All
        All Yammer Users

    .PARAMETER Full
        Used to fetch the 'full' data for all Yammer users (slower)

    .EXAMPLE
        Fetch the current Yammer user.

        PS> Get-YammerUser -Current

    .EXAMPLE
        Fetch the Yammer user with the email 'John.Doe@company.co.uk'.

        PS> Get-YammerUser -Email "John.Doe@company.co.uk"

    .EXAMPLE
        Fetch all Yammer users in 'Full' mode.

        PS> Get-YammerUser -All -Full
    #>

    [CmdletBinding(DefaultParameterSetName = 'Current')]
    [OutputType([System.Object])]

    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'ById', HelpMessage = "Yammer User ID")]
        [string] $Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByEmail', HelpMessage = "Yammer User Email")]
        [string] $Email,

        [Parameter(Mandatory = $false, ParameterSetName = 'Current', HelpMessage = "Current Yammer User")]
        [switch] $Current,

        [Parameter(Mandatory = $false, ParameterSetName = 'All', HelpMessage = "All Yammer Users")]
        [switch] $All,

        [Parameter(Mandatory = $false, ParameterSetName = 'All', HelpMessage = "Fetch full data when returning all Yammer users")]
        [switch] $Full
    )

    Begin {
        Write-Verbose "Get-YammerUser: Begin"
        Write-Verbose "Get-YammerUser: Param -Id $Id"
        Write-Verbose "Get-YammerUser: Param -Email $Email"
        Write-Verbose "Get-YammerUser: Param -Current $Current"
        Write-Verbose "Get-YammerUser: Param -All $All"
        Write-Verbose "Get-YammerUser: Param -Full $Full"

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
        switch -Wildcard ($PSCmdlet.ParameterSetName) {
            "ById" {
                $ApiResponseContent = Invoke-YammerRequest -Path "/users/$Id.json"
                $Response = [PSCustomObject]@{
                    Id                         = $ApiResponseContent.id
                    NetworkId                  = $ApiResponseContent.network_id
                    State                      = $ApiResponseContent.state
                    JobTitle                   = $ApiResponseContent.job_title
                    Location                   = $ApiResponseContent.location
                    Interests                  = $ApiResponseContent.interests
                    Summary                    = $ApiResponseContent.summary
                    Expertise                  = $ApiResponseContent.expertise
                    FullName                   = $ApiResponseContent.full_name
                    ActivatedAt                = $ApiResponseContent.activated_at
                    AutoActivated              = $ApiResponseContent.auto_activated
                    ShowAskForPhoto            = $ApiResponseContent.show_ask_for_photo
                    FirstName                  = $ApiResponseContent.first_name
                    LastName                   = $ApiResponseContent.last_name
                    NetworkName                = $ApiResponseContent.network_name
                    NetworkDomains             = $ApiResponseContent.network_domains
                    Url                        = $ApiResponseContent.url
                    WebUrl                     = $ApiResponseContent.web_url
                    Name                       = $ApiResponseContent.name
                    MugshotUrl                 = $ApiResponseContent.mugshot_url
                    MugshotRedirectUrl         = $ApiResponseContent.mugshot_redirect_url
                    MugshotUrlTemplate         = $ApiResponseContent.mugshot_url_template
                    MugshotRedirectUrlTemplate = $ApiResponseContent.mugshot_redirect_url_template
                    BirthDate                  = $ApiResponseContent.birth_date
                    BirthDateComplete          = $ApiResponseContent.birth_date_complete
                    Timezone                   = $ApiResponseContent.timezone
                    ExternalUrls               = $ApiResponseContent.external_urls
                    Admin                      = $ApiResponseContent.admin
                    VerifiedAdmin              = $ApiResponseContent.verified_admin
                    M365YammerAdmin            = $ApiResponseContent.m365_yammer_admin
                    SupervisorAdmin            = $ApiResponseContent.supervisor_admin
                    O365TenantAdmin            = $ApiResponseContent.o365_tenant_admin
                    AnswersAdmin               = $ApiResponseContent.answers_admin
                    CorporateCommunicator      = $ApiResponseContent.corporate_communicator
                    CanBroadcast               = $ApiResponseContent.can_broadcast
                    Department                 = $ApiResponseContent.department
                    Email                      = $ApiResponseContent.email
                    Guest                      = $ApiResponseContent.guest
                    AadGuest                   = $ApiResponseContent.aad_guest
                    CanViewDelegations         = $ApiResponseContent.can_view_delegations
                    CanCreateNewNetwork        = $ApiResponseContent.can_create_new_network
                    CanBrowseExternalNetworks  = $ApiResponseContent.can_browse_external_networks
                    ReactionAccentColor        = $ApiResponseContent.reaction_accent_color
                    CanCreateConnectedGroups   = $ApiResponseContent.can_create_connected_groups
                    SignificantOther           = $ApiResponseContent.significant_other
                    KidsNames                  = $ApiResponseContent.kids_names
                    PreviousCompanies          = $ApiResponseContent.previous_companies
                    Schools                    = $ApiResponseContent.schools
                    Contact                    = $ApiResponseContent.contact
                    Stats                      = $ApiResponseContent.stats
                    Settings                   = $ApiResponseContent.settings
                    WebPreferences             = $ApiResponseContent.web_preferences
                    ShowInviteLightbox         = $ApiResponseContent.show_invite_lightbox
                    AgeBucket                  = $ApiResponseContent.age_bucket
                }
            }
            "ByEmail" {
                $ApiResponseContent = Invoke-YammerRequest -Path "/users/by_email.json?email=$Email"
                $Response = [PSCustomObject]@{
                    Id                         = $ApiResponseContent.id
                    NetworkId                  = $ApiResponseContent.network_id
                    State                      = $ApiResponseContent.state
                    JobTitle                   = $ApiResponseContent.job_title
                    Location                   = $ApiResponseContent.location
                    Interests                  = $ApiResponseContent.interests
                    Summary                    = $ApiResponseContent.summary
                    Expertise                  = $ApiResponseContent.expertise
                    FullName                   = $ApiResponseContent.full_name
                    ActivatedAt                = $ApiResponseContent.activated_at
                    AutoActivated              = $ApiResponseContent.auto_activated
                    ShowAskForPhoto            = $ApiResponseContent.show_ask_for_photo
                    FirstName                  = $ApiResponseContent.first_name
                    LastName                   = $ApiResponseContent.last_name
                    NetworkName                = $ApiResponseContent.network_name
                    NetworkDomains             = $ApiResponseContent.network_domains
                    Url                        = $ApiResponseContent.url
                    WebUrl                     = $ApiResponseContent.web_url
                    Name                       = $ApiResponseContent.name
                    MugshotUrl                 = $ApiResponseContent.mugshot_url
                    MugshotRedirectUrl         = $ApiResponseContent.mugshot_redirect_url
                    MugshotUrlTemplate         = $ApiResponseContent.mugshot_url_template
                    MugshotRedirectUrlTemplate = $ApiResponseContent.mugshot_redirect_url_template
                    BirthDate                  = $ApiResponseContent.birth_date
                    BirthDateComplete          = $ApiResponseContent.birth_date_complete
                    Timezone                   = $ApiResponseContent.timezone
                    ExternalUrls               = $ApiResponseContent.external_urls
                    Admin                      = $ApiResponseContent.admin
                    VerifiedAdmin              = $ApiResponseContent.verified_admin
                    M365YammerAdmin            = $ApiResponseContent.m365_yammer_admin
                    SupervisorAdmin            = $ApiResponseContent.supervisor_admin
                    O365TenantAdmin            = $ApiResponseContent.o365_tenant_admin
                    AnswersAdmin               = $ApiResponseContent.answers_admin
                    CorporateCommunicator      = $ApiResponseContent.corporate_communicator
                    CanBroadcast               = $ApiResponseContent.can_broadcast
                    Department                 = $ApiResponseContent.department
                    Email                      = $ApiResponseContent.email
                    Guest                      = $ApiResponseContent.guest
                    AadGuest                   = $ApiResponseContent.aad_guest
                    CanViewDelegations         = $ApiResponseContent.can_view_delegations
                    CanCreateNewNetwork        = $ApiResponseContent.can_create_new_network
                    CanBrowseExternalNetworks  = $ApiResponseContent.can_browse_external_networks
                    ReactionAccentColor        = $ApiResponseContent.reaction_accent_color
                    CanCreateConnectedGroups   = $ApiResponseContent.can_create_connected_groups
                    SignificantOther           = $ApiResponseContent.significant_other
                    KidsNames                  = $ApiResponseContent.kids_names
                    PreviousCompanies          = $ApiResponseContent.previous_companies
                    Schools                    = $ApiResponseContent.schools
                    Contact                    = $ApiResponseContent.contact
                    Stats                      = $ApiResponseContent.stats
                    Settings                   = $ApiResponseContent.settings
                    WebPreferences             = $ApiResponseContent.web_preferences
                    ShowInviteLightbox         = $ApiResponseContent.show_invite_lightbox
                    AgeBucket                  = $ApiResponseContent.age_bucket
                }
            }
            "Current" {
                $ApiResponseContent = Invoke-YammerRequest -Path "/users/current.json"
                $Response = [PSCustomObject]@{
                    Id                         = $ApiResponseContent.id
                    NetworkId                  = $ApiResponseContent.network_id
                    State                      = $ApiResponseContent.state
                    JobTitle                   = $ApiResponseContent.job_title
                    Location                   = $ApiResponseContent.location
                    Interests                  = $ApiResponseContent.interests
                    Summary                    = $ApiResponseContent.summary
                    Expertise                  = $ApiResponseContent.expertise
                    FullName                   = $ApiResponseContent.full_name
                    ActivatedAt                = $ApiResponseContent.activated_at
                    AutoActivated              = $ApiResponseContent.auto_activated
                    ShowAskForPhoto            = $ApiResponseContent.show_ask_for_photo
                    FirstName                  = $ApiResponseContent.first_name
                    LastName                   = $ApiResponseContent.last_name
                    NetworkName                = $ApiResponseContent.network_name
                    NetworkDomains             = $ApiResponseContent.network_domains
                    Url                        = $ApiResponseContent.url
                    WebUrl                     = $ApiResponseContent.web_url
                    Name                       = $ApiResponseContent.name
                    MugshotUrl                 = $ApiResponseContent.mugshot_url
                    MugshotRedirectUrl         = $ApiResponseContent.mugshot_redirect_url
                    MugshotUrlTemplate         = $ApiResponseContent.mugshot_url_template
                    MugshotRedirectUrlTemplate = $ApiResponseContent.mugshot_redirect_url_template
                    BirthDate                  = $ApiResponseContent.birth_date
                    BirthDateComplete          = $ApiResponseContent.birth_date_complete
                    Timezone                   = $ApiResponseContent.timezone
                    ExternalUrls               = $ApiResponseContent.external_urls
                    Admin                      = $ApiResponseContent.admin
                    VerifiedAdmin              = $ApiResponseContent.verified_admin
                    M365YammerAdmin            = $ApiResponseContent.m365_yammer_admin
                    SupervisorAdmin            = $ApiResponseContent.supervisor_admin
                    O365TenantAdmin            = $ApiResponseContent.o365_tenant_admin
                    AnswersAdmin               = $ApiResponseContent.answers_admin
                    CorporateCommunicator      = $ApiResponseContent.corporate_communicator
                    CanBroadcast               = $ApiResponseContent.can_broadcast
                    Department                 = $ApiResponseContent.department
                    Email                      = $ApiResponseContent.email
                    Guest                      = $ApiResponseContent.guest
                    AadGuest                   = $ApiResponseContent.aad_guest
                    CanViewDelegations         = $ApiResponseContent.can_view_delegations
                    CanCreateNewNetwork        = $ApiResponseContent.can_create_new_network
                    CanBrowseExternalNetworks  = $ApiResponseContent.can_browse_external_networks
                    ReactionAccentColor        = $ApiResponseContent.reaction_accent_color
                    CanCreateConnectedGroups   = $ApiResponseContent.can_create_connected_groups
                    SignificantOther           = $ApiResponseContent.significant_other
                    KidsNames                  = $ApiResponseContent.kids_names
                    PreviousCompanies          = $ApiResponseContent.previous_companies
                    Schools                    = $ApiResponseContent.schools
                    Contact                    = $ApiResponseContent.contact
                    Stats                      = $ApiResponseContent.stats
                    Settings                   = $ApiResponseContent.settings
                    WebPreferences             = $ApiResponseContent.web_preferences
                    ShowInviteLightbox         = $ApiResponseContent.show_invite_lightbox
                    AgeBucket                  = $ApiResponseContent.age_bucket
                }
            }
            "All" {
                if ($Full) {
                    $Users = New-Object System.Collections.Generic.List[System.Object]
                    $Page = 0
                    $HasUsers = $true
                    do {
                        $Page++
                        $ApiResponseContent = Invoke-YammerRequest -Path "/users.json?page=$Page"
                        if ($ApiResponseContent.Count -eq 0) {
                            $HasUsers = $false
                        }
                        else {
                            $Users.AddRange($ApiResponseContent)
                        }
                    } while (
                        $HasUsers -ne $false
                    )
                    $Response = foreach ($User in $Users) {
                        [PSCustomObject]@{
                            Id                         = $User.id
                            NetworkId                  = $User.network_id
                            State                      = $User.state
                            JobTitle                   = $User.job_title
                            Location                   = $User.location
                            Interests                  = $User.interests
                            Summary                    = $User.summary
                            Expertise                  = $User.expertise
                            FullName                   = $User.full_name
                            ActivatedAt                = $User.activated_at
                            AutoActivated              = $User.auto_activated
                            ShowAskForPhoto            = $User.show_ask_for_photo
                            FirstName                  = $User.first_name
                            LastName                   = $User.last_name
                            NetworkName                = $User.network_name
                            NetworkDomains             = $User.network_domains
                            Url                        = $User.url
                            WebUrl                     = $User.web_url
                            Name                       = $User.name
                            MugshotUrl                 = $User.mugshot_url
                            MugshotRedirectUrl         = $User.mugshot_redirect_url
                            MugshotUrlTemplate         = $User.mugshot_url_template
                            MugshotRedirectUrlTemplate = $User.mugshot_redirect_url_template
                            BirthDate                  = $User.birth_date
                            BirthDateComplete          = $User.birth_date_complete
                            Timezone                   = $User.timezone
                            ExternalUrls               = $User.external_urls
                            Admin                      = $User.admin
                            VerifiedAdmin              = $User.verified_admin
                            M365YammerAdmin            = $User.m365_yammer_admin
                            SupervisorAdmin            = $User.supervisor_admin
                            O365TenantAdmin            = $User.o365_tenant_admin
                            AnswersAdmin               = $User.answers_admin
                            CorporateCommunicator      = $User.corporate_communicator
                            CanBroadcast               = $User.can_broadcast
                            Department                 = $User.department
                            Email                      = $User.email
                            Guest                      = $User.guest
                            AadGuest                   = $User.aad_guest
                            CanViewDelegations         = $User.can_view_delegations
                            CanCreateNewNetwork        = $User.can_create_new_network
                            CanBrowseExternalNetworks  = $User.can_browse_external_networks
                            ReactionAccentColor        = $User.reaction_accent_color
                            CanCreateConnectedGroups   = $User.can_create_connected_groups
                            SignificantOther           = $User.significant_other
                            KidsNames                  = $User.kids_names
                            PreviousCompanies          = $User.previous_companies
                            Schools                    = $User.schools
                            Contact                    = $User.contact
                            Stats                      = $User.stats
                            Settings                   = $User.settings
                            WebPreferences             = $User.web_preferences
                            ShowInviteLightbox         = $User.show_invite_lightbox
                            AgeBucket                  = $User.age_bucket
                        }
                    }
                }
                else {
                    $Uri = "https://www.yammer.com/api/v1/export?since=2013-11-25T00%3A00%3A00%2B00%3A00&model=User&include=csv"
                    $YammerReportZip = "C:\temp\YammerUserExport.zip"
                    $YammerReportZipExtract = "C:\temp\YammerUserExport"
                    $YammerReportZipExtractUsers = "C:\temp\YammerUserExport\Users.csv"

                    Invoke-RestMethod -Method Get -Uri $Uri -Headers @{ Authorization = "Bearer $($YammerToken.AccessToken)" } -OutFile $YammerReportZip
                    Expand-Archive -Path $YammerReportZip -DestinationPath $YammerReportZipExtract
                    $YammerUsers = Import-CSV -Path $YammerReportZipExtractUsers -Delimiter ","

                    $Response = foreach ($YammerUser in $YammerUsers) {
                        if ($YammerUser.state -ne "soft_delete") {
                            [PSCustomObject]@{
                                Id                         = $YammerUser.id
                                NetworkId                  = $null
                                State                      = $YammerUser.state
                                JobTitle                   = $YammerUser.job_title
                                Location                   = $YammerUser.location
                                Interests                  = $null
                                Summary                    = $null
                                Expertise                  = $null
                                FullName                   = $null
                                ActivatedAt                = $null
                                AutoActivated              = $null
                                ShowAskForPhoto            = $null
                                FirstName                  = $null
                                LastName                   = $null
                                NetworkName                = $null
                                NetworkDomains             = $null
                                Url                        = $YammerUser.api_url
                                WebUrl                     = $null
                                Name                       = $YammerUser.name
                                MugshotUrl                 = $null
                                MugshotRedirectUrl         = $null
                                MugshotUrlTemplate         = $null
                                MugshotRedirectUrlTemplate = $null
                                BirthDate                  = $null
                                BirthDateComplete          = $null
                                Timezone                   = $null
                                ExternalUrls               = $null
                                Admin                      = $null
                                VerifiedAdmin              = $null
                                M365YammerAdmin            = $null
                                SupervisorAdmin            = $null
                                O365TenantAdmin            = $null
                                AnswersAdmin               = $null
                                CorporateCommunicator      = $null
                                CanBroadcast               = $null
                                Department                 = $YammerUser.department
                                Email                      = $YammerUser.email
                                Guest                      = $null
                                AadGuest                   = $null
                                CanViewDelegations         = $null
                                CanCreateNewNetwork        = $null
                                CanBrowseExternalNetworks  = $null
                                ReactionAccentColor        = $null
                                CanCreateConnectedGroups   = $null
                                SignificantOther           = $null
                                KidsNames                  = $null
                                PreviousCompanies          = $null
                                Schools                    = $null
                                Contact                    = $null
                                Stats                      = $null
                                Settings                   = $null
                                WebPreferences             = $null
                                ShowInviteLightbox         = $null
                                AgeBucket                  = $null
                            }
                        }
                    }

                    Remove-Item $YammerReportZip -Force
                    Remove-Item $YammerReportZipExtract -Recurse -Force
                }
            }
        }
    }

    End {
        Write-Verbose "Get-YammerUser: End"
        If ($?) {
            Write-Verbose "Get-YammerUser: Completed Successfully"
        }
        return $Response
    }
}