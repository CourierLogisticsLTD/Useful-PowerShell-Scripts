function Get-YammerNetwork {
    <#
    .SYNOPSIS
        Get current Yammer user network.

    .DESCRIPTION
        Use this function fetch the current user's Yammer network.

    .PARAMETER IncludeSuspended
        Include networks the user is suspended in

    .PARAMETER ExcludeOwn
        Exclude the user's own messages from the unseen count

    .EXAMPLE
        Fetch the Yammer network for the current user.

        PS> Get-YammerNetwork
    #>

    [CmdletBinding()]
    [OutputType([System.Object])]

    Param (
        [Parameter(Mandatory = $false, HelpMessage = "Include networks the user is suspended in")]
        [switch] $IncludeSuspended,

        [Parameter(Mandatory = $false, HelpMessage = "Exclude the user's own messages from the unseen count")]
        [switch] $ExcludeOwn
    )

    Begin {
        Write-Verbose "Get-YammerNetwork: Begin"
        Write-Verbose "Get-YammerNetwork: Param -IncludeSuspended $IncludeSuspended"
        Write-Verbose "Get-YammerNetwork: Param -ExcludeOwn $ExcludeOwn"

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
        if ($IncludeSuspended) {
            $RequestParams['include_suspended'] = $true
        }
        if ($ExcludeOwn) {
            $RequestParams['exclude_own_messages_from_unseen'] = $true
        }
        $UriParamsStr = Format-UriParams -UriParams $RequestParams
        # https://learn.microsoft.com/en-us/rest/api/yammer/networkscurrentjson
        $ApiResponse = Invoke-YammerRequest -Path "/networks/current.json$($UriParamsStr)"
        # foreach ($prop in $Response.psObject.Properties) {
        #     $TextInfo = (Get-Culture).TextInfo
        #     $Name = $textInfo.ToTitleCase($prop.Name).Replace("_", "")
        #     Write-Host "$($Name) = `$Response.$($prop.Name)"
        # }
        $Response = [PSCustomObject]@{
            Type                               = $ApiResponse.type
            Id                                 = $ApiResponse.id
            Email                              = $ApiResponse.email
            Name                               = $ApiResponse.name
            Community                          = $ApiResponse.community
            Permalink                          = $ApiResponse.permalink
            WebUrl                             = $ApiResponse.web_url
            ShowUpgradeBanner                  = $ApiResponse.show_upgrade_banner
            HeaderBackgroundColor              = $ApiResponse.header_background_color
            HeaderTextColor                    = $ApiResponse.header_text_color
            NavigationBackgroundColor          = $ApiResponse.navigation_background_color
            NavigationTextColor                = $ApiResponse.navigation_text_color
            Paid                               = $ApiResponse.paid
            Moderated                          = $ApiResponse.moderated
            IsFreemium                         = $ApiResponse.is_freemium
            IsOrgChartEnabled                  = $ApiResponse.is_org_chart_enabled
            IsGroupEnabled                     = $ApiResponse.is_group_enabled
            IsChatEnabled                      = $ApiResponse.is_chat_enabled
            IsTranslationEnabled               = $ApiResponse.is_translation_enabled
            CreatedAt                          = $ApiResponse.created_at
            IsStorylineEnabled                 = $ApiResponse.is_storyline_enabled
            IsStorylineMtoEnabled              = $ApiResponse.is_storyline_mto_enabled
            IsStorylinePreviewEnabled          = $ApiResponse.is_storyline_preview_enabled
            IsStorylinePerUserControlEnabled   = $ApiResponse.is_storyline_per_user_control_enabled
            StorylineAllowedAadSecurityGroupId = $ApiResponse.storyline_allowed_aad_security_group_id
            IsStoriesEnabled                   = $ApiResponse.is_stories_enabled
            IsStoriesPreviewEnabled            = $ApiResponse.is_stories_preview_enabled
            IsPremiumPreviewEnabled            = $ApiResponse.is_premium_preview_enabled
            IsLeadershipCornerEnabled          = $ApiResponse.is_leadership_corner_enabled
            ProfileFieldsConfig                = $ApiResponse.profile_fields_config
            BrowserDeprecationUrl              = $ApiResponse.browser_deprecation_url
            ExternalMessagingState             = $ApiResponse.external_messaging_state
            State                              = $ApiResponse.state
            EnforceOfficeAuthentication        = $ApiResponse.enforce_office_authentication
            OfficeAuthenticationCommitted      = $ApiResponse.office_authentication_committed
            IsGifShortcutEnabled               = $ApiResponse.is_gif_shortcut_enabled
            IsLinkPreviewEnabled               = $ApiResponse.is_link_preview_enabled
            AttachmentsInPrivateMessages       = $ApiResponse.attachments_in_private_messages
            SecretGroups                       = $ApiResponse.secret_groups
            ForceConnectedGroups               = $ApiResponse.force_connected_groups
            ForceSpoFiles                      = $ApiResponse.force_spo_files
            ConnectedAllCompany                = $ApiResponse.connected_all_company
            M365NativeMode                     = $ApiResponse.m365_native_mode
            ForceOptinModernClient             = $ApiResponse.force_optin_modern_client
            AdminModernClientFlexibleOptin     = $ApiResponse.admin_modern_client_flexible_optin
            AadGuestsEnabled                   = $ApiResponse.aad_guests_enabled
            AllCompanyGroupCreationState       = $ApiResponse.all_company_group_creation_state
            IsNetworkQuestionsEnabled          = $ApiResponse.is_network_questions_enabled
            IsNetworkQuestionsOnlyModeEnabled  = $ApiResponse.is_network_questions_only_mode_enabled
            EnablePrivateMessages              = $ApiResponse.enable_private_messages
            IsGroupAgentEnabled                = $ApiResponse.is_group_agent_enabled
            TenantId                           = $ApiResponse.tenant_id
            IsAtMentionCustomNameEnabled       = $ApiResponse.is_at_mention_custom_name_enabled
            AttachmentTypesAllowed             = $ApiResponse.attachment_types_allowed
            IsRecommendedCommentsEnabled       = $ApiResponse.is_recommended_comments_enabled
            NetworkType                        = $ApiResponse.network_type
            IsMutedAutoplayEnabled             = $ApiResponse.is_muted_autoplay_enabled
            IsMoveConversationsEnabled         = $ApiResponse.is_move_conversations_enabled
            IsExportEventQuestionsEnabled      = $ApiResponse.is_export_event_questions_enabled
            IsAutocloseConversationsEnabled    = $ApiResponse.is_autoclose_conversations_enabled
            IsHideUsersEnabled                 = $ApiResponse.is_hide_users_enabled
            UnseenMessageCount                 = $ApiResponse.unseen_message_count
            PreferredUnseenMessageCount        = $ApiResponse.preferred_unseen_message_count
            PrivateUnseenThreadCount           = $ApiResponse.private_unseen_thread_count
            InboxUnseenThreadCount             = $ApiResponse.inbox_unseen_thread_count
            PrivateUnreadThreadCount           = $ApiResponse.private_unread_thread_count
            UnseenNotificationCount            = $ApiResponse.unseen_notification_count
            HasFakeEmail                       = $ApiResponse.has_fake_email
            IsPrimary                          = $ApiResponse.is_primary
            AllowAttachments                   = $ApiResponse.allow_attachments
            PrivacyLink                        = $ApiResponse.privacy_link
            UserState                          = $ApiResponse.user_stat
        }
    }

    End {
        Write-Verbose "Get-YammerNetwork: End"
        If ($?) {
            Write-Verbose "Get-YammerNetwork: Completed Successfully"
        }
        return $Response
    }
}