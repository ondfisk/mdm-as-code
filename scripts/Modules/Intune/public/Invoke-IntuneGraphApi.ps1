
$script:graphBaseUri = "https://graph.microsoft.com"

$script:betaResources = @(
    "deviceManagement/deviceCompliancePolicies"
    "deviceManagement/deviceConfigurations"
    "deviceManagement/groupPolicyConfigurations"
    "deviceManagement/intents"
    "deviceManagement/templates"
    "deviceManagement/windowsAutopilotDeploymentProfiles"
)

function Invoke-IntuneGraphApi {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Get", "Post", "Put", "Delete", "Patch")]
        $Method,

        [Parameter(Mandatory = $true)]
        [string]
        $Resource,

        [Parameter(Mandatory = $false)]
        [object]
        $Body
    )

    begin {
        $version = "v1.0"

        $script:betaResources | ForEach-Object {
            if ($Resource -match $PSItem) {
                $version = "beta"
            }
        }

        if (-not $env:IntuneTenantId) {
            Write-Error -Message "No environment variable set for 'IntuneTenantId'"
        }

        if (-not $env:IntuneClientId) {
            Write-Error -Message "No environment variable set for 'IntuneClientId'"
        }

        if ($env:IntuneClientSecret) {
            $clientSecret = $env:IntuneClientSecret | ConvertTo-SecureString -AsPlainText -Force
        }
    }

    process {
        $accessToken = Get-IntuneAccessToken -TenantId $env:IntuneTenantId -ClientId $env:IntuneClientId -ClientSecret $clientSecret

        if ([uri]::IsWellFormedUriString($resource, [System.UriKind]::Absolute)) {
            $uri = $resource
        }
        else {
            $uri = "$script:graphBaseUri/$version/$resource"
        }

        if ($Body) {
            $json = ConvertTo-Json -InputObject $Body -Depth 10
        }
        else {
            $json = $null
        }

        Write-Log -Level INFO -Message "$($Method.ToUpper()) $uri" -Body @{Function = 'Invoke-IntuneGraphApi'; ObjectName = $uri; ObjectId = "N/A" }

        # Invoke-RestMethod will use a new HttpClient for each call. Added retry to workaround socket starvation issues.
        Invoke-RestMethod -Method $Method `
            -Uri $uri `
            -Body $json `
            -ContentType "application/json" `
            -Headers @{ Accept = "application/json" } `
            -Authentication Bearer `
            -Token $accessToken `
            -RetryIntervalSec 5 `
            -MaximumRetryCount 3
    }

    end { }
}
