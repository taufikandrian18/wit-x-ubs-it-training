CREATE TABLE UBS_TRAINING.TOKEN_AUTH (
    token_auth_id NUMBER UNIQUE,
    token_auth_name VARCHAR2(255),
    device_id VARCHAR2(255),
    device_type VARCHAR2(255),
    token VARCHAR2(355),
    token_expired TIMESTAMP NULL,
    refresh_token VARCHAR2(355),
    refresh_token_expired TIMESTAMP NULL,
    is_login NUMBER(1,0),
    user_login VARCHAR2(255),
    fcm_token VARCHAR2(255),
    ip_address VARCHAR2(255),
    created_by VARCHAR2(100),  
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by VARCHAR2(100) NULL, 
    updated_at TIMESTAMP NULL,
    deleted_by VARCHAR2(100) NULL,
    deleted_at TIMESTAMP NULL
)

---

CREATE SEQUENCE UBS_TRAINING.token_auth_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;
  
---

CREATE OR REPLACE TRIGGER UBS_TRAINING.token_auth_trigger
  BEFORE INSERT ON UBS_TRAINING.TOKEN_AUTH
  FOR EACH ROW
BEGIN
  :new.token_auth_id := token_auth_seq.nextval;
END;