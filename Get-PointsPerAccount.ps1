function Get-PointsPerAccount {
    param (
        [Parameter(Mandatory)]
        [string]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [string]
        $Resource
    )
    $donationData = Import-Csv -Path $DonationLogPath
    $accountData = @{}

    $donationData | ForEach-Object {
        if ($_.Resource -eq $Resource) {
            $accountName = $_."Account Handle"
            [int]$amount = $_."Resource Quantity"
            $accountData.$accountName += $amount
        }
    }
    
    return $accountData
}
