USE Pharmacy_Warehouse;
SELECT 
    m.medicine_name,
    IFNULL(SUM(spi.quantity), 0) AS total_supplied
FROM Medicine m
LEFT JOIN Supply_pharmacy_items spi ON m.medicine_id = spi.medicine_id
LEFT JOIN Supply_to_pharmacy stp ON spi.id_supply = stp.id_supply
    AND stp.supply_date BETWEEN "2024.05.01" AND "2024.05.31"
GROUP BY m.medicine_id
ORDER BY total_supplied ASC;
