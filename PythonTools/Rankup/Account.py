class Account:
    account_handle: str
    join_date: str

    def __init__(self, account_handle: str, join_date: str):
        self.account_handle = account_handle
        self.join_date = join_date

    def __str__(self):
        return f"{self.account_handle} joined on {self.join_date}"
