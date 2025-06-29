USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Medicines_By_Manufacturer(IN in_manufacturer_id INT)
BEGIN
    IF in_manufacturer_id IS NULL OR in_manufacturer_id NOT IN (SELECT manufacturer_id FROM Manufacturer) THEN
        SELECT 'Ошибка: указанного производителя не существует.' AS error_message;
    ELSE
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
        WHERE m.manufacturer_id = in_manufacturer_id;
    END IF;
END //

DELIMITER ;

CALL Get_Medicines_By_Manufacturer(1);
