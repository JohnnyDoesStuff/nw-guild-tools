function Show-Question {
    param (
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter(Mandatory)]
        [array]
        $Choices
    )
    Write-Host $Question
    for ($i = 0; $i -lt $Choices.Count; $i++) {
        Write-Host "[$i]: $($Choices[$i])"
    }
}
