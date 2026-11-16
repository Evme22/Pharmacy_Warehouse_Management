
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
    reason="Requires explicit RUN_DB_TESTS=1",
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


def test_cannot_ship_nonexistent_medicine(db):
    db.execute("SELECT COUNT(*) FROM Supply_pharmacy_items")
    before = db.fetchone()[0]

    with pytest.raises(Error) as error:
        db.execute(
            """
            INSERT INTO Supply_pharmacy_items
                (id_supply, medicine_id, quantity)
            VALUES (%s, %s, %s)
            """,
            (1, 9999, 10),
        )

    assert error.value.errno == 1452

    db.execute("SELECT COUNT(*) FROM Supply_pharmacy_items")
    assert db.fetchone()[0] == before


def test_cannot_delete_referenced_medicine(db):
    with pytest.raises(Error) as error:
        db.execute(
            "DELETE FROM Medicine WHERE medicine_id = %s",
            (1,),
        )

    assert error.value.errno == 1451

    db.execute(
        "SELECT COUNT(*) FROM Medicine WHERE medicine_id = %s",
        (1,),
    )
    assert db.fetchone()[0] == 1
