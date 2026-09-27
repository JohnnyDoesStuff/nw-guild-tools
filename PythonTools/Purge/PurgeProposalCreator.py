from datetime import date
import os
from PythonTools.NwAccount.AccountReader import AccountReader
from PythonTools.Purge.PurgeRuleHandler import PurgeRuleHandler

class PurgeProposalCreator:
    def __init__(self, member_path=None, rule_path=None, ban_list=None):
        self.member_path = member_path
        self.rule_path = rule_path
        self.ban_list = ban_list

        self.purge_tool = PurgeRuleHandler()

    def check_args(self):
        if self.rule_path is None:
            print('No rule path provided')
            exit(1)

        if self.member_path is None:
            print('No member path provided')
            exit(1)

        if not os.path.isfile(self.rule_path):
            print(f"Rule path '{self.rule_path}' does not exist")
            exit(1)

        if not os.path.isfile(self.member_path):
            print(f"Member path '{self.member_path}' does not exist")
            exit(1)

        if self.ban_list and not os.path.isfile(self.ban_list):
            print(f"Ban list '{self.ban_list}' does not exist")
            exit(1)

    def create_proposal_for_single_rule(self, rule, accounts):
        accountsToPurge = self.purge_tool.create_purge_proposal(
            rule,
            accounts,
            date.today()
        )
        return accountsToPurge

    def create_banned_account_report(self, banned_accounts, accounts):
        if not banned_accounts:
            return

        found_banned_accounts = self.purge_tool.get_banned_accounts(accounts, banned_accounts)

        print('================================')
        print('=== Banned accounts in guild ===')
        print('================================')
        if found_banned_accounts:

            for account in found_banned_accounts:
                print(f" - {account.account_handle}")
        else:
            print('No banned accounts found')


    def create_proposal(self):
        self.check_args()
        rules = self.purge_tool.read_rules(self.rule_path)
        account_reader = AccountReader()
        accounts = account_reader.read_accounts(self.member_path)
        banned_accounts = self.purge_tool.read_banned_accounts(self.ban_list)

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

        self.create_banned_account_report(banned_accounts, accounts)
