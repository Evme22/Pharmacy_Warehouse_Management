
from getpass import getpass

from mysql.connector import Error
from werkzeug.security import generate_password_hash

from db import get_connection


ALLOWED_ROLES = {
    "db_admin",
    "director",
    "warehouse_clerk",
}


def main():
    username = input("Логин нового пользователя: ").strip()
    role = input(
        "Роль (db_admin / director / warehouse_clerk): "
    ).strip()

    if not username:
        raise SystemExit("Логин не может быть пустым.")

    if role not in ALLOWED_ROLES:
        raise SystemExit("Указана недопустимая роль.")

    password = getpass("Пароль: ")
    password_confirm = getpass("Повторите пароль: ")

    if len(password) < 12:
        raise SystemExit("Пароль должен содержать не менее 12 символов.")

    if password != password_confirm:
        raise SystemExit("Пароли не совпадают.")

    password_hash = generate_password_hash(
        password,
        method="scrypt",
    )

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            INSERT INTO users (username, password_hash, role)
            VALUES (%s, %s, %s)
            """,
            (username, password_hash, role),
        )

        connection.commit()

    except Error as error:
        if connection is not None:
            connection.rollback()

        raise SystemExit(
            f"Не удалось создать пользователя: {error}"
        )

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None:
            connection.close()

    print(f"Пользователь '{username}' успешно создан.")


if __name__ == "__main__":
    main()
