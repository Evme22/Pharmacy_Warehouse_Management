
USE Pharmacy_Warehouse;

DELIMITER //

CREATE TRIGGER trg_remove_from_warehouse_stock
AFTER INSERT ON Supply_pharmacy_items
FOR EACH ROW
BEGIN
    DECLARE target_warehouse_id INT DEFAULT NULL;

    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Количество отгрузки должно быть положительным';
    END IF;

    SELECT e.warehouse_id
    INTO target_warehouse_id
    FROM Supply_to_pharmacy s
    JOIN Warehouse_employee e
        ON e.employee_id = s.employee_id
    WHERE s.id_supply = NEW.id_supply;

    IF target_warehouse_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Не удалось определить склад отгрузки';
    END IF;

    UPDATE Warehouse_stock
    SET quantity = quantity - NEW.quantity
    WHERE warehouse_id = target_warehouse_id
      AND medicine_id = NEW.medicine_id
      AND quantity >= NEW.quantity;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Препарат отсутствует или недостаточно товара';
    END IF;
END //

DELIMITER ;
