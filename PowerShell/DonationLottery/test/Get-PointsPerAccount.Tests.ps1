Describe "Get-PointsPerAccount" {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-PointsPerAccount.ps1"
        . "$PSScriptRoot\..\private\Test-GuildMembership.ps1"
        $fakeDonationLogPath = "fakePath"
        $recipientGuild = "recipient"
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
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
               DonationLogPath = $fakeDonationLogPath
               Resource = $resource
               RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be 5
            Should -InvokeVerifiable
        }

        It "Multiple entries" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "6"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "8"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (5 + 6 + 8)
            Should -InvokeVerifiable
        }

        It "Multiple item types" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "1"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "2"; Resource = "something else"; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "4"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be (1 + 3 + 4)
            Should -InvokeVerifiable
        }
    }

    Context "Multiple accounts" {
        It "Single Item" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "1"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "2"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "4"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }

        It "Multiple Items" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "1"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "5"; Resource = "something else"; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "2"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "5"; Resource = "something else"; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "4"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be (1 + 2)
            $result.bar1 | Should -Be (3 + 4)
            Should -InvokeVerifiable
        }
    }

    Context "Only donations with target guild" {
        It "Single user donates to different guild" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = "some other guild"}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 0
            $result.bar | Should -Be $null
            Should -InvokeVerifiable
        }

        It "Single user donates to multiple guilds" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = "some other guild"}
                @{ "Character Name" = "foo"; "Account Handle" = "bar"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be 3
            Should -InvokeVerifiable
        }

        It "Multiple users donate to guild" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be 5
            $result.bar1 | Should -Be 3
            Should -InvokeVerifiable
        }

        It "Multiple users donate to multiple guilds" {
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild}
                @{ "Character Name" = "foo"; "Account Handle" = "bar0"; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = "some other guild"}
                @{ "Character Name" = "foo"; "Account Handle" = "bar1"; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = "another guild"}
            )

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be 5
            $result.bar1 | Should -Be 3
            Should -InvokeVerifiable
        }
    }

    Context "Specifiy Donor's Guild" {
        BeforeAll {
            $donorsGuild = "donor"
        }
        It "User from the right guild" {
            $accountHandle = "bar"
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = $accountHandle; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $donorsGuild}
            )

            Mock Test-GuildMembership -ParameterFilter {
                @(
                    $AccountName -eq $accountHandle
                    $GuildNameToTest -eq $donorsGuild
                    $DonationData -eq $script:donationData
                    $GuildOfCharacter -eq $donorsGuild
                ) -notcontains $false
            } -MockWith {
                $true
            } -Verifiable

            $getpointsParams = @{
               DonationLogPath = $fakeDonationLogPath
               Resource = $resource
               RecipientGuild = $recipientGuild
               DonorsGuild = $donorsGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 1
            $result.bar | Should -Be 5
            Should -InvokeVerifiable
        }

        It "User from different guild" {
            $accountHandle = "bar"
            $differentGuild = "different guild"
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = $accountHandle; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $differentGuild}
            )

            Mock Test-GuildMembership -ParameterFilter {
                @(
                    $AccountName -eq $accountHandle
                    $GuildNameToTest -eq $donorsGuild
                    $DonationData -eq $script:donationData
                    $GuildOfCharacter -eq $differentGuild
                ) -notcontains $false
            } -MockWith {
                $false
            } -Verifiable

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
                DonorsGuild = $donorsGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 0
            $result.bar | Should -Be $null
            Should -InvokeVerifiable
        }

        It "Multiple users from right guild" {
            $accounts = @("bar0", "bar1")
            $script:donationData = @(
                @{ "Character Name" = "foo"; "Account Handle" = $accounts[0]; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $donorsGuild}
                @{ "Character Name" = "foo"; "Account Handle" = $accounts[1]; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $donorsGuild}
            )

            Mock Test-GuildMembership -ParameterFilter {
                @(
                    $accounts -contains $AccountName
                    $GuildNameToTest -eq $donorsGuild
                    $DonationData -eq $script:donationData
                    $GuildOfCharacter -eq $donorsGuild
                ) -notcontains $false
            } -MockWith {
                $true
            } -Verifiable

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
                DonorsGuild = $donorsGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be 5
            $result.bar1 | Should -Be 3
            Should -InvokeVerifiable
        }

        It "Multiple users from different guilds" {
            $accounts = @("bar0", "bar1")
            $script:donationData = @(
                @{ "Character Name" = "foo0"; "Account Handle" = $accounts[0]; "Resource Quantity" = "5"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $donorsGuild}
                @{ "Character Name" = "foo1"; "Account Handle" = $accounts[1]; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = "different guild"}
                @{ "Character Name" = "foo2"; "Account Handle" = $accounts[1]; "Resource Quantity" = "3"; Resource = $resource; "Recipient Guild" = $recipientGuild; "Donor's Guild" = $donorsGuild}
            )

            Mock Test-GuildMembership -ParameterFilter {
                @(
                    $accounts -contains $AccountName
                    $GuildNameToTest -eq $donorsGuild
                    $DonationData -eq $script:donationData
                    $GuildOfCharacter -eq $donorsGuild
                ) -notcontains $false
            } -MockWith {
                $true
            } -Verifiable

            $getpointsParams = @{
                DonationLogPath = $fakeDonationLogPath
                Resource = $resource
                RecipientGuild = $recipientGuild
                DonorsGuild = $donorsGuild
            }
            $result = Get-PointsPerAccount @getpointsParams

            $result.Keys.Count | Should -Be 2
            $result.bar0 | Should -Be 5
            $result.bar1 | Should -Be 6
            Should -InvokeVerifiable
        }
    }
}
