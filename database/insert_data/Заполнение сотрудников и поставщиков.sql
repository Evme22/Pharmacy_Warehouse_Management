-- SYNTHETIC DEMO DATA: all people and organizations are fictional.
USE Pharmacy_Warehouse;

INSERT INTO Supplier (
    supplier_id, supplier_name, company_address,
    contact_last_name, contact_first_name, contact_middle_name,
    phone_number, inn, license_number
) VALUES
(1, 'ООО «Учебный поставщик 01»', 'Вымышленный адрес 1', 'Тестовый', 'Контакт01', 'Демо', 'DEMO-PHONE-0001', '0000000001', 'DEMO-LICENSE-0001'),
(2, 'ООО «Учебный поставщик 02»', 'Вымышленный адрес 2', 'Тестовый', 'Контакт02', 'Демо', 'DEMO-PHONE-0002', '0000000002', 'DEMO-LICENSE-0002'),
(3, 'ООО «Учебный поставщик 03»', 'Вымышленный адрес 3', 'Тестовый', 'Контакт03', 'Демо', 'DEMO-PHONE-0003', '0000000003', 'DEMO-LICENSE-0003'),
(4, 'ООО «Учебный поставщик 04»', 'Вымышленный адрес 4', 'Тестовый', 'Контакт04', 'Демо', 'DEMO-PHONE-0004', '0000000004', 'DEMO-LICENSE-0004');

INSERT INTO Warehouse_employee (
    employee_id, last_name, first_name, middle_name,
    passport_data, position_id, phone_number, salary, warehouse_id
) VALUES
(1, 'Тестовый', 'Сотрудник01', 'Демо', 'DEMO-PASSPORT-0001', 1, 'DEMO-PHONE-0001', 41500.00, 1),
(2, 'Тестовый', 'Сотрудник02', 'Демо', 'DEMO-PASSPORT-0002', 1, 'DEMO-PHONE-0002', 43000.00, 2),
(3, 'Тестовый', 'Сотрудник03', 'Демо', 'DEMO-PASSPORT-0003', 1, 'DEMO-PHONE-0003', 44500.00, 3),
(4, 'Тестовый', 'Сотрудник04', 'Демо', 'DEMO-PASSPORT-0004', 1, 'DEMO-PHONE-0004', 46000.00, 4),
(5, 'Тестовый', 'Сотрудник05', 'Демо', 'DEMO-PASSPORT-0005', 1, 'DEMO-PHONE-0005', 47500.00, 1),
(6, 'Тестовый', 'Сотрудник06', 'Демо', 'DEMO-PASSPORT-0006', 1, 'DEMO-PHONE-0006', 49000.00, 2),
(7, 'Тестовый', 'Сотрудник07', 'Демо', 'DEMO-PASSPORT-0007', 1, 'DEMO-PHONE-0007', 50500.00, 3),
(8, 'Тестовый', 'Сотрудник08', 'Демо', 'DEMO-PASSPORT-0008', 1, 'DEMO-PHONE-0008', 52000.00, 4),
(9, 'Тестовый', 'Сотрудник09', 'Демо', 'DEMO-PASSPORT-0009', 2, 'DEMO-PHONE-0009', 53500.00, 1),
(10, 'Тестовый', 'Сотрудник10', 'Демо', 'DEMO-PASSPORT-0010', 2, 'DEMO-PHONE-0010', 55000.00, 2),
(11, 'Тестовый', 'Сотрудник11', 'Демо', 'DEMO-PASSPORT-0011', 2, 'DEMO-PHONE-0011', 56500.00, 3),
(12, 'Тестовый', 'Сотрудник12', 'Демо', 'DEMO-PASSPORT-0012', 2, 'DEMO-PHONE-0012', 58000.00, 4),
(13, 'Тестовый', 'Сотрудник13', 'Демо', 'DEMO-PASSPORT-0013', 3, 'DEMO-PHONE-0013', 59500.00, 1),
(14, 'Тестовый', 'Сотрудник14', 'Демо', 'DEMO-PASSPORT-0014', 3, 'DEMO-PHONE-0014', 61000.00, 2),
(15, 'Тестовый', 'Сотрудник15', 'Демо', 'DEMO-PASSPORT-0015', 3, 'DEMO-PHONE-0015', 62500.00, 3),
(16, 'Тестовый', 'Сотрудник16', 'Демо', 'DEMO-PASSPORT-0016', 3, 'DEMO-PHONE-0016', 64000.00, 4),
(17, 'Тестовый', 'Сотрудник17', 'Демо', 'DEMO-PASSPORT-0017', 4, 'DEMO-PHONE-0017', 65500.00, 1),
(18, 'Тестовый', 'Сотрудник18', 'Демо', 'DEMO-PASSPORT-0018', 4, 'DEMO-PHONE-0018', 67000.00, 2),
(19, 'Тестовый', 'Сотрудник19', 'Демо', 'DEMO-PASSPORT-0019', 4, 'DEMO-PHONE-0019', 68500.00, 3),
(20, 'Тестовый', 'Сотрудник20', 'Демо', 'DEMO-PASSPORT-0020', 4, 'DEMO-PHONE-0020', 70000.00, 4);
