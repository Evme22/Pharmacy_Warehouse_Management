USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Medicine_Movement_By_Period(IN start_date DATE, IN end_date DATE)
BEGIN
    IF start_date IS NULL OR end_date IS NULL OR start_date > end_date THEN
        SELECT 'Ошибка: некорректный период' AS error_message;
    ELSE
        SELECT 
            m.medicine_name,
            swi.quantity,
            stw.supply_date AS date_event,
            'Поступление на склад' AS operation
        FROM Supply_warehouse_items swi
        JOIN Medicine m ON swi.medicine_id = m.medicine_id
        JOIN Supply_to_warehouse stw ON swi.supply_id = stw.supply_id
        WHERE stw.supply_date BETWEEN start_date AND end_date

        UNION

        SELECT 
            m.medicine_name,
            spi.quantity,
            stp.supply_date AS date_event,
            'Передача в аптеку' AS operation
        FROM Supply_pharmacy_items spi
        JOIN Medicine m ON spi.medicine_id = m.medicine_id
        JOIN Supply_to_pharmacy stp ON spi.id_supply = stp.id_supply
        WHERE stp.supply_date BETWEEN start_date AND end_date;
    END IF;
END //

DELIMITER ;

CALL Get_Medicine_Movement_By_Period('2024-01-01', '2024-03-01');
