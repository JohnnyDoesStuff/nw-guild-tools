import pandas as pd

from PythonTools.Rankup.Account import Account

class RankupProposal:
    def __init__(self):
        print("Rankup init")

    def read_accounts(self, path: str) -> list:
        print(f"Reading accounts from {path}")
        raw_account_data = pd.read_csv(path)

        accounts = []
        for _, row in raw_account_data.iterrows():
            account = Account(
                row['Account Handle'],
                row['Join Date'])
            accounts.append(account)
        return accounts
