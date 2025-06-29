USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_remove_from_warehouse_stock
AFTER INSERT ON Supply_pharmacy_items
FOR EACH ROW
BEGIN
    DECLARE emp_id INT;
    DECLARE w_id INT;
    DECLARE current_stock INT;

    SELECT employee_id INTO emp_id
    FROM Supply_to_pharmacy
    WHERE id_supply = NEW.id_supply
    LIMIT 1;

    IF emp_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: не найден employee_id по id_supply в Supply_to_pharmacy';
    END IF;

    SELECT warehouse_id INTO w_id
    FROM Warehouse_employee
    WHERE employee_id = emp_id
    LIMIT 1;

    IF w_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: не найден warehouse_id по employee_id';
    END IF;

    SELECT quantity INTO current_stock
    FROM Warehouse_stock
    WHERE warehouse_id = w_id AND medicine_id = NEW.medicine_id
    LIMIT 1;

    IF current_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: препарат отсутствует на складе';
    END IF;

    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: недостаточно товара на складе для отгрузки';
    END IF;

    UPDATE Warehouse_stock
    SET quantity = quantity - NEW.quantity
    WHERE warehouse_id = w_id AND medicine_id = NEW.medicine_id;
END //

DELIMITER ;

INSERT INTO Supply_to_pharmacy (id_supply, pharmacy_id, supply_date, employee_id)
VALUES (18, 2, '2024-05-06', 1);
INSERT INTO Supply_pharmacy_items (id_supply, medicine_id, quantity)
VALUES (18, 3, 20);
SELECT * FROM Warehouse_stock WHERE warehouse_id = 1 AND medicine_id = 3;

