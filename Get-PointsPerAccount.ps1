function Get-PointsPerAccount {
    param (
        [Parameter(Mandatory)]
        [string]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [string]
        $ItemName
    )
    $donationData = Import-Csv -Path $DonationLogPath
    $accountData = @{}

    $donationData | ForEach-Object {
        if ($_.item -eq $ItemName) {
            $accountName = $_.account
            [int]$amount = $_.amount
            $accountData.$accountName += $amount
        }
    }
    
    return $accountData
}
