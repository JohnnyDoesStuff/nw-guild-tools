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
