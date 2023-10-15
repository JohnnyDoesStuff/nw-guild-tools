function Format-DonationLottery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [array]
        $OrderedNames
    )

    for ($i = 0; $i -lt $OrderedNames.Count; $i++) {
        "$($i + 1). $($OrderedNames[$i])"
    }

}