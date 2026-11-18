
USE Pharmacy_Warehouse;

DELIMITER //

CREATE PROCEDURE Get_Top10_Medicines_By_Pharmacy_Supply()
BEGIN
    SELECT
        m.medicine_name,
        m.selling_price AS current_selling_price,
        SUM(spi.quantity) AS total_supplied
    FROM Supply_pharmacy_items spi
    JOIN Medicine m
        ON m.medicine_id = spi.medicine_id
    GROUP BY
        m.medicine_id,
        m.medicine_name,
        m.selling_price
    ORDER BY
        total_supplied DESC,
        m.medicine_name ASC
    LIMIT 10;
END //

DELIMITER ;
