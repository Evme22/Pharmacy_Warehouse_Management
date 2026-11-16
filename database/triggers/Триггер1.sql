
USE Pharmacy_Warehouse;

DELIMITER //

CREATE TRIGGER trg_check_medicine_price
BEFORE INSERT ON Medicine
FOR EACH ROW
BEGIN
    IF NEW.purchase_price <= 0 OR NEW.selling_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Цены лекарства должны быть положительными';
    END IF;
END //

CREATE TRIGGER trg_check_medicine_price_update
BEFORE UPDATE ON Medicine
FOR EACH ROW
BEGIN
    IF NEW.purchase_price <= 0 OR NEW.selling_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Цены лекарства должны быть положительными';
    END IF;
END //

DELIMITER ;
