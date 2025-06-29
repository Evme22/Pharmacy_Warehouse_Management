USE Pharmacy_Warehouse;
SELECT 
    s.supplier_name,
    SUM(swi.quantity) AS total_supplied
FROM Supply_warehouse_items swi
JOIN Supply_to_warehouse stw ON swi.supply_id = stw.supply_id
JOIN Supplier s ON stw.supplier_id = s.supplier_id
WHERE stw.supply_date BETWEEN "2024.05.01" AND "2024.05.31"
GROUP BY s.supplier_id
ORDER BY total_supplied DESC
LIMIT 5;
