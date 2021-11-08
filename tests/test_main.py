from fastapi.testclient import TestClient


def test_that_tests_work():
    assert True


def test_ping(app_client: TestClient):
    response = app_client.get("/api_v1/ping")
    assert response.status_code == 200
    assert response.json() == "Ping was received, hi from the IDS"
