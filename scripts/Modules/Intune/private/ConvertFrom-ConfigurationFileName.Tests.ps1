BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertFrom-ConfigurationFileName" {
    Context "Given configuration file name" {
        $testCases = @(
            @{
                ConfigurationFileName = "configuration\deviceManagement\deviceConfigurations\android\config\config.json"
                Resource              = "deviceManagement/deviceConfigurations"
                DisplayName           = "config"
                FullName              = "deviceManagement/deviceConfigurations/config"
            }
            @{
                ConfigurationFileName = "C:\Temp\arbitrary-folder\deviceManagement\deviceConfigurations\windows\Win10-DeviceRestrictions\Win10-DeviceRestrictions.json"
                Resource              = "deviceManagement/deviceConfigurations"
                DisplayName           = "Win10-DeviceRestrictions"
                FullName              = "deviceManagement/deviceConfigurations/Win10-DeviceRestrictions"
            }
            @{
                ConfigurationFileName = "C:\Temp\arbitrary-folder\deviceManagement\deviceConfigurations\windows\Win10-DeviceRestrictions\Win10-DeviceRestrictions.ring1.json"
                Resource              = "deviceManagement/deviceConfigurations"
                DisplayName           = "Win10-DeviceRestrictions.ring1"
                FullName              = "deviceManagement/deviceConfigurations/Win10-DeviceRestrictions.ring1"
            }
            @{
                ConfigurationFileName = "C:\Source\Repos\MDM-as-Code\configuration\deviceManagement\deviceCompliancePolicies\windows\Win10compliance\Win10compliance.json"
                Resource              = "deviceManagement/deviceCompliancePolicies"
                DisplayName           = "Win10compliance"
                FullName              = "deviceManagement/deviceCompliancePolicies/Win10compliance"
            }
            @{
                ConfigurationFileName = "C:\Source\Repos\MDM-as-Code\configuration\deviceManagement\deviceCompliancePolicies\windows\Win10compliance\Win10compliance.beta.json"
                Resource              = "deviceManagement/deviceCompliancePolicies"
                DisplayName           = "Win10compliance.beta"
                FullName              = "deviceManagement/deviceCompliancePolicies/Win10compliance.beta"
            }
            @{
                ConfigurationFileName = "resource/subresource/displayName/displayName.json"
                Resource              = "resource/subresource"
                DisplayName           = "displayName"
                FullName              = "resource/subresource/displayName"
            }
            @{
                ConfigurationFileName = "arbitrary-folder\resource/subresource\displayName\displayName.json"
                Resource              = "resource/subresource"
                DisplayName           = "displayName"
                FullName              = "resource/subresource/displayName"
            }
        )

        It "<ConfigurationFileName> returns resource: <Resource> and displayName: <DisplayName>" -TestCases $testCases {
            $result = ConvertFrom-ConfigurationFileName -ConfigurationFileName $ConfigurationFileName

            $result.Resource | Should -Be $Resource
            $result.DisplayName | Should -Be $DisplayName
            $result.FullName | Should -Be $FullName
        }
    }
}
