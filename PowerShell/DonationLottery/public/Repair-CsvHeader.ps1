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
