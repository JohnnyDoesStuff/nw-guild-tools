function Convert-UserAnswerToChoice {
    param (
        [Parameter(Mandatory)]
        [array]
        $Choices,
        [Parameter(Mandatory)]
        [string]
        $Answer
    )
    try {
        [int]$answerId = $answer
        if (($answerId -lt 0) -or ($answerId -gt ($Choices.Count - 1))) {
            Write-Error "You have to write a number of the list!"
        } else {
            return $Choices[$answerId]
        }
    }
    catch {
        Write-Error "You have to enter a number"
    }
    return $null
}
