-- 在创建表之前先删除已存在的表
DROP TABLE IF EXISTS registrations;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS time_slots;

CREATE TABLE drivers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    license_number VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    plate_number VARCHAR(20) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE time_slots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_capacity INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registrations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    time_slot_id INT NOT NULL,
    expected_check_in_time DATETIME NOT NULL,
    registration_date DATETIME NOT NULL,
    check_in_time DATETIME,
    status ENUM('pending', 'checked_in', 'completed', 'expired', 'skipped') NOT NULL,
    missed_check_in_time DATETIME,
    is_dispatched BOOLEAN DEFAULT FALSE,
    dispatch_time DATETIME,
    trailer_number VARCHAR(50),
    route VARCHAR(20),
    FOREIGN KEY (driver_id) REFERENCES drivers(id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    FOREIGN KEY (time_slot_id) REFERENCES time_slots(id)
); 