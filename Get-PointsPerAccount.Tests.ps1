Describe "Get-PointsPerAccount" {
    BeforeAll {
        . $PSScriptRoot\Get-PointsPerAccount.ps1
        $fakeDonationLogPath = "fakePath"
        $itemName = "dummyItem"
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
                @{ name = "foo"; account = "bar"; amount = "5"; item = $itemName}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -ItemName $itemName

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be 5
            Should -InvokeVerifiable
        }

        It "Multiple entries" {
            $script:donationData = @(
                @{ name = "foo"; account = "bar"; amount = "5"; item = $itemName}
                @{ name = "foo"; account = "bar"; amount = "6"; item = $itemName}
                @{ name = "foo"; account = "bar"; amount = "8"; item = $itemName}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -ItemName $itemName

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (5 + 6 + 8)
            Should -InvokeVerifiable
        }

        It "Multiple item types" {
            $script:donationData = @(
                @{ name = "foo"; account = "bar"; amount = "1"; item = $itemName}
                @{ name = "foo"; account = "bar"; amount = "2"; item = "something else"}
                @{ name = "foo"; account = "bar"; amount = "3"; item = $itemName}
                @{ name = "foo"; account = "bar"; amount = "4"; item = $itemName}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -ItemName $itemName

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (1 + 3 + 4)
            Should -InvokeVerifiable
        }
    }

    Context "Multiple accounts" {
        It "Single Item" {
            $script:donationData = @(
                @{ name = "foo"; account = "bar0"; amount = "1"; item = $itemName}
                @{ name = "foo"; account = "bar0"; amount = "2"; item = $itemName}
                @{ name = "foo"; account = "bar1"; amount = "3"; item = $itemName}
                @{ name = "foo"; account = "bar1"; amount = "4"; item = $itemName}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -ItemName $itemName

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }

        It "Multiple Items" {
            $script:donationData = @(
                @{ name = "foo"; account = "bar0"; amount = "1"; item = $itemName}
                @{ name = "foo"; account = "bar1"; amount = "5"; item = "something else"}
                @{ name = "foo"; account = "bar0"; amount = "2"; item = $itemName}
                @{ name = "foo"; account = "bar0"; amount = "5"; item = "something else"}
                @{ name = "foo"; account = "bar1"; amount = "3"; item = $itemName}
                @{ name = "foo"; account = "bar1"; amount = "4"; item = $itemName}
            )

            $result = Get-PointsPerAccount -DonationLogPath $fakeDonationLogPath -ItemName $itemName

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }
    }
}
