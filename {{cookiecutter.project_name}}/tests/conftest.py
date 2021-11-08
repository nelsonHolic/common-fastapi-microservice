import pytest
from fastapi.testclient import TestClient

from {{cookiecutter.project_name}}.app import app


@pytest.fixture()
def app_client() -> TestClient:
    client = TestClient(app)
    return client
