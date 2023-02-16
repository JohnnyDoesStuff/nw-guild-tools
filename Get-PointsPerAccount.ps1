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
            $accountData.$accountName += $_.amount
        }
    }
    
    return $accountData
}
