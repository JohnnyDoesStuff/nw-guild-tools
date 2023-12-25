<#
.SYNOPSIS
    Create a list of random guild members to win a prize

.PARAMETER GuildMemberList
    A list of all members created by the ingame command
    /ExportGuildMemberList <filename.csv>
    The export should be done from an english game client because
    the game's exports don't always properly export data
    (this usually happens if a comma is used in a date format)

.PARAMETER ListLength
    The amount of people you want to have on the lottery

.PARAMETER AccountIgnoreFile
    (Optional) The path to a file with people that should not be put on the list
    The file must be a simple text file.
    Each account that will be ignored has to be in a separate line

.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

param(
    [Parameter(Mandatory)]
    [string]
    $GuildMemberList,
    [Parameter(Mandatory)]
    [int]
    $ListLength,
    [Parameter()]
    [string]
    $AccountIgnoreFile
)

Import-Module "$PSScriptRoot\..\DonationLottery"

$guildMembers = Get-Account -GuildMemberList $GuildMemberList
[string[]]$accountsToIgnore = Get-IgnoredAccount -AccountIgnoreFile $AccountIgnoreFile

$guildMembersToConsider = $guildMembers | Where-Object {
    $shortenedAccountHandle = $_.Substring(1)
    $accountsToIgnore -notcontains $shortenedAccountHandle
}

$accounts = Get-Random -InputObject $guildMembersToConsider -Count $ListLength

return $accounts | ForEach-Object {
    $_.Substring(1)
}
