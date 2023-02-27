<#
    .SYNOPSIS
    Merges *.csv files and removes entries having the same value within the column "Time"

    .PARAMETER RawData
        An array with paths to all *.csv files to consider

    .PARAMETER TimePattern
    A pattern to specify which entries should be contained within the merged file

    .EXAMPLE
    PS> .\Merge-Csv.ps1 -RawData $myarray -TimePattern ".*2\.2022"

#>


param(
    [Parameter(Mandatory)]
    [array]$RawData,
    [Parameter(Mandatory)]
    [String]$TimePattern,
    [Parameter(Mandatory)]
    [String]$TargetFile
)

function Repair-CsvHeader {
    param (
        [Parameter(Mandatory)]
        $FilePath
    )
    $content = Get-Content $FilePath
    $firstLine = $content[0]
    if ($firstLine -notmatch "Day,Time") {
        $content[0] = $firstLine.Replace("Time", "Day,Time")
        Set-Content -Path $FilePath -Value $content
    }
}

$results = @()
$existingDates = @()

foreach ($file in $RawData) {
    $existingDates = $results | ForEach-Object { $_.Day + $_.Time }
    Repair-CsvHeader $file
    $dataSet = Import-Csv -Path $file

    $newData = $dataSet | Where-Object {
        $dateNotExists = $existingDates -notcontains ($_.Day + $_.Time)
        $dateIsInAllowedRange = $_.Day -match $TimePattern
        $dateNotExists -and $dateIsInAllowedRange
    }
    $results = $results + $newData
}

$results | Select-Object * | Export-Csv -Path $TargetFile -NoTypeInformation
