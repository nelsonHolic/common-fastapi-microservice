import pytest
from fastapi.testclient import TestClient

from microservice.app import app


@pytest.fixture()
def app_client() -> TestClient:
    client = TestClient(app)
    return client
