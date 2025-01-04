from datetime import date, timedelta
import pandas as pd
from PythonTools.Purge.PurgeRule import PurgeRule

class PurgeProposal:

    def __init__(self):
        print("Purge init")

    def read_rules(self, path: str):
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
                        reference_date: date
                        ) -> list:
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
