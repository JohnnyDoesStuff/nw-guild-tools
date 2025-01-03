from datetime import datetime
import os
import unittest

from PythonTools.NwAccount.Account import Account
from PythonTools.Purge.PurgeProposal import PurgeProposal
from PythonTools.Purge.PurgeRule import PurgeRule

class PurgeProposalTest(unittest.TestCase):

    def test_can_read_rules(self):
        file_path = "testdata/testPurgeRules.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        full_path = os.path.join(current_directory, file_path)
        purge_tool = PurgeProposal()

        rules = purge_tool.read_rules(full_path)

        self.assertEqual(len(rules), 3)
        self.assertEqual(rules[0].rank, 'Rank1')
        self.assertEqual(rules[0].purge_after, 30)
        self.assertEqual(rules[1].rank, 'Rank2')
        self.assertEqual(rules[1].purge_after, 60)
        self.assertEqual(rules[2].rank, 'Rank3')
        self.assertEqual(rules[2].purge_after, 90)

    def test_can_create_a_purge_proposal(self):
        purge_rule = PurgeRule('Rank1', 30)
        accounts = [
            Account(
                '@bar',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            )
        ]
        reference_date = datetime(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 1)
        self.assertEqual(purge_proposal[0], accounts[0])

    def test_purge_proposal_only_contains_inactive_accounts(self):
        purge_rule = PurgeRule('Rank1', 30)
        accounts = [
            Account(
                '@bar',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            ),
            Account(
                '@foo',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 3, 31, 12, 0, 0)
            )
        ]
        reference_date = datetime(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 1)
        self.assertEqual(purge_proposal[0], accounts[0])

    def test_purge_proposal_only_contains_accounts_of_the_right_rank(self):
        purge_rule = PurgeRule('Rank1', 30)
        accounts = [
            Account(
                '@bar',
                'Rank2',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            ),
            Account(
                '@foo',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            )
        ]
        reference_date = datetime(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 1)
        self.assertEqual(purge_proposal[0], accounts[1])

    def test_purge_proposal_can_be_empty(self):
        purge_rule = PurgeRule('Rank1', 30)
        accounts = [
            Account(
                '@bar',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 3, 31, 12, 0, 0)
            )
        ]
        reference_date = datetime(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 0)

    def test_purge_prososal_can_contain_multiple_accounts(self):
        purge_rule = PurgeRule('Rank1', 30)
        accounts = [
            Account(
                '@bar',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            ),
            Account(
                '@foo',
                'Rank1',
                datetime(2024, 1, 1, 10, 0, 0),
                last_active_date = datetime(2024, 1, 31, 12, 0, 0)
            )
        ]
        reference_date = datetime(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 2)
        self.assertTrue(accounts[0] in purge_proposal)
        self.assertTrue(accounts[1] in purge_proposal)
