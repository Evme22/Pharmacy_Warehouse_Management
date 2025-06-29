USE Pharmacy_Warehouse;
SELECT 
    m.medicine_id,
    m.medicine_name,
    m.purpose,
    mf.manufacturer_name,
    m.unit,
    m.purchase_price,
    m.selling_price
FROM Medicine m
JOIN Manufacturer mf ON m.manufacturer_id = mf.manufacturer_id
WHERE m.manufacturer_id = 1;
