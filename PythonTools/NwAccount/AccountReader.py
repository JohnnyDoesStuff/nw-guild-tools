from datetime import datetime
import pandas as pd

from PythonTools.NwAccount.Account import Account


class AccountReader:

    def _convert_date_to_date_object(self, date_string: str) -> datetime:
        # todo: support more timeformats
        return datetime.strptime(date_string, "%d.%m.%Y, %H:%M:%S")

    def _add_account_data_to_list(self, account_list: list, account: Account):
        account_list = account_list.copy()
        saved_account = None
        for existing_account in account_list:
            if existing_account.account_handle == account.account_handle:
                saved_account = existing_account
                break

        if saved_account is not None:
            if saved_account.join_date > account.join_date:
                saved_account.join_date = account.join_date
            if saved_account.last_active_date < account.last_active_date:
                saved_account.last_active_date = account.last_active_date
        else:
            account_list.append(account)

        return account_list

    def read_accounts(self, path: str) -> list:
        """
        Reads account information from a CSV file and returns a list of Account objects.

        Args:
            path (str): The file path to the CSV file containing account data.
                The file must be properly formatted.
                Neverwinter does not export data properly with some languages,
                so you may have to repair it before using this function.
                Such a repair can also be necessary due to comments with
                unexpected characters like quotation marks and commas.

        Returns:
            list: A list of Account objects.
        """
        print(f"Reading accounts from {path}")
        raw_account_data = pd.read_csv(path)

        accounts = []
        for _, row in raw_account_data.iterrows():
            join_date = self._convert_date_to_date_object(row['Join Date'])
            last_active_date = self._convert_date_to_date_object(row['Last Active Date'])
            account = Account(
                row['Account Handle'],
                row['Guild Rank'],
                join_date,
                last_active_date = last_active_date
            )
            accounts = self._add_account_data_to_list(accounts, account)
        return accounts
