import os
import tempfile
import unittest

import numpy as np
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

    def test_repair_also_fixes_other_dates(self):
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

            self.assertEqual(fixed_data['Rank Change Date'][0], '2.1.2024, 11:00:00')
            self.assertEqual(fixed_data['Last Active Date'][0], '3.1.2024, 12:00:00')
            self.assertEqual(fixed_data['Rank Change Date'][1], '2.1.2024, 11:00:00')
            self.assertEqual(fixed_data['Last Active Date'][1], '3.1.2024, 12:00:00')

    def test_repair_fixes_date_as_last_value(self):
        file_path = "testdata/accountsDateAsLastValue.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        source_path = os.path.join(current_directory, file_path)
        repair_tool = RepairCsv()

        with tempfile.TemporaryDirectory() as temp_dir:
            fix_file_path = os.path.join(temp_dir, 'fixes.csv')
            repair_tool.repair_csv(source_path, fix_file_path)

            fixed_data = pd.read_csv(fix_file_path)

            self.assertEqual(fixed_data['Rank Change Date'][0], '2.1.2024, 11:00:00')
            self.assertEqual(fixed_data['Last Active Date'][0], '3.1.2024, 12:00:00')
            self.assertEqual(fixed_data['Public Comment Last Edit Date'][0], '2.1.2024, 11:30:00')
            self.assertEqual(fixed_data['Rank Change Date'][1], '2.1.2024, 11:00:00')
            self.assertEqual(fixed_data['Last Active Date'][1], '3.1.2024, 12:00:00')

    def test_repair_removes_comments(self):
        file_path = "testdata/accountsWithQuoteComments.csv"
        current_directory = os.path.dirname(
            os.path.abspath(__file__)
        )
        source_path = os.path.join(current_directory, file_path)
        repair_tool = RepairCsv()

        with tempfile.TemporaryDirectory() as temp_dir:
            fix_file_path = os.path.join(temp_dir, 'fixes.csv')
            repair_tool.repair_csv(source_path, fix_file_path)

            fixed_data = pd.read_csv(fix_file_path)

            self.assertEqual(2, len(fixed_data))
            self.assertTrue(pd.isna(fixed_data['Public Comment'][0]))
