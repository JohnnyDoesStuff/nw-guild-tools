from datetime import datetime
import os
import unittest

from PythonTools.NwAccount.AccountReader import AccountReader


class NwAccountTest(unittest.TestCase):

    def test_read_accounts_from_wellformed_csv(self):
        file_path = "testdata/accountsGermanExportFixed.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        full_path = os.path.join(current_directory, file_path)
        account_reader = AccountReader()

        accounts = account_reader.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[0].guild_rank, "FakeRank1")
        self.assertEqual(accounts[0].join_date, datetime(2024, 1, 1, 10, 0, 0))
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].guild_rank, "FakeRank2")
        self.assertEqual(accounts[1].join_date, datetime(2024, 1, 2, 10, 0, 0))
