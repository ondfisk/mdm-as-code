BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "New-MetaFile" {
    Context "File does not exist" {
        BeforeAll {
            Mock Test-Path { $false }
            Mock Set-Content { }
        }

        It "It creates new readme file" {
            New-MetaFile -Path "folder/readme.md" -Content "config"

            Should -Invoke Set-Content -ParameterFilter {
                $Value -eq "config" -and
                $Path -eq "folder/readme.md"
            }
        }
    }

    Context "File exists" {
        BeforeAll {
            Mock Test-Path { $true }
            Mock Set-Content { }
        }

        It "It does not create new readme file" {
            New-MetaFile -Path "folder/readme.md" -Content "config"

            Should -Not -Invoke Set-Content
        }
    }
}
