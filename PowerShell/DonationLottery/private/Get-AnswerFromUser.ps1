function Get-AnswerFromUser {
    param (
        [Parameter(Mandatory)]
        [String]
        $Question,
        [Parameter(Mandatory)]
        [array]
        $Choices
    )
    $result = $null
    do {
        Write-Host $Question
        for ($i = 0; $i -lt $Choices.Count; $i++) {
            Write-Host "[$i]: $($Choices[$i])"
        }
        $answer = Read-Host -Prompt "Answer"
        $result = Convert-UserAnswerToChoice -Choices $Choices -Answer $answer

    } while (
        $null -eq $result
    )

    return $result
}
