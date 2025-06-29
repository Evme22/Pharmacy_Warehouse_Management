USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_add_to_warehouse_stock
AFTER INSERT ON Supply_warehouse_items
FOR EACH ROW
BEGIN
    DECLARE emp_id INT;
    DECLARE w_id INT;
    DECLARE existing_quantity INT;

    SELECT employee_id INTO emp_id
    FROM Supply_to_warehouse
    WHERE supply_id = NEW.supply_id
    LIMIT 1;

    IF emp_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: не найден employee_id по supply_id в Supply_to_warehouse';
    END IF;

    SELECT warehouse_id INTO w_id
    FROM Warehouse_employee
    WHERE employee_id = emp_id
    LIMIT 1;

    IF w_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: не найден warehouse_id по employee_id';
    END IF;

    SELECT quantity INTO existing_quantity
    FROM Warehouse_stock
    WHERE warehouse_id = w_id AND medicine_id = NEW.medicine_id
    LIMIT 1;

    IF existing_quantity IS NOT NULL THEN
        UPDATE Warehouse_stock
        SET quantity = quantity + NEW.quantity
        WHERE warehouse_id = w_id AND medicine_id = NEW.medicine_id;
    ELSE
        INSERT INTO Warehouse_stock (warehouse_id, medicine_id, quantity)
        VALUES (w_id, NEW.medicine_id, NEW.quantity);
    END IF;
END //

DELIMITER ;


INSERT INTO Supply_warehouse_items (supply_id, medicine_id, quantity)
VALUES (1, 5, 40);
SELECT * FROM Warehouse_stock WHERE warehouse_id = 1 AND medicine_id = 5;
