import pandas as pd
from PythonTools.Purge.PurgeRule import PurgeRule

class PurgeProposal:

    def __init__(self):
        print("Purge init")

    def read_rules(self, path: str):
        print(f"Reading rules from {path}")
        raw_rule_data = pd.read_csv(path)

        rules = []
        for _, row in raw_rule_data.iterrows():
            rule = PurgeRule(
                row['Rank'],
                row['PurgeAfter']
            )
            rules.append(rule)
        return rules
