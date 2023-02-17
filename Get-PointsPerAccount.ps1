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
        if ($_.Resource -eq $ItemName) {
            $accountName = $_."Account Handle"
            [int]$amount = $_."Resource Quantity"
            $accountData.$accountName += $amount
        }
    }
    
    return $accountData
}
