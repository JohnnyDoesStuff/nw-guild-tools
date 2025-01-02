import os
import unittest

from PythonTools.Purge.PurgeProposal import PurgeProposal

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
