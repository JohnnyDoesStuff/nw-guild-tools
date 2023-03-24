Describe "Convert-AltAccount" {
    BeforeEach {
        . $PSScriptRoot\Convert-AltAccount.ps1
        $donationFakePath = "fake/path/data.csv"
        $mappingFakePath = "fake/path/mapping.txt"
        $targetFakePath = "fake/path/result.csv"
        Mock Get-Content -ParameterFilter {
            ($Path -eq $donationFakePath) -and ($Raw -eq $true)
        } -MockWith {
            $script:datafile
        } -Verifiable
        Mock Get-Content -ParameterFilter {
            ($Path -eq $mappingFakePath) -and ($Raw -ne $true)
        } -MockWith {
            $script:mappingFile
        } -Verifiable
        Mock New-Item -ParameterFilter {
            @(
                $Path -eq $targetFakePath
                $ItemType -eq "File"
                $Value -eq $script:expectedResult
                $Force -eq $true
            ) -notcontains $false
        } -MockWith {} -Verifiable
    }

    Context "Empty mappingfile" {
        It "Does not replace anything" {
            $script:dataFile = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
            """
            $script:mappingFile = @(
                ""
            )
            $script:expectedResult = $script:dataFile

            $convertArgs = @{
                DonationLogPath = $donationFakePath
                AltAccountMappingFile = $mappingFakePath
                TargetFile = $targetFakePath
            }
            Convert-AltAccount @convertArgs | Should -BeNullOrEmpty

            Should -InvokeVerifiable
        }
    }

    Context "Accounts to replace" {
        It "Single account" {
            $script:dataFile = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                f002,replacer,3,even more stuff
            """
            $script:mappingFile = @(
                "replacer:bar"
            )
            $script:expectedResult = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                f002,bar,3,even more stuff
            """

            $convertArgs = @{
                DonationLogPath = $donationFakePath
                AltAccountMappingFile = $mappingFakePath
                TargetFile = $targetFakePath
            }
            Convert-AltAccount @convertArgs | Should -BeNullOrEmpty

            Should -InvokeVerifiable
        }

        It "Single account, multiple entries" {
            $script:dataFile = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                f002,replacer,3,even more stuff
                f003,replacer,3,even more stuff
                f002,replacer,3,even more stuff
            """
            $script:mappingFile = @(
                "replacer:bar"
            )
            $script:expectedResult = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                f002,bar,3,even more stuff
                f003,bar,3,even more stuff
                f002,bar,3,even more stuff
            """

            $convertArgs = @{
                DonationLogPath = $donationFakePath
                AltAccountMappingFile = $mappingFakePath
                TargetFile = $targetFakePath
            }
            Convert-AltAccount @convertArgs | Should -BeNullOrEmpty

            Should -InvokeVerifiable
        }

        It "Multiple accounts" {
            $script:dataFile = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                es1,barfoos,2,more stuff
                f002,replacer0,3,even more stuff
                f003,replacer0,3,even more stuff
                es0,replacer1,3,even more stuff
            """
            $script:mappingFile = @(
                "replacer0:bar"
                "replacer1:barfoos"
            )
            $script:expectedResult = """Character Name,Account Handle,Resource Quantity,Resource
                foo0,bar,1,stuff
                f001,bar,2,more stuff
                es1,barfoos,2,more stuff
                f002,bar,3,even more stuff
                f003,bar,3,even more stuff
                es0,barfoos,3,even more stuff
            """

            $convertArgs = @{
                DonationLogPath = $donationFakePath
                AltAccountMappingFile = $mappingFakePath
                TargetFile = $targetFakePath
            }
            Convert-AltAccount @convertArgs | Should -BeNullOrEmpty

            Should -InvokeVerifiable
        }
    }
}
