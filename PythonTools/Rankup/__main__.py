import argparse

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

    def create_proposal(self):
        print(self.args.rule_path)
        print(self.args.member_path)

        print('not implemented yet')

def main():
    proposal_creator = RankupProposalCreator()
    proposal_creator.create_proposal()

if __name__ == '__main__':
    main()
