Describe "Get-PointsPerAccount" {
    BeforeAll {
        . $PSScriptRoot\Get-PointsPerAccount.ps1
        $fakeDonationLogPath = "fakePath"
        $resource = "dummyItem"
        $script:donationData = $null
        
        Mock Import-Csv -ParameterFilter {
            $Path -eq $fakeDonationLogPath
        } -MockWith {
            $script:donationData
        } -Verifiable
    }
    Context "Single account" {
        It "Single entry" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -Resource $resource

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be 5
            Should -InvokeVerifiable
        }

        It "Multiple entries" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "6"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "8"; Resource = $resource}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -Resource $resource

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (5 + 6 + 8)
            Should -InvokeVerifiable
        }

        It "Multiple item types" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "1"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "2"; Resource = "something else"}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "3"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "4"; Resource = $resource}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -Resource $resource

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (1 + 3 + 4)
            Should -InvokeVerifiable
        }
    }

    Context "Multiple accounts" {
        It "Single Item" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "1"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "2"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "4"; Resource = $resource}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -Resource $resource

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }

        It "Multiple Items" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "1"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "5"; Resource = "something else"}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "2"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "5"; Resource = "something else"}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "4"; Resource = $resource}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -Resource $resource

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }
    }
}
