
USE Pharmacy_Warehouse;

DELIMITER //

CREATE TRIGGER trg_add_to_warehouse_stock
AFTER INSERT ON Supply_warehouse_items
FOR EACH ROW
BEGIN
    DECLARE target_warehouse_id INT DEFAULT NULL;

    IF NEW.quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Количество поступления должно быть положительным';
    END IF;

    SELECT e.warehouse_id
    INTO target_warehouse_id
    FROM Supply_to_warehouse s
    JOIN Warehouse_employee e
        ON e.employee_id = s.employee_id
    WHERE s.supply_id = NEW.supply_id;

    IF target_warehouse_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Не удалось определить склад поступления';
    END IF;

    INSERT INTO Warehouse_stock (
        warehouse_id,
        medicine_id,
        quantity
    )
    VALUES (
        target_warehouse_id,
        NEW.medicine_id,
        NEW.quantity
    )
    ON DUPLICATE KEY UPDATE
        quantity = quantity + NEW.quantity;
END //

DELIMITER ;
