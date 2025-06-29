USE Pharmacy_Warehouse;
SELECT 
    m.medicine_name,
    AVG(m.selling_price) AS avg_selling_price,
    SUM(spi.quantity) AS total_sold
FROM Supply_pharmacy_items spi
JOIN Medicine m ON spi.medicine_id = m.medicine_id
GROUP BY spi.medicine_id
ORDER BY total_sold DESC
LIMIT 10;
