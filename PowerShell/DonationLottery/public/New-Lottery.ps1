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

.PARAMETER AccountIgnoreFile
    An optional parameter to specify a file with a list of accounts who should be excluded
    E.g. if you don't want to give prices to your officers since they already got that stuff

.EXAMPLE
    New-Lottery -PointsPerAccount @(
                    @{Name = "foo0"; Points = 10}
                    @{Name = "foo1"; Points = 10}
                    @{Name = "foo2"; Points = 10}
                ) -ListLength 2 -PointThreshold 10
#>



function New-Lottery {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", '',Justification="false positive")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'PointThreshold', Justification = 'False positive as rule does not know that Where-Object operates within the same scope')]
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
        $PointThreshold,
        [Parameter()]
        [string]
        $AccountIgnoreFile
    )

    if ($PointsPerAccount.Length -lt $ListLength) {
        $errorMessage = @(
            "There are not enough people to create a list of the",
            "given length of $ListLength -- even without",
            "the PointThreshold"
        ) -join " "
        throw $errorMessage
    }

    [string[]]$accountsToIgnore = Get-IgnoredAccount -AccountIgnoreFile $AccountIgnoreFile

    $qualifiedPeople = $PointsPerAccount | Where-Object {
        ([int]$_.Points -ge $PointThreshold) -and (-not ($accountsToIgnore.Contains($_.Name)))
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
