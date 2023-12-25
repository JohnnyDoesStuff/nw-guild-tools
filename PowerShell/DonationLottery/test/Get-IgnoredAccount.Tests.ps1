Describe "Get-IgnoredAccount" {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-IgnoredAccount.ps1"
    }
    Context "throws" {
        It "If the ignore file does not exist" {
            Mock Test-Path -MockWith {
                $false
            } -Verifiable

            {
                Get-IgnoredAccount -AccountIgnoreFile 'some\path.txt'
            } | Should -Throw

            Should -InvokeVerifiable
        }
    }

    Context "returns a list" {
        BeforeEach {
            Mock Test-Path -MockWith {
                $true
            } -Verifiable
        }
        It "if the file contains 0 accounts" {
            $fileLines = @(
                ''
            )
            $filePath = 'some\path.txt'
            Mock Get-Content -ParameterFilter {
                ($Path.Length -eq 1) -and ($Path[0] -eq $filePath) -and ($Raw -ne $true)
            } -MockWith {
                $fileLines
            } -Verifiable

            $result = Get-IgnoredAccount -AccountIgnoreFile $filePath

            $result.Length | Should -Be 0
        }

        It "if the file contains 1 account" {
            $fileLines = @(
                'foo'
                ''
            )
            $filePath = 'some\path.txt'
            Mock Get-Content -ParameterFilter {
                ($Path.Length -eq 1) -and ($Path[0] -eq $filePath) -and ($Raw -ne $true)
            } -MockWith {
                $fileLines
            } -Verifiable

            [string[]]$result = Get-IgnoredAccount -AccountIgnoreFile $filePath

            $result.Length | Should -Be 1
            $result[0] | Should -Be $fileLines[0]
            Should -InvokeVerifiable
        }

        It "if the file contains 3 account" {
            $fileLines = @(
                'foo'
                'bar'
                'es'
                ''
            )
            $filePath = 'some\path.txt'
            Mock Get-Content -ParameterFilter {
                ($Path.Length -eq 1) -and ($Path[0] -eq $filePath) -and ($Raw -ne $true)
            } -MockWith {
                $fileLines
            } -Verifiable

            [string[]]$result = Get-IgnoredAccount -AccountIgnoreFile $filePath

            $result.Length | Should -Be 3
            $result[0] | Should -Be $fileLines[0]
            $result[1] | Should -Be $fileLines[1]
            $result[2] | Should -Be $fileLines[2]
            Should -InvokeVerifiable
        }
    }
}
