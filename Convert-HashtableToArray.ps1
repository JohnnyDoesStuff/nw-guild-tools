function Convert-HashtableToArray {
    param (
        [Parameter(Mandatory)]
        [hashtable]
        $InputObject
    )
    $output = @()
    $InputObject.Keys | ForEach-Object {
        $output = $output + @(@{
            Name = $_
            Points = $InputObject.$_
        })
    }
    return $output
}