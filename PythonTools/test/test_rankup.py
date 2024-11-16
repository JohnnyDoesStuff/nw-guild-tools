import os
import unittest

from PythonTools.Rankup.RankupProposal import RankupProposal


class RankupTest(unittest.TestCase):

    def test_read_accounts_from_wellformed_csv(self):
        file_path = "testdata/accountsGermanExportFixed.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        full_path = os.path.join(current_directory, file_path)
        rankup_tool = RankupProposal()

        accounts = rankup_tool.read_accounts(full_path)

        self.assertEqual(len(accounts), 2)
        self.assertEqual(accounts[0].account_handle, "@bar")
        self.assertEqual(accounts[0].join_date, "1.1.2024, 10:00:00")
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].join_date, "2.1.2024, 10:00:00")
