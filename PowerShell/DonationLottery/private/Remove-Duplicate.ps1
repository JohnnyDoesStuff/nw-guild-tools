function Remove-Duplicate {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", '',Justification="false positive")]
    param (
        # The elements have to support 'equals' used by 'contains'
        [Parameter(Mandatory)]
        [array]
        $Array
    )

    $result = @()
    $Array | ForEach-Object {
        if (-not $result.Contains($_)) {
            $result = $result + @($_)
        }
    }
    return $result
}
