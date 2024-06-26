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

    .PARAMETER DonorsGuild
        The guild that the donators should come from.

    .PARAMETER AccountIgnoreFile
        (Optional) The path to a file with people that should not be put on the list
        The file must be a simple text file.
        Each account that will be ignored has to be in a separate line

    .PARAMETER AccountMappingFile
        (Optional) The path to a file with other accounts of people
        The file must be a simple text files
        Each line is a mapping in this schema "altAccount:mainAccount"

    .EXAMPLE
        New-DonationLottery -DonationLogPath .\data\donation.csv -ListLength 10 -Resource "Influence" -ResourceThreshold 400 -RecipientGuild "My Guild"
        New-DonationLottery -DonationLogPath .\data\donation.csv -ListLength 10 -Resource "Influence" -ResourceThreshold 400 -RecipientGuild "My Guild" -AccountIgnoreFile .\data\ignore-accounts.txt -AccountMappingFile .\data\mapping.txt
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
    [Parameter()]
    [string]
    $RecipientGuild,
    [Parameter()]
    [string]
    $DonorsGuild,
    [Parameter()]
    [string]
    $AccountIgnoreFile,
    [Parameter()]
    [string]
    $AccountMappingFile
)

Import-Module "$PSScriptRoot\..\DonationLottery"

$donationDataPath = $DonationLogPath
if (-not [String]::IsNullOrEmpty($AccountMappingFile)) {
    $donationDataPath = Join-Path -Path $PSScriptRoot -ChildPath "data\donations.temp.csv"
    $convertArgs = @{
        DonationLogPath = $DonationLogPath
        AltAccountMappingFile = $AccountMappingFile
        TargetFile = $donationDataPath
    }
    Convert-AltAccount @convertArgs
}

$getpointsParams = @{
   DonationLogPath = $donationDataPath
   Resource = $Resource
   RecipientGuild = $RecipientGuild
   DonorsGuild = $DonorsGuild
}
$rawPoints = Get-PointsPerAccount @getpointsParams
$points = Convert-HashtableToArray -InputObject $rawPoints
Write-Information "---- Points per account ----"
$points | ForEach-Object {
    Write-Information "$($_.Name): $($_.Points)"
}
Write-Information "----------------------------"
$getDonationLotteryParams = @{
    PointsPerAccount = $points
    ListLength = $ListLength
    PointThreshold = $ResourceThreshold
    AccountIgnoreFile = $AccountIgnoreFile
}
$winnerAccounts = New-Lottery @getDonationLotteryParams
$accounts = Get-AccountMainList -DonationLogPath $donationDataPath -Accounts $winnerAccounts

$namesWithAccount = $accounts | ForEach-Object {
    "$($_.Main)@$($_.Account)"
}

$resultText = Format-DonationLottery -OrderedNames $namesWithAccount
return $resultText
