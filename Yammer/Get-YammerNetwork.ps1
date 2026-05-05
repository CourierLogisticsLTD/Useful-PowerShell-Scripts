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
        $Response = foreach ($item in $ApiResponse) {
            [PSCustomObject]@{
                Type                               = $item.type
                Id                                 = $item.id
                Email                              = $item.email
                Name                               = $item.name
                Community                          = $item.community
                Permalink                          = $item.permalink
                WebUrl                             = $item.web_url
                ShowUpgradeBanner                  = $item.show_upgrade_banner
                HeaderBackgroundColor              = $item.header_background_color
                HeaderTextColor                    = $item.header_text_color
                NavigationBackgroundColor          = $item.navigation_background_color
                NavigationTextColor                = $item.navigation_text_color
                Paid                               = $item.paid
                Moderated                          = $item.moderated
                IsFreemium                         = $item.is_freemium
                IsOrgChartEnabled                  = $item.is_org_chart_enabled
                IsGroupEnabled                     = $item.is_group_enabled
                IsChatEnabled                      = $item.is_chat_enabled
                IsTranslationEnabled               = $item.is_translation_enabled
                CreatedAt                          = $item.created_at
                IsStorylineEnabled                 = $item.is_storyline_enabled
                IsStorylineMtoEnabled              = $item.is_storyline_mto_enabled
                IsStorylinePreviewEnabled          = $item.is_storyline_preview_enabled
                IsStorylinePerUserControlEnabled   = $item.is_storyline_per_user_control_enabled
                StorylineAllowedAadSecurityGroupId = $item.storyline_allowed_aad_security_group_id
                IsStoriesEnabled                   = $item.is_stories_enabled
                IsStoriesPreviewEnabled            = $item.is_stories_preview_enabled
                IsPremiumPreviewEnabled            = $item.is_premium_preview_enabled
                IsLeadershipCornerEnabled          = $item.is_leadership_corner_enabled
                ProfileFieldsConfig                = $item.profile_fields_config
                BrowserDeprecationUrl              = $item.browser_deprecation_url
                ExternalMessagingState             = $item.external_messaging_state
                State                              = $item.state
                EnforceOfficeAuthentication        = $item.enforce_office_authentication
                OfficeAuthenticationCommitted      = $item.office_authentication_committed
                IsGifShortcutEnabled               = $item.is_gif_shortcut_enabled
                IsLinkPreviewEnabled               = $item.is_link_preview_enabled
                AttachmentsInPrivateMessages       = $item.attachments_in_private_messages
                SecretGroups                       = $item.secret_groups
                ForceConnectedGroups               = $item.force_connected_groups
                ForceSpoFiles                      = $item.force_spo_files
                ConnectedAllCompany                = $item.connected_all_company
                M365NativeMode                     = $item.m365_native_mode
                ForceOptinModernClient             = $item.force_optin_modern_client
                AdminModernClientFlexibleOptin     = $item.admin_modern_client_flexible_optin
                AadGuestsEnabled                   = $item.aad_guests_enabled
                AllCompanyGroupCreationState       = $item.all_company_group_creation_state
                IsNetworkQuestionsEnabled          = $item.is_network_questions_enabled
                IsNetworkQuestionsOnlyModeEnabled  = $item.is_network_questions_only_mode_enabled
                EnablePrivateMessages              = $item.enable_private_messages
                IsGroupAgentEnabled                = $item.is_group_agent_enabled
                TenantId                           = $item.tenant_id
                IsAtMentionCustomNameEnabled       = $item.is_at_mention_custom_name_enabled
                AttachmentTypesAllowed             = $item.attachment_types_allowed
                IsRecommendedCommentsEnabled       = $item.is_recommended_comments_enabled
                NetworkType                        = $item.network_type
                IsMutedAutoplayEnabled             = $item.is_muted_autoplay_enabled
                IsMoveConversationsEnabled         = $item.is_move_conversations_enabled
                IsExportEventQuestionsEnabled      = $item.is_export_event_questions_enabled
                IsAutocloseConversationsEnabled    = $item.is_autoclose_conversations_enabled
                IsHideUsersEnabled                 = $item.is_hide_users_enabled
                UnseenMessageCount                 = $item.unseen_message_count
                PreferredUnseenMessageCount        = $item.preferred_unseen_message_count
                PrivateUnseenThreadCount           = $item.private_unseen_thread_count
                InboxUnseenThreadCount             = $item.inbox_unseen_thread_count
                PrivateUnreadThreadCount           = $item.private_unread_thread_count
                UnseenNotificationCount            = $item.unseen_notification_count
                HasFakeEmail                       = $item.has_fake_email
                IsPrimary                          = $item.is_primary
                AllowAttachments                   = $item.allow_attachments
                PrivacyLink                        = $item.privacy_link
                UserState                          = $item.user_stat
            }
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