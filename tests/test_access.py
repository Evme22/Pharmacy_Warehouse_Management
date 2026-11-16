
import sys
from pathlib import Path
from unittest.mock import Mock

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

import app as pharmacy_app


@pytest.fixture
def client():
    pharmacy_app.app.config.update(
        TESTING=True,
        SECRET_KEY="test-secret-key",
    )
    return pharmacy_app.app.test_client()


def login_as(client, role):
    with client.session_transaction() as session:
        session["user_id"] = 1
        session["username"] = "test_user"
        session["role"] = role


@pytest.mark.parametrize(
    "url",
    ["/", "/procedures", "/analytics", "/table/Warehouse_stock"],
)
def test_anonymous_user_redirected(client, url):
    response = client.get(url)

    assert response.status_code == 302
    assert response.location.endswith("/login")


@pytest.mark.parametrize(
    "role, table",
    [
        ("warehouse_clerk", "Warehouse_employee"),
        ("warehouse_clerk", "Supplier"),
        ("director", "Warehouse_stock"),
        ("db_admin", "users"),
        ("unknown_role", "Medicine"),
    ],
)
def test_forbidden_tables(client, monkeypatch, role, table):
    login_as(client, role)

    fake_connection = Mock()
    connect = Mock(return_value=fake_connection)
    monkeypatch.setattr(pharmacy_app, "get_connection", connect)

    response = client.get(f"/table/{table}")

    assert response.status_code == 403
    connect.assert_not_called()


def test_admin_can_view_allowed_table(client, monkeypatch):
    login_as(client, "db_admin")

    fake_cursor = Mock()
    fake_cursor.description = [("medicine_id",)]
    fake_cursor.fetchall.return_value = [(1,), (2,)]

    fake_connection = Mock()
    fake_connection.cursor.return_value = fake_cursor

    monkeypatch.setattr(
        pharmacy_app,
        "get_connection",
        lambda: fake_connection,
    )

    response = client.get("/table/Medicine")

    assert response.status_code == 200
    assert b"medicine_id" in response.data

    fake_cursor.execute.assert_called_once_with(
        "SELECT * FROM `Medicine`"
    )
    fake_cursor.close.assert_called_once()
    fake_connection.close.assert_called_once()


@pytest.mark.parametrize("url", ["/procedures", "/analytics"])
def test_unknown_role_denied(client, url):
    login_as(client, "unknown_role")

    response = client.get(url)

    assert response.status_code == 403
