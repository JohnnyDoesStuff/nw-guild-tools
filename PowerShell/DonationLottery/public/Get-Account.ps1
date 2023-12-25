<#
.SYNOPSIS
    Return an ordered list of all accounts in your guild
.DESCRIPTION
    Parses a memberlist which can be retrieved by the ingame command
    /ExportGuildMemberList <filename.csv>
.NOTES
    The export should be done from an english game client because
    the game's exports don't always properly export data
    (this usually happens if a comma is used in a date format)
.EXAMPLE
    PS> Get-Account.ps1 -GuildMemberList .\members.csv
    Parses the file .\members.csv and write a list of all members to the output stream
#>

function Get-Account {
    param(
        [Parameter(Mandatory)]
        [string]
        $GuildMemberList
    )

    $data = Import-Csv -Path $GuildMemberList
    $allAccounts = $data.'Account Handle'
    return $allAccounts | Select-Object -Unique | Sort-Object
}
