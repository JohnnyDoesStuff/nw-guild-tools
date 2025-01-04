import argparse
from datetime import date
import os
from PythonTools.NwAccount.AccountReader import AccountReader
from PythonTools.Purge.PurgeProposal import PurgeProposal


class PurgeProposalCreator:
    def __init__(self):
        self.args = self.parse_args()
        self.purge_tool = PurgeProposal()

    def parse_args(self):
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

    def create_proposal_for_single_rule(self, rule, accounts):
        accountsToPurge = self.purge_tool.create_purge_proposal(
            rule,
            accounts,
            date.today()
        )
        return accountsToPurge

    def create_proposal(self):
        self.check_args()
        rules = self.purge_tool.read_rules(self.args.rule_path)
        account_reader = AccountReader()
        accounts = account_reader.read_accounts(self.args.member_path)

        all_accounts_to_purge = []
        for rule in rules:
            accounts_to_purge = self.create_proposal_for_single_rule(rule, accounts)
            all_accounts_to_purge.extend(accounts_to_purge)

        all_accounts_to_purge.sort(key=lambda x: x.account_handle.lower())

        print('==========================')
        print('=== Proposal for purge ===')
        print('==========================')

        for account in all_accounts_to_purge:
            print(f" - {account.account_handle}")

def main():
    proposal_creator = PurgeProposalCreator()
    proposal_creator.create_proposal()

if __name__ == '__main__':
    main()
