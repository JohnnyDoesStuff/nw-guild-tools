import os
import tempfile
import unittest

import pandas as pd

from PythonTools.CsvRepair.RepairCsv import RepairCsv

class TestRepairCsv(unittest.TestCase):

    def test_repair_german_exported_csv(self):
        file_path = "testdata/accountsGermanExport.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        source_path = os.path.join(current_directory, file_path)
        repair_tool = RepairCsv()

        with tempfile.TemporaryDirectory() as temp_dir:
            fix_file_path = os.path.join(temp_dir, 'fixes.csv')
            repair_tool.repair_csv(source_path, fix_file_path)

            fixed_data = pd.read_csv(fix_file_path)

            self.assertEqual(len(fixed_data), 2)
            self.assertEqual(fixed_data['Account Handle'][0], '@bar')
            self.assertEqual(fixed_data['Guild Rank'][0], 'FakeRank1')
            self.assertEqual(fixed_data['Join Date'][0], '1.1.2024, 10:00:00')
            self.assertEqual(fixed_data['Account Handle'][1], '@baz')
            self.assertEqual(fixed_data['Guild Rank'][1], 'FakeRank2')
            self.assertEqual(fixed_data['Join Date'][1], '2.1.2024, 10:00:00')
