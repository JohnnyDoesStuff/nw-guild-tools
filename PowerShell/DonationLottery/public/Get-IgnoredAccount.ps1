function Get-IgnoredAccount {
    param (
        [Parameter()]
        [string]
        $AccountIgnoreFile
    )
    $accountsToIgnore = @()
    if (-not ([String]::IsNullOrEmpty($AccountIgnoreFile))) {
        if (Test-Path $AccountIgnoreFile) {
            [array]$lines = Get-Content -Path $AccountIgnoreFile
            [array]$accountsToIgnore = $lines | Where-Object {
                -not [String]::IsNullOrWhiteSpace($_)
            } | ForEach-Object {
                $_.Trim()
            }
            Write-Verbose "Ignoring the following accounts"
            $accountsToIgnore | ForEach-Object {
                Write-Verbose "    $_"
            }
        } else {
            throw "The ignore file '$AccountIgnoreFile' could not be found"
        }
    }
    # Comma in front of the array to ensure that also an empty
    # array is returned as such and converted implicitly to $null
    return ,$accountsToIgnore
}
