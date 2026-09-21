from datetime import date, timedelta
import pandas as pd
from PythonTools.Purge.PurgeRule import PurgeRule

class PurgeProposal:

    def __init__(self):
        print("Purge init")

    def read_rules(self, path: str):
        """
        Reads rule information from a CSV file and returns a list of PurgeRule objects.

        Args:
            path (str): The path to the CSV file containing the purge rules.

        Returns:
            list: A list of PurgeRule objects.
        """
        print(f"Reading rules from {path}")
        raw_rule_data = pd.read_csv(path)

        rules = []
        for _, row in raw_rule_data.iterrows():
            rule = PurgeRule(
                row['Rank'],
                row['PurgeAfter']
            )
            rules.append(rule)
        return rules

    def read_banned_accounts(self, path: str) -> list:
        """
        Reads banned accounts from a text file that are separated by newlines.

        Args:
            path (str): The path to the text file containing the banned accounts.

        Returns:
            list: A list of banned accounts.
        """

        if not path:
            return []

        print(f"Reading banned accounts from {path}")
        with open(path, "r") as f:
            return f.read().splitlines()

    def create_purge_proposal(self,
                        rule: PurgeRule,
                        accounts: list,
                        reference_date: date = date.today()
                        ) -> list:
        """
        Creates a purge proposal for the given accounts based on the given purge rule
        and reference date.

        Args:
            rule (PurgeRule): The purge rule to use for the purge proposal.
            accounts (list): A list of Account objects.
            reference_date (date): The reference date to use to calculate the time
                when the purge should be done.
                Usually that's the value of date.today()

        Returns:
            list: A list of Account objects that should receive a purge
                according to the given rule.
        """
        purge_proposal = []
        max_inactivity_time = timedelta(days=rule.purge_after)

        for account in accounts:
            last_active_datetime = account.last_active_date

            if account.guild_rank != rule.rank:
                continue

            if last_active_datetime is None:
                print(f"[Warning] Account {account.account_handle} has no last active date")
                continue

            last_active_date = last_active_datetime.date()
            next_possible_purge_date = last_active_date + max_inactivity_time

            if next_possible_purge_date < reference_date:
                purge_proposal.append(account)

        return purge_proposal

    def get_banned_accounts(self,
                            accounts: list,
                            banned_accounts: list
                            ) -> list:
        """
        Returns a list of all banned accounts found

        Args:
            accounts (list): A list of Account objects.
            banned_accounts (list): A list of banned accounts

        Returns:
            list: A list of banned accounts
        """
        normalized_banned_accounts = [
            f"@{handle}"
            if not handle.startswith("@") else handle
            for handle in banned_accounts]

        return [account for account in accounts if account.account_handle in normalized_banned_accounts]
