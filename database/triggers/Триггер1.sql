USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_check_medicine_price
BEFORE INSERT ON Medicine
FOR EACH ROW
BEGIN
    IF NEW.purchase_price <= 0 OR NEW.selling_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: цена должна быть положительной';
    END IF;
END //

DELIMITER ;

INSERT INTO Medicine (medicine_id, medicine_name, manufacturer_id, purpose, group_id, unit, purchase_price, selling_price)
VALUES (100, 'ФейкПрепарат', 1, 'Пусто', 1, 'таблетки', -10.00, 50.00);