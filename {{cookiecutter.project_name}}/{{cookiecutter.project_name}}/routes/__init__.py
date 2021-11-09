from {{cookiecutter.project_name}}.routes.ping.ping import ping_endpoint
from {{cookiecutter.project_name}}.routes.auth.auth_routes import login_for_access_token

__all__ = ["ping_endpoint", "login_for_access_token"]
