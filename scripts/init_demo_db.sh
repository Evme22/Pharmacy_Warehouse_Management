#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="${PHARMACY_COMPOSE_PROJECT:-pharmacy-warehouse-polish}"

compose() {
    docker compose -p "$PROJECT" -f compose.dev.yaml "$@"
}

run_sql() {
    local file="$1"
    echo "Устанавливаем: $file"

    compose exec -T db sh -c \
        'MYSQL_PWD="$MYSQL_PASSWORD" mysql --default-character-set=utf8mb4 -u "$MYSQL_USER" "$MYSQL_DATABASE"' \
        < "$file"
}

echo "Проверяем базу данных..."

existing_objects="$(
    compose exec -T db sh -c \
        'MYSQL_PWD="$MYSQL_PASSWORD" mysql -N -s -u "$MYSQL_USER" "$MYSQL_DATABASE" -e "
            SELECT
                (SELECT COUNT(*)
                 FROM information_schema.tables
                 WHERE table_schema = DATABASE())
              + (SELECT COUNT(*)
                 FROM information_schema.routines
                 WHERE routine_schema = DATABASE());
        "'
)"

if [[ "$existing_objects" != "0" ]]; then
    echo "ОШИБКА: база не пуста ($existing_objects объектов)."
    echo "Установщик не изменил существующую базу."
    exit 1
fi

echo "База пуста. Начинаем установку."

# 1. Создаём таблицы.
run_sql "database/Pharmacy_Warehouse.sql"

# 2. Загружаем справочники.
run_sql "database/insert_data/Заполнение города и складов.sql"
run_sql "database/insert_data/Заполнение должности и аптек.sql"
run_sql "database/insert_data/Заполнение производителя и мед группы.sql"

# 3. Загружаем сотрудников и поставщиков.
run_sql "database/insert_data/Заполнение сотрудников и поставщиков.sql"

# 4. Загружаем лекарства и начальные остатки.
run_sql "database/insert_data/Заполнение остатков на складе и препаратов.sql"

# 5. Загружаем документы и позиции поставок.
run_sql "database/insert_data/Заполнение поставок на склад и в аптеку.sql"
run_sql "database/insert_data/Промежуточные табл для поставок.sql"

# 6. Создаём таблицу пользователей приложения.
run_sql "database/user-roles/Пользователи.sql"

# 7. Разрешаем создание триггеров
# в локальной демонстрационной MySQL.
compose exec -T db sh -c \
    'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -u root -e "SET GLOBAL log_bin_trust_function_creators = 1;"'

# 8. Устанавливаем только необходимые триггеры.
for n in 1 2 3; do
    run_sql "database/triggers/Триггер${n}.sql"
done

# 9. Устанавливаем аналитические процедуры.
for n in {1..10}; do
    run_sql "database/procedures/Процедура${n}.sql"
done

# 10. Устанавливаем проверку минимальной суммы.
run_sql "database/procedures/Validate_Pharmacy_Supply_Min_Value.sql"

echo ""
echo "Демонстрационная база успешно инициализирована."
echo "Для входа в Flask создайте пользователя через app/create_user.py."
