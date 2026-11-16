
USE Pharmacy_Warehouse;

DELIMITER //

CREATE PROCEDURE Get_Low_Supply_Medicines_By_Period(
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    IF start_date IS NULL
       OR end_date IS NULL
       OR start_date > end_date THEN

        SELECT 'Ошибка: некорректный период' AS error_message;

    ELSE
        SELECT
            m.medicine_name,
            COALESCE(s.total_supplied, 0) AS total_supplied
        FROM Medicine m

        LEFT JOIN (
            SELECT
                spi.medicine_id,
                SUM(spi.quantity) AS total_supplied
            FROM Supply_pharmacy_items spi

            JOIN Supply_to_pharmacy stp
                ON stp.id_supply = spi.id_supply

            WHERE stp.supply_date
                BETWEEN start_date AND end_date

            GROUP BY spi.medicine_id
        ) s
            ON s.medicine_id = m.medicine_id

        ORDER BY
            total_supplied ASC,
            m.medicine_name ASC;
    END IF;
END //

DELIMITER ;
