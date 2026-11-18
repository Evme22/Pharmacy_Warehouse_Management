import os
import sys
from collections import Counter
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "app"))

from db import get_connection


@pytest.mark.skipif(
    os.getenv("RUN_DB_TESTS") != "1",
    reason="Requires RUN_DB_TESTS=1",
)
def test_top10_matches_source_data():
    if (
        os.getenv("DB_HOST") != "127.0.0.1"
        or os.getenv("DB_PORT") != "3307"
        or os.getenv("DB_NAME") != "Pharmacy_Warehouse"
    ):
        pytest.skip("Only local test MySQL is allowed")

    conn = get_connection()

    try:
        cursor = conn.cursor()

        try:
            cursor.execute(
                "CALL Get_Top10_Medicines_By_Pharmacy_Supply()"
            )

            columns = [col[0] for col in cursor.description]
            actual = cursor.fetchall()

            while cursor.nextset():
                if cursor.with_rows:
                    cursor.fetchall()

            # Независимо считаем количество по каждому препарату.
            cursor.execute(
                "SELECT medicine_id, quantity "
                "FROM Supply_pharmacy_items"
            )

            totals = Counter()
            for medicine_id, quantity in cursor.fetchall():
                totals[medicine_id] += quantity

            cursor.execute(
                "SELECT medicine_id, medicine_name, selling_price "
                "FROM Medicine"
            )

            medicines = {
                medicine_id: (name, price)
                for medicine_id, name, price in cursor.fetchall()
            }

            expected = [
                (medicines[mid][0], medicines[mid][1], quantity)
                for mid, quantity in totals.items()
            ]

            expected.sort(key=lambda row: (-row[2], row[0]))
            expected = expected[:10]

            assert columns == [
                "medicine_name",
                "current_selling_price",
                "total_supplied",
            ]
            assert len(actual) == 10
            assert actual == expected

        finally:
            cursor.close()

    finally:
        conn.close()
