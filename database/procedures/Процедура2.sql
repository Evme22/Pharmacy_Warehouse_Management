USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Medicines_By_Price_Range(IN min_price DECIMAL(10,2), IN max_price DECIMAL(10,2))
BEGIN
    IF min_price IS NULL OR max_price IS NULL OR min_price < 0 OR max_price < 0 OR min_price > max_price THEN
        SELECT 'Ошибка: неверно задан диапазон цен.' AS error_message;
    ELSE
        SELECT 
            medicine_id,
            medicine_name,
            purpose,
            purchase_price,
            selling_price
        FROM Medicine
        WHERE selling_price BETWEEN min_price AND max_price;
    END IF;
END //

DELIMITER ;

CALL Get_Medicines_By_Price_Range(150, 230);
