-- Hospital Management System | MySQL 8.0+
CREATE DATABASE IF NOT EXISTS hospital_management;
USE hospital_management;

-- 1. Schema: parent tables precede dependent tables.
CREATE TABLE IF NOT EXISTS Patients (
 patient_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL,
 dob DATE NOT NULL, gender VARCHAR(20), phone_number VARCHAR(20),
 email VARCHAR(120) UNIQUE, address VARCHAR(255), registration_date DATE NOT NULL
);
CREATE TABLE IF NOT EXISTS Doctors (
 doctor_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL,
 specialization VARCHAR(80) NOT NULL, phone_number VARCHAR(20),
 email VARCHAR(120) UNIQUE, available_days VARCHAR(100),
 consultation_fee DECIMAL(10,2) NOT NULL, experience_years INT NOT NULL DEFAULT 0,
 CHECK (consultation_fee >= 0), CHECK (experience_years >= 0)
);
CREATE TABLE IF NOT EXISTS Departments (
 department_id INT AUTO_INCREMENT PRIMARY KEY, department_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS Doctor_Department (
 doctor_id INT NOT NULL, department_id INT NOT NULL,
 PRIMARY KEY (doctor_id, department_id),
 FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
 FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
CREATE TABLE IF NOT EXISTS Appointments (
 appointment_id INT AUTO_INCREMENT PRIMARY KEY,
 patient_id INT NOT NULL, doctor_id INT NOT NULL,
 appointment_date DATETIME NOT NULL,
 status ENUM('Scheduled','Completed','Cancelled') NOT NULL DEFAULT 'Scheduled',
 FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
 FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
CREATE TABLE IF NOT EXISTS Medical_Records (
 record_id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL,
 doctor_id INT NOT NULL, diagnosis VARCHAR(255) NOT NULL,
 prescription TEXT, treatment_date DATE NOT NULL,
 admission_date DATE NULL, discharge_date DATE NULL,
 FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
 FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
 CHECK (discharge_date IS NULL OR admission_date IS NULL OR discharge_date >= admission_date)
);
CREATE TABLE IF NOT EXISTS Billing (
 invoice_id INT AUTO_INCREMENT PRIMARY KEY, patient_id INT NOT NULL,
 appointment_id INT NOT NULL UNIQUE, amount DECIMAL(10,2) NOT NULL,
 payment_status ENUM('Paid','Pending','Cancelled') NOT NULL DEFAULT 'Pending',
 payment_date DATE NULL,
 FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
 FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id),
 CHECK (amount >= 0)
);

-- 2. Sample data: run on a fresh database once.
INSERT INTO Patients (patient_id,name,dob,gender,phone_number,email,address,registration_date) VALUES
(1,'Aarav Shah','1998-05-12','Male','9000000001','aarav@example.com','Ahmedabad','2026-02-10'),
(2,'Diya Patel','2001-09-21','Female','9000000002','diya@example.com','Surat','2026-04-02'),
(3,'Rohan Mehta','1987-12-04','Male','9000000003','rohan@example.com','Vadodara','2025-01-15'),
(4,'Anaya Desai','1995-03-18','Female','9000000004','anaya@example.com','Rajkot','2026-06-07'),
(5,'Kabir Joshi','1979-07-08','Male','9000000005','kabir@example.com','Ahmedabad','2026-08-01'),
(6,'Mira Trivedi','1992-11-11','Female','9000000006','mira@example.com','Gandhinagar','2026-09-10');
INSERT INTO Doctors (doctor_id,name,specialization,phone_number,email,available_days,consultation_fee,experience_years) VALUES
(1,'Dr Neha Rao','Cardiology','9111111111','neha@hospital.example','Mon,Wed,Fri',1200,18),
(2,'Dr Vikram Sen','Neurology','9222222222','vikram@hospital.example','Tue,Thu',1500,12),
(3,'Dr Priya Iyer','Dermatology','9333333333','priya@hospital.example','Mon-Sat',800,4),
(4,'Dr Amit Bose','Orthopedics','9444444444','amit@hospital.example','Mon,Thu',1100,8),
(5,'Dr Sara Khan','Cardiology','9555555555','sara@hospital.example','Wed,Fri',1300,16);
INSERT INTO Departments (department_id,department_name) VALUES
(1,'Cardiology'),(2,'Neurology'),(3,'Dermatology'),(4,'Orthopedics');
INSERT INTO Doctor_Department (doctor_id,department_id) VALUES (1,1),(2,2),(3,3),(4,4),(5,1);
INSERT INTO Appointments (appointment_id,patient_id,doctor_id,appointment_date,status) VALUES
(1,1,1,'2026-05-10 10:00:00','Completed'),
(2,2,3,'2026-06-11 11:00:00','Completed'),
(3,3,2,'2026-07-12 12:00:00','Completed'),
(4,1,3,'2026-09-15 10:30:00','Completed'),
(5,4,3,'2026-11-05 09:00:00','Scheduled'),
(6,5,1,'2026-11-06 10:00:00','Scheduled'),
(7,2,4,'2026-08-20 15:00:00','Cancelled');
INSERT INTO Medical_Records (record_id,patient_id,doctor_id,diagnosis,prescription,treatment_date,admission_date,discharge_date) VALUES
(1,1,1,'Hypertension','Follow-up recommended','2026-05-10','2026-05-09','2026-05-12'),
(2,2,3,'Eczema','Topical treatment','2026-06-11',NULL,NULL),
(3,3,2,'Migraine','Review after two weeks','2026-07-12',NULL,NULL),
(4,1,3,'Acne','Skin care routine','2026-09-15',NULL,NULL),
(5,2,4,'Joint pain','Physiotherapy referral','2026-08-20',NULL,NULL),
(6,1,1,'Blood pressure review','Monitoring','2026-10-02',NULL,NULL);
INSERT INTO Billing (invoice_id,patient_id,appointment_id,amount,payment_status,payment_date) VALUES
(1,1,1,1200,'Paid','2026-05-10'),(2,2,2,800,'Paid','2026-06-11'),
(3,3,3,1500,'Paid','2026-07-12'),(4,1,4,800,'Paid','2026-09-15'),
(5,4,5,800,'Pending',NULL),(6,5,6,1200,'Pending',NULL),
(7,2,7,1100,'Cancelled',NULL);

-- 3. CRUD: examples use transaction rollback so sample data remains intact.
START TRANSACTION;
INSERT INTO Patients (name,dob,gender,phone_number,email,address,registration_date)
VALUES ('Test Patient','2000-01-01','Other','9000000099','test.patient@example.com','Old address',CURDATE());
SET @new_patient_id = LAST_INSERT_ID();
UPDATE Patients SET address='New address' WHERE patient_id=@new_patient_id;
INSERT INTO Doctors (name,specialization,consultation_fee,experience_years)
VALUES ('Dr Test','Dermatology',900,6);
SET @new_doctor_id = LAST_INSERT_ID();
INSERT INTO Appointments (patient_id,doctor_id,appointment_date,status)
VALUES (@new_patient_id,@new_doctor_id,DATE_ADD(NOW(),INTERVAL 7 DAY),'Scheduled');
DELETE FROM Appointments WHERE appointment_date < DATE_SUB(NOW(),INTERVAL 6 MONTH) AND status='Cancelled';
ROLLBACK; -- Remove ROLLBACK and use COMMIT only if you intend to save these changes.

-- 4. WHERE / HAVING / LIMIT
SELECT * FROM Patients WHERE registration_date >= DATE_SUB(CURDATE(),INTERVAL 1 YEAR);
SELECT patient_id,name,TIMESTAMPDIFF(YEAR,dob,CURDATE()) AS age FROM Patients
ORDER BY age DESC,dob ASC LIMIT 5;
SELECT * FROM Doctors WHERE consultation_fee > 1000;
SELECT doctor_id,COUNT(*) AS appointment_count FROM Appointments
GROUP BY doctor_id HAVING COUNT(*) > 1;

-- 5. AND / OR / NOT
SELECT * FROM Appointments WHERE status='Scheduled' AND doctor_id=3;
SELECT * FROM Doctors WHERE specialization IN ('Cardiology','Neurology');
SELECT DISTINCT p.* FROM Patients p JOIN Appointments a ON a.patient_id=p.patient_id
WHERE a.appointment_date >= DATE_SUB(CURDATE(),INTERVAL 1 YEAR);
-- Patients who have NOT visited in the past year (includes never-visited patients).
SELECT p.* FROM Patients p WHERE NOT EXISTS (
 SELECT 1 FROM Appointments a WHERE a.patient_id=p.patient_id
 AND a.status='Completed' AND a.appointment_date >= DATE_SUB(CURDATE(),INTERVAL 1 YEAR));

-- 6. ORDER BY / GROUP BY
SELECT * FROM Doctors ORDER BY specialization,name;
SELECT d.doctor_id,d.name,COUNT(a.appointment_id) AS patient_appointments,
 COUNT(DISTINCT a.patient_id) AS unique_patients
FROM Doctors d LEFT JOIN Appointments a ON a.doctor_id=d.doctor_id
GROUP BY d.doctor_id,d.name ORDER BY patient_appointments DESC;
SELECT dep.department_id,dep.department_name,COALESCE(SUM(CASE WHEN b.payment_status='Paid' THEN b.amount ELSE 0 END),0) AS revenue
FROM Departments dep LEFT JOIN Doctor_Department dd ON dd.department_id=dep.department_id
LEFT JOIN Appointments a ON a.doctor_id=dd.doctor_id
LEFT JOIN Billing b ON b.appointment_id=a.appointment_id
GROUP BY dep.department_id,dep.department_name ORDER BY revenue DESC;

-- 7. Aggregates
SELECT COALESCE(SUM(amount),0) AS total_revenue FROM Billing WHERE payment_status='Paid';
SELECT d.doctor_id,d.name,COUNT(a.appointment_id) AS completed_visits FROM Doctors d
LEFT JOIN Appointments a ON a.doctor_id=d.doctor_id AND a.status='Completed'
GROUP BY d.doctor_id,d.name ORDER BY completed_visits DESC LIMIT 1;
SELECT AVG(consultation_fee) AS average_consultation_fee,
 MIN(consultation_fee) AS minimum_fee,MAX(consultation_fee) AS maximum_fee,
 COUNT(*) AS total_doctors FROM Doctors;

-- 8. Relationships / joins
SELECT d.doctor_id,d.name,dep.department_name FROM Doctors d
INNER JOIN Doctor_Department dd ON dd.doctor_id=d.doctor_id
INNER JOIN Departments dep ON dep.department_id=dd.department_id;
SELECT DISTINCT p.patient_id,p.name FROM Patients p INNER JOIN Appointments a
ON a.patient_id=p.patient_id WHERE a.status='Completed';
SELECT p.patient_id,p.name,a.appointment_id,a.status FROM Patients p
LEFT JOIN Appointments a ON a.patient_id=p.patient_id AND a.status='Completed';
SELECT a.appointment_id,a.appointment_date,p.name AS patient_name FROM Appointments a
RIGHT JOIN Patients p ON p.patient_id=a.patient_id WHERE a.appointment_id IS NULL;
-- MySQL FULL OUTER JOIN equivalent (UNION removes duplicate matched rows).
SELECT p.patient_id,p.name,a.appointment_id FROM Patients p
LEFT JOIN Appointments a ON a.patient_id=p.patient_id
UNION
SELECT p.patient_id,p.name,a.appointment_id FROM Patients p
RIGHT JOIN Appointments a ON a.patient_id=p.patient_id;
-- Specifically, patients who never booked an appointment:
SELECT p.* FROM Patients p LEFT JOIN Appointments a ON a.patient_id=p.patient_id
WHERE a.appointment_id IS NULL;
-- Invoices and their appointments
SELECT b.invoice_id,b.amount,b.payment_status,a.appointment_date,a.status
FROM Billing b JOIN Appointments a ON a.appointment_id=b.appointment_id;

-- 9. Subqueries
SELECT d.doctor_id,d.name FROM Doctors d WHERE
 (SELECT COUNT(DISTINCT a.patient_id) FROM Appointments a
  WHERE a.doctor_id=d.doctor_id AND a.status='Completed') > 50;
SELECT p.patient_id,p.name,SUM(b.amount) AS amount_spent FROM Patients p
JOIN Billing b ON b.patient_id=p.patient_id WHERE b.payment_status='Paid'
GROUP BY p.patient_id,p.name ORDER BY amount_spent DESC LIMIT 1;
SELECT a.* FROM Appointments a WHERE a.doctor_id IN
 (SELECT doctor_id FROM Doctors WHERE specialization='Dermatology');

-- 10. Date and time
SELECT MONTH(appointment_date) AS month_number,MONTHNAME(appointment_date) AS month_name,
COUNT(*) AS visits FROM Appointments WHERE status='Completed'
GROUP BY MONTH(appointment_date),MONTHNAME(appointment_date) ORDER BY month_number;
SELECT record_id,patient_id,admission_date,discharge_date,
DATEDIFF(discharge_date,admission_date) AS stay_days FROM Medical_Records
WHERE admission_date IS NOT NULL AND discharge_date IS NOT NULL;
SELECT record_id,DATE_FORMAT(treatment_date,'%d-%m-%Y') AS formatted_treatment_date FROM Medical_Records;

-- 11. String manipulation
SELECT patient_id,UPPER(name) AS uppercase_name FROM Patients;
SELECT doctor_id,TRIM(name) AS trimmed_name FROM Doctors;
SELECT patient_id,COALESCE(NULLIF(TRIM(phone_number),''),'Not Available') AS phone FROM Patients;

-- 12. Window functions
WITH doctor_visits AS (
 SELECT d.doctor_id,d.name,COUNT(DISTINCT CASE WHEN a.status='Completed' THEN a.patient_id END) AS patients_treated
 FROM Doctors d LEFT JOIN Appointments a ON a.doctor_id=d.doctor_id GROUP BY d.doctor_id,d.name
) SELECT *,DENSE_RANK() OVER (ORDER BY patients_treated DESC) AS doctor_rank FROM doctor_visits;
WITH monthly_revenue AS (
 SELECT DATE_FORMAT(a.appointment_date,'%Y-%m') AS revenue_month,SUM(b.amount) AS revenue
 FROM Billing b JOIN Appointments a ON a.appointment_id=b.appointment_id
 WHERE b.payment_status='Paid' GROUP BY DATE_FORMAT(a.appointment_date,'%Y-%m')
) SELECT revenue_month,revenue,SUM(revenue) OVER (ORDER BY revenue_month) AS running_revenue FROM monthly_revenue;
SELECT appointment_id,appointment_date,COUNT(*) OVER
 (ORDER BY appointment_date,appointment_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_appointments
FROM Appointments ORDER BY appointment_date,appointment_id;

-- 13. CASE expressions
SELECT p.patient_id,p.name,COUNT(m.record_id) AS medical_record_count,
CASE WHEN COUNT(m.record_id)>5 THEN 'High'
 WHEN COUNT(m.record_id) BETWEEN 3 AND 5 THEN 'Medium' ELSE 'Low' END AS Patient_Risk_Level
FROM Patients p LEFT JOIN Medical_Records m ON m.patient_id=p.patient_id
GROUP BY p.patient_id,p.name;
SELECT doctor_id,name,experience_years,
CASE WHEN experience_years>15 THEN 'Senior'
 WHEN experience_years BETWEEN 5 AND 15 THEN 'Mid-Level' ELSE 'Junior' END AS doctor_level
FROM Doctors;
