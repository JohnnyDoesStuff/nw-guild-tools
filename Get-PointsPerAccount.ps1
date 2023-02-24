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
        $conditions = @(
            $_.Resource -eq $Resource
            $_."Recipient Guild" -eq $RecipientGuild
            ([String]::IsNullOrEmpty($DonorsGuild)) -or ($_."Donor's Guild" -eq $DonorsGuild)
        )
        if ($conditions -notcontains $false) {
            $accountName = $_."Account Handle"
            [int]$amount = $_."Resource Quantity"
            $accountData.$accountName += $amount
        }
    }
    
    return $accountData
}
