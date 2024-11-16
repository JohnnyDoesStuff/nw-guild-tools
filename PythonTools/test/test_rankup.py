from datetime import date, datetime
import os
import unittest

from PythonTools.Rankup.Account import Account
from PythonTools.Rankup.RankupProposal import RankupProposal
from PythonTools.Rankup.RankupRule import RankupRule

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
        self.assertEqual(accounts[0].guild_rank, "FakeRank1")
        self.assertEqual(accounts[0].join_date, datetime(2024, 1, 1, 10, 0, 0))
        self.assertEqual(accounts[1].account_handle, "@baz")
        self.assertEqual(accounts[1].guild_rank, "FakeRank2")
        self.assertEqual(accounts[1].join_date, datetime(2024, 1, 2, 10, 0, 0))

    def test_creates_rankup_proposal_for_rank1_accounts(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 2, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[0])
