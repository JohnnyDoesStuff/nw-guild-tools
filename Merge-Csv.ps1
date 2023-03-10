<#
    .SYNOPSIS
    Merges *.csv files and removes entries having the same value within the column "Time"

    .NOTES
    All *.csv files should have been exported with the same language.
    Otherwise the TimePattern (and maybe also further processing) does not make sense

    .PARAMETER RawData
    An array with paths to all *.csv files to consider

    .PARAMETER TimePattern
    A pattern to specify which entries should be contained within the merged file

    .EXAMPLE
    PS> .\Merge-Csv.ps1 -RawData $myarray -TimePattern ".*2\.2022.*"
    This assumes that the time is something like "24.2.2022, 10:10:10"

    .EXAMPLE
    PS> .\Merge-Csv.ps1 -RawData $myarray -TimePattern "2/.*/2022.*"
    This assumes that the time is something like "2/24/2022 10:10:10 AM"

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
    $firstLineWithData = $content[1]

    $csvDelimiter = ','
    $header = $content[0]
    $cellsInFirstLine = $firstLineWithData.Split($csvDelimiter)
    $amountOfCells = $cellsInFirstLine.Length

    $headerItems = $header.Split($csvDelimiter)
    $amountOfColumns = $headerItems.Length

    if ($amountOfCells -eq $amountOfColumns) {
        Write-Verbose "No repair seems to be necessary for $FilePath"
    } elseif ($amountOfCells -eq ($amountOfColumns + 1)) {
        Write-Verbose "Repairing $($FilePath)..."
        Write-Verbose "Assuming that the time is comma separated into day and time of day"
        $content[0] = $header.Replace("Time", "Time$($csvDelimiter)TimeOfDay")
        Set-Content -Path $FilePath -Value $content
    } else {
        $errorMessage = @(
            "Unexpected format when importing $FilePath"
            "Please check that it uses $csvDelimiter as delimiter"
            "and that it is well-formed"
        ) -join " "
        Write-Error $errorMessage
    }
}

$results = @()
$existingDates = @()

foreach ($file in $RawData) {
    Write-Verbose "Processing $file"
    Repair-CsvHeader $file

    $dataSet = Import-Csv -Path $file
    $existingDates = $results | ForEach-Object { $_.Time + $_.TimeOfDay }

    $newData = $dataSet | Where-Object {
        $dateNotExists = $existingDates -notcontains ($_.Time + $_.TimeOfDay)
        $dateIsInAllowedRange = $_.Time -match $TimePattern
        $dateNotExists -and $dateIsInAllowedRange
    }
    $results = $results + $newData
}

$results | Select-Object * | Export-Csv -Path $TargetFile -NoTypeInformation
