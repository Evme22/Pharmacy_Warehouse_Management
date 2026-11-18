import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

parser = argparse.ArgumentParser(
    description="Initialize a fresh Pharmacy Warehouse demo database"
)
parser.add_argument(
    "--project",
    default="pharmacy-warehouse-polish",
    help="Docker Compose project name",
)
parser.add_argument(
    "--port",
    type=int,
    default=3307,
    help="MySQL host port",
)
args = parser.parse_args()

if not 1 <= args.port <= 65535:
    parser.error("Port must be between 1 and 65535")

env = os.environ.copy()
env["MYSQL_HOST_PORT"] = str(args.port)

compose = [
    "docker", "compose",
    "-p", args.project,
    "-f", "compose.dev.yaml",
]


def mysql(sql, root=False):
    if root:
        command = (
            'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" '
            'mysql --default-character-set=utf8mb4 '
            '-u root "$MYSQL_DATABASE" -N -s'
        )
    else:
        command = (
            'MYSQL_PWD="$MYSQL_PASSWORD" '
            'mysql --default-character-set=utf8mb4 '
            '-u "$MYSQL_USER" "$MYSQL_DATABASE" -N -s'
        )

    result = subprocess.run(
        compose + ["exec", "-T", "db", "sh", "-c", command],
        input=sql.encode("utf-8") if isinstance(sql, str) else sql,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=ROOT,
        env=env,
        check=False,
    )

    output = result.stdout.decode("utf-8", errors="replace").strip()
    errors = result.stderr.decode("utf-8", errors="replace").strip()

    if result.returncode != 0:
        raise RuntimeError(errors or output or "Docker/MySQL command failed")

    return output


def install(relative_path):
    path = ROOT / relative_path
    print(f"Устанавливаем: {relative_path}", flush=True)
    mysql(path.read_bytes())


def main():
    print(f"Docker-проект: {args.project}")
    print(f"Порт MySQL: {args.port}")
    print("Проверяем базу данных...", flush=True)

    existing = mysql("""
        SELECT
            (SELECT COUNT(*)
             FROM information_schema.TABLES
             WHERE TABLE_SCHEMA = DATABASE())
          + (SELECT COUNT(*)
             FROM information_schema.ROUTINES
             WHERE ROUTINE_SCHEMA = DATABASE())
          + (SELECT COUNT(*)
             FROM information_schema.TRIGGERS
             WHERE TRIGGER_SCHEMA = DATABASE())
          + (SELECT COUNT(*)
             FROM information_schema.EVENTS
             WHERE EVENT_SCHEMA = DATABASE());
    """)

    if int(existing) != 0:
        print(f"ОТКАЗ: база не пуста ({existing} объектов).")
        print("Существующая база не изменена.")
        return 1

    print("База пуста. Начинаем установку.")

    install("database/Pharmacy_Warehouse.sql")

    seed_files = [
        "Заполнение города и складов.sql",
        "Заполнение должности и аптек.sql",
        "Заполнение производителя и мед группы.sql",
        "Заполнение сотрудников и поставщиков.sql",
        "Заполнение остатков на складе и препаратов.sql",
        "Заполнение поставок на склад и в аптеку.sql",
        "Промежуточные табл для поставок.sql",
    ]

    for filename in seed_files:
        install(f"database/insert_data/{filename}")

    install("database/user-roles/Пользователи.sql")

    print("Настраиваем разрешение на создание триггеров.")
    mysql(
        "SET GLOBAL log_bin_trust_function_creators = 1;",
        root=True,
    )

    for number in (1, 2, 3):
        install(f"database/triggers/Триггер{number}.sql")

    for number in range(1, 11):
        install(f"database/procedures/Процедура{number}.sql")

    install(
        "database/procedures/"
        "Validate_Pharmacy_Supply_Min_Value.sql"
    )

    print("\nДемонстрационная база успешно инициализирована.")
    print("Создайте пользователя через app/create_user.py.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print(f"\nОШИБКА: {error}", file=sys.stderr)
        sys.exit(1)
