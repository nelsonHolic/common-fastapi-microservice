from {{cookiecutter.project_name}}.routes.routers import ping

from fastapi_versioning import version  # type: ignore


@ping.get("")
@ping.post("")
@ping.put("")
@ping.delete("")
@version(1)
def ping_endpoint() -> str:
    return "Ping was received, hi from the IDS"
