
import os
import sys
from decimal import Decimal
from pathlib import Path

import pytest
from mysql.connector import Error

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from db import get_connection


pytestmark = pytest.mark.skipif(
    os.getenv("RUN_DB_TESTS") != "1",
    reason="Integration tests require RUN_DB_TESTS=1",
)


@pytest.fixture
def shipment():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
        or os.getenv("DB_NAME") != "Pharmacy_Warehouse"
    ):
        pytest.skip("Only local test MySQL is allowed")

    connection = get_connection()
    connection.autocommit = False
    cursor = connection.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO Supply_to_pharmacy
                (pharmacy_id, supply_date, employee_id)
            VALUES (1, CURRENT_DATE(), 1)
            """
        )

        supply_id = cursor.lastrowid
        yield cursor, supply_id

    finally:
        connection.rollback()
        cursor.close()
        connection.close()


def add_item(cursor, supply_id, medicine_id, quantity):
    cursor.execute(
        """
        INSERT INTO Supply_pharmacy_items
            (id_supply, medicine_id, quantity)
        VALUES (%s, %s, %s)
        """,
        (supply_id, medicine_id, quantity),
    )


def test_supply_below_minimum_is_rejected(shipment):
    cursor, supply_id = shipment

    # 5 * 40 = 200 рублей
    add_item(cursor, supply_id, medicine_id=1, quantity=5)

    with pytest.raises(Error) as error:
        cursor.execute(
            "CALL Validate_Pharmacy_Supply_Min_Value(%s)",
            (supply_id,),
        )

    assert error.value.sqlstate == "45000"


def test_supply_above_minimum_is_accepted(shipment):
    cursor, supply_id = shipment

    # Парацетамол: 5 * 40 = 200 рублей
    add_item(cursor, supply_id, medicine_id=1, quantity=5)

    # Но-шпа: 4 * 256 = 1024 рубля
    add_item(cursor, supply_id, medicine_id=2, quantity=4)

    # Итого: 1224 рубля
    cursor.execute(
        "CALL Validate_Pharmacy_Supply_Min_Value(%s)",
        (supply_id,),
    )

    rows = cursor.fetchall()

    assert len(rows) == 1
    assert rows[0][0] == supply_id
    assert rows[0][1] == Decimal("1224.00")

    while cursor.nextset():
        if cursor.with_rows:
            cursor.fetchall()
