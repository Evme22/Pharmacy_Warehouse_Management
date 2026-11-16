
import sys
from pathlib import Path
from unittest.mock import Mock

import pytest
from werkzeug.security import generate_password_hash

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


def mock_database(monkeypatch, user):
    cursor = Mock()
    cursor.fetchone.return_value = user

    connection = Mock()
    connection.cursor.return_value = cursor

    connect = Mock(return_value=connection)
    monkeypatch.setattr(
        pharmacy_app,
        "get_connection",
        connect,
    )

    return connect, cursor, connection


def test_login_with_correct_password(client, monkeypatch):
    password = "TestPassword123!"
    password_hash = generate_password_hash(
        password,
        method="scrypt",
    )

    connect, cursor, connection = mock_database(
        monkeypatch,
        (1, "db_admin", password_hash),
    )

    response = client.post(
        "/login",
        data={
            "username": "admin",
            "password": password,
        },
    )

    assert response.status_code == 302
    assert response.location.endswith("/")

    with client.session_transaction() as session:
        assert session["user_id"] == 1
        assert session["username"] == "admin"
        assert session["role"] == "db_admin"

    query, parameters = cursor.execute.call_args.args
    assert "password_hash" in query
    assert parameters == ("admin",)

    connect.assert_called_once()
    cursor.close.assert_called_once()
    connection.close.assert_called_once()


def test_login_with_wrong_password(client, monkeypatch):
    password_hash = generate_password_hash(
        "CorrectPassword123!",
        method="scrypt",
    )

    mock_database(
        monkeypatch,
        (1, "db_admin", password_hash),
    )

    response = client.post(
        "/login",
        data={
            "username": "admin",
            "password": "WrongPassword123!",
        },
    )

    assert response.status_code == 200

    with client.session_transaction() as session:
        assert "user_id" not in session


def test_login_with_unknown_user(client, monkeypatch):
    mock_database(monkeypatch, None)

    response = client.post(
        "/login",
        data={
            "username": "unknown",
            "password": "SomePassword123!",
        },
    )

    assert response.status_code == 200

    with client.session_transaction() as session:
        assert "user_id" not in session


def test_login_with_invalid_role(client, monkeypatch):
    password = "TestPassword123!"
    password_hash = generate_password_hash(
        password,
        method="scrypt",
    )

    mock_database(
        monkeypatch,
        (1, "unknown_role", password_hash),
    )

    response = client.post(
        "/login",
        data={
            "username": "user",
            "password": password,
        },
    )

    assert response.status_code == 200

    with client.session_transaction() as session:
        assert "user_id" not in session


def test_login_with_empty_fields(client, monkeypatch):
    connect = Mock()
    monkeypatch.setattr(
        pharmacy_app,
        "get_connection",
        connect,
    )

    response = client.post(
        "/login",
        data={
            "username": "",
            "password": "",
        },
    )

    assert response.status_code == 200
    connect.assert_not_called()
