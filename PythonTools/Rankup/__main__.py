import argparse
import os

from .RankupProposal import RankupProposal


class RankupProposalCreator:
    def __init__(self):
        self.args = self.parse_args()

    def parse_args(self) -> argparse.Namespace:
        parser = argparse.ArgumentParser(
            description='Create a rankup proposal for a given memberlist'
        )
        parser.add_argument(
            '-m', '--member_path',
            help= 'Path to a well-formed csv file with member data'
        )
        parser.add_argument(
            '-r', '--rule_path',
            help= 'Path to a csv file with rules that you have defined'
        )

        args = parser.parse_args()

        return args

    def check_args(self):
        if self.args.rule_path is None:
            print('No rule path provided')
            exit(1)

        if self.args.member_path is None:
            print('No member path provided')
            exit(1)

        if not os.path.isfile(self.args.rule_path):
            print(f"Rule path '{self.args.rule_path}' does not exist")
            exit(1)

        if not os.path.isfile(self.args.member_path):
            print(f"Member path '{self.args.member_path}' does not exist")
            exit(1)

    def create_proposal(self):
        self.check_args()

        print(self.args.rule_path)
        print(self.args.member_path)

        print('not implemented yet')

def main():
    proposal_creator = RankupProposalCreator()
    proposal_creator.create_proposal()

if __name__ == '__main__':
    main()
