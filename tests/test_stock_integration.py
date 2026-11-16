
import os
import sys
from pathlib import Path

import pytest
from mysql.connector import Error

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from db import get_connection


pytestmark = pytest.mark.skipif(
    os.getenv("RUN_DB_TESTS") != "1",
    reason="Integration tests require explicit RUN_DB_TESTS=1",
)


@pytest.fixture
def db():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
    ):
        pytest.skip("Tests are restricted to local MySQL on port 3307")

    connection = get_connection()
    connection.autocommit = False
    cursor = connection.cursor()

    try:
        yield connection, cursor
    finally:
        connection.rollback()
        cursor.close()
        connection.close()


def get_stock(cursor, warehouse_id, medicine_id):
    cursor.execute(
        """
        SELECT quantity
        FROM Warehouse_stock
        WHERE warehouse_id = %s AND medicine_id = %s
        """,
        (warehouse_id, medicine_id),
    )
    row = cursor.fetchone()
    return row[0] if row else None


def test_incoming_increases_existing_stock(db):
    connection, cursor = db

    before = get_stock(cursor, 1, 3)
    assert before is not None

    cursor.execute(
        """
        INSERT INTO Supply_warehouse_items
        (supply_id, medicine_id, quantity)
        VALUES (1, 3, 40)
        """
    )

    assert get_stock(cursor, 1, 3) == before + 40

    connection.rollback()
    assert get_stock(cursor, 1, 3) == before


def test_incoming_creates_new_stock_row(db):
    connection, cursor = db

    assert get_stock(cursor, 1, 9) is None

    cursor.execute(
        """
        INSERT INTO Supply_warehouse_items
        (supply_id, medicine_id, quantity)
        VALUES (1, 9, 20)
        """
    )

    assert get_stock(cursor, 1, 9) == 20

    connection.rollback()
    assert get_stock(cursor, 1, 9) is None


def test_outgoing_decreases_stock(db):
    connection, cursor = db

    before = get_stock(cursor, 1, 1)
    assert before is not None and before >= 40

    cursor.execute(
        """
        INSERT INTO Supply_pharmacy_items
        (id_supply, medicine_id, quantity)
        VALUES (1, 1, 40)
        """
    )

    assert get_stock(cursor, 1, 1) == before - 40

    connection.rollback()
    assert get_stock(cursor, 1, 1) == before


def test_cannot_ship_more_than_available(db):
    _, cursor = db

    before = get_stock(cursor, 1, 1)
    assert before is not None

    with pytest.raises(Error) as error:
        cursor.execute(
            """
            INSERT INTO Supply_pharmacy_items
            (id_supply, medicine_id, quantity)
            VALUES (1, 1, %s)
            """,
            (before + 1,),
        )

    assert error.value.sqlstate == "45000"
    assert get_stock(cursor, 1, 1) == before


@pytest.mark.parametrize("amount", [0, -5])
def test_incoming_rejects_invalid_quantity(db, amount):
    _, cursor = db

    before = get_stock(cursor, 1, 3)

    with pytest.raises(Error) as error:
        cursor.execute(
            """
            INSERT INTO Supply_warehouse_items
            (supply_id, medicine_id, quantity)
            VALUES (1, 3, %s)
            """,
            (amount,),
        )

    assert error.value.sqlstate == "45000"
    assert get_stock(cursor, 1, 3) == before


@pytest.mark.parametrize("amount", [0, -5])
def test_outgoing_rejects_invalid_quantity(db, amount):
    _, cursor = db

    before = get_stock(cursor, 1, 1)

    with pytest.raises(Error) as error:
        cursor.execute(
            """
            INSERT INTO Supply_pharmacy_items
            (id_supply, medicine_id, quantity)
            VALUES (1, 1, %s)
            """,
            (amount,),
        )

    assert error.value.sqlstate == "45000"
    assert get_stock(cursor, 1, 1) == before
