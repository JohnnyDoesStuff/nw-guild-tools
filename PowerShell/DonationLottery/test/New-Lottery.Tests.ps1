Describe "Test New-Lottery" {
    BeforeAll {
        . "$PSScriptRoot\..\public\New-Lottery.ps1"
        $fakePath = "fake/data.csv"
    }
    Context "Invalid data" {
        It "Not enough people" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
            )

            { New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9} | Should -Throw
        }

        It "No participants" {
            $pointsPerAccount =@(
                @{Name = "foo0"; Points = 0}
                @{Name = "foo1"; Points = 0}
                @{Name = "foo2"; Points = 0}
                @{Name = "foo3"; Points = 0}
                @{Name = "foo4"; Points = 0}
                @{Name = "foo5"; Points = 0}
            )

            { New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9} | Should -Throw
        }

        It "No people" {
            $pointsPerAccount = @()

            { New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9} | Should -Throw
        }

        It "Not enough qualified people" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 0}
                @{Name = "foo5"; Points = 0}
            )

            { New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9} | Should -Throw
        }
    }

    Context "Valid data" {
        It "Right amount of people" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 10}
            )

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Contain $pointsPerAccount[0].Name
            $result | Should -Contain $pointsPerAccount[1].Name
            $result | Should -Contain $pointsPerAccount[2].Name
            $result | Should -Contain $pointsPerAccount[3].Name
            $result | Should -Contain $pointsPerAccount[4].Name
        }

        It "Right people with exact threshold" {
            $threshold = 9
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = $threshold}
                @{Name = "foo1"; Points = $threshold}
                @{Name = "foo2"; Points = $threshold}
                @{Name = "foo3"; Points = $threshold}
                @{Name = "foo4"; Points = $threshold}
            )

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold $threshold

            $result.Length | Should -Be 5
            $result | Should -Contain $pointsPerAccount[0].Name
            $result | Should -Contain $pointsPerAccount[1].Name
            $result | Should -Contain $pointsPerAccount[2].Name
            $result | Should -Contain $pointsPerAccount[3].Name
            $result | Should -Contain $pointsPerAccount[4].Name
        }

        It "More people than required" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 10}
                @{Name = "foo5"; Points = 10}
                @{Name = "foo6"; Points = 10}
            )

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | ForEach-Object {
                $pointsPerAccount.Name | Should -Contain $_
            }
        }

        It "Only right amount of people meets requirements" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 8}
                @{Name = "foo4"; Points = 10}
                @{Name = "foo5"; Points = 6}
                @{Name = "foo6"; Points = 10}
                @{Name = "foo7"; Points = 0}
            )

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Contain $pointsPerAccount[0].Name
            $result | Should -Contain $pointsPerAccount[1].Name
            $result | Should -Contain $pointsPerAccount[2].Name
            $result | Should -Contain $pointsPerAccount[4].Name
            $result | Should -Contain $pointsPerAccount[6].Name
        }

        It "More people meet requirement and some don't" {
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 0}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = "foo4"; Points = 8}
                @{Name = "foo5"; Points = 10}
                @{Name = "foo6"; Points = 10}
                @{Name = "foo7"; Points = 5}
                @{Name = "foo8"; Points = 10}
                @{Name = "foo9"; Points = 7}
                @{Name = "foo10"; Points = 10}
            )

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 5 -PointThreshold 9

            $result.Length | Should -Be 5
            $result | Should -Not -Contain $pointsPerAccount[1].Name
            $result | Should -Not -Contain $pointsPerAccount[4].Name
            $result | Should -Not -Contain $pointsPerAccount[7].Name
            $result | Should -Not -Contain $pointsPerAccount[9].Name
            $result | ForEach-Object {
                $pointsPerAccount.Name | Should -Contain $_
            }
        }
    }

    Context "Ignore accounts" {
        It "Can ignore an account" {
            $accountToIgnore = "someGuildOfficer"
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = $accountToIgnore; Points = 10}
            )
            $ignoreFile = "path/to/ignore-accounts.txt"

            Mock Test-Path -ParameterFilter {
                $Path -eq $ignoreFile
            } -MockWith {
                $true
            } -Verifiable
            Mock Get-Content -ParameterFilter {
                $Path -eq $ignoreFile
            } -MockWith {
                [array]@(
                    $accountToIgnore
                )
            } -Verifiable

            $mockResult = @(
                $pointsPerAccount[0],
                $pointsPerAccount[2],
                $pointsPerAccount[1],
                $pointsPerAccount[3]
            )
            Mock Get-Random -ParameterFilter {
                if ($InputObject -contains $pointsPerAccount[4]) {
                    return $false
                }
                $sizeCorrect = $InputObject.Length -eq 4
                $foo0Present = $InputObject -contains $pointsPerAccount[0]
                $foo1Present = $InputObject -contains $pointsPerAccount[1]
                $foo2Present = $InputObject -contains $pointsPerAccount[2]
                $foo3Present = $InputObject -contains $pointsPerAccount[3]
                $sizeCorrect -and $foo0Present -and $foo1Present -and $foo2Present -and $foo3Present
            } -MockWith {
                $mockResult
            } -Verifiable

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 4 -PointThreshold 9 -AccountIgnoreFile $ignoreFile

            $result.Length | Should -Be 4
            $result | Should -Contain $pointsPerAccount[0].Name
            $result | Should -Contain $pointsPerAccount[1].Name
            $result | Should -Contain $pointsPerAccount[2].Name
            $result | Should -Contain $pointsPerAccount[3].Name
            $result | Should -Not -Contain $pointsPerAccount[4].Name

            Should -InvokeVerifiable
        }

        It "Can ignore multiple accounts" {
            $script:accountsToIgnore = @(
                "someGuildOfficer"
                "anotherOfficer"
            )
            $pointsPerAccount = @(
                @{Name = "foo0"; Points = 10}
                @{Name = "foo1"; Points = 10}
                @{Name = "foo2"; Points = 10}
                @{Name = "foo3"; Points = 10}
                @{Name = $script:accountsToIgnore[0]; Points = 10}
                @{Name = $script:accountsToIgnore[1]; Points = 10}
            )
            $ignoreFile = "path/to/ignore-accounts.txt"

            Mock Test-Path -ParameterFilter {
                $Path -eq $ignoreFile
            } -MockWith {
                $true
            } -Verifiable
            Mock Get-Content -ParameterFilter {
                $Path -eq $ignoreFile
            } -MockWith {
                @(
                    $script:accountsToIgnore[0]
                    $script:accountsToIgnore[1]
                )
            } -Verifiable

            $mockResult = @(
                $pointsPerAccount[0],
                $pointsPerAccount[2],
                $pointsPerAccount[1],
                $pointsPerAccount[3]
            )
            Mock Get-Random -ParameterFilter {
                if ($InputObject -contains $pointsPerAccount[4]) {
                    return $false
                }
                if ($InputObject -contains $pointsPerAccount[5]) {
                    return $false
                }
                $sizeCorrect = $InputObject.Length -eq 4
                $foo0Present = $InputObject -contains $pointsPerAccount[0]
                $foo1Present = $InputObject -contains $pointsPerAccount[1]
                $foo2Present = $InputObject -contains $pointsPerAccount[2]
                $foo3Present = $InputObject -contains $pointsPerAccount[3]
                $sizeCorrect -and $foo0Present -and $foo1Present -and $foo2Present -and $foo3Present
            } -MockWith {
                $mockResult
            } -Verifiable

            $result = New-Lottery -PointsPerAccount $pointsPerAccount -ListLength 4 -PointThreshold 9 -AccountIgnoreFile $ignoreFile

            $result.Length | Should -Be 4
            $result | Should -Contain $pointsPerAccount[0].Name
            $result | Should -Contain $pointsPerAccount[1].Name
            $result | Should -Contain $pointsPerAccount[2].Name
            $result | Should -Contain $pointsPerAccount[3].Name
            $result | Should -Not -Contain $pointsPerAccount[4].Name
            $result | Should -Not -Contain $pointsPerAccount[5].Name

            Should -InvokeVerifiable
        }
    }
}