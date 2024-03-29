function Get-PointsPerAccount {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Resource', Justification = 'False positive as rule does not know that ForEach-Object operates within the same scope')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'RecipientGuild', Justification = 'False positive as rule does not know that ForEach-Object operates within the same scope')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'DonorsGuild', Justification = 'False positive as rule does not know that ForEach-Object operates within the same scope')]
    param (
        [Parameter(Mandatory)]
        [string]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [string]
        $Resource,
        [Parameter()]
        [string]
        $RecipientGuild,
        [Parameter()]
        [string]
        $DonorsGuild
    )
    $donationData = Import-Csv -Path $DonationLogPath
    $accountData = @{}

    $donationData | ForEach-Object {
        $accountName = $_."Account Handle"
        $testMembershipParams = @{
            AccountName = $accountName
            GuildNameToTest = $DonorsGuild
            DonationData = $donationData
            GuildOfCharacter = $_."Donor's Guild"
        }
        $conditions = @(
            $_.Resource -eq $Resource
            ([String]::IsNullOrEmpty($RecipientGuild)) -or ($_."Recipient Guild" -eq $RecipientGuild)
            ([String]::IsNullOrEmpty($DonorsGuild)) -or (Test-GuildMembership @testMembershipParams)
        )
        if ($conditions -notcontains $false) {
            [int]$amount = $_."Resource Quantity"
            $accountData.$accountName += $amount
        }
    }

    return $accountData
}
