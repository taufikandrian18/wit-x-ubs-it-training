CREATE TABLE UBS_TRAINING.EMPLOYEE (
    employee_id NUMBER UNIQUE,
    guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
    fullname VARCHAR2(255),
    email VARCHAR2(255),
    phone_number VARCHAR2(255),
    date_of_birth DATE,
    hire_date DATE,
    id_card VARCHAR2(255) UNIQUE,
    gender VARCHAR2(255),
    profile_picture_url CLOB,
    pic_id NUMBER REFERENCES UBS_TRAINING.EMPLOYEE(employee_id) ON DELETE CASCADE,
    status_user VARCHAR2(10),
    created_by VARCHAR2(100),  
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by VARCHAR2(100) NULL, 
    updated_at TIMESTAMP NULL,
    deleted_by VARCHAR2(100) NULL,
    deleted_at TIMESTAMP NULL,
    last_sync_hris TIMESTAMP
)

---

CREATE SEQUENCE UBS_TRAINING.employee_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
  
---

CREATE OR REPLACE TRIGGER UBS_TRAINING.employee_trigger
  BEFORE INSERT ON UBS_TRAINING.EMPLOYEE
  FOR EACH ROW
BEGIN
  :new.employee_id := employee_seq.nextval;
END;