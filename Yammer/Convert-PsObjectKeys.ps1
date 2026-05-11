function Convert-PsObjectKeys {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
        $Depth = 5
    )

    begin {
        $InputObjectCopy = $InputObject

        $MinDepth = 0
        $CurrentDepth = $MinDepth + 1
        $MaxDepth = $Depth

        Write-Host "Convert-PsObjectKeys: MinDepth     = $MinDepth"
        Write-Host "Convert-PsObjectKeys: CurrentDepth = $CurrentDepth"
        Write-Host "Convert-PsObjectKeys: MaxDepth     = $MaxDepth"
    }

    process {
        function Update-PsObjectKeys {
            param (
                [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
                $Obj,

                [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
                $MinDepth = 0,

                [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
                $CurrentDepth,

                [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
                $MaxDepth
            )

            begin {
                # Write-Host "Update-PsObjectKeys: MinDepth     = $MinDepth"
                Write-Host "Update-PsObjectKeys: CurrentDepth = $CurrentDepth"
                # Write-Host "Update-PsObjectKeys: MaxDepth     = $MaxDepth"
                $MaxDepthReached = $false
                if ($CurrentDepth -gt $MaxDepth) {
                    Write-Warning "Reached max depth!"
                    $MaxDepthReached = $true
                }
                $ObjTypeName = (($Obj).GetType()).Name
            }

            process {
                switch ($ObjTypeName) {
                    "PSCustomObject" {
                        Write-Debug "Found 'PSCustomObject'"
                        $RootProps = @($Obj.psObject.Properties | Where-Object { $_.MemberType -eq "NoteProperty" })
                        foreach ($RootProp in $RootProps) {
                            if (-not ($MaxDepthReached)) {
                                $TextInfo = (Get-Culture).TextInfo
                                $NewRootPropName = $TextInfo.ToTitleCase($RootProp.Name).Replace("_", "")
                                $OldRootPropName = $RootProp.Name
                                if ($RootProp.Value) {
                                    $RootPropValueType = ($RootProp.Value.GetType()).Name
                                }
                                else {
                                    $RootPropValueType = $null
                                }
                                Write-Debug "Processing: $NewRootPropName ($OldRootPropName)"
                                Write-Debug "`Prop has value Type($RootPropValueType)"
                                $Obj.PSObject.Properties.Remove($OldRootPropName)
                                $Obj | Add-Member -MemberType NoteProperty -Name $NewRootPropName -Value $RootProp.Value
                                if ($RootPropValueType -eq "PSCustomObject" -or $RootPropValueType -eq "Object[]") {
                                    if ($RootProp.Value) {
                                        Update-PsObjectKeys -Obj ($RootProp.Value) -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                                    }
                                }
                            }
                            # else {
                            #     $OldRootPropName = $RootProp.Name
                            #     Write-Host $OldRootPropName
                            #     if ($RootProp.Value) {
                            #         $RootPropValueType = ($RootProp.Value.GetType()).Name
                            #     }
                            #     else {
                            #         $RootPropValueType = $null
                            #     }
                            #     $Obj.PSObject.Properties.Remove($OldRootPropName)
                            #     $Obj | Add-Member -MemberType NoteProperty -Name $OldRootPropName -Value $RootProp.Value
                            #     if ($RootPropValueType -eq "PSCustomObject" -or $RootPropValueType -eq "Object[]") {
                            #         if ($RootProp.Value) {
                            #             Update-PsObjectKeys -Obj ($RootProp.Value) -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                            #         }
                            #     }
                            # }
                        }
                    }
                    "Object[]" {
                        Write-Debug "Found 'Object[]'"
                        foreach ($SubObj in $Obj) {
                            Update-PsObjectKeys -Obj $SubObj -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                        }
                    }
                }
            }
        }
        Update-PsObjectKeys -Obj $InputObjectCopy -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
    }

    end {
        return $InputObjectCopy
    }
}