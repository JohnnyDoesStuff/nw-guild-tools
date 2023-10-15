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
        Show-Question -Question $Question -Choices $Choices
        $answer = Read-Host -Prompt "Answer"
        $result = Convert-UserAnswerToChoice -Choices $Choices -Answer $answer

    } while (
        $null -eq $result
    )

    return $result
}
