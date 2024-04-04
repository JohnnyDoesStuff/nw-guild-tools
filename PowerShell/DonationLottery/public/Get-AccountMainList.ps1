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
    $mainList = @()

    $Accounts | ForEach-Object {
        $main = Get-AccountMain -DonationData $donationData -AccountName $_
        $mainList = $mainList + @(
            @{
                Account = $_
                Main = $main
            }
        )
    }

    return $mainList
}
