CREATE DATABASE hospital_db;
USE hospital_db;


-- Objective 1: Managing Hospital Data Efficiently

-- Task 1: Creating Database Tables & Structures
-- create patients table

CREATE TABLE Patients (
	patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT CHECK (age>0),
    contact VARCHAR(15) UNIQUE
);

-- create departments table

CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- create doctors table

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
        ON DELETE SET NULL     -- if department is removed -- doctor stays but debartment becomes NULL
);

-- create hospital_rooms table

CREATE TABLE Hospital_Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    room_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Available'
);

-- create table services

CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    cost DECIMAL(10,2) CHECK (cost >= 0)
);

-- create appointments table

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    room_id INT,
    visit_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id)
        ON DELETE CASCADE,   -- if patient is removed -- visit removed

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id)
        ON DELETE CASCADE,

    FOREIGN KEY (room_id)
        REFERENCES Hospital_Rooms(room_id)
        ON DELETE SET NULL
);

-- create service_usage table

CREATE TABLE Service_Usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    service_id INT NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),

    FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON DELETE CASCADE,

    FOREIGN KEY (service_id)
        REFERENCES Services(service_id)
        ON DELETE CASCADE
);

-- create bills table

CREATE TABLE Bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    total_amount DECIMAL(10,2) DEFAULT 0,
    bill_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (appointment_id)
        REFERENCES Appointments(appointment_id)
        ON DELETE CASCADE
);

-- create payments table

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    amount DECIMAL(10,2) CHECK (amount >= 0),
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    method VARCHAR(50),

    FOREIGN KEY (bill_id)
        REFERENCES Bills(bill_id)
        ON DELETE CASCADE
);


SHOW TABLES;

-- Task 2: Adding & Updating Hospital Records
-- Inserting sample values in the above created tables

INSERT INTO Patients (name, age, contact) VALUES
('Rahul Sharma', 35, '9876543210'),
('Priya Patel', 28, '9123456780'),
('Amit Verma', 42, '9988776655'),
('Neha Gupta', 31, '9090909090');

SELECT * FROM Patients;

INSERT INTO Departments (department_name) VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('General Medicine');

SELECT * FROM Departments;


INSERT INTO Doctors (name, specialization, department_id) VALUES
('Dr. Mehta', 'Cardiologist', 1),
('Dr. Singh', 'Neurologist', 2),
('Dr. Rao', 'Orthopedic Surgeon', 3),
('Dr. Khan', 'Physician', 4);

SELECT * FROM Doctors;


INSERT INTO Hospital_Rooms (room_number, room_type, status) VALUES
('R101', 'General', 'Available'),
('R102', 'ICU', 'Occupied'),
('R103', 'Private', 'Available'),
('R104', 'General', 'Maintenance');

SELECT * FROM Hospital_Rooms;


INSERT INTO Services (service_name, cost) VALUES
('Consultation', 500.00),
('X-Ray', 1200.00),
('Blood Test', 800.00),
('MRI Scan', 5000.00);

SELECT * FROM Services;


INSERT INTO Service_Usage (appointment_id, service_id, quantity) VALUES
(1, 1, 1),  -- consultation
(1, 2, 1),  -- x-ray
(2, 1, 1),
(2, 3, 2),  -- blood test twice
(3, 4, 1),  -- MRI
(4, 1, 1),
(4, 3, 1);

SELECT * FROM Service_Usage;


INSERT INTO Bills (appointment_id, total_amount) VALUES
(1, 1700.00),
(2, 2100.00),
(3, 5000.00),
(4, 1300.00);

SELECT * FROM Bills;


INSERT INTO Payments (bill_id, amount, method) VALUES
(1, 1700.00, 'Card'),
(2, 1000.00, 'Cash'),
(2, 1100.00, 'Card'),
(3, 5000.00, 'Online'),
(4, 1300.00, 'Insurance');

SELECT * FROM Payments;




-- Retrieve filtered hospital Data

SELECT name, age
FROM Patients
WHERE age > 30;


-- Update patient data

UPDATE Patients
SET contact = '9876543211'
WHERE patient_id = 1;

SELECT * FROM Patients;

-- Delete a test patient record

INSERT INTO Patients (name, age, contact)
VALUES ('Test Patient', 26, '9999995555');

DELETE FROM Patients
WHERE name = 'Test Patient';

SELECT * FROM Patients;

-- Objective 2: Connecting Hospital Information Across Departments

-- Join patients with doctors

SELECT 
    p.name AS patient,
    d.name AS doctor,
    a.visit_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- Revenue Generated per Patient
SELECT 
    p.name AS patient,
    SUM(b.total_amount) AS total_bill
FROM Bills b
JOIN Appointments a ON b.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
GROUP BY p.name;


-- Identify Most used Hospital Services
SELECT 
    s.service_name,
    SUM(u.quantity) AS total_usage
FROM Service_Usage u
JOIN Services s ON u.service_id = s.service_id
GROUP BY s.service_name
ORDER BY total_usage DESC;

-- Show patients even if they have no bills
SELECT 
    p.name,
    b.total_amount
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
LEFT JOIN Bills b ON a.appointment_id = b.appointment_id;

-- Show all doctors including unused ones
SELECT 
    d.name,
    a.appointment_id
FROM Appointments a
RIGHT JOIN Doctors d ON a.doctor_id = d.doctor_id;


-- Objective 3: Automating Hospital Workflows

-- creating stored procedure to add a new appointment

CALL AddAppointment(2, 3, 1);
SELECT * FROM Appointments;

-- stored procedure to calculate bill
CALL GenerateBill(3);
SELECT * FROM Bills;

-- stored procedure to add Payment
CALL AddPayment(5, 500, 'Cash');
SELECT * FROM Payments;


-- Objective 4:Handling Flexible and Modern Data Formats
-- ADD JSON medical notes column

ALTER TABLE Appointments
ADD COLUMN medical_notes JSON;

-- Insert JSON medical notes

UPDATE Appointments
SET medical_notes = JSON_OBJECT(
    'symptoms', 'fever and cough',
    'diagnosis', 'viral infection',
    'doctor_notes', 'rest for 5 days'
)
WHERE appointment_id = 1;

SELECT appointment_id, medical_notes
FROM Appointments
WHERE appointment_id = 1;

-- Extracting JSON values
SELECT
    appointment_id,
    medical_notes->>'$.diagnosis' AS diagnosis
FROM Appointments
WHERE appointment_id = 1;

SELECT appointment_id
FROM Appointments
WHERE medical_notes->>'$.diagnosis' = 'viral infection';


-- Dbjective 5:Ensuring Reliable and Secure Operations
--  Trigger to auto update room status

DELIMITER //

CREATE TRIGGER RoomOccupied
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    UPDATE Hospital_Rooms
    SET status = 'Occupied'
    WHERE room_id = NEW.room_id;
END //

DELIMITER ;

-- Test trigger
CALL AddAppointment(2, 2, 4);
SELECT * FROM Hospital_Rooms;

-- Transaction Example
START TRANSACTION;
INSERT INTO Payments (bill_id, amount, method)
VALUES (6, 800, 'Cash');

COMMIT;

START TRANSACTION;
INSERT INTO Payments (bill_id, amount, method)
VALUES (1, 9999, 'Error');
ROLLBACK;

-- Create hospital view 
CREATE VIEW Patient_Bill_Report AS
SELECT 
    p.name AS patient,
    d.name AS doctor,
    b.total_amount,
    a.visit_date
FROM Bills b
JOIN Appointments a ON b.appointment_id = a.appointment_id
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- use view
SELECT * FROM Patient_Bill_Report;






