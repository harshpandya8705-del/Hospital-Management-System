# Hospital Management System Using MySQL

## Project Overview

The Hospital Management System is a database management project developed using MySQL. It is designed to manage hospital operations such as patient information, doctor details, appointments, medical records, departments, and billing.

This project demonstrates SQL concepts ranging from basic CRUD operations to advanced SQL queries, including joins, subqueries, aggregate functions, window functions, and CASE expressions.

## Objectives

- Manage patient and doctor records.
- Schedule and track appointments.
- Maintain patient medical histories.
- Manage hospital billing and payments.
- Analyze hospital revenue and performance.
- Implement relational database concepts using MySQL.

## Technologies Used

- Database: MySQL 8.0+
- Tool: MySQL Workbench
- Language: SQL
- Version Control: Git & GitHub

## Project Folder Structure

```text
hospital-management-system/
│
├── hospital_management.sql
│
└── README.md
```

## Database Schema

The project contains seven interconnected tables.

### 1. Patients
Stores patient information.

- patient_id (Primary Key)
- name
- dob
- gender
- phone_number
- email
- address
- registration_date

### 2. Doctors
Stores doctor details.

- doctor_id (Primary Key)
- name
- specialization
- phone_number
- email
- available_days
- consultation_fee
- experience_years

### 3. Appointments
Stores appointment information.

- appointment_id (Primary Key)
- patient_id (Foreign Key)
- doctor_id (Foreign Key)
- appointment_date
- status (Scheduled, Completed, Cancelled)

### 4. Medical_Records
Maintains patient medical histories.

- record_id (Primary Key)
- patient_id (Foreign Key)
- doctor_id (Foreign Key)
- diagnosis
- prescription
- treatment_date
- admission_date
- discharge_date

### 5. Billing
Stores payment and invoice details.

- invoice_id (Primary Key)
- patient_id (Foreign Key)
- appointment_id (Foreign Key, Unique)
- amount
- payment_status (Paid, Pending, Cancelled)
- payment_date

### 6. Departments
Stores hospital department information.

- department_id (Primary Key)
- department_name

### 7. Doctor_Department
Mapping table connecting doctors with departments.

- doctor_id (Foreign Key)
- department_id (Foreign Key)
- Composite Primary Key (doctor_id, department_id)

## SQL Operations Implemented

### 1. CRUD Operations
- Insert new patients, doctors, and appointments.
- Update existing patient information.
- Delete appointments older than six months.

### 2. SQL Clauses
- WHERE
- HAVING
- LIMIT

### 3. SQL Operators
- AND
- OR
- NOT

### 4. Sorting
