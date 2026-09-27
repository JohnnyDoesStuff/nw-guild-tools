from datetime import date
import os
import unittest
from unittest import mock
from PythonTools.Purge.PurgeProposalCreator import PurgeProposalCreator

class TestPurgeProposalCreator(unittest.TestCase):

    def setUp(self):
        self.current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )

    def test_can_setup_blank_creator(self):
        creator = PurgeProposalCreator()
        self.assertIsNotNone(creator)

    @mock.patch('PythonTools.Purge.PurgeProposalCreator.date', side_effect=lambda *args, **kw: date(*args, **kw))
    def test_can_create_a_purge_proposal(self, mock_date):
        mocked_today = date(2024, 7, 1)
        mock_date.today.return_value = mocked_today

        members_path = os.path.join(
            self.current_directory,
            "testdata/integrationtestAccountsGerman.csv"
        )
        rules_path = os.path.join(
            self.current_directory,
            "testdata/integrationtestPurgeRules.csv"
        )
        creator = PurgeProposalCreator(
            member_path=members_path,
            rule_path=rules_path
        )

        creator.create_proposal()

        # todo: make the console output testable

    @mock.patch('PythonTools.Purge.PurgeProposalCreator.date', side_effect=lambda *args, **kw: date(*args, **kw))
    def test_can_create_a_purge_proposal_with_bans(self, mock_date):
        mocked_today = date(2024, 7, 1)
        mock_date.today.return_value = mocked_today

        members_path = os.path.join(
            self.current_directory,
            "testdata/integrationtestAccountsGerman.csv"
        )
        rules_path = os.path.join(
            self.current_directory,
            "testdata/integrationtestPurgeRules.csv"
        )
        ban_path = os.path.join(
            self.current_directory,
            "testdata/integrationtestBannedAccounts.txt"
        )
        creator = PurgeProposalCreator(
            member_path=members_path,
            rule_path=rules_path,
            ban_list=ban_path
        )

        creator.create_proposal()

        # todo: make the console output testable
