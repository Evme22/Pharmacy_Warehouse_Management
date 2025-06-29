USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Supplied_Medicines_By_Supplier(IN in_supplier_id INT)
BEGIN
    IF in_supplier_id IS NULL OR in_supplier_id NOT IN (SELECT supplier_id FROM Supplier) THEN
        SELECT 'Ошибка: поставщик не найден.' AS error_message;
    ELSE
        SELECT 
            swi.supply_id,
            m.medicine_name,
            swi.quantity,
            s.supplier_name,
            stw.supply_date
        FROM Supply_warehouse_items swi
        JOIN Medicine m ON swi.medicine_id = m.medicine_id
        JOIN Supply_to_warehouse stw ON swi.supply_id = stw.supply_id
        JOIN Supplier s ON stw.supplier_id = s.supplier_id
        WHERE s.supplier_id = in_supplier_id;
    END IF;
END //

DELIMITER ;

CALL Get_Supplied_Medicines_By_Supplier(1);
