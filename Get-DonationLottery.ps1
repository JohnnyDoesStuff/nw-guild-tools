<#
.SYNOPSIS
    Creates a donation lottery for multiple accounts that could achieve points

.PARAMETER PointsPerAccount
    An array with the points per accoung
    The elements of the array must have a field 'Name' and a field 'Points'

.PARAMETER ListLength
    How many people should win something

.PARAMETER PointThreshold
    The amount of points that have to be achieved to have a chance of winning something

.EXAMPLE
    Get-DonationLottery -PointsPerAccount @(
                    @{Name = "foo0"; Points = 10}
                    @{Name = "foo1"; Points = 10}
                    @{Name = "foo2"; Points = 10}
                ) -ListLength 2 -PointThreshold 10
#>



function Get-DonationLottery {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [array]
        $PointsPerAccount,
        [Parameter(Mandatory)]
        [int]
        $ListLength,
        [Parameter(Mandatory)]
        [int]
        $PointThreshold
    )

    if ($PointsPerAccount.Length -lt $ListLength) {
        $errorMessage = @(
            "There are not enough people to create a list of the",
            "given length of $ListLength -- even without",
            "the PointThreshold"
        ) -join " "
        throw $errorMessage
    }

    $qualifiedPeople = $PointsPerAccount | Where-Object {
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
