class PurgeRule:

    rank: str
    purge_after: int

    def __init__(self, rank: str, purge_after: int):
        self.rank = rank
        self.purge_after = purge_after

    def __str__(self):
        return f"Purge members of rank {self.rank} after {self.purge_after} days of inactivity"
