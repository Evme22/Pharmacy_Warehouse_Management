USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_check_pharmacy_supply_medicine
BEFORE INSERT ON Supply_pharmacy_items
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Medicine WHERE medicine_id = NEW.medicine_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ошибка: препарат не существует в базе';
    END IF;
END //

DELIMITER ;

INSERT INTO Supply_pharmacy_items (id_supply, medicine_id, quantity)
VALUES (1001, 9999, 50);