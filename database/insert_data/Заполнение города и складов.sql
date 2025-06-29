USE Pharmacy_Warehouse;
INSERT INTO City (city_id, city_name) VALUES
(1, 'Москва'),
(2, 'Санкт-Петербург'),
(3, 'Казань'),
(4, 'Екатеринбург'),
(5, 'Новосибирск');

INSERT INTO Warehouse (warehouse_id, warehouse_name, city_id) VALUES
(1, 'ООО "Химфармпродукт"', 2),
(2, 'ООО "Ленфарма"', 2),
(3, 'ООО "Корекс"', 1),
(4, 'ООО "Интер-с Внуково"', 1);
