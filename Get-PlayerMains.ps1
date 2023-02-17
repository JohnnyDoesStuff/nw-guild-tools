<#
.SYNOPSIS
    Returns the main of an account in an interactive dialogue
#>


function Get-PlayerMain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath
    )

    $donationData = Import-Csv -Path $DonationLogPath
    $accounts = $donationData.account
    $accounts = Remove-Duplicate -Array $accounts
    $mains = @()
    
    $accounts | ForEach-Object {
        $mains = $mains + @(
            Get-AccountMain -DonationData $donationData -AccountName $_
        )
    }
    return $mains
}

function Get-AccountMainList {
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [array]
        $Accounts
    )
    
    $donationData = Import-Csv -Path $DonationLogPath
    $mains = @()
    
    $Accounts | ForEach-Object {
        $mains = $mains + @(
            Get-AccountMain -DonationData $donationData -AccountName $_
        )
    }
    return $mains
}

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
        $_.account -eq $AccountName
    }
    [array]$characters = $dataRows.name
    $characters = Remove-Duplicate -Array $characters
    if ($characters.Count -eq 1) {
        return $characters[0]
    } else {
        return Get-AnswerFromUser -Question "What is the main of the account $AccountName" -Choices $characters
    }
}

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

function Remove-Duplicate {
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
