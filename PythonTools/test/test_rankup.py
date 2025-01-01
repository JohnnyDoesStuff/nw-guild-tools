from datetime import date, datetime
import os
import unittest

from PythonTools.NwAccount.Account import Account
from PythonTools.Rankup.RankupProposal import RankupProposal
from PythonTools.Rankup.RankupRule import RankupRule

class RankupTest(unittest.TestCase):

    def test_read_rules_from_file(self):
        file_path = "testdata/testRules.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        full_path = os.path.join(current_directory, file_path)
        rankup_tool = RankupProposal()

        rules = rankup_tool.read_rules(full_path)

        self.assertEqual(len(rules), 3)
        self.assertEqual(rules[0].rank, 'Rank1')
        self.assertEqual(rules[0].rankup_after, 30)
        self.assertEqual(rules[1].rank, 'Rank2')
        self.assertEqual(rules[1].rankup_after, 90)
        self.assertEqual(rules[2].rank, 'Rank3')
        self.assertEqual(rules[2].rankup_after, 180)

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

    def test_does_not_rankup_too_new_members(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 2, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 0)

    def test_rankup_with_multiple_accounts(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
            Account(
                account_handle = "@baz",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 2, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[0])

    def test_rankup_with_different_ranks(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
            Account(
                account_handle = "@baz",
                guild_rank = "rank2",
                join_date = datetime(2023, 12, 1, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 2, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[0])

    def test_apply_rule_for_higher_ranks(self):
        rankup_rule = RankupRule(rank = "rank2", rankup_after=90)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
            Account(
                account_handle = "@baz",
                guild_rank = "rank2",
                join_date = datetime(2023, 12, 1, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 3, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[1])

    def test_removes_duplicates(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
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
        self.assertEqual(rankup_proposal[0].account_handle, accounts[0].account_handle)
        self.assertEqual(rankup_proposal[0].guild_rank, accounts[0].guild_rank)
        self.assertEqual(rankup_proposal[0].join_date, accounts[0].join_date)

    def test_the_oldest_account_instance_counts_as_a_rankup_proposal(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 1, 10, 0, 0)
            ),
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 3, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[0])

    def test_the_order_of_account_duplicates_does_not_matter(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
            Account(
                account_handle = "@bar",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 10, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 3, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 1)
        self.assertEqual(rankup_proposal[0], accounts[1])

    def test_proposals_are_sorted_alphabetically(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@def",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
            Account(
                account_handle = "@abc",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 10, 10, 0, 0)
            ),
        ]
        reference_date = date(2024, 3, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 2)
        self.assertEqual(rankup_proposal[0], accounts[1])
        self.assertEqual(rankup_proposal[1], accounts[0])

    def test_sorting_is_case_insensitive(self):
        rankup_rule = RankupRule(rank = "rank1", rankup_after=30)
        accounts = [
            Account(
                account_handle = "@DEF",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 20, 10, 0, 0)
            ),
            Account(
                account_handle = "@abc",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 10, 10, 0, 0)
            ),
            Account(
                account_handle = "@doh",
                guild_rank = "rank1",
                join_date = datetime(2024, 1, 10, 10, 0, 0)
            )
        ]
        reference_date = date(2024, 3, 1)

        rankup_tool = RankupProposal()
        rankup_proposal = rankup_tool.create_rankup_proposal_for_accounts(
            rankup_rule, accounts, reference_date)

        self.assertEqual(len(rankup_proposal), 3)
        self.assertEqual(rankup_proposal[0], accounts[1])
        self.assertEqual(rankup_proposal[1], accounts[0])
        self.assertEqual(rankup_proposal[2], accounts[2])
        pass
