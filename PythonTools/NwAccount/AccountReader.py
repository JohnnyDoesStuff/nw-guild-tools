from datetime import datetime
import pandas as pd

from PythonTools.NwAccount.Account import Account


class AccountReader:

    def _convert_date_to_date_object(self, date_string: str) -> datetime:
        # todo: support more timeformats
        return datetime.strptime(date_string, "%d.%m.%Y, %H:%M:%S")

    def _merge_account_data_into_list(self, all_account_data: list, new_account_data: Account):
        all_account_data = all_account_data.copy()
        saved_account = None
        for existing_account in all_account_data:
            if existing_account.account_handle == new_account_data.account_handle:
                saved_account = existing_account
                break

        if saved_account is not None:
            if saved_account.join_date > new_account_data.join_date:
                saved_account.join_date = new_account_data.join_date
            if saved_account.last_active_date < new_account_data.last_active_date:
                saved_account.last_active_date = new_account_data.last_active_date
        else:
            all_account_data.append(new_account_data)

        return all_account_data

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
                The accounts contain the combination of the data that is
                automatically retrievable from all of their characters' data
                in the guild. (e.g. latest active date)
        """
        print(f"Reading accounts from {path}")
        raw_account_data = pd.read_csv(path)

        all_accounts = []
        for _, row in raw_account_data.iterrows():
            join_date = self._convert_date_to_date_object(row['Join Date'])
            last_active_date = self._convert_date_to_date_object(row['Last Active Date'])
            account_data_of_current_character = Account(
                row['Account Handle'],
                row['Guild Rank'],
                join_date,
                last_active_date = last_active_date
            )

            all_accounts = self._merge_account_data_into_list(
                all_accounts,
                account_data_of_current_character
            )
        return all_accounts
