function Get-AccountMainList {
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [array]
        $Accounts
    )

    $donationData = Import-Csv -Path $DonationLogPath
    $mains = @()

    $Accounts | ForEach-Object {
        $mains = $mains + @(
            Get-AccountMain -DonationData $donationData -AccountName $_
        )
    }
    return $mains
}
