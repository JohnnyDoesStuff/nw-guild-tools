function Get-PointsPerAccount {
    param (
        [Parameter(Mandatory)]
        [string]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [string]
        $Resource,
        [Parameter(Mandatory)]
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
            $_."Recipient Guild" -eq $RecipientGuild
            ([String]::IsNullOrEmpty($DonorsGuild)) -or (Test-GuildMembership @testMembershipParams)
        )
        if ($conditions -notcontains $false) {
            [int]$amount = $_."Resource Quantity"
            $accountData.$accountName += $amount
        }
    }
    
    return $accountData
}
