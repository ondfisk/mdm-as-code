function Sync-IntuneConfiguration {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputFolder,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TempFolder,

        [string]
        $Environment
    )

    begin {
        if (-not (Test-Path -Path $TempFolder)) {
            New-Item -Path $TempFolder -ItemType "Directory" -WhatIf:$false
        }

        Get-ChildItem -Path $TempFolder -Exclude ".gitignore" | Remove-Item -Recurse -Force -WhatIf:$false
    }

    process {
        Write-Log -Level INFO -Message "Exporting existing configuration to $TempFolder" -Body @{Function = 'Sync-IntuneConfiguration'; ObjectName = "N/A"; ObjectId = "N/A" }

        $script:resources | ForEach-Object {
            Export-IntuneConfiguration -Resource $PSItem -OutputFolder $TempFolder -SkipDetails -WhatIf:$false
        }

        $existing = Get-ChildItem -Path $TempFolder -File -Filter "*.json" -Exclude "transformations.json" -Recurse

        $resolvedTempFolder = Resolve-Path -Path $TempFolder
        $resolvedInputFolder = Resolve-Path -Path $InputFolder

        $existing | ForEach-Object {
            $incomingFile = $PSItem.FullName.Replace($resolvedTempFolder, $resolvedInputFolder)

            $configuration = ($incomingFile | ConvertFrom-ConfigurationFileName).FullName

            Write-Log -Level INFO -Message "Checking if $configuration exists..." -Body @{Function = 'Sync-IntuneConfiguration'; ObjectName = $configuration; ObjectId = "N/A" }

            if (-not (Test-Path -Path $incomingFile)) {
                # TODO: Do not remove root certs for now
                if ($PSCmdlet.ShouldProcess($configuration, "DELETE")) {
                    Write-Log -Level WARNING -Message "$configuration not found. Deleting..." -Body @{Function = 'Sync-IntuneConfiguration'; ObjectName = $configuration; ObjectId = "N/A" }
                    Write-Warning -Message "$configuration not found. Deleting..."
                    Remove-IntuneConfiguration -ConfigurationFileName $PSItem.FullName
                }
            }
        }

        Write-Log -Level INFO -Message "Importing new configuration from $InputFolder" -Body @{Function = 'Sync-IntuneConfiguration'; ObjectName = $InputFolder; ObjectId = "N/A" }

        Import-IntuneConfiguration -InputFolder $InputFolder -Environment $Environment
    }

    end { }
}
