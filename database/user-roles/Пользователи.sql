USE Pharmacy_Warehouse;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

INSERT INTO users (username, password, role) VALUES
('db_admin', 'admin123', 'db_admin'),
('warehouse_clerk', 'pass123', 'warehouse_clerk'),
('director', 'director123', 'director');
