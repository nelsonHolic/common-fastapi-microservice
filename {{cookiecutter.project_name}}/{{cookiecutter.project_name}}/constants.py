import os
from typing import Final

ALLOW_ORIGINS: Final[str] = os.environ.get("ALLOW_ORIGINS", ["*"])
