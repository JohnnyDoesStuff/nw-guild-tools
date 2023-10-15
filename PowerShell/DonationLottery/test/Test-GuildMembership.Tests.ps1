Describe "Test-GuildMembership" {
    BeforeAll {
        . "$PSScriptRoot\..\private\Test-GuildMembership.ps1"
        $fakeDonationData = @(
            @{}
        )
        $fakeGuildName = "My Guild"
        $fakeAccountName = "fakeAccount"
    }
    Context "Player is in guild" {
        It "Character is already in the guild" {
            $testMembershipParams = @{
                AccountName = $fakeAccountName
                GuildNametoTest = $fakeGuildName
                DonationData = $fakeDonationData
                GuildOfCharacter = $fakeGuildName
            }

            Test-GuildMembership @testMembershipParams | Should -BeTrue
        }

        It "Character is not in the guild" {
            $otherGuild = "otherGuild"
            $donationData = @(
                @{ "Character Name" = "character in different guild"; "Account Handle" = $fakeAccountName; "Donor's Guild" = $otherGuild}
                @{ "Character Name" = "character in the guild"; "Account Handle" = $fakeAccountName; "Donor's Guild" = $fakeGuildName}
            )
            $testMembershipParams = @{
                AccountName = $fakeAccountName
                GuildNametoTest = $fakeGuildName
                DonationData = $donationData
                GuildOfCharacter = $otherGuild
            }

            Test-GuildMembership @testMembershipParams | Should -BeTrue
        }
    }

    Context "Player is not in guild" {
        It "Single data entry" {
            $otherGuild = "otherGuild"
            $donationData = @(
                @{ "Character Name" = "character in different guild"; "Account Handle" = $fakeAccountName; "Donor's Guild" = $otherGuild}
            )

            $testMembershipParams = @{
                AccountName = $fakeAccountName
                GuildNametoTest = $fakeGuildName
                DonationData = $donationData
                GuildOfCharacter = $otherGuild
            }

            Test-GuildMembership @testMembershipParams | Should -BeFalse
        }

        It "Multiple entries" {
            $otherGuild = "otherGuild"
            $donationData = @(
                @{ "Character Name" = "character in different guild"; "Account Handle" = $fakeAccountName; "Donor's Guild" = $otherGuild}
                @{ "Character Name" = "character in the guild"; "Account Handle" = "other account"; "Donor's Guild" = $fakeGuildName}
            )

            $testMembershipParams = @{
                AccountName = $fakeAccountName
                GuildNametoTest = $fakeGuildName
                DonationData = $donationData
                GuildOfCharacter = $otherGuild
            }

            Test-GuildMembership @testMembershipParams | Should -BeFalse
        }
    }

    Context "Handle old entries that still appear in exports" {
        It "Character is in guild" {
            $testMembershipParams = @{
                AccountName = ""
                GuildNametoTest = $fakeGuildName
                DonationData = $fakeDonationData
                GuildOfCharacter = $fakeGuildName
            }

            Test-GuildMembership @testMembershipParams | Should -BeTrue
        }

        It "Character is not in guild" {
            $testMembershipParams = @{
                AccountName = ""
                GuildNametoTest = $fakeGuildName
                DonationData = $fakeDonationData
                GuildOfCharacter = "other guild"
            }

            Test-GuildMembership @testMembershipParams | Should -BeFalse
        }
    }
}
