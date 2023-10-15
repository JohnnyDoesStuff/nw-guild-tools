<#
    .SYNOPSIS
        Shows the amount of ressources that players donated to a guild
    
    .PARAMETER DonationLogPath
        The path to the *.csv file that contains all the necessary data
        This file must only contain the data from the time you want to use
        E.g. older data has to be removed before running this script

    .PARAMETER Resource
        The name of the resource (e.g. Influence) you want to base the lottery on

    .PARAMETER RecipientGuild
        The guild that should be donated to.

    .PARAMETER DonorsGuild
        The guild that the donators should come from.

    .EXAMPLE
        .\Show-PointsPerAccount.ps1 -DonationLogPath .\data\donations.csv -Resource "Influence" -RecipientGuild "My Guild"
    .EXAMPLE
        .\Show-PointsPerAccount.ps1 -DonationLogPath .\data\donations.csv -Resource "Influence" -RecipientGuild "My Guild" -DonorsGuild "My Guild"
#>



param (
    [Parameter(Mandatory)]
    [String]
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

Import-Module "$PSScriptRoot\..\DonationLottery"

$getpointsParams = @{
    DonationLogPath = $DonationLogPath
    Resource = $Resource
    RecipientGuild = $RecipientGuild
    DonorsGuild = $DonorsGuild
}
$rawPoints = Get-PointsPerAccount @getpointsParams
$points = Convert-HashtableToArray -InputObject $rawPoints
$characterNames = Get-AccountMainList -DonationLogPath $DonationLogPath -Accounts $points.Name

$summedDonationData = for ($i = 0; $i -lt $points.Count; $i++) {
    [PSCustomObject]@{
        MainCharacter = $characterNames[$i]
        AccountHandle = $points[$i].Name
        DonatedAmount = $points[$i].Points
    }
}

return $summedDonationData | Sort-Object -Property AccountHandle
