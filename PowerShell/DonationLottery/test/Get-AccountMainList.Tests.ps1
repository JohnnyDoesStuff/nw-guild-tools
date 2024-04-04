Describe "Get-AccountMainList" {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-AccountMainList.ps1"
        . "$PSScriptRoot\..\private\Get-AccountMain.ps1"
    }

    BeforeEach {
        $fakeCsvPath = "fakeCsvPath"
        Mock Import-Csv -ParameterFilter {
            $Path -eq $fakeCsvPath
        } -MockWith {
            $script:testData
        } -Verifiable
    }

    Context "Returns a list of objects" {
        It "if there is only one account" {
            $accounts = @(
                "bar"
            )
            $mainName = "foo"
            $script:testData = @(
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
            )

            Mock Get-AccountMain -ParameterFilter {
                $comparObject = @{
                   ReferenceObject = $DonationData
                   DifferenceObject = $script:testData
                }
                (Compare-Object @comparObject) -eq $null
            } -MockWith {
                $mainName
            } -Verifiable

            $result = Get-AccountMainList -DonationLogPath $fakeCsvPath -Accounts $accounts

            $result.Length | Should -Be 1
            $result.Main | Should -Be $mainName
            $result.Account | Should -Be $accounts[0]
            Should -InvokeVerifiable
        }

        It "if there are multiple accounts with the same main name" {
            $accounts = @(
                "bar"
                "es"
            )
            $mainName = "foo"
            $script:testData = @(
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[1]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainName
                    "Account Handle" = $accounts[1]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
            )

            Mock Get-AccountMain -ParameterFilter {
                $comparObject = @{
                   ReferenceObject = $DonationData
                   DifferenceObject = $script:testData
                }
                (Compare-Object @comparObject) -eq $null
            } -MockWith {
                $mainName
            } -Verifiable

            $result = Get-AccountMainList -DonationLogPath $fakeCsvPath -Accounts $accounts

            $result.Length | Should -Be 2
            $result[0].Main | Should -Be $mainName
            $result[0].Account | Should -Be $accounts[0]
            $result[1].Main | Should -Be $mainName
            $result[1].Account | Should -Be $accounts[1]
            Should -InvokeVerifiable
        }

        It "if there are multiple accounts whose mains have different names" {
            $accounts = @(
                "bar"
                "es"
            )

            $mainNames = @(
                "foo"
                "foo2"
            )

            $script:testData = @(
                @{
                    "Character Name" = $mainNames[0]
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainNames[0]
                    "Account Handle" = $accounts[0]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainNames[1]
                    "Account Handle" = $accounts[1]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
                @{
                    "Character Name" = $mainNames[1]
                    "Account Handle" = $accounts[1]
                    "Resource Quantity" = 5
                    "Resource" = "dummyItem"
                }
            )

            Mock Get-AccountMain -ParameterFilter {
                $comparObject = @{
                   ReferenceObject = $DonationData
                   DifferenceObject = $script:testData
                }
                (Compare-Object @comparObject) -eq $null
            } -MockWith {
                if ($AccountName -eq $accounts[0]) {
                    $mainNames[0]
                }
                elseif ($AccountName -eq $accounts[1]) {
                    $mainNames[1]
                }
            } -Verifiable

            $result = Get-AccountMainList -DonationLogPath $fakeCsvPath -Accounts $accounts

            $result.Length | Should -Be 2
            $result[0].Main | Should -Be $mainNames[0]
            $result[0].Account | Should -Be $accounts[0]
            $result[1].Main | Should -Be $mainNames[1]
            $result[1].Account | Should -Be $accounts[1]
            Should -InvokeVerifiable
        }
    }
}