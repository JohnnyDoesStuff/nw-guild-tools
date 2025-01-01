from datetime import date
import pandas as pd

from PythonTools.NwAccount.Account import Account

from .RankupRule import RankupRule

class RankupProposal:
    def __init__(self):
        print("Rankup init")

    def _add_account_to_list(self, account_list: list, account: Account):
        account_list = account_list.copy()
        for existing_account in account_list:
            if existing_account.account_handle == account.account_handle:
                if existing_account.join_date > account.join_date:
                    account_list.remove(existing_account)
                    account_list.append(account)
                    return account_list
                else:
                    return account_list

        account_list.append(account)
        return account_list

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
                (account.guild_rank == rankup_rule.rank) and \
                (account not in rankup_proposal):

                rankup_proposal = self._add_account_to_list(rankup_proposal, account)

        rankup_proposal.sort(key=lambda account: account.account_handle.lower())

        return rankup_proposal

