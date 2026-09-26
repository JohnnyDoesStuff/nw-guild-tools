import argparse
from PythonTools.Purge.PurgeProposalCreator import PurgeProposalCreator

def parse_args() -> PurgeProposalCreator:
    parser = argparse.ArgumentParser(
        description='Create a proposal of inactive members to kick'
    )
    parser.add_argument(
        '-m', '--member_path',
        help= 'Path to a well-formed csv file with member data'
    )
    parser.add_argument(
        '-r', '--rule_path',
        help= 'Path to a csv file with rules that you have defined'
    )
    parser.add_argument(
        '-b', '--ban_list',
        help= 'Path to a text file with banned accounts where each account is in a separate line'
    )

    args = parser.parse_args()

    return PurgeProposalCreator(
        args.member_path,
        args.rule_path,
        args.ban_list
    )


def main():
    proposal_creator = parse_args()
    proposal_creator.create_proposal()

if __name__ == '__main__':
    main()
