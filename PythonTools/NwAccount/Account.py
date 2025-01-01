from datetime import datetime

class Account:
    account_handle: str
    guild_rank: str
    join_date: datetime

    def __init__(self, account_handle: str,
                 guild_rank: str,
                 join_date: datetime):
        self.account_handle = account_handle
        self.guild_rank = guild_rank
        self.join_date = join_date

    def __str__(self):
        return f"{self.account_handle}, Rank {self.guild_rank}, joined on {self.join_date}"
