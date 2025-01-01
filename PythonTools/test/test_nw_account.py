from datetime import datetime
import os
import unittest

from PythonTools.NwAccount.AccountReader import AccountReader


class NwAccountTest(unittest.TestCase):

    def setUp(self):
        self.current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )

    def test_read_accounts_from_wellformed_csv(self):
        file_path = "testdata/accountsGermanExportFixed.csv"
        full_path = os.path.join(self.current_directory, file_path)
        account_reader = AccountReader()

        accounts = account_reader.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[0].guild_rank, "FakeRank1")
        self.assertEqual(accounts[0].join_date, datetime(2024, 1, 1, 10, 0, 0))
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].guild_rank, "FakeRank2")
        self.assertEqual(accounts[1].join_date, datetime(2024, 1, 2, 10, 0, 0))

    def test_contains_no_duplicates(self):
        file_path = "testdata/accountsGermanWithDuplicates.csv"
        full_path = os.path.join(self.current_directory, file_path)
        account_reader = AccountReader()

        accounts = account_reader.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[1].account_handle, "@baz")

    def test_join_date_matches_first_joined_character(self):
        file_path = "testdata/accountsGermanWithDuplicates.csv"
        full_path = os.path.join(self.current_directory, file_path)
        account_reader = AccountReader()

        accounts = account_reader.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[0].join_date, datetime(2024, 1, 1, 10, 0, 0))
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].join_date, datetime(2024, 1, 2, 10, 0, 0))

    def test_active_date_matches_last_character_activity(self):
        file_path = "testdata/accountsGermanWithDuplicates.csv"
        full_path = os.path.join(self.current_directory, file_path)
        account_reader = AccountReader()

        accounts = account_reader.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[0].last_active_date, datetime(2024, 1, 31, 12, 0, 0))
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].last_active_date, datetime(2024, 2, 3, 12, 0, 0))
