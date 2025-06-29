USE Pharmacy_Warehouse;
SELECT 
    m.medicine_name,
    SUM(spi.quantity) AS total_supplied,
    COUNT(DISTINCT stp.pharmacy_id) AS pharmacies_count
FROM Supply_pharmacy_items spi
JOIN Medicine m ON spi.medicine_id = m.medicine_id
JOIN Supply_to_pharmacy stp ON spi.id_supply = stp.id_supply
GROUP BY spi.medicine_id
ORDER BY total_supplied DESC;
