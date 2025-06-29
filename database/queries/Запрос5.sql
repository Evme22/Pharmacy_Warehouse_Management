USE Pharmacy_Warehouse;
SELECT 
    swi.supply_id,
    m.medicine_name,
    swi.quantity,
    s.supplier_name,
    stw.supply_date
FROM Supply_warehouse_items swi
JOIN Medicine m ON swi.medicine_id = m.medicine_id
JOIN Supply_to_warehouse stw ON swi.supply_id = stw.supply_id
JOIN Supplier s ON stw.supplier_id = s.supplier_id
WHERE s.supplier_id = 3;
