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
        # foreach ($prop in $ApiResponse.Messages.psObject.Properties) {
        #     $TextInfo = (Get-Culture).TextInfo
        #     $Name = $textInfo.ToTitleCase($prop.Name).Replace("_", "")
        #     Write-Host "$($Name) = `$ApiResponse.$($prop.Name)"
        # }
        $Response = $ApiResponse.Messages
        # $Response = foreach ($Message in ($ApiResponse.Messages)) {
        #     $MessageAttachments = foreach ($Attachment in $Message.attachments) {
        #         [PSCustomObject]@{
        #             Id                 = $Attachment.id
        #             NetworkId          = $Attachment.network_id
        #             Url                = $Attachment.url
        #             WebUrl             = $Attachment.web_url
        #             Type               = $Attachment.type
        #             Name               = $Attachment.name
        #             OriginalName       = $Attachment.original_name
        #             FullName           = $Attachment.full_name
        #             Description        = $Attachment.description
        #             ContentType        = $Attachment.content_type
        #             ContentClass       = $Attachment.content_class
        #             CreatedAt          = $Attachment.created_at
        #             OwnerId            = $Attachment.owner_id
        #             Official           = $Attachment.official
        #             StorageType        = $Attachment.storage_type
        #             TargetType         = $Attachment.target_type
        #             StorageState       = $Attachment.storage_state
        #             SharepointId       = $Attachment.sharepoint_id
        #             SharepointWebUrl   = $Attachment.sharepoint_web_url
        #             SmallIconUrl       = $Attachment.small_icon_url
        #             LargeIconUrl       = $Attachment.large_icon_url
        #             DownloadUrl        = $Attachment.download_url
        #             ThumbnailUrl       = $Attachment.thumbnail_url
        #             PreviewUrl         = $Attachment.preview_url
        #             LargePreviewUrl    = $Attachment.large_preview_url
        #             Size               = $Attachment.size
        #             OwnerType          = $Attachment.owner_type
        #             LastUploadedAt     = $Attachment.last_uploaded_at
        #             LastUploadedById   = $Attachment.last_uploaded_by_id
        #             LastUploadedByType = $Attachment.last_uploaded_by_type
        #             Uuid               = $Attachment.uuid
        #             Transcoded         = $Attachment.transcoded
        #             StreamingUrl       = $Attachment.streaming_url
        #             Path               = $Attachment.path
        #             YId                = $Attachment.y_id
        #             OverlayUrl         = $Attachment.overlay_url
        #             Privacy            = $Attachment.privacy
        #             Height             = $Attachment.height
        #             Width              = $Attachment.width
        #             ScaledUrl          = $Attachment.scaled_url
        #             Image              = $Attachment.image
        #             LatestVersionId    = $Attachment.latest_version_id
        #             Status             = $Attachment.status
        #             RealType           = $Attachment.real_type
        #         }
        #     }
        #     [PSCustomObject]@{
        #         Id                 = $Message.id
        #         SenderId           = $Message.sender_id
        #         DelegateId         = $Message.delegate_id
        #         RepliedToId        = $Message.replied_to_id
        #         CreatedAt          = $Message.created_at
        #         PublishedAt        = $Message.published_at
        #         NetworkId          = $Message.network_id
        #         MessageType        = $Message.message_type
        #         SenderType         = $Message.sender_type
        #         Url                = $Message.url
        #         WebUrl             = $Message.web_url
        #         GroupId            = $Message.group_id
        #         Body               = $Message.body
        #         ThreadId           = $Message.thread_id
        #         ClientType         = $Message.client_type
        #         ClientUrl          = $Message.client_url
        #         SystemMessage      = $Message.system_message
        #         DirectMessage      = $Message.direct_message
        #         ChatClientSequence = $Message.chat_client_sequence
        #         Language           = $Message.language
        #         NotifiedUserIds    = $Message.notified_user_ids
        #         Privacy            = $Message.privacy
        #         Attachments        = $MessageAttachments
        #         LikedBy            = $Message.liked_by
        #         SupplementalReply  = $Message.supplemental_reply
        #         ContentExcerpt     = $Message.content_excerpt
        #         GroupCreatedId     = $Message.group_created_id
        #     }
        # }
    }

    End {
        Write-Verbose "Get-YammerPost: End"
        If ($?) {
            Write-Verbose "Get-YammerPost: Completed Successfully"
        }
        return $Response
    }
}