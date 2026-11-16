
import os
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from db import get_connection


pytestmark = pytest.mark.skipif(
    os.getenv("RUN_DB_TESTS") != "1",
    reason="Integration tests require RUN_DB_TESTS=1",
)


@pytest.fixture
def db():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
        or os.getenv("DB_NAME") != "Pharmacy_Warehouse"
    ):
        pytest.skip("Only local test MySQL is allowed")

    connection = get_connection()
    cursor = connection.cursor()

    try:
        yield cursor
    finally:
        cursor.close()
        connection.close()


def get_report(cursor, start_date, end_date):
    cursor.execute(
        "CALL Get_Low_Supply_Medicines_By_Period(%s, %s)",
        (start_date, end_date),
    )

    columns = [column[0] for column in cursor.description]
    rows = cursor.fetchall()

    while cursor.nextset():
        if cursor.with_rows:
            cursor.fetchall()

    return columns, rows


def test_january_report(db):
    columns, rows = get_report(
        db, "2024-01-01", "2024-01-31"
    )

    assert columns == ["medicine_name", "total_supplied"]
    assert len(rows) == 24

    medicines = dict(rows)

    assert medicines["Парацетамол"] == 300
    assert medicines["Амоксиклав"] == 400


def test_month_without_shipments(db):
    _, rows = get_report(
        db, "2024-05-01", "2024-05-31"
    )

    assert len(rows) == 24
    assert all(quantity == 0 for _, quantity in rows)


def test_single_day_report(db):
    _, rows = get_report(
        db, "2024-01-18", "2024-01-18"
    )

    medicines = dict(rows)

    assert len(rows) == 24
    assert medicines["Амоксиклав"] == 200
    assert medicines["Ибупрофен"] == 300
    assert medicines["Цетрин"] == 150
    assert sum(medicines.values()) == 650


def test_invalid_date_range(db):
    columns, rows = get_report(
        db, "2024-05-31", "2024-05-01"
    )

    assert columns == ["error_message"]
    assert len(rows) == 1
    assert "некорректный период" in rows[0][0]
