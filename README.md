# Neverwinter Guild Tools

This repository contains utility tools for managing guilds within the MMO game Neverwinter.

Tools are written in different languages since this repository is also used as a playground to try different things.

Because of that, the tools are intended to be executable from the repository's root. This means that e.g. for Python tools the documentation describes to use them as modules.

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

### Csv Repair

A tool that repairs ill-formed Member exports because Neverwinter does not properly export \*.csv files in some languages (Currently only tested for german exports; please create an issue to request more languages). For information about how to use this tool, please have a look at its help:
```bash
python -m PythonTools.CsvRepair -h
```

### Rankup
This tool assumes that certain members of a certain rank should automatically get promoted if they are within the guild for a certain time. For example, when rank 1 members got a probation time of 30 days.

You have to create a rule file that defines when which rank should receive a promotion. It has to be a \*.csv file, e.g.:
```csv
Rank,RankupAfter
Rank1,30
Rank2,90
Rank3,180
```

Use the help of the tool for further information:
```bash
python -m PythonTools.Rankup -h
```

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
