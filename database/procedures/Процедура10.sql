USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Low_Supply_Medicines_By_Period(IN start_date DATE, IN end_date DATE)
BEGIN
    IF start_date IS NULL OR end_date IS NULL OR start_date > end_date THEN
        SELECT 'Ошибка: некорректный период' AS error_message;
    ELSE
        SELECT 
            m.medicine_name,
            IFNULL(SUM(spi.quantity), 0) AS total_supplied
        FROM Medicine m
        LEFT JOIN Supply_pharmacy_items spi ON m.medicine_id = spi.medicine_id
        LEFT JOIN Supply_to_pharmacy stp ON spi.id_supply = stp.id_supply
            AND stp.supply_date BETWEEN start_date AND end_date
        GROUP BY m.medicine_id
        ORDER BY total_supplied ASC;
    END IF;
END //

DELIMITER ;

CALL Get_Low_Supply_Medicines_By_Period('2024-05-01', '2024-05-31');
