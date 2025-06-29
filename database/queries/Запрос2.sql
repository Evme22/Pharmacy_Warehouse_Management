USE Pharmacy_Warehouse;
SELECT 
    medicine_id,
    medicine_name,
    purpose,
    purchase_price,
    selling_price
FROM Medicine
WHERE selling_price BETWEEN 150 AND 230;
