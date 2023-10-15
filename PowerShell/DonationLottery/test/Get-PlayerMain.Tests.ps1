Describe "Test Get-PlayerMain and help functions" {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-PlayerMain.ps1"
        . "$PSScriptRoot\..\private\Convert-UserAnswerToChoice.ps1"
        . "$PSScriptRoot\..\private\Get-AccountMain.ps1"
        . "$PSScriptRoot\..\private\Get-AnswerFromUser.ps1"
        . "$PSScriptRoot\..\private\Remove-Duplicate.ps1"
    }
    Context "Remove-Duplicate" {
        It "Single entry" {
            [array]$inputData = @(
                "foo"
            )
            [array]$expectedResult = @(
                "foo"
            )

            Remove-Duplicate -Array $inputData | Should -Be $expectedResult
        }

        It "Multiple duplicates" {
            [array]$inputData = @(
                "foo",
                "foo",
                "foo"
            )
            [array]$expectedResult = @(
                "foo"
            )

            Remove-Duplicate -Array $inputData | Should -Be $expectedResult
        }

        It "Multiple uniques" {
            [array]$inputData = @(
                "foo0",
                "foo1"
            )
            [array]$expectedResult = @(
                "foo0",
                "foo1"
            )

            Remove-Duplicate -Array $inputData | Should -Be $expectedResult
        }

        It "Multiples with multiple duplicates" {
            [array]$inputData = @(
                "foo0",
                "foo1",
                "foo0",
                "foo1",
                "foo2",
                "foo0"
            )
            [array]$expectedResult = @(
                "foo0",
                "foo1",
                "foo2"
            )

            Remove-Duplicate -Array $inputData | Should -Be $expectedResult
        }
    }

    Context "Get-AccountMain" {
        It "Account with only one character" {
            $accountName = "foo0"
            $mainName = "bar"
            $donationData = @(
                @{ "Character Name" = $mainName; "Account Handle" = $accountName; "Resource Quantity" = 5; "Resource" = "dummyItem"}
            )

            $result = Get-AccountMain -DonationData $donationData -AccountName $accountName

            $result | Should -Be $mainName
        }

        It "Account with multiple characters" {
            $accountName = "foo0"
            $mainName = "bar"
            $altName = "es"
            $donationData = @(
                @{ "Character Name" = $mainName; "Account Handle" = $accountName; "Resource Quantity" = 5; "Resource" = "dummyItem"}
                @{ "Character Name" = $altName; "Account Handle" = $accountName; "Resource Quantity" = 5; "Resource" = "dummyItem"}
            )
            Mock Get-AnswerFromUser -ParameterFilter {
                $expectedQuestion = "What is the main of the account $accountName"
                $choicesCorrect = ($Choices.Count -eq 2) -and ($Choices[0] -eq $mainName) -and ($Choices[1] -eq $altName)
                ($Question -eq $expectedQuestion) -and $choicesCorrect
            } -MockWith { $mainName } -Verifiable

            $result = Get-AccountMain -DonationData $donationData -AccountName $accountName

            $result | Should -Be $mainName
        }
    }

    Context "Get-AnswerFromUser" {
        It "Correct answer" {
            $userInput = "0"
            $expectedResult = "bar0"
            $fakeChoices = @($expectedResult, "bar1")
            Mock Read-Host -MockWith {
                $userInput
            } -Verifiable
            Mock Convert-UserAnswerToChoice -ParameterFilter {
                ($Choices -eq $fakeChoices) -and ($Answer -eq $userInput)
            } -MockWith { $expectedResult } -Verifiable

            $result = Get-AnswerFromUser -Question "foo" -Choices $fakeChoices

            $result | Should -Be $expectedResult
        }

        It "Correct answer on second try" {
            $userInput = @("someInput", "0")
            $expectedResult = "bar0"
            $script:iteration = 0
            $fakeChoices = @($expectedResult, "bar1")

            Mock Read-Host -ParameterFilter {
                $Prompt -eq "Answer"
            } -MockWith {
                $userInput[$script:iteration]
            } -Verifiable

            Mock Convert-UserAnswerToChoice -ParameterFilter {
                $choicesCorrect = $null -eq (Compare-Object -DifferenceObject $Choices -ReferenceObject $fakeChoices)
                $answerCorrect = $Answer -eq $userInput[$script:iteration]
                $choicesCorrect -and $answerCorrect
            } -MockWith {
                $script:iteration = $script:iteration + 1
                $expectedResult
            } -Verifiable

            $result = Get-AnswerFromUser -Question "foo" -Choices $fakeChoices

            $result | Should -Be $expectedResult
        }
    }

    Context "Convert-UserAnswerToChoice" {
        It "Correct Answer" {
            $expectedChoice = "foo0"
            $choices = @("foo0", "foo1", "foo2")
            $answer = "0"

            $result = Convert-UserAnswerToChoice -Choices $choices -Answer $answer

            $result | Should -Be $expectedChoice
        }

        It "No number" {
            $expectedChoice = $null
            $choices = @("foo0", "foo1", "foo2")
            $answer = "k"
            Mock Write-Error -ParameterFilter {
                $Message -eq "You have to enter a number"
            } -MockWith {} -Verifiable

            $result = Convert-UserAnswerToChoice -Choices $choices -Answer $answer

            $result | Should -Be $expectedChoice
            Should -InvokeVerifiable
        }

        It "Number is too big" {
            $expectedChoice = $null
            $choices = @("foo0", "foo1", "foo2")
            $answer = "5"
            Mock Write-Error -ParameterFilter {
                $Message -eq "You have to write a number of the list!"
            } -MockWith {} -Verifiable

            $result = Convert-UserAnswerToChoice -Choices $choices -Answer $answer

            $result | Should -Be $expectedChoice
            Should -InvokeVerifiable
        }
    }
}