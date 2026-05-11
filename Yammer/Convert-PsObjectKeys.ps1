function Convert-PsObjectKeys {
    param (
        [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
        $InputObject,

        [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
        $Depth = 5
    )

    begin {
        Write-Verbose "Convert-PsObjectKeys: Begin"
        Write-Verbose "Convert-PsObjectKeys: Param -InputObject ''"
        Write-Verbose "Convert-PsObjectKeys: Param -Depth '$(Depth)'"
        $InputObjectCopy = $InputObject

        $MinDepth = 0
        $CurrentDepth = $MinDepth + 1
        $MaxDepth = $Depth
    }

    process {
        Write-Verbose "Convert-PsObjectKeys: Process"
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
                Write-Verbose "Update-PsObjectKeys: Begin"
                $MaxDepthReached = $false
                if ($CurrentDepth -gt $MaxDepth) {
                    Write-Warning "Reached max depth!"
                    $MaxDepthReached = $true
                }
                $ObjTypeName = (($Obj).GetType()).Name
            }

            process {
                Write-Verbose "Update-PsObjectKeys: Process"
                Write-Verbose "Update-PsObjectKeys: Param -Obj ''"
                Write-Verbose "Update-PsObjectKeys: Param -MinDepth '$(MinDepth)'"
                Write-Verbose "Update-PsObjectKeys: Param -CurrentDepth '$(CurrentDepth)'"
                Write-Verbose "Update-PsObjectKeys: Param -MaxDepth '$(MaxDepth)'"
                switch ($ObjTypeName) {
                    "PSCustomObject" {
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
                        foreach ($SubObj in $Obj) {
                            Update-PsObjectKeys -Obj $SubObj -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                        }
                    }
                }
            }

            end {
                Write-Verbose "Update-PsObjectKeys: End"
                If ($?) {
                    Write-Verbose "Update-PsObjectKeys: Completed Successfully"
                }
            }
        }
        Update-PsObjectKeys -Obj $InputObjectCopy -MinDepth $MinDepth -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
    }

    end {
        Write-Verbose "Convert-PsObjectKeys: End"
        If ($?) {
            Write-Verbose "Convert-PsObjectKeys: Completed Successfully"
        }
        return $InputObjectCopy
    }
}