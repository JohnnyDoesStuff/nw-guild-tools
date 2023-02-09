Describe "Test Get-DonationLottery" {
    BeforeAll {
        . $PSScriptRoot\Get-DonationLottery.ps1
        $fakePath = "fake/data.csv"
    }
    Context "Invalid data" {
        It "Not enough people" {
            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                @(
                    @{Name = "foo0"; Points = 10}
                    @{Name = "foo1"; Points = 10}
                    @{Name = "foo2"; Points = 10}
                )
            } -Verifiable

            { Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9} | Should -Throw

            Should -InvokeVerifiable
        }

        It "No participants" {
            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                @(
                    @{Name = "foo0"; Points = 0}
                    @{Name = "foo1"; Points = 0}
                    @{Name = "foo2"; Points = 0}
                    @{Name = "foo3"; Points = 0}
                    @{Name = "foo4"; Points = 0}
                    @{Name = "foo5"; Points = 0}
                )
            } -Verifiable

            { Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9} | Should -Throw

            Should -InvokeVerifiable
        }

        It "No people" {
            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                @()
            } -Verifiable

            { Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9} | Should -Throw

            Should -InvokeVerifiable
        }

        It "Not enough qualified people" {
            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                @(
                    @{Name = "foo0"; Points = 10}
                    @{Name = "foo1"; Points = 10}
                    @{Name = "foo2"; Points = 10}
                    @{Name = "foo3"; Points = 10}
                    @{Name = "foo4"; Points = 0}
                    @{Name = "foo5"; Points = 0}
                )
            } -Verifiable

            { Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9} | Should -Throw

            Should -InvokeVerifiable
        }
    }

    Context "Valid data" {
        It "Right amount of people" {
            $mockItems = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 10}
            )

            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                $mockItems
            } -Verifiable

            $result = Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Contain $mockItems[0].Name
            $result | Should -Contain $mockItems[1].Name
            $result | Should -Contain $mockItems[2].Name
            $result | Should -Contain $mockItems[3].Name
            $result | Should -Contain $mockItems[4].Name

            Should -InvokeVerifiable
        }

        It "Right people with exact threshold" {
            $threshold = 9
            $mockItems = @(
                @{Name = "foo0"; Points = $threshold}
                @{Name = "foo1"; Points = $threshold}
                @{Name = "foo2"; Points = $threshold}
                @{Name = "foo3"; Points = $threshold}
                @{Name = "foo4"; Points = $threshold}
            )

            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                $mockItems
            } -Verifiable

            $result = Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold $threshold

            $result.Length | Should -Be 5
            $result | Should -Contain $mockItems[0].Name
            $result | Should -Contain $mockItems[1].Name
            $result | Should -Contain $mockItems[2].Name
            $result | Should -Contain $mockItems[3].Name
            $result | Should -Contain $mockItems[4].Name

            Should -InvokeVerifiable
        }

        It "More people than required" {
            $mockItems = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 10}
                @{Name = "foo5"; Points = 10}
                @{Name = "foo6"; Points = 10}
            )

            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                $mockItems
            } -Verifiable

            $result = Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | ForEach-Object {
                $mockItems.Name | Should -Contain $_
            }

            Should -InvokeVerifiable
        }

        It "Only right amount of people meets requirements" {
            $mockItems = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 8}
                @{Name = "foo4"; Points = 10}
                @{Name = "foo5"; Points = 6}
                @{Name = "foo6"; Points = 10}
                @{Name = "foo7"; Points = 0}
            )

            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                $mockItems
            } -Verifiable

            $result = Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Contain $mockItems[0].Name
            $result | Should -Contain $mockItems[1].Name
            $result | Should -Contain $mockItems[2].Name
            $result | Should -Contain $mockItems[4].Name
            $result | Should -Contain $mockItems[6].Name

            Should -InvokeVerifiable
        }

        It "More people meet requirement and some don't" {
            $mockItems = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 0}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 8}
                @{Name = "foo5"; Points = 10}
                @{Name = "foo6"; Points = 10}
                @{Name = "foo7"; Points = 5}
                @{Name = "foo8"; Points = 10}
                @{Name = "foo9"; Points = 7}
                @{Name = "foo10"; Points = 10}
            )

            Mock Import-Csv -ParameterFilter {
                $Path -eq $fakePath
            } -MockWith {
                $mockItems
            } -Verifiable

            $result = Get-DonationLottery -CsvWithPeople $fakePath -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Not -Contain $mockItems[1].Name
            $result | Should -Not -Contain $mockItems[4].Name
            $result | Should -Not -Contain $mockItems[7].Name
            $result | Should -Not -Contain $mockItems[9].Name
            $result | ForEach-Object {
                $mockItems.Name | Should -Contain $_
            }

            Should -InvokeVerifiable
        }
    }
}