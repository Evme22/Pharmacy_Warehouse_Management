USE Pharmacy_Warehouse;
DELIMITER //

CREATE PROCEDURE Get_Medicines_By_Group(IN in_group_id INT)
BEGIN
    IF in_group_id IS NULL OR in_group_id NOT IN (SELECT group_id FROM Medicine_group) THEN
        SELECT 'Ошибка: неверный идентификатор группы препаратов.' AS error_message;
    ELSE
        SELECT 
            m.medicine_id,
            m.medicine_name,
            m.purpose,
            mg.group_name,
            m.unit,
            m.purchase_price,
            m.selling_price
        FROM Medicine m
        JOIN Medicine_group mg ON m.group_id = mg.group_id
        WHERE m.group_id = in_group_id;
    END IF;
END //

DELIMITER ;

CALL Get_Medicines_By_Group(5);