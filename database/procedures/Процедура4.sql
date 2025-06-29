USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Supplied_Medicines_By_Pharmacy(IN in_pharmacy_id INT)
BEGIN
    IF in_pharmacy_id IS NULL OR in_pharmacy_id NOT IN (SELECT pharmacy_id FROM Pharmacy) THEN
        SELECT 'Ошибка: указанная аптека не найдена.' AS error_message;
    ELSE
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
        WHERE ph.pharmacy_id = in_pharmacy_id;
    END IF;
END //

DELIMITER ;

CALL Get_Supplied_Medicines_By_Pharmacy(3);
