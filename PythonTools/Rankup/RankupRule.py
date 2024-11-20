class RankupRule:

    rank: str
    rankup_after: int

    def __init__(self, rank: str, rankup_after: int):
        self.rank = rank
        self.rankup_after = rankup_after

    def __str__(self):
        return f"Promote rank {self.rank} after {self.rankup_after} days"
