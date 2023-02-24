<#
    .SYNOPSIS
        Creates a lottery for people who contributed to your stronghold
    
    .PARAMETER DonationLogPath
        The path to the *.csv file that contains all the necessary data
        This file must only contain the data from the time you want to use
        E.g. older data has to be removed before running this script

    .PARAMETER ListLength
        The amount of people you want to have on the lottery

    .PARAMETER Resource
        The name of the resource (e.g. Influence) you want to base the lottery on

    .PARAMETER ResourceThreshold
        The amount of the resource that has to be donated to be qualified for the lottery

    .PARAMETER RecipientGuild
        The guild that should be donated to.

    .PARAMETER AccountIgnoreFile
        (Optional) The path to a file with people that should not be put on the list
        The file must be a simple text file.
        Each account that will be ignored has to be in a separate line
    
    .EXAMPLE
        New-DonationLottery -DonationLogPath .\data\donation.csv -ListLength 10 -Resource "Influence" -ResourceThreshold 400 -RecipientGuild "My Guild"
        New-DonationLottery -DonationLogPath .\data\donation.csv -ListLength 10 -Resource "Influence" -ResourceThreshold 400 -RecipientGuild "My Guild" -AccountIgnoreFile .\data\ignore-accounts.txt
#>


param (
    [Parameter(Mandatory)]
    [String]
    $DonationLogPath,
    [Parameter(Mandatory)]
    [int]
    $ListLength,
    [Parameter(Mandatory)]
    [string]
    $Resource,
    [Parameter(Mandatory)]
    [string]
    $ResourceThreshold,
    [Parameter(Mandatory)]
    [string]
    $RecipientGuild,
    [Parameter()]
    [string]
    $AccountIgnoreFile
)

. $PSScriptRoot\Convert-HashtableToArray.ps1
. $PSScriptRoot\Format-DonationLottery.ps1
. $PSScriptRoot\New-Lottery.ps1
. $PSScriptRoot\Get-PlayerMains.ps1
. $PSScriptRoot\Get-PointsPerAccount.ps1

$rawPoints = Get-PointsPerAccount -DonationLogPath $DonationLogPath -Resource $Resource -RecipientGuild $RecipientGuild
$points = Convert-HashtableToArray -InputObject $rawPoints
Write-Host "---- Points per account ----"
$points | ForEach-Object {
    Write-Host "$($_.Name): $($_.Points)"
}
Write-Host "----------------------------"
$getDonationLotteryParams = @{
    PointsPerAccount = $points
    ListLength = $ListLength
    PointThreshold = $ResourceThreshold
    AccountIgnoreFile = $AccountIgnoreFile
}
$winnerAccounts = New-Lottery @getDonationLotteryParams
$characterNames = Get-AccountMainList -DonationLogPath $DonationLogPath -Accounts $winnerAccounts
$resultText = Format-DonationLottery -OrderedNames $characterNames
return $resultText
