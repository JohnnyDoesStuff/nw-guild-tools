from datetime import date, datetime
import pandas as pd

from PythonTools.Rankup.Account import Account
from PythonTools.Rankup.RankupRule import RankupRule

class RankupProposal:
    def __init__(self):
        print("Rankup init")

    def _convert_date_to_date_object(self, date_string: str) -> datetime:
        # todo: support more timeformats
        return datetime.strptime(date_string, "%d.%m.%Y, %H:%M:%S")

    def read_accounts(self, path: str) -> list:
        """
        Reads account information from a CSV file and returns a list of Account objects.

        Args:
            path (str): The file path to the CSV file containing account data.
                The file must be properly formatted.
                Neverwinter does not export data properly with some languages,
                so you may have to repair it before using this function.

        Returns:
            list: A list of Account objects with account handle, guild rank, and join date.
        """
        print(f"Reading accounts from {path}")
        raw_account_data = pd.read_csv(path)

        accounts = []
        for _, row in raw_account_data.iterrows():
            join_date = self._convert_date_to_date_object(row['Join Date'])
            account = Account(
                row['Account Handle'],
                row['Guild Rank'],
                join_date
            )
            accounts.append(account)
        return accounts

    def read_rules(self, path: str) -> list:
        """
        Reads rule information from a CSV file and returns a list of RankupRule objects.

        Args:
            path (str): The file path to the CSV file containing rule data.
                This is a file you have to create manually

        Returns:
            list: A list of RankupRule objects.
        """
        print(f"Reading rules from {path}")
        raw_rule_data = pd.read_csv(path)

        rules = []
        for _, row in raw_rule_data.iterrows():
            rule = RankupRule(
                row['Rank'],
                row['RankupAfter']
            )
            rules.append(rule)
        return rules

    def create_rankup_proposal_for_accounts(self,
                                            rankup_rule: RankupRule,
                                            accounts: list,
                                            reference_date: date) -> list:
        """
        Creates a rankup proposal for the given accounts based on the given rankup rule
        and reference date.

        Args:
            rankup_rule (RankupRule): The rankup rule to use for the rankup proposal.
            accounts (list): A list of Account objects.
            reference_date (date): The reference date to use to calculate the time since
                the accounts joined.

        Returns:
            list: A list of Account objects that should receive a promotion
                according to the given rule.
        """
        rankup_proposal = []

        for account in accounts:
            join_date = account.join_date.date()
            days_since_join = (reference_date - join_date).days

            if (days_since_join >= rankup_rule.rankup_after) and \
                (account.guild_rank == rankup_rule.rank):

                rankup_proposal.append(account)

        return rankup_proposal

