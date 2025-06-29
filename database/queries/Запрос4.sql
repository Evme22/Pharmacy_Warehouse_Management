USE Pharmacy_Warehouse;
SELECT 
    spi.id_supply,
    m.medicine_name,
    spi.quantity,
    ph.pharmacy_address,
    stp.supply_date
FROM Supply_pharmacy_items spi
JOIN Medicine m ON spi.medicine_id = m.medicine_id
JOIN Supply_to_pharmacy stp ON spi.id_supply = stp.id_supply
JOIN Pharmacy ph ON stp.pharmacy_id = ph.pharmacy_id
WHERE ph.pharmacy_id = 1;
