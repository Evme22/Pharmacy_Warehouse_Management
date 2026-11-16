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
