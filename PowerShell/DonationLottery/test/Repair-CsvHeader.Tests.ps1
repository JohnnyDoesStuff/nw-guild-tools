Describe "Repair-CsvHeader" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Justification="Constant variable for the test")]
        $fakeFilePath = "fake/data.csv"
        . "$PSScriptRoot\..\public\Repair-CsvHeader.ps1"
    }
    BeforeEach {
        Mock Get-Content -ParameterFilter {
            ($Path -eq $fakeFilePath) -and ($null -eq $Raw)
        } -MockWith {
            $script:originalData
        } -Verifiable
    }
    Context "Correct header" {
        It "Does not modify if everything is correct" {
            $script:originalData = @(
                "Character Name,Account Handle,Time,Item,Item Count,Resource,Resource Quantity,Donor`'s Guild,Recipient Guild"
                "foo,bar,1/1/2023 1:23:45 PM,`"Dungeoneer's Shard of Power`",375,`"Dungeoneer's Shard of Power`",375,Foo Fighters,Bar Fighters"
                "barfoos,es,1/2/2023 1:23:34 PM,`"Strongbox of Surplus Equipment`",1,`"Surplus Equipment`",970,Foo Fighters,Bar Fighters"
            )
            Mock Write-Verbose -ParameterFilter {
                $Message -eq "No repair seems to be necessary for $fakeFilePath"
            } -MockWith {} -Verifiable

            Repair-CsvHeader -FilePath $fakeFilePath | Should -Be $null

            Should -InvokeVerifiable
        }
    }

    Context "Incorrect header" {
        It "Time is missing quotation marks" {
            $script:originalData = @(
                "Character Name,Account Handle,Time,Item,Item Count,Resource,Resource Quantity,Donor's Guild,Recipient Guild"
                "foo,bar,1.2.2023, 12:34:56,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
                "barfoos,es,1.2.2023, 12:34:56,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
            )
            $expectedResult = @(
                "Character Name,Account Handle,Time,TimeOfDay,Item,Item Count,Resource,Resource Quantity,Donor's Guild,Recipient Guild"
                "foo,bar,1.2.2023, 12:34:56,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
                "barfoos,es,1.2.2023, 12:34:56,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
            )
            Mock Set-Content -ParameterFilter {
                @(
                    $Path -eq $fakeFilePath
                    $Value.Count -eq $expectedResult.Count
                    $Value[0] -eq $expectedResult[0]
                    $Value[1] -eq $expectedResult[1]
                    $Value[2] -eq $expectedResult[2]
                ) -notcontains $false
            } -MockWith {} -Verifiable

            Repair-CsvHeader -FilePath $fakeFilePath | Should -Be $null

            Should -InvokeVerifiable
        }

        It "Header is missing more than one column" {
            $script:originalData = @(
                "Character Name,Account Handle,Time,Item,Item Count,Resource,Resource Quantity,Donor's Guild,Recipient Guild"
                "foo,bar,1.2.2023, 12:34:56,This should not,be here,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
                "barfoos,es,1.2.2023, 12:34:56,This should not,be here,`"Heldenscherbe der Kraft`",46,`"Heldenscherbe der Kraft`",46,Foo Fighters,Bar Fighters"
            )
            Mock Set-Content -MockWith {}
            Mock Write-Error -ParameterFilter {
                $Message -eq @(
                    "Unexpected format when importing $FilePath"
                    "Please check that it uses $csvDelimiter as delimiter"
                    "and that it is well-formed"
                ) -join " "
            } -MockWith {} -Verifiable

            Repair-CsvHeader -FilePath $fakeFilePath | Should -Be $null

            Should -Not -Invoke Set-Content
        }
    }
}
