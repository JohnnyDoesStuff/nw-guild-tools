function Get-AccountMain {
    param (
        [Parameter(Mandatory)]
        [array]
        $DonationData,
        [Parameter(Mandatory)]
        [String]
        $AccountName
    )
    $dataRows = $DonationData | Where-Object {
        $_."Account Handle" -eq $AccountName
    }
    [array]$characters = $dataRows."Character Name"
    $characters = Remove-Duplicate -Array $characters
    if ($characters.Count -eq 1) {
        return $characters[0]
    } else {
        return Get-AnswerFromUser -Question "What is the main of the account $AccountName" -Choices $characters
    }
}
