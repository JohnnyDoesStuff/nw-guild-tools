from datetime import datetime
import pandas as pd

from PythonTools.NwAccount.Account import Account


class AccountReader:

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
            list: A list of Account objects.
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
