from datetime import date, datetime
import pandas as pd

from PythonTools.Rankup.Account import Account
from PythonTools.Rankup.RankupRule import RankupRule

class RankupProposal:
    def __init__(self):
        print("Rankup init")

    def convert_date_to_date_object(self, date_string: str) -> datetime:
        # todo: support more timeformats
        return datetime.strptime(date_string, "%d.%m.%Y, %H:%M:%S")

    def read_accounts(self, path: str) -> list:
        print(f"Reading accounts from {path}")
        raw_account_data = pd.read_csv(path)

        accounts = []
        for _, row in raw_account_data.iterrows():
            join_date = self.convert_date_to_date_object(row['Join Date'])
            account = Account(
                row['Account Handle'],
                row['Guild Rank'],
                join_date
            )
            accounts.append(account)
        return accounts

    def create_rankup_proposal_for_accounts(self,
                                            rankup_rule: RankupRule,
                                            accounts: list,
                                            reference_date: date) -> list:
        rankup_proposal = []

        for account in accounts:
            join_date = account.join_date.date()
            days_since_join = (reference_date - join_date).days

            if (days_since_join >= rankup_rule.rankup_after) and \
                (account.guild_rank == rankup_rule.rank):

                rankup_proposal.append(account)

        return rankup_proposal

