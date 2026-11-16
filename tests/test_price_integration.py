
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
def db():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
    ):
        pytest.skip("Only local test MySQL is allowed")

    connection = get_connection()
    connection.autocommit = False
    cursor = connection.cursor()

    try:
        yield cursor
    finally:
        connection.rollback()
        cursor.close()
        connection.close()


@pytest.mark.parametrize(
    "purchase_price, selling_price",
    [
        (0, 50),
        (-10, 50),
        (20, 0),
        (20, -10),
    ],
)
def test_insert_rejects_invalid_prices(
    db, purchase_price, selling_price
):
    with pytest.raises(Error) as error:
        db.execute(
            """
            INSERT INTO Medicine (
                medicine_name,
                manufacturer_id,
                purpose,
                group_id,
                unit,
                purchase_price,
                selling_price
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                "Тестовый препарат",
                1,
                "Тест",
                1,
                "таблетки",
                purchase_price,
                selling_price,
            ),
        )

    assert error.value.sqlstate == "45000"


@pytest.mark.parametrize(
    "purchase_price, selling_price",
    [
        (0, 50),
        (-10, 50),
        (20, 0),
        (20, -10),
    ],
)
def test_update_rejects_invalid_prices(
    db, purchase_price, selling_price
):
    db.execute(
        """
        SELECT purchase_price, selling_price
        FROM Medicine
        WHERE medicine_id = 1
        """
    )
    before = db.fetchone()

    with pytest.raises(Error) as error:
        db.execute(
            """
            UPDATE Medicine
            SET purchase_price = %s,
                selling_price = %s
            WHERE medicine_id = 1
            """,
            (purchase_price, selling_price),
        )

    assert error.value.sqlstate == "45000"

    db.execute(
        """
        SELECT purchase_price, selling_price
        FROM Medicine
        WHERE medicine_id = 1
        """
    )
    assert db.fetchone() == before


def test_insert_accepts_valid_prices(db):
    db.execute(
        """
        INSERT INTO Medicine (
            medicine_name,
            manufacturer_id,
            purpose,
            group_id,
            unit,
            purchase_price,
            selling_price
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        (
            "Тестовый препарат",
            1,
            "Тест",
            1,
            "таблетки",
            25.50,
            40.00,
        ),
    )

    medicine_id = db.lastrowid

    db.execute(
        """
        SELECT purchase_price, selling_price
        FROM Medicine
        WHERE medicine_id = %s
        """,
        (medicine_id,),
    )

    assert db.fetchone() == (
        Decimal("25.50"),
        Decimal("40.00"),
    )


def test_update_accepts_valid_prices(db):
    db.execute(
        """
        UPDATE Medicine
        SET purchase_price = %s,
            selling_price = %s
        WHERE medicine_id = 1
        """,
        (20.00, 55.00),
    )

    db.execute(
        """
        SELECT purchase_price, selling_price
        FROM Medicine
        WHERE medicine_id = 1
        """
    )

    assert db.fetchone() == (
        Decimal("20.00"),
        Decimal("55.00"),
    )
