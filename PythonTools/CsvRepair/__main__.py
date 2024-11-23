import argparse
from .RepairCsv import RepairCsv

class CsvRepairWrapper:

    def __init__(self):
        self.repair_tool = RepairCsv()
        self.args = self.parse_args()

    def parse_args(self):
        parser = argparse.ArgumentParser(
            description='Repair a csv file (Only applicable for german exports right now)'
        )
        parser.add_argument(
            '-s', '--source_path',
            help= 'Path to an ill-formed csv file'
        )
        parser.add_argument(
            '-t', '--target_path',
            help= 'Path where this tool shall write the fixed file'
        )

        args = parser.parse_args()

        return args

    def repair_file(self):
        self.repair_tool.repair_csv(
            self.args.source_path,
            self.args.target_path
        )

def main():
    repair_tool = CsvRepairWrapper()
    repair_tool.repair_file()

if __name__ == '__main__':
    main()
