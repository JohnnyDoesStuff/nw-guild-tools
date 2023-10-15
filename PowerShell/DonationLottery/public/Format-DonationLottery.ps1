function Format-DonationLottery {
    [OutputType([String[]])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [array]
        $OrderedNames
    )

    [string[]]$outputLines = for ($i = 0; $i -lt $OrderedNames.Count; $i++) {
        "$($i + 1). $($OrderedNames[$i])"
    }
    return $outputLines
}
