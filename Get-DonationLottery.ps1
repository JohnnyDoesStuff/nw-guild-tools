
function Get-DonationLottery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $CsvWithPeople,
        [Parameter(Mandatory)]
        [int]
        $ListLength,
        [Parameter(Mandatory)]
        [int]
        $PointThreshold
    )

    $allPeople = Import-Csv -Path $CsvWithPeople

    if ($allPeople.Length -lt $ListLength) {
        $errorMessage = @(
            "There are not enough people to create a list of the",
            "given length of $ListLength -- even without",
            "the PointThreshold"
        ) -join " "
        throw $errorMessage
    }

    $qualifiedPeople = $allPeople | Where-Object {
        [int]$_.Points -ge $PointThreshold
    }

    if ($qualifiedPeople.Length -eq 0) {
        throw "Nobody meets the Point Threshold. Cannot generate list."
    }

    if ($qualifiedPeople.Length -lt $ListLength) {
        throw "Not enough people meet the requirement ($($qualifiedPeople.Length) people)"
    }
    $randomizedObjects = Get-Random -InputObject $qualifiedPeople -Count $ListLength
    $names = $randomizedObjects | ForEach-Object {
        $_.Name
    }
    return $names
}
