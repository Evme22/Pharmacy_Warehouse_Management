USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_check_min_pharmacy_supply_value
BEFORE INSERT ON Supply_pharmacy_items
FOR EACH ROW
BEGIN
    IF (
        SELECT selling_price * NEW.quantity
        FROM Medicine
        WHERE medicine_id = NEW.medicine_id
    ) < 1000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: сумма поставки в аптеку меньше 1000 руб.';
    END IF;
END //

DELIMITER ;

INSERT INTO Supply_pharmacy_items (id_supply, medicine_id, quantity)
VALUES (1001, 1, 10);
INSERT INTO Supply_pharmacy_items (id_supply, medicine_id, quantity)
VALUES (1, 7, 100);



