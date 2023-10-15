<#
.SYNOPSIS
    A script that uses a mapping file to replace test in a textfile with a different text
    and stores the result in a new file

.PARAMETER DonationLogPath
    The file with the donation data where people have multiple accounts

.PARAMETER AltAccountMappingFile
    The path to a file with mapping information
    Each line in that file is an entry and separated by a colon ("altAccount#1234:MainAccount#1233")

.PARAMETER TargetFile
    The target file that should be created

.EXAMPLE
    .\Convert-AltAccount -DonationLogPath .\data\donations.csv -AltAccountMappingFile .\data\accountMapping.txt -TargetFile .\data\donationData_clean.csv
#>



function Convert-AltAccount {
    param (
        [Parameter(Mandatory)]
        [String]
        $DonationLogPath,
        [Parameter(Mandatory)]
        [String]
        $AltAccountMappingFile,
        [Parameter(Mandatory)]
        [String]
        $TargetFile
    )

    Write-Verbose "Mapping accounts:"
    [array]$lines = Get-Content -Path $AltAccountMappingFile
    [array]$accountsToMap = $lines | Where-Object {
        -not [String]::IsNullOrWhiteSpace($_)
    } | ForEach-Object {
        $altAccount, $mainAccount = $_.Trim().Split(':')
        Write-Verbose "    $altAccount -> $mainAccount"
        @{
            Alt = $altAccount
            Main = $mainAccount
        }
    }

    $fileContent = Get-Content -Path $DonationLogPath -Raw
    $accountsToMap | ForEach-Object {
        $fileContent = $fileContent.Replace($_.Alt, $_.Main)
    }
    New-Item -Path $TargetFile -ItemType File -Value $fileContent -Force | Out-Null
}
