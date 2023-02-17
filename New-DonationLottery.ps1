function New-DonationLottery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [int]
        $ListLength,
        [Parameter(Mandatory)]
        [string]
        $ItemName,
        [Parameter(Mandatory)]
        [string]
        $ItemThreshold
    )

    . $PSScriptRoot\Convert-HashtableToArray.ps1
    . $PSScriptRoot\Format-DonationLottery.ps1
    . $PSScriptRoot\Get-DonationLottery.ps1
    . $PSScriptRoot\Get-PlayerMains.ps1
    . $PSScriptRoot\Get-PointsPerAccount.ps1

    $rawPoints = Get-PointsPerAccount -DonationLogPath $DonationLogPath -ItemName $ItemName
    $points = Convert-HashtableToArray -InputObject $rawPoints
    Write-Host "---- Points per account ----"
    $points | ForEach-Object {
        Write-Host "$($_.Name): $($_.Points)"
    }
    Write-Host "----------------------------"
    $winnerAccounts = Get-DonationLottery -PointsPerAccount $points -ListLength $ListLength -PointThreshold $ItemThreshold
    $characterNames = Get-AccountMainList -DonationLogPath $DonationLogPath -Accounts $winnerAccounts
    $resultText = Format-DonationLottery -OrderedNames $characterNames
    return $resultText
}
