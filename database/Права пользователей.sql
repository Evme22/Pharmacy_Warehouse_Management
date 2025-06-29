-- Кладовщик
CREATE USER 'warehouse_clerk'@'localhost' IDENTIFIED BY 'pass123';
GRANT SELECT, INSERT, UPDATE ON Pharmacy_Warehouse.Warehouse_stock TO 'warehouse_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Pharmacy_Warehouse.Supply_to_pharmacy TO 'warehouse_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Pharmacy_Warehouse.Supply_pharmacy_items TO 'warehouse_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Pharmacy_Warehouse.Supply_warehouse_items TO 'warehouse_clerk'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Pharmacy_Warehouse.Supply_to_warehouse TO 'warehouse_clerk'@'localhost';

-- Директор
CREATE USER 'director'@'localhost' IDENTIFIED BY 'director123';
GRANT SELECT, INSERT, UPDATE, DELETE ON Pharmacy_Warehouse.Supplier TO 'director'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Pharmacy_Warehouse.Supply_to_warehouse TO 'director'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Pharmacy_Warehouse.Supply_warehouse_items TO 'director'@'localhost';

-- Администратор БД
CREATE USER 'db_admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON Pharmacy_Warehouse.* TO 'db_admin'@'localhost' WITH GRANT OPTION;
