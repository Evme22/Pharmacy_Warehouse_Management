USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Avg_Selling_Top10()
BEGIN
    SELECT 
        m.medicine_name,
        ROUND(AVG(m.selling_price), 2) AS avg_selling_price,
        SUM(spi.quantity) AS total_sold
    FROM Supply_pharmacy_items spi
    JOIN Medicine m ON spi.medicine_id = m.medicine_id
    GROUP BY spi.medicine_id
    ORDER BY total_sold DESC
    LIMIT 10;
END //

DELIMITER ;

CALL Get_Avg_Selling_Top10();
