USE Pharmacy_Warehouse;
INSERT INTO Position (position_id, position_name) VALUES
(1, 'Кладовщик'),
(2, 'Директор'),
(3, 'Администратор БД'),
(4, 'Бухгалтер');

INSERT INTO Pharmacy (pharmacy_id, city_id, pharmacy_address) VALUES
(1, 1, 'ул. Тверская, 5'),
(2, 2, 'Невский пр-т., 10'),
(3, 1, 'ул. Арбат, 8'),
(4, 3, 'ул. Баумана, 21'),
(5, 5, 'ул. Орджоникидзе, 30'),
(6, 2, 'Московский пр-т., 145'),
(7, 4, 'ул. 8 Марта, 118');
