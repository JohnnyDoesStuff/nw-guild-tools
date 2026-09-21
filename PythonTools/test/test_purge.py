from datetime import date, datetime
import os
import unittest
from parameterized import parameterized

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
        reference_date = date(2024, 4, 1)

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
        reference_date = date(2024, 4, 1)

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
        reference_date = date(2024, 4, 1)

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
        reference_date = date(2024, 4, 1)

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
        reference_date = date(2024, 4, 1)

        purge_tool = PurgeProposal()

        purge_proposal = purge_tool.create_purge_proposal(
            purge_rule,
            accounts,
            reference_date
        )

        self.assertEqual(len(purge_proposal), 2)
        self.assertTrue(accounts[0] in purge_proposal)
        self.assertTrue(accounts[1] in purge_proposal)

    def test_read_banned_accounts_if_none_provided(self):
        purge_tool = PurgeProposal()
        self.assertEqual(purge_tool.read_banned_accounts(None), [])

    def test_read_banned_accounts_if_empty_string_provided(self):
        purge_tool = PurgeProposal()
        self.assertEqual(purge_tool.read_banned_accounts(""), [])

    @parameterized.expand([
        ('testdata/bannedAccountsEmpty.txt', []),
        ('testdata/bannedAccountsSingle.txt', ['banned#001']),
        ('testdata/bannedAccounts.txt', ['banned#001', 'banned#002', 'banned#007']),
    ])
    def test_read_banned_accounts(self, file_path, expected_output):
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        full_path = os.path.join(current_directory, file_path)
        purge_tool = PurgeProposal()
        result = purge_tool.read_banned_accounts(full_path)
        self.assertEqual(result, expected_output)

    def test_can_identify_a_banned_account(self):
        purge_tool = PurgeProposal()
        all_accounts = [
            Account('@foo', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@bar', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@banned#001', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),]
        banned_accounts = ['@banned#001']
        result = purge_tool.get_banned_accounts(all_accounts, banned_accounts)
        self.assertEqual(result, [all_accounts[2]])

    def test_can_identify_account_if_at_character_is_missing(self):
        purge_tool = PurgeProposal()
        all_accounts = [
            Account('@foo', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@bar', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@banned#001', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),]
        banned_accounts = ['banned#001']
        result = purge_tool.get_banned_accounts(all_accounts, banned_accounts)
        self.assertEqual(result, [all_accounts[2]])

    def test_returns_empty_if_no_banned_accounts_exist(self):
        purge_tool = PurgeProposal()
        all_accounts = [
            Account('@foo', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@bar', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),]
        banned_accounts = ['banned#001']
        result = purge_tool.get_banned_accounts(all_accounts, banned_accounts)
        self.assertEqual(result, [])

    def test_also_works_if_no_account_is_banned(self):
        purge_tool = PurgeProposal()
        all_accounts = [
            Account('@foo', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@bar', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),]
        banned_accounts = []
        result = purge_tool.get_banned_accounts(all_accounts, banned_accounts)
        self.assertEqual(result, [])

    def test_can_identify_multiple_banned_accounts(self):
        purge_tool = PurgeProposal()
        all_accounts = [
            Account('@foo', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@bar', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@banned#001', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@banned#002', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),
            Account('@banned#007', 'Rank1', datetime(2024, 1, 1, 10, 0, 0), last_active_date = datetime(2024, 1, 31, 12, 0, 0)),]
        banned_accounts = ['banned#001', 'banned#002', 'banned#007']
        result = purge_tool.get_banned_accounts(all_accounts, banned_accounts)
        self.assertEqual(result, [all_accounts[2], all_accounts[3], all_accounts[4]])
