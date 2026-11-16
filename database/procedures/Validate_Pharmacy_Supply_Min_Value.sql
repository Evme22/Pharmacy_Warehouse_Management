
USE Pharmacy_Warehouse;

DELIMITER //

CREATE PROCEDURE Validate_Pharmacy_Supply_Min_Value(
    IN in_supply_id INT
)
BEGIN
    DECLARE total_amount DECIMAL(18, 2) DEFAULT 0;
    DECLARE item_count INT DEFAULT 0;

    IF NOT EXISTS (
        SELECT 1
        FROM Supply_to_pharmacy
        WHERE id_supply = in_supply_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Отгрузка не существует';
    END IF;

    SELECT
        COUNT(*),
        COALESCE(SUM(i.quantity * m.selling_price), 0)
    INTO item_count, total_amount
    FROM Supply_pharmacy_items i
    JOIN Medicine m
        ON m.medicine_id = i.medicine_id
    WHERE i.id_supply = in_supply_id;

    IF item_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Отгрузка не содержит препаратов';
    END IF;

    IF total_amount < 1000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Сумма отгрузки меньше 1000 рублей';
    END IF;

    SELECT
        in_supply_id AS supply_id,
        total_amount AS total_value;
END //

DELIMITER ;
