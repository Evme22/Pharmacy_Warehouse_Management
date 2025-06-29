USE Pharmacy_Warehouse;
DELIMITER //

CREATE TRIGGER trg_prevent_delete_medicine_in_supply
BEFORE DELETE ON Medicine
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM Supply_warehouse_items WHERE medicine_id = OLD.medicine_id
        UNION
        SELECT 1 FROM Supply_pharmacy_items WHERE medicine_id = OLD.medicine_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить препарат, участвующий в поставках';
    END IF;
END //

DELIMITER ;

INSERT INTO Medicine (medicine_id, medicine_name, manufacturer_id, purpose, group_id, unit, purchase_price, selling_price)
VALUES (999, 'ТестУдаление', 1, 'тест', 1, 'таблетки', 10.00, 15.00);
DELETE FROM Medicine WHERE medicine_id = 999;
DELETE FROM Medicine WHERE medicine_id = 3;