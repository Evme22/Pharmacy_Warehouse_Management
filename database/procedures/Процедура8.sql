USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Top_Suppliers_By_Period(IN start_date DATE, IN end_date DATE)
BEGIN
    IF start_date IS NULL OR end_date IS NULL OR start_date > end_date THEN
        SELECT 'Ошибка: некорректный период' AS error_message;
    ELSE
        SELECT 
            s.supplier_name,
            SUM(swi.quantity) AS total_supplied
        FROM Supply_warehouse_items swi
        JOIN Supply_to_warehouse stw ON swi.supply_id = stw.supply_id
        JOIN Supplier s ON stw.supplier_id = s.supplier_id
        WHERE stw.supply_date BETWEEN start_date AND end_date
        GROUP BY s.supplier_id
        ORDER BY total_supplied DESC
        LIMIT 5;
    END IF;
END //

DELIMITER ;

CALL Get_Top_Suppliers_By_Period('2024-05-01', '2024-05-31');
