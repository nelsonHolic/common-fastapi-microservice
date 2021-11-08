import os
from typing import Optional


class Config:

    def __init__(self):
        pass

    def __getattr__(self, name) -> Optional[str]:
        return os.environ.get("name")


config = Config()
