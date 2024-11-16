# Neverwinter Guild Tools

This repository contains utility tools for managing guilds within the MMO game Neverwinter.


## Functions
### [Merge-Csv.ps1](./PowerShell/scripts/Merge-Csv.ps1)
A PowerShell script to merge *.csv files with donation data. You can get those files by executing the following command ingame (Replace the path with a proper value):
```
/ExportGuildDonationLog "path\to\download\directory\donations.csv"
```

If you got multiple of those files, you can merge them with this script, so that you get a single *.csv file with only the entries that match a certain time pattern.

E.g. if you want all the entries from february of 2022 you use the following pattern: `.*2\.2022`

### [New-DonationLottery.ps1](./PowerShell/scripts/New-DonationLottery.ps1)
A PowerShell script that runs a lottery based on donation data. This means that all members who donated at least a minimum amount of a resource (e.g. influence) are put on a ranked list. You have to specify the length of the list. If there are more people than the ones who donated enough, then not everyone will make it on the list (e.g. if you have prices for 10 people but 14 have qualified, then 4 people are not put on the list).

The results of this script are the following:
- Points per account: This is a simple console output that lists which account donated how much of the resource
- Lottery: A ranked list of a specified length (This is also the actual return value of the function)

### [Show-PointsPerAccount](./PowerShell/scripts/Show-PointsPerAccount.ps1)

A PowerShell script that shows who donated how much of a certain ressource to a guild.

Example output:
```
MainCharacter      AccountHandle      DonatedAmount
-------------      -------------      -------------
foo                bar                           20
es                 stuf#12345                   100
hello              there#23456                   40
general            kenobi#9876                  200
```

### [New-GeneralLottery](./PowerShell/scripts/New-GeneralLottery.ps1)

A PowerShell script that takes an export of your current members and returns a list of random accounts.

## Tests
### PowerShell
PowerShell scripts can be tested with [Pester](https://pester.dev/) (Major version: 5). Open a PowerShell and execute:

```PowerShell
Invoke-Pester
```

### Python
Python tools in this repository are tested with default tools. Execute from the repository's root:

```
python -m unittest discover PythonTools/test
```
