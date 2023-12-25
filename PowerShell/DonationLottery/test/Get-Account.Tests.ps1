Describe "Get-Account" {
    BeforeAll {
        . "$PSScriptRoot\..\public\Get-Account.ps1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments', '', Justification="Constant variable for the test")]
        $accountNames = @(
            '@abc'
            '@abd'
            '@abf'
        )
    }
    BeforeEach {
        $fakePath = "fake\data.csv"
        Mock Import-Csv -ParameterFilter {
            $Path -eq $fakePath
        } -MockWith {
            $script:testData
        } -Verifiable
    }
    Context "returns accounts correctly" {
        It "if accounts are already ordered correctly" {
            $script:testData = @(
                @{
                    'Character Name' = 'foo'
                    'Account Handle' = $accountNames[0]
                }
                @{
                    'Character Name' = 'bar'
                    'Account Handle' = $accountNames[1]
                }
                @{
                    'Character Name' = 'es'
                    'Account Handle' = $accountNames[2]
                }
            )

            $result = Get-Account -GuildMemberList $fakePath

            $result.Length | Should -Be $accountNames.Length
            for ($i = 0; $i -lt $accountNames.Count; $i++) {
                $result[$i] | Should -Be $accountNames[$i]
            }
        }

        It "if accounts are not sorted" {
            $script:testData = @(
                @{
                    'Character Name' = 'es'
                    'Account Handle' = $accountNames[2]
                }
                @{
                    'Character Name' = 'foo'
                    'Account Handle' = $accountNames[0]
                }
                @{
                    'Character Name' = 'bar'
                    'Account Handle' = $accountNames[1]
                }
            )

            $result = Get-Account -GuildMemberList $fakePath

            $result.Length | Should -Be $accountNames.Length
            for ($i = 0; $i -lt $accountNames.Count; $i++) {
                $result[$i] | Should -Be $accountNames[$i]
            }
        }

        It "if an account has multiple characters" {
            $script:testData = @(
                @{
                    'Character Name' = 'foo'
                    'Account Handle' = $accountNames[0]
                }
                @{
                    'Character Name' = 'bar0'
                    'Account Handle' = $accountNames[1]
                }
                @{
                    'Character Name' = 'bar1'
                    'Account Handle' = $accountNames[1]
                }
                @{
                    'Character Name' = 'es'
                    'Account Handle' = $accountNames[2]
                }
            )

            $result = Get-Account -GuildMemberList $fakePath

            $result.Length | Should -Be $accountNames.Length
            for ($i = 0; $i -lt $accountNames.Count; $i++) {
                $result[$i] | Should -Be $accountNames[$i]
            }
        }
    }
}
