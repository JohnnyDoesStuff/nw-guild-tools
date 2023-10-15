<#
.SYNOPSIS
    Returns the main of an account in an interactive dialogue
#>


function Get-PlayerMain {
    [OutputType([String[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath
    )

    $donationData = Import-Csv -Path $DonationLogPath
    $accounts = $donationData."Account Handle"
    $accounts = Remove-Duplicate -Array $accounts
    $mains = [string[]]@()

    $accounts | ForEach-Object {
        $mains = $mains + @(
            Get-AccountMain -DonationData $donationData -AccountName $_
        )
    }
    return $mains
}
