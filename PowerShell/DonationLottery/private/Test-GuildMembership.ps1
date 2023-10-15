function Test-GuildMembership {
    param (
        [Parameter()]
        [string]
        $AccountName,
        [Parameter(Mandatory)]
        [string]
        $GuildNameToTest,
        [Parameter(Mandatory)]
        [array]
        $DonationData,
        # This parameter is just used to speed up the processing of donation logs
        [Parameter()]
        [string]
        $GuildOfCharacter
    )

    if ($GuildOfCharacter -eq $GuildNameToTest) {
        return $true
    }
    if ([String]::IsNullOrEmpty($AccountName)) {
        return $false
    }

    $donationsOfTheAccountInsideTheGuild = $donationData | Where-Object {
        ($_."Account Handle" -eq $AccountName) -and ($_."Donor's Guild" -eq $GuildNameToTest)
    }

    return ($null -ne $donationsOfTheAccountInsideTheGuild)
}
