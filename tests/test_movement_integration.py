
import os
import sys
from datetime import date
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from db import get_connection


pytestmark = pytest.mark.skipif(
    os.getenv("RUN_DB_TESTS") != "1",
    reason="Integration tests require RUN_DB_TESTS=1",
)


def test_identical_movements_are_preserved():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
        or os.getenv("DB_NAME") != "Pharmacy_Warehouse"
    ):
        pytest.skip("Only local test MySQL is allowed")

    conn = get_connection()
    conn.autocommit = False
    cursor = conn.cursor()

    try:
        test_date = date(2025, 6, 15)

        # Убеждаемся, что за тестовую дату
        # ещё нет поступлений и отгрузок.
        cursor.execute(
            """
            SELECT COUNT(*)
            FROM Supply_to_warehouse
            WHERE supply_date = %s
            """,
            (test_date,),
        )
        assert cursor.fetchone()[0] == 0

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM Supply_to_pharmacy
            WHERE supply_date = %s
            """,
            (test_date,),
        )
        assert cursor.fetchone()[0] == 0

        cursor.execute(
            "SELECT medicine_name FROM Medicine WHERE medicine_id = 1"
        )
        medicine_name = cursor.fetchone()[0]

        # Два разных документа с одинаковыми операциями.
        for _ in range(2):
            cursor.execute(
                """
                INSERT INTO Supply_to_warehouse
                    (supplier_id, supply_date, employee_id)
                VALUES (1, %s, 1)
                """,
                (test_date,),
            )

            supply_id = cursor.lastrowid

            cursor.execute(
                """
                INSERT INTO Supply_warehouse_items
                    (supply_id, medicine_id, quantity)
                VALUES (%s, 1, 7)
                """,
                (supply_id,),
            )

        # Проверяем журнал движения.
        cursor.execute(
            "CALL Get_Medicine_Movement_By_Period(%s, %s)",
            (test_date, test_date),
        )

        movements = cursor.fetchall()

        while cursor.nextset():
            if cursor.with_rows:
                cursor.fetchall()

        expected = (
            medicine_name,
            7,
            test_date,
            "Поступление на склад",
        )

        assert len(movements) == 2
        assert movements.count(expected) == 2

    finally:
        # Отменяем обе поставки и изменения остатков.
        conn.rollback()
        cursor.close()
        conn.close()
