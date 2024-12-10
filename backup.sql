CREATE TABLE UBS_TRAINING.ROLE (
  role_id NUMBER UNIQUE,
  guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
  code VARCHAR(255) NOT NULL UNIQUE,
  role_name VARCHAR(255) NOT NULL,
  order_number NUMBER,
  created_by VARCHAR2(100),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_by VARCHAR2(100) NULL,
  updated_at TIMESTAMP NULL,
  deleted_by VARCHAR2(100) NULL,
  deleted_at TIMESTAMP NULL
);

---

CREATE SEQUENCE UBS_TRAINING.role_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.role_trigger
  BEFORE INSERT ON UBS_TRAINING.ROLE
  FOR EACH ROW
BEGIN
  :new.role_id := sidebar_menu_seq.nextval;
  :new.order_number := :new.role_id;
END;

---

CREATE TABLE UBS_TRAINING.IAM_ACCESS (
  id NUMBER UNIQUE,
  guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
  is_notification NUMBER(1,0),
  role_guid VARCHAR2(32) NOT NULL UNIQUE REFERENCES UBS_TRAINING.ROLE(guid) ON DELETE CASCADE,
  created_by VARCHAR2(100),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_by VARCHAR2(100) NULL,
  updated_at TIMESTAMP NULL,
  deleted_by VARCHAR2(100) NULL,
  deleted_at TIMESTAMP NULL
);

---

CREATE SEQUENCE UBS_TRAINING.iam_access_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.iam_access_trigger
  BEFORE INSERT ON UBS_TRAINING.iam_access
  FOR EACH ROW
BEGIN
  :new.id := iam_access_seq.nextval;
END;

---

CREATE TABLE UBS_TRAINING.SIDEBAR_MENU (
  sidebar_menu_id NUMBER UNIQUE,
  guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
  code VARCHAR2(255) UNIQUE,
  text_sidebar VARCHAR2(255) NOT NULL,
  icon VARCHAR2(255),
  has_page NUMBER(1,0),
  url_path VARCHAR2(255),
  slug VARCHAR2(255),
  level_sidebar NUMBER NOT NULL,
  parent_id NUMBER REFERENCES UBS_TRAINING.SIDEBAR_MENU(SIDEBAR_MENU_ID) ON DELETE CASCADE,
  order_number NUMBER,
  created_by VARCHAR2(100),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_by VARCHAR2(100) NULL,
  updated_at TIMESTAMP NULL,
  deleted_by VARCHAR2(100) NULL,
  deleted_at TIMESTAMP NULL
);

---

CREATE SEQUENCE UBS_TRAINING.sidebar_menu_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.sidebar_menu_trigger
  BEFORE INSERT ON UBS_TRAINING.SIDEBAR_MENU
  FOR EACH ROW
BEGIN
  :new.sidebar_menu_id := sidebar_menu_seq.nextval;
  :new.order_number := :new.sidebar_menu_id;
END;

---

CREATE TABLE UBS_TRAINING.IAM_HAS_ACCESS (
  id NUMBER UNIQUE,
  guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
  is_create NUMBER(1,0) NOT NULL,
  is_read NUMBER(1,0) NOT NULL,
  is_update NUMBER(1,0) NOT NULL,
  is_delete NUMBER(1,0) NOT NULL,
  is_custom1 NUMBER(1,0) NULL,
  is_custom2 NUMBER(1,0) NULL,
  is_custom3 NUMBER(1,0) NULL,
  iam_access_guid VARCHAR2(255) NOT NULL REFERENCES UBS_TRAINING.IAM_ACCESS(GUID) ON DELETE CASCADE,
  sidebar_menu_guid VARCHAR2(255) NOT NULL REFERENCES UBS_TRAINING.SIDEBAR_MENU(GUID) ON DELETE CASCADE
);

---

CREATE SEQUENCE UBS_TRAINING.iam_has_access_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.iam_has_access_trigger
  BEFORE INSERT ON UBS_TRAINING.iam_has_access
  FOR EACH ROW
BEGIN
  :new.id := iam_has_access_seq.nextval;
END;

---

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
    role_guid  VARCHAR2(32) REFERENCES UBS_TRAINING.ROLE(GUID) ON DELETE CASCADE,
    status_user VARCHAR2(10),
    created_by VARCHAR2(100),  
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by VARCHAR2(100) NULL, 
    updated_at TIMESTAMP NULL,
    deleted_by VARCHAR2(100) NULL,
    deleted_at TIMESTAMP NULL,
    last_sync_hris TIMESTAMP
);

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

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.INSERT_EMPLOYEE (
    p_fullname VARCHAR2,
    p_email VARCHAR2,
    p_phone_number VARCHAR2,
    p_date_of_birth DATE,
    p_hire_date DATE,
    p_id_card VARCHAR2,
    p_gender VARCHAR2,
    p_profile_picture_url VARCHAR2,
    p_pic_id NUMBER,
    p_role_id VARCHAR2,
    p_status_user VARCHAR2,
    p_created_by VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN 
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_employee_id       NUMBER;
        l_guid              VARCHAR2(32);
        l_fullname          VARCHAR2(255);
        l_email             VARCHAR2(255);
        l_phone_number      VARCHAR2(255);
        l_date_of_birth     DATE;
        l_hire_date         DATE;
        l_id_card           VARCHAR2(255);
        l_gender            VARCHAR2(255);
        l_profile_picture   VARCHAR2(255);
        l_pic_id            NUMBER;
       	l_role_id            VARCHAR2(32);
        l_status_user       VARCHAR2(255);
        l_created_by        VARCHAR2(100);  
        l_created_at        TIMESTAMP DEFAULT SYSTIMESTAMP;
        l_updated_by        VARCHAR2(100) NULL;
        l_updated_at        TIMESTAMP NULL;
        l_deleted_by        VARCHAR2(100) NULL;
        l_deleted_at        TIMESTAMP NULL;
    BEGIN 
        --DBMS_OUTPUT.PUT_LINE('Debug - Departement GUID: ' || p_email);
        --DBMS_OUTPUT.PUT_LINE('Debug - Position GUID: ' || p_phone_number);
        --DBMS_OUTPUT.PUT_LINE('Debug - id card GUID: ' || p_id_card);
        
        -- Insert new row
        BEGIN
            INSERT INTO UBS_TRAINING.EMPLOYEE (
                fullname, email, phone_number,
                date_of_birth, hire_date, id_card, gender,
                profile_picture_url, pic_id, role_guid, status_user, created_by,
                updated_by, deleted_by
            )
            VALUES (
                p_fullname, p_email,
                p_phone_number, p_date_of_birth, p_hire_date, p_id_card, p_gender,
                p_profile_picture_url, p_pic_id, p_role_id, p_status_user, p_created_by,
                p_updated_by, p_deleted_by
            )
            RETURNING employee_id, guid, fullname, email, phone_number, date_of_birth, hire_date, id_card, gender, profile_picture_url, pic_id, role_guid, status_user, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at 
            INTO l_employee_id, l_guid, l_fullname, l_email, l_phone_number, l_date_of_birth, l_hire_date, l_id_card, l_gender, l_profile_picture, l_pic_id, l_role_id, l_status_user, l_created_by, l_created_at, l_updated_by, l_updated_at, l_deleted_by, l_deleted_at;
        -- Construct JSON object
           
        v_json := '{"employee_id": ' || l_employee_id ||
       ',"guid":"' || l_guid || 
      '","fullname":"' || l_fullname ||
     '","email":"' || l_email || 
    '","phone_number":"' || l_phone_number ||
   '","date_of_birth":"' || TO_CHAR(l_date_of_birth, 'YYYY-MM-DD') ||
  '","hire_date":"' || TO_CHAR(l_hire_date, 'YYYY-MM-DD') || 
 '","id_card":"' || l_id_card || 
'","gender":"' || l_gender ||
'","profile_picture":"' || l_profile_picture ||
'","pic_id": ' || NVL(l_pic_id, 0) ||
',"role_id":"' || NVL(l_role_id, '') || 
'","status_user":"' || l_status_user ||
'","created_by":"' ||  NVL(l_created_by, '') || 
'","created_at":"' ||  TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || 
'","updated_by":"' || NVL(l_updated_by, '') || 
'","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"}';
    
           EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code":"' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
                DBMS_OUTPUT.PUT_LINE('Error: ' || v_json);
                -- You can choose to perform additional actions or continue without raising an error
        END;

        EXCEPTION
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
            DBMS_OUTPUT.PUT_LINE('Error: ' || v_json);
            -- Re-raise the exception to propagate it to the caller
            RAISE;
    END;

    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_employee (
    p_guid VARCHAR2,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.EMPLOYEE
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_EMPLOYEE_USERNAME" (
    p_username VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"employee_id":' || employee_id || ',"guid":"' || guid ||
        '","fullname":"' || fullname || '","email":"' || email ||
        '","phone_number":"' || phone_number || '","date_of_birth":"' || TO_CHAR(date_of_birth, 'YYYY-MM-DD') ||
        '","hire_date":"' || TO_CHAR(hire_date, 'YYYY-MM-DD') || '","id_card":"' || id_card ||
        '","gender":"' || gender || '","profile_picture_url":"' || profile_picture_url ||
        '","pic_id":' || NVL(pic_id, 0) || '","status_user":"' || status_user ||
        '","last_sync_hris":"' || NVL(last_sync_hris, '') || '","created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","deleted_by":"' || NVL(deleted_by, '') || '","deleted_at":"' || TO_CHAR(deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json
    FROM UBS_TRAINING.EMPLOYEE
    WHERE id_card = p_username AND deleted_at IS NULL;

    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_employee (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"employee_id":' || employee_id || ',"guid":"' || guid ||
        '","fullname":"' || fullname || '","email":"' || email ||
        '","phone_number":"' || phone_number || '","date_of_birth":"' || TO_CHAR(date_of_birth, 'YYYY-MM-DD') ||
        '","hire_date":"' || TO_CHAR(hire_date, 'YYYY-MM-DD') || '","id_card":"' || id_card ||
        '","gender":"' || gender || '","profile_picture_url":"' || profile_picture_url ||
        '","pic":' || UBS_TRAINING.detail_pic_l(PIC_ID,0,5) || 
    	',"role":' || UBS_TRAINING.detail_role_l(ROLE_GUID,0,5) || 
        ',"status_user":"' || status_user ||
        '","last_sync_hris":"' || NVL(last_sync_hris, '') || '","created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","deleted_by":"' || NVL(deleted_by, '') || '","deleted_at":"' || TO_CHAR(deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json 
    FROM UBS_TRAINING.EMPLOYEE
    WHERE guid = p_guid AND deleted_at IS NULL;

    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN 'null';
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN 'null';
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_employee_username (
    p_username VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"employee_id":' || employee_id || ',"guid":"' || guid ||
        '","fullname":"' || fullname || '","email":"' || email ||
        '","phone_number":"' || phone_number || '","date_of_birth":"' || TO_CHAR(date_of_birth, 'YYYY-MM-DD') ||
        '","hire_date":"' || TO_CHAR(hire_date, 'YYYY-MM-DD') || '","id_card":"' || id_card ||
        '","gender":"' || gender || '","profile_picture_url":"' || profile_picture_url ||
        '","pic":' || UBS_TRAINING.detail_pic_l(PIC_ID,0,5) || 
    	',"role":' || UBS_TRAINING.detail_role_l(ROLE_GUID,0,5) || 
        ',"status_user":"' || status_user ||
        '","last_sync_hris":"' || NVL(last_sync_hris, '') || '","created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","deleted_by":"' || NVL(deleted_by, '') || '","deleted_at":"' || TO_CHAR(deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json 
    FROM UBS_TRAINING.EMPLOYEE
    WHERE email = p_username AND deleted_at IS NULL;

    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN 'null';
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN 'null';
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_employee (
    p_guid VARCHAR2,
    p_fullname VARCHAR2,
    p_email VARCHAR2,
    p_phone_number VARCHAR2,
    p_date_of_birth DATE,
    p_hire_date DATE,
    p_id_card VARCHAR2,
    p_gender VARCHAR2,
    p_profile_picture_url VARCHAR2,
    p_pic_id NUMBER,
    p_status_user VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_employee_id       NUMBER;
        l_guid              VARCHAR2(32); -- Adjust the size based on your column definition
        l_fullname          VARCHAR2(255); -- Adjust the size based on your column definition
        l_email             VARCHAR2(255);
        l_phone_number      VARCHAR2(255);
        l_date_of_birth     DATE;
        l_hire_date         DATE;
        l_id_card           VARCHAR2(255);
        l_gender            VARCHAR2(255);
        l_profile_picture   VARCHAR2(255);
        l_pic_id            NUMBER;
        l_status_user       VARCHAR2(255);
        l_created_by        VARCHAR2(100);  
        l_created_at        TIMESTAMP DEFAULT SYSTIMESTAMP;
        l_updated_by        VARCHAR2(100) NULL;
        l_updated_at        TIMESTAMP NULL;
        l_deleted_by        VARCHAR2(100) NULL;
        l_deleted_at        TIMESTAMP NULL;
    BEGIN
	    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.EMPLOYEE
        SET
            fullname = p_fullname,
            email = p_email,
            phone_number = p_phone_number,
            date_of_birth = p_date_of_birth,
            hire_date = p_hire_date,
            id_card = p_id_card,
            gender = p_gender,
            profile_picture_url = p_profile_picture_url,
            pic_id = p_pic_id,
            status_user = p_status_user,
            updated_by = p_updated_by,
            updated_at = SYSTIMESTAMP
        WHERE
            guid = p_guid
        RETURNING
            employee_id,
            guid,
            fullname,
            email,
            phone_number,
            date_of_birth,
            hire_date,
            id_card,
            gender,
            profile_picture_url,
            pic_id,
            status_user,
            created_by,
            created_at,
            updated_by,
            updated_at,
            deleted_by,
            deleted_at
        INTO
            l_employee_id,
            l_guid,
            l_fullname,
            l_email,
            l_phone_number,
            l_date_of_birth,
            l_hire_date,
            l_id_card,
            l_gender,
            l_profile_picture,
            l_pic_id,
            l_status_user,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at,
            l_deleted_by,
            l_deleted_at;
        
        -- Construct JSON object
        v_json := '{"employee_id": ' || l_employee_id || 
       ',"guid":"' || l_guid || 
      '","fullname":"' || l_fullname || 
     '","email":"' || l_email || 
    '","phone_number":"' || l_phone_number || 
   '","date_of_birth":"' || TO_CHAR(l_date_of_birth, 'YYYY-MM-DD') || 
  '","hire_date":"' || TO_CHAR(l_hire_date, 'YYYY-MM-DD') || 
 '","id_card":"' || l_id_card || 
'","gender":"' || l_gender || 
'","profile_picture":"' || l_profile_picture || 
'","pic_id": ' || NVL(l_pic_id, 0) || 
'","status_user":"' || l_status_user ||
'","created_by":"' || l_created_by || 
'","created_at":"' ||  TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') ||
'","updated_by":"' || l_updated_by || 
'","updated_at":"' ||  TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"}';
EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code":"' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
                DBMS_OUTPUT.PUT_LINE('Error: ' || v_json);
                -- You can choose to perform additional actions or continue without raising an error
        END;

        EXCEPTION
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
            DBMS_OUTPUT.PUT_LINE('Error: ' || v_json);
            -- Re-raise the exception to propagate it to the caller
            RAISE;
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_EMPLOYEE" (
    p_set_guid NUMBER,
    p_value_guid VARCHAR2,
    p_set_fullname NUMBER,
    p_value_fullname VARCHAR2,
    p_set_email NUMBER,
    p_value_email VARCHAR2,
    p_set_phone_number NUMBER,
    p_value_phone_number VARCHAR2,
    p_set_date_of_birth NUMBER,
    p_value_date_of_birth DATE,
    p_set_hire_date NUMBER,
    p_value_hire_date DATE,
    p_set_id_card NUMBER,
    p_value_id_card VARCHAR2,
    p_set_gender NUMBER,
    p_value_gender VARCHAR2,
    p_set_pic_id NUMBER,
    p_value_pic_id NUMBER,
    p_set_role_id NUMBER,
    p_value_role_id VARCHAR2,
    p_set_status_user NUMBER,
    p_value_status_user VARCHAR2,
    p_set_created_by NUMBER,
    p_value_created_by VARCHAR2,
    P_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN UBS_TRAINING.CLOBTABLE
IS
    v_json CLOB := ' ';
   	v_clob UBS_TRAINING.CLOBTABLE;
BEGIN
    DECLARE
        v_employee_data CLOB; -- Adjust the size based on your data
        v_employee_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
	    v_clob:=UBS_TRAINING.CLOBTABLE();
        -- Initialize CLOB for v_employee_data
        DBMS_LOB.CREATETEMPORARY(v_employee_data, TRUE);
        -- make limit variable
        IF P_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := P_limit_data;
        END IF;
        -- make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * P_limit_data + 1;
        END IF;
        -- Query for employee data
 		-- Query for employee count
        SELECT COUNT(*)
        INTO v_employee_count
        FROM UBS_TRAINING.EMPLOYEE emp
        WHERE
            (p_set_guid != 1 OR ((1=1) AND emp.GUID = p_value_guid))
            AND (p_set_fullname != 1 OR ((1=1) AND UPPER(emp.FULLNAME) LIKE UPPER(p_value_fullname)))
            AND (p_set_email != 1 OR ((1=1) AND UPPER(emp.EMAIL) LIKE UPPER(p_value_email)))
            AND (p_set_phone_number != 1 OR ((1=1) AND UPPER(emp.PHONE_NUMBER) LIKE UPPER(p_value_phone_number)))
            AND (p_set_date_of_birth != 1 OR ((1=1) AND TRUNC(emp.DATE_OF_BIRTH) = p_value_date_of_birth))
            AND (p_set_hire_date != 1 OR ((1=1) AND TRUNC(emp.HIRE_DATE) = p_value_hire_date))
            AND (p_set_id_card != 1 OR ((1=1) AND UPPER(emp.ID_CARD) LIKE UPPER(p_value_id_card)))
            AND (p_set_gender != 1 OR ((1=1) AND UPPER(emp.GENDER) = UPPER(p_value_gender)))
            AND (p_set_pic_id != 1 OR ((1=1) AND emp.PIC_ID = p_value_pic_id))
            AND (p_set_role_id != 1 OR ((1=1) AND emp.ROLE_GUID = p_value_role_id))
            AND (p_set_status_user != 1 OR ((1=1) AND LOWER(emp.STATUS_USER) IN (
					    SELECT LOWER(TRIM(VALUE)) AS status_user FROM XMLTABLE(XMLNAMESPACES(DEFAULT 'http://www.w3.org/2001/XMLSchema-instance'), ('"' || REPLACE(p_value_status_user, ',', '","') || '"') COLUMNS VALUE VARCHAR2(4000) PATH '.')
					)))
            AND (p_set_created_by != 1 OR ((1=1) AND UPPER(emp.CREATED_BY) LIKE UPPER(p_value_created_by)))
            AND emp.DELETED_AT IS NULL;
        -- Construct the JSON object
           IF v_employee_count = 0 THEN
           v_clob.EXTEND;
        v_clob(1) := '{"employee_data":[' || v_employee_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_employee_count / limit_value) || ',"total_data":' || v_employee_count || '}';
		    -- Return the JSON
		    RETURN v_clob;
       END IF;
        FOR emp_rec IN (
        SELECT * FROM(
            SELECT
                GUID,
                EMPLOYEE_ID,
			    FULLNAME,
			    EMAIL,
			    PHONE_NUMBER,
			    DATE_OF_BIRTH,
			    HIRE_DATE,
			    ID_CARD,
			    GENDER,
			    ROLE_GUID,
			    PROFILE_PICTURE_URL,
			    PIC_ID,
			    STATUS_USER,
			    CREATED_AT,
			    CREATED_BY,
			    UPDATED_AT,
			    UPDATED_BY,
			    LAST_SYNC_HRIS,
			    ROWNUM AS rnum
            FROM
                (
			    SELECT
			        emp.GUID,
			        emp.EMPLOYEE_ID,
			        emp.FULLNAME,
			        emp.EMAIL,
			        emp.PHONE_NUMBER,
			        emp.DATE_OF_BIRTH,
			        emp.HIRE_DATE,
			        emp.ID_CARD,
			        emp.GENDER,
			        emp.ROLE_GUID,
			        emp.PROFILE_PICTURE_URL,
			        emp.PIC_ID,
			        emp.STATUS_USER,
			        emp.CREATED_AT,
			        emp.CREATED_BY,
			        emp.UPDATED_AT,
			        emp.UPDATED_BY,
			        emp.LAST_SYNC_HRIS
			    FROM 
			        UBS_TRAINING.EMPLOYEE emp
			    WHERE
			        emp.DELETED_AT IS NULL
			        AND (p_set_guid != 1 OR ((1=1) AND emp.GUID = p_value_guid))
	                AND (p_set_fullname != 1 OR ((1=1) AND UPPER(emp.FULLNAME) LIKE UPPER(p_value_fullname)))
	                AND (p_set_email != 1 OR ((1=1) AND UPPER(emp.EMAIL) LIKE UPPER(p_value_email)))
	                AND (p_set_phone_number != 1 OR ((1=1) AND UPPER(emp.PHONE_NUMBER) LIKE UPPER(p_value_phone_number)))
	                AND (p_set_date_of_birth != 1 OR ((1=1) AND TRUNC(emp.DATE_OF_BIRTH) = p_value_date_of_birth))
	                AND (p_set_hire_date != 1 OR ((1=1) AND TRUNC(emp.HIRE_DATE) = p_value_hire_date))
	                AND (p_set_id_card != 1 OR ((1=1) AND UPPER(emp.ID_CARD) LIKE UPPER(p_value_id_card)))
	                AND (p_set_gender != 1 OR ((1=1) AND UPPER(emp.GENDER) = UPPER(p_value_gender)))
	                AND (p_set_pic_id != 1 OR ((1=1) AND emp.PIC_ID = p_value_pic_id))
                    AND (p_set_role_id != 1 OR ((1=1) AND emp.ROLE_GUID = p_value_role_id))
	                AND (p_set_status_user != 1 OR ((1=1) AND LOWER(emp.STATUS_USER) IN (
					    SELECT LOWER(TRIM(VALUE)) AS status_user FROM XMLTABLE(XMLNAMESPACES(DEFAULT 'http://www.w3.org/2001/XMLSchema-instance'), ('"' || REPLACE(p_value_status_user, ',', '","') || '"') COLUMNS VALUE VARCHAR2(4000) PATH '.')
					)))
	                AND (p_set_created_by != 1 OR ((1=1) AND UPPER(emp.CREATED_BY) LIKE UPPER(p_value_created_by)))
	                AND emp.DELETED_AT IS NULL
	                ORDER BY
	                CASE WHEN UPPER(p_sort_value) = 'EMPLOYEE_ID ASC' THEN EMP.EMPLOYEE_ID END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'EMPLOYEE_ID DESC' THEN EMP.EMPLOYEE_ID END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'FULLNAME ASC' THEN EMP.FULLNAME END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'FULLNAME DESC' THEN EMP.FULLNAME END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'GUID ASC' THEN EMP.GUID END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'GUID DESC' THEN EMP.GUID END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'PHONE_NUMBER ASC' THEN EMP.PHONE_NUMBER END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'PHONE_NUMBER DESC' THEN EMP.PHONE_NUMBER END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'DATE_OF_BIRTH ASC' THEN EMP.DATE_OF_BIRTH END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'DATE_OF_BIRTH DESC' THEN EMP.DATE_OF_BIRTH END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'HIRE_DATE ASC' THEN EMP.HIRE_DATE END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'HIRE_DATE DESC' THEN EMP.HIRE_DATE END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'ID_CARD ASC' THEN EMP.ID_CARD END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'ID_CARD DESC' THEN EMP.ID_CARD END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'GENDER ASC' THEN EMP.GENDER END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'GENDER DESC' THEN EMP.GENDER END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'PIC_ID ASC' THEN EMP.PIC_ID END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'PIC_ID DESC' THEN EMP.PIC_ID END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'STATUS_USER ASC' THEN EMP.STATUS_USER END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'STATUS_USER DESC' THEN EMP.STATUS_USER END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT ASC' THEN EMP.CREATED_AT END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT DESC' THEN EMP.CREATED_AT END DESC,
	                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY ASC' THEN EMP.CREATED_BY END ASC,
	                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY DESC' THEN EMP.CREATED_BY END DESC,
	                emp.CREATED_AT DESC
			))
            WHERE
                rnum BETWEEN offset_value AND (offset_value + limit_value - 1)
            
        )
        
        LOOP
            -- Append the JSON representation of the current record to the CLOB
	        v_employee_data := '{"guid":"' || emp_rec.GUID || 
            '","employee_id":"' || emp_rec.EMPLOYEE_ID || 
           	'","fullname":"' || emp_rec.FULLNAME || 
         	'","email":"' || emp_rec.EMAIL || 
         	'","phone_number":"' || emp_rec.PHONE_NUMBER || 
        	'","date_of_birth":"' || TO_CHAR(emp_rec.DATE_OF_BIRTH, 'YYYY-MM-DD') || 
        	'","hire_date":"' || TO_CHAR(emp_rec.HIRE_DATE, 'YYYY-MM-DD') || 
        	'","id_card":"' || emp_rec.ID_CARD || 
        	'","gender":"' || emp_rec.GENDER || 
        	'","profile_picture_url":"' || emp_rec.PROFILE_PICTURE_URL || 
        	'","pic":' || UBS_TRAINING.detail_pic_l(emp_rec.PIC_ID,0,5) || 
        	',"role":' || UBS_TRAINING.detail_role_l(emp_rec.ROLE_GUID,0,5) || 
        	',"status_user":"' || emp_rec.STATUS_USER || 
        	'","created_at":"' || TO_CHAR(emp_rec.CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","created_by":"' || emp_rec.CREATED_BY || 
        	'","updated_at":"' || TO_CHAR(emp_rec.UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","updated_by":"' || NVL(emp_rec.UPDATED_BY,'') || 
        	'","last_sync_hris":"' || TO_CHAR(emp_rec.LAST_SYNC_HRIS, 'YYYY-MM-DD HH24:MI:SS') ||'"}';
  
            
            -- Append a comma to separate JSON objects (except for the last one)
           
           IF v_clob.COUNT = 0 THEN 
        	   v_clob.EXTEND;
        	   v_clob(1):=v_employee_data||',';
        	ELSE
        		IF (LENGTH(v_clob(v_clob.COUNT))+LENGTH(v_employee_data)) > 32000 THEN
        		v_clob.EXTEND;
        	    v_clob(v_clob.COUNT):=v_clob(v_clob.COUNT) || v_employee_data||',';
        		ELSE
        		v_clob(v_clob.COUNT):=v_clob(v_clob.COUNT)|| v_employee_data ;
        		v_clob(v_clob.COUNT):=v_clob(v_clob.COUNT)||',';
        	  END IF;
        	END IF;
        END LOOP;
        -- Remove the trailing comma
        DBMS_LOB.TRIM(v_clob(v_clob.COUNT), DBMS_LOB.GETLENGTH(v_clob(v_clob.COUNT)) - 1);
       	v_clob(1):='{"employee_data":[' || v_clob(1);
        v_clob(v_clob.COUNT):=v_clob(v_clob.COUNT) || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_employee_count / limit_value) || ',"total_data":' || v_employee_count || '}';
        END;
		RETURN v_clob;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_EMPLOYEE_IS_ACTIVE" (
    p_username VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"employee_id":' || employee_id || ',"guid":"' || guid ||
        '","fullname":"' || fullname || '","email":"' || email ||
        '","phone_number":"' || phone_number || '","date_of_birth":"' || TO_CHAR(date_of_birth, 'YYYY-MM-DD') ||
        '","hire_date":"' || TO_CHAR(hire_date, 'YYYY-MM-DD') || '","id_card":"' || id_card ||
        '","gender":"' || gender || '","profile_picture_url":"' || profile_picture_url ||
        '","pic_id":' || NVL(pic_id, 0) || ',"status_user":"' || status_user ||
        '","last_sync_hris":"' || NVL(last_sync_hris, '') || '","created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","deleted_by":"' || NVL(deleted_by, '') || '","deleted_at":"' || TO_CHAR(deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json
    FROM UBS_TRAINING.EMPLOYEE
    WHERE id_card = p_username AND status_user = 'Active' AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.DETAIL_PIC_C(
    p_guid NUMBER
)
RETURN NUMBER 
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(EMPLOYEE_ID) 
    INTO v_count 
    FROM UBS_TRAINING.EMPLOYEE
    WHERE EMPLOYEE_ID = p_guid;
    RETURN v_count;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.DETAIL_PIC_L (
    p_guid NUMBER,
    p_len NUMBER,
    p_row_limit NUMBER
)
RETURN CLOB
IS
     v_json CLOB := '{}'; -- Initialize with an opening bracket for JSON ARRAY
BEGIN
    SELECT 
       '{"guid":"' || GUID || 
           	'","fullname":"' || FULLNAME || 
         	'","email":"' || EMAIL || 
         	'","phone_number":"' || PHONE_NUMBER || 
        	'","date_of_birth":"' || TO_CHAR(DATE_OF_BIRTH, 'YYYY-MM-DD') || 
        	'","hire_date":"' || TO_CHAR(HIRE_DATE, 'YYYY-MM-DD') || 
        	'","id_card":"' || ID_CARD || 
        	'","gender":"' || GENDER || 
        	'","profile_picture_url":"' || PROFILE_PICTURE_URL || 
        	'","pic_id":' || NVL(PIC_ID,0) ||  
        	',"role_id":"' || ROLE_GUID || 
        	',"status_user":"' || STATUS_USER || 
        	'","created_at":"' || TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","created_by":"' || CREATED_BY || 
        	'","updated_at":"' || TO_CHAR(UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","updated_by":"' || NVL(UPDATED_BY,'') || '"}'
    INTO v_json
    FROM UBS_TRAINING.EMPLOYEE
    WHERE EMPLOYEE_ID  = p_guid AND deleted_at IS NULL;
    RETURN v_json;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN 'null';
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.DETAIL_ROLE_C(
    p_guid NUMBER
)
RETURN NUMBER 
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(ROLE_ID) 
    INTO v_count 
    FROM UBS_TRAINING.ROLE
    WHERE ROLE_ID = p_guid;
    RETURN v_count;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.DETAIL_ROLE_L (
    p_guid varchar2,
    p_len NUMBER,
    p_row_limit NUMBER
)
RETURN CLOB
IS
     v_json CLOB := '{}'; -- Initialize with an opening bracket for JSON ARRAY
BEGIN
   SELECT 
        '{"guid":"' || GUID || 
       	'","role_id":' || role_id|| 
       	',"order_number":' || order_number ||
     	',"code":"' || code || 
     	'","role_name":"' || role_name ||'"}'
    INTO v_json
    FROM UBS_TRAINING.ROLE
    WHERE GUID  = p_guid AND deleted_at IS NULL;
    RETURN v_json;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN 'null';
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.DETAIL_PIC_K (
    p_guid NUMBER,
    p_len NUMBER,
    p_row_limit NUMBER
)
RETURN CLOB
IS
     v_json CLOB := '{}'; -- Initialize with an opening bracket for JSON ARRAY
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"guid":"' || GUID || 
           	'","fullname":"' || FULLNAME || 
         	'","email":"' || EMAIL || 
         	'","phone_number":"' || PHONE_NUMBER || 
        	'","date_of_birth":"' || TO_CHAR(DATE_OF_BIRTH, 'YYYY-MM-DD') || 
        	'","hire_date":"' || TO_CHAR(HIRE_DATE, 'YYYY-MM-DD') || 
        	'","id_card":"' || ID_CARD || 
        	'","gender":"' || GENDER || 
        	'","profile_picture_url":"' || PROFILE_PICTURE_URL || 
        	'","pic_id":' || NVL(PIC_ID,0) || 
        	',"role_id":"' || ROLE_GUID || 
        	',"status_user":"' || STATUS_USER || 
        	'","created_at":"' || TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","created_by":"' || CREATED_BY || 
        	'","updated_at":"' || TO_CHAR(UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS') || 
        	'","updated_by":"' || NVL(UPDATED_BY,'') || '"}'
    INTO v_json
    FROM UBS_TRAINING.EMPLOYEE
    WHERE EMPLOYEE_ID  = p_guid AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_ROLE_KEY"
(
	p_guid VARCHAR2
)
RETURN CLOB
IS
v_json CLOB :='{}';
BEGIN
    SELECT 
        '{"guid":"' || guid ||
        '","id":' ||role_id||
        ',"code":"' || code ||
        '","role_name":"' || role_name ||
        '","order_number":' || order_number ||
        '}' 
    INTO v_json
    FROM UBS_TRAINING.ROLE
    WHERE guid = p_guid AND deleted_at IS NULL;

    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'null';
    WHEN OTHERS THEN
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_TO_BOOLEAN" 
(
	p_num NUMBER
)
RETURN VARCHAR2
IS
	v_bool VARCHAR2(255) :='';
BEGIN
	IF p_num IS NULL THEN
		v_bool:=TO_CHAR('null');
		RETURN v_bool;
	END IF;
	
    IF p_num = 1 THEN
        v_bool := 'true';
    ELSE
        v_bool := 'false';
    END IF;
    
    RETURN v_bool; -- Add the semicolon here
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING."UPDATE_PROFILE_PHOTO_EMP"
(
	p_url VARCHAR2,
	p_guid VARCHAR2
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.EMPLOYEE
    SET
        PROFILE_PICTURE_URL = p_url
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_sidebar_menu (
    p_code VARCHAR2,
    p_text VARCHAR2,
    p_icon VARCHAR2,
    p_has_page NUMBER,
    p_url_path VARCHAR2,
    p_slug VARCHAR2,
    p_level NUMBER,
    p_parent_id NUMBER,
    p_created_by VARCHAR2,
    v_error OUT VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_guid VARCHAR2(32);
        l_code VARCHAR2(255);
        l_text_sidebar VARCHAR2(255);
        l_icon VARCHAR2(255);
        l_has_page NUMBER(1,0);
        l_url_path VARCHAR2(255);
        l_slug VARCHAR2(255);
        l_level_sidebar NUMBER;
        l_parent_id NUMBER;
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP DEFAULT SYSTIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.sidebar_menu (
            code,
            text_sidebar,
            icon,
            has_page,
            url_path,
            slug,
            level_sidebar,
            parent_id,
            created_by
        )
        VALUES (
            p_code,
            p_text,
            p_icon,
            p_has_page,
            p_url_path,
            p_slug,
            p_level,
            p_parent_id,
            p_created_by
        )
        RETURNING 
            guid,
            code,
            text_sidebar,
            icon,
            has_page,
            url_path,
            slug,
            level_sidebar,
            parent_id,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at,
            deleted_by,
            deleted_at
        INTO 
            l_guid,
            l_code,
            l_text_sidebar,
            l_icon,
            l_has_page,
            l_url_path,
            l_slug,
            l_level_sidebar,
            l_parent_id,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at,
            l_deleted_by,
            l_deleted_at;
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","code":"' || l_code || '","text_sidebar":"' || l_text_sidebar || '","icon":"' || l_icon || '","has_page":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_has_page) || ',"url_path":"' || l_url_path || '","slug":"' || l_slug || '","level_sidebar":' || l_level_sidebar || ',"parent_id":' || UBS_TRAINING.DETAIL_SIDEBAR_MENU_PARENT(NVL(l_parent_id, 0)) || ',"order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '","deleted_by":"' || NVL(l_deleted_by, '') || '","deleted_at":"' || TO_CHAR(l_deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}';
    END;
    -- Return the JSON
    RETURN v_json;
      EXCEPTION
    WHEN OTHERS THEN
        -- Check for the specific constraint violation error
        IF SQLCODE = -00001 THEN
           v_error:='constraint violation';
        ELSE
        	v_error:=SQLERRM;
        END IF;
   	RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_sidebar_menu (
    p_guid VARCHAR2,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.sidebar_menu
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_SIDEBAR_MENU_BY_GUID" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"sidebar_menu_id":' || sidebar_menu_id || ',"guid":"' || guid ||
        '","code":"' || code || '","text_sidebar":"' || text_sidebar ||
        '","icon":"' || icon || '","has_page":' || UBS_TRAINING.detail_to_boolean(has_page) ||
        ',"url_path":"' || NVL(url_path, '') || '","slug":"' || slug ||
        '","level_sidebar":' || level_sidebar || ',"parent":' || UBS_TRAINING.detail_sidebar_menu_parent(NVL(parent_id, 0)) || ',"order_number":' || order_number ||
        ',"created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","deleted_by":"' || NVL(deleted_by, '') || '","deleted_at":"' || TO_CHAR(deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json
    FROM UBS_TRAINING.SIDEBAR_MENU
    WHERE guid = p_guid AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_sidebar_menu (
    p_guid VARCHAR2,
    p_code VARCHAR2,
    p_text VARCHAR2,
    p_icon VARCHAR2,
    p_has_page NUMBER,
    p_url_path VARCHAR2,
    p_slug VARCHAR2,
    p_level NUMBER,
    p_parent_id NUMBER,
    p_order_number NUMBER,
    p_updated_by VARCHAR2,
    v_error OUT VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_guid VARCHAR2(32);
        l_code VARCHAR2(255);
        l_text_sidebar VARCHAR2(255);
        l_icon VARCHAR2(255);
        l_has_page NUMBER(1,0);
        l_url_path VARCHAR2(255);
        l_slug VARCHAR2(255);
        l_level_sidebar NUMBER;
        l_parent_id NUMBER;
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP DEFAULT SYSTIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        UPDATE UBS_TRAINING.sidebar_menu SET
            code=p_code,
            text_sidebar=p_text,
            icon=p_icon,
            has_page=p_has_page,
            url_path=p_url_path,
            slug=p_slug,
            level_sidebar=p_level,
            parent_id=p_parent_id,
            order_number=p_order_number,
            updated_by=p_updated_by,
            updated_at=SYSTIMESTAMP
        WHERE 
            guid=p_guid
        RETURNING 
            guid,
            code,
            text_sidebar,
            icon,
            has_page,
            url_path,
            slug,
            level_sidebar,
            parent_id,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at,
            deleted_by,
            deleted_at
        INTO 
            l_guid,
            l_code,
            l_text_sidebar,
            l_icon,
            l_has_page,
            l_url_path,
            l_slug,
            l_level_sidebar,
            l_parent_id,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at,
            l_deleted_by,
            l_deleted_at;
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","code":"' || l_code || '","text_sidebar":"' || l_text_sidebar || '","icon":"' || l_icon || '","has_page":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_has_page) || ',"url_path":"' || l_url_path || '","slug":"' || l_slug || '","level_sidebar":' || l_level_sidebar || ',"parent":' || UBS_TRAINING.DETAIL_SIDEBAR_MENU_PARENT(NVL(l_parent_id, 0)) || ',"order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '","deleted_by":"' || NVL(l_deleted_by, '') || '","deleted_at":"' || TO_CHAR(l_deleted_at, 'YYYY-MM-DD HH24:MI:SS') || '"}';
    END;
    RETURN v_json;
      EXCEPTION
    WHEN OTHERS THEN
        -- Check for the specific constraint violation error
        IF SQLCODE = -00001 THEN
           v_error:='constraint violation';
        ELSE
        	v_error:=SQLERRM;
        END IF;
   	RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_SIDEBARMENU" (
    p_set_code NUMBER,
    p_value_code VARCHAR2,
    p_set_text_sidebar NUMBER,
    p_value_text_sidebar VARCHAR2,
    p_set_level_sidebar NUMBER,
    p_value_level_sidebar NUMBER,
    p_set_parent_id NUMBER,
    p_value_parent_id NUMBER,
    p_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    DECLARE
        v_sidebarmenu_data CLOB; -- Adjust the size based on your data
        v_sidebarmenu_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
	    
        DBMS_LOB.CREATETEMPORARY(v_sidebarmenu_data, TRUE);
        -- make limit variable
        IF p_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := p_limit_data;
        END IF;
        -- make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * p_limit_data + 1;
        END IF;
        -- Query for sidebar menu data
        SELECT COUNT(*)
        INTO v_sidebarmenu_count
        FROM UBS_TRAINING.SIDEBAR_MENU s
        WHERE
                (p_set_code != 1 OR ((1=1) AND UPPER(s.CODE) LIKE UPPER(p_value_code)))
                AND (p_set_text_sidebar != 1 OR ((1=1) AND UPPER(s.TEXT_SIDEBAR) LIKE UPPER(p_value_text_sidebar)))
                AND (p_set_level_sidebar != 1 OR ((1=1) AND s.LEVEL_SIDEBAR = p_value_level_sidebar))
                AND (p_set_parent_id != 1 OR ((1=1) AND s.PARENT_ID = p_value_parent_id))
                AND s.DELETED_AT IS NULL;
       	IF v_sidebarmenu_count = 0 THEN
       		v_json := '{"sidebarmenu_data":[' || v_sidebarmenu_data || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_sidebarmenu_count / limit_value) || ',"total_data":' || v_sidebarmenu_count || '}';
       		RETURN v_json;
       	END IF;
       
       IF CEIL(v_sidebarmenu_count / limit_value)<p_offset_page THEN
              		v_json := '{"sidebarmenu_data":[' || v_sidebarmenu_data || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_sidebarmenu_count / limit_value) || ',"total_data":' || v_sidebarmenu_count || '}';
       		RETURN v_json;
       	END IF;
       
        FOR s_rec IN(
        SELECT * FROM (
        	SELECT
        		GUID,
        		CODE,
        		TEXT_SIDEBAR,
        		ICON,
        		HAS_PAGE,
        		URL_PATH,
        		SLUG,
        		LEVEL_SIDEBAR,
        		PARENT_ID,
        		ORDER_NUMBER,
        		CREATED_AT,
        		CREATED_BY,
        		UPDATED_AT,
        		UPDATED_BY,
                ROWNUM AS rnum
        	FROM
        		(
            SELECT
                s.GUID,
                s.CODE,
                s.TEXT_SIDEBAR,
                s.ICON,
                s.HAS_PAGE,
                s.URL_PATH,
                s.SLUG,
                s.LEVEL_SIDEBAR,
                s.PARENT_ID,
                s.ORDER_NUMBER,
                s.CREATED_AT,
                s.CREATED_BY,
                s.UPDATED_AT,
                s.UPDATED_BY
            FROM
                UBS_TRAINING.SIDEBAR_MENU s
            WHERE
                (p_set_code != 1 OR ((1=1) AND UPPER(s.CODE) LIKE UPPER(p_value_code)))
                AND (p_set_text_sidebar != 1 OR ((1=1) AND UPPER(s.TEXT_SIDEBAR) LIKE UPPER(p_value_text_sidebar)))
                AND (p_set_level_sidebar != 1 OR ((1=1) AND s.LEVEL_SIDEBAR = p_value_level_sidebar))
                AND (p_set_parent_id != 1 OR ((1=1) AND s.PARENT_ID = p_value_parent_id))
                AND s.DELETED_AT IS NULL
            ORDER BY
                CASE WHEN UPPER(p_sort_value) = 'SIDEBAR_MENU_ID ASC' THEN s.SIDEBAR_MENU_ID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'SIDEBAR_MENU_ID DESC' THEN s.SIDEBAR_MENU_ID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'GUID ASC' THEN s.GUID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'GUID DESC' THEN s.GUID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CODE ASC' THEN s.CODE END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CODE DESC' THEN s.CODE END DESC,
                CASE WHEN UPPER(p_sort_value) = 'TEXT_SIDEBAR ASC' THEN s.TEXT_SIDEBAR END ASC,
                CASE WHEN UPPER(p_sort_value) = 'TEXT_SIDEBAR DESC' THEN s.TEXT_SIDEBAR END DESC,
                CASE WHEN UPPER(p_sort_value) = 'ICON ASC' THEN s.ICON END ASC,
                CASE WHEN UPPER(p_sort_value) = 'ICON DESC' THEN s.ICON END DESC,
                CASE WHEN UPPER(p_sort_value) = 'HAS_PAGE ASC' THEN s.HAS_PAGE END ASC,
                CASE WHEN UPPER(p_sort_value) = 'HAS_PAGE DESC' THEN s.HAS_PAGE END DESC,
                CASE WHEN UPPER(p_sort_value) = 'URL_PATH ASC' THEN s.URL_PATH END ASC,
                CASE WHEN UPPER(p_sort_value) = 'URL_PATH DESC' THEN s.URL_PATH END DESC,
                CASE WHEN UPPER(p_sort_value) = 'SLUG ASC' THEN s.SLUG END ASC,
                CASE WHEN UPPER(p_sort_value) = 'SLUG DESC' THEN s.SLUG END DESC,
                CASE WHEN UPPER(p_sort_value) = 'LEVEL_SIDEBAR ASC' THEN s.LEVEL_SIDEBAR END ASC,
                CASE WHEN UPPER(p_sort_value) = 'LEVEL_SIDEBAR DESC' THEN s.LEVEL_SIDEBAR END DESC,
                CASE WHEN UPPER(p_sort_value) = 'PARENT_ID ASC' THEN s.PARENT_ID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'PARENT_ID DESC' THEN s.PARENT_ID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER ASC' THEN s.ORDER_NUMBER END ASC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER DESC' THEN s.ORDER_NUMBER END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT ASC' THEN s.CREATED_AT END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT DESC' THEN s.CREATED_AT END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY ASC' THEN s.CREATED_BY END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY DESC' THEN s.CREATED_BY END DESC,
                s.CREATED_AT DESC
        		))
        	WHERE rnum BETWEEN offset_value AND (offset_value + limit_value - 1)
        )
        LOOP
	        DBMS_LOB.APPEND(v_sidebarmenu_data,'{"guid":"' || s_rec.GUID || 
                '","code":"' || s_rec.CODE || 
                '","text_sidebar":"' || s_rec.TEXT_SIDEBAR || 
                '","icon":"' || NVL(s_rec.ICON, '') || 
                '","has_page":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(s_rec.HAS_PAGE) || 
                ',"url_path":"' || NVL(s_rec.URL_PATH, '') || 
                '","slug":"' || NVL(s_rec.SLUG, '') || 
                '","level_sidebar":' || s_rec.LEVEL_SIDEBAR || 
                ',"parent":' || UBS_TRAINING.detail_sidebar_menu_parent(NVL(s_rec.PARENT_ID, 0)) || 
                ',"order_number":' || s_rec.ORDER_NUMBER|| 
                ',"created_at":"' || NVL(TO_CHAR(s_rec.CREATED_AT, 'YYYY-MM-DD HH24:MI:SS'), '') || 
                '","created_by":"' || s_rec.CREATED_BY || 
                '","updated_at":"' || NVL(TO_CHAR(s_rec.UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS'), '') || 
                '","updated_by":"' || NVL(s_rec.UPDATED_BY, '') ||'"}');
               DBMS_LOB.APPEND(v_sidebarmenu_data, ',');
        END LOOP;
DBMS_LOB.TRIM(v_sidebarmenu_data, DBMS_LOB.GETLENGTH(v_sidebarmenu_data) - 1);
        -- Construct the JSON object
        v_json := '{"sidebarmenu_data":[' || v_sidebarmenu_data || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_sidebarmenu_count / limit_value) || ',"total_data":' || v_sidebarmenu_count || '}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_SIDEBAR_ACCESS"
(
p_iam_access_guid VARCHAR2,
p_level_sidebar NUMBER,
p_parent_id NUMBER
)
RETURN CLOB
IS
v_temp_data CLOB;
v_json CLOB;
v_count NUMBER;
BEGIN
	DBMS_LOB.CREATETEMPORARY(v_temp_data, TRUE);
	SELECT COUNT(sm.guid) INTO v_count FROM UBS_TRAINING.SIDEBAR_MENU sm 
	LEFT JOIN UBS_TRAINING.IAM_HAS_ACCESS i on sm.GUID = i.SIDEBAR_MENU_GUID
	LEFT JOIN UBS_TRAINING.IAM_ACCESS ia on i.iam_access_guid = ia.guid
	WHERE sm.level_sidebar = p_level_sidebar AND NVL(sm.PARENT_ID, 0) = NVL(p_parent_id, 0)
	AND ia.guid = p_iam_access_guid;
	IF v_count = 0 THEN
		v_json:=TO_CHAR('null');
		RETURN v_json;
	END IF;
FOR rec IN (
	SELECT
			i.GUID as HAS_ACCESS,
			s.SIDEBAR_MENU_ID,
			s.GUID,
			s.CODE,
			s.TEXT_SIDEBAR,
			s.ICON,
			s.HAS_PAGE,
			s.URL_PATH,
			s.SLUG,
			s.LEVEL_SIDEBAR,
			s.PARENT_ID,
			s.ORDER_NUMBER,
			s.CREATED_AT,
			s.CREATED_BY,
			s.UPDATED_AT,
			s.UPDATED_BY
	FROM
			UBS_TRAINING.SIDEBAR_MENU s
	LEFT JOIN UBS_TRAINING.IAM_HAS_ACCESS i on s.GUID = i.SIDEBAR_MENU_GUID
	LEFT JOIN UBS_TRAINING.IAM_ACCESS ia on i.iam_access_guid = ia.guid
	WHERE s.level_sidebar = p_level_sidebar AND COALESCE(s.PARENT_ID, -1) = COALESCE(p_parent_id, -1)
	AND ia.guid = p_iam_access_guid
	ORDER BY
			s.ORDER_NUMBER ASC
)
LOOP
DBMS_LOB.APPEND(v_temp_data, '{"guid":"' || rec.guid ||
    '","code":"' || rec.code || 
    '","text_sidebar":"' || rec.text_sidebar ||
    '","icon":"' || rec.icon || 
    '","has_page":' || UBS_TRAINING.detail_to_boolean(rec.has_page) ||
    ',"url_path":"' || NVL(rec.url_path, '') || '","slug":"' || rec.slug ||
    '","level_sidebar":' || rec.level_sidebar || 
    ',"order_number":' || rec.order_number ||
		',"has_access":' || UBS_TRAINING.get_iam_has_access_by_guid(rec.HAS_ACCESS) ||
    ',"sub_menu":' || UBS_TRAINING.LIST_SIDEBAR_ACCESS(p_iam_access_guid,(rec.level_sidebar+1),rec.sidebar_menu_id) ||'}'
);
    	DBMS_LOB.APPEND(v_temp_data, ',');
END LOOP;
	DBMS_LOB.TRIM(v_temp_data, DBMS_LOB.GETLENGTH(v_temp_data) - 1);
	v_json:='[' || v_temp_data || ']';
    RETURN v_json;
END;
---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_SIDEBAR_MENU_PARENT"
(
p_id NUMBER
)
RETURN CLOB
IS
v_json CLOB:='{}';
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"guid":"' || guid ||
        '","code":"' || code ||
        '","text_sidebar":"' || text_sidebar ||
        '","icon":"' || icon ||
        '","has_page":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(has_page) ||
        ',"url_path":"' || url_path ||
        '","slug":"' || slug ||
        '","level_sidebar":' || level_sidebar ||
        ',"parent_id":' || NVL(TO_CHAR(parent_id), 'null') ||
        ',"order_number":' || order_number ||
        '}' 
    INTO v_json
    FROM UBS_TRAINING.SIDEBAR_MENU
    WHERE sidebar_menu_id = p_id AND deleted_at IS NULL;

    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN 'null';
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_SIDEBAR_TREE"
(
p_level_sidebar NUMBER,
p_parent_id NUMBER
)
RETURN CLOB
IS
	v_temp_data clob :='';
v_json clob :='';
v_count NUMBER :=0;
BEGIN
	DBMS_LOB.CREATETEMPORARY(v_temp_data, TRUE);
	SELECT COUNT(guid) INTO v_count FROM UBS_TRAINING.SIDEBAR_MENU sm 
	WHERE sm.level_sidebar = p_level_sidebar AND NVL(sm.PARENT_ID, 0) = NVL(p_parent_id, 0);
	IF v_count = 0 THEN
		v_json:=TO_CHAR('null');
		RETURN v_json;
	END IF;
FOR rec IN (
            SELECT
            s.SIDEBAR_MENU_ID,
                s.GUID,
                s.CODE,
                s.TEXT_SIDEBAR,
                s.ICON,
                s.HAS_PAGE,
                s.URL_PATH,
                s.SLUG,
                s.LEVEL_SIDEBAR,
                s.PARENT_ID,
                s.ORDER_NUMBER,
                s.CREATED_AT,
                s.CREATED_BY,
                s.UPDATED_AT,
                s.UPDATED_BY
            FROM
                UBS_TRAINING.SIDEBAR_MENU s
            WHERE s.level_sidebar = p_level_sidebar AND COALESCE(s.PARENT_ID, -1) = COALESCE(p_parent_id, -1)
            ORDER BY
                s.ORDER_NUMBER ASC
)
LOOP
DBMS_LOB.APPEND(v_temp_data, '{"guid":"' || rec.guid ||
    '","code":"' || rec.code || 
    '","text_sidebar":"' || rec.text_sidebar ||
    '","icon":"' || rec.icon || 
    '","has_page":' || UBS_TRAINING.detail_to_boolean(rec.has_page) ||
    ',"url_path":"' || NVL(rec.url_path, '') || '","slug":"' || rec.slug ||
    '","level_sidebar":' || rec.level_sidebar || 
    ',"order_number":' || rec.order_number ||
    ',"sub_menu":' || UBS_TRAINING.LIST_SIDEBAR_TREE((rec.level_sidebar+1),rec.sidebar_menu_id) ||'}'
);
    	DBMS_LOB.APPEND(v_temp_data, ',');
END LOOP;
	DBMS_LOB.TRIM(v_temp_data, DBMS_LOB.GETLENGTH(v_temp_data) - 1);
	v_json:='[' || v_temp_data || ']';
    RETURN v_json;
END;

---

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

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_token_auth (
    p_token_auth_name VARCHAR2,
    p_device_id VARCHAR2,
    p_device_type VARCHAR2,
    p_token VARCHAR2,
    p_token_expired TIMESTAMP,
    p_refresh_token VARCHAR2,
    p_refresh_token_expired TIMESTAMP,
    p_is_login NUMBER,
    p_user_login VARCHAR2,
    ip_address VARCHAR2,
    p_created_by VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN 
	MERGE INTO UBS_TRAINING.TOKEN_AUTH tgt
		USING (
				SELECT
						p_token_auth_name AS token_auth_name,
						p_device_id AS device_id,
						p_device_type AS device_type,
						p_token AS token,
						p_token_expired AS token_expired,
						p_refresh_token AS refresh_token,
						p_refresh_token_expired AS refresh_token_expired,
						p_is_login AS is_login,
						p_user_login AS user_login,
						ip_address AS ip_address,
						SYSTIMESTAMP AS created_at,
						p_created_by AS created_by
				FROM dual
		) src
		ON (tgt.token_auth_name = src.token_auth_name AND tgt.device_id = src.device_id AND tgt.device_type = src.device_type)
		WHEN MATCHED THEN
				UPDATE SET
						tgt.token = src.token,
						tgt.token_expired = src.token_expired,
						tgt.refresh_token = src.refresh_token,
						tgt.refresh_token_expired = src.refresh_token_expired,
						tgt.is_login = src.is_login,
						tgt.user_login = src.user_login,
						tgt.ip_address = src.ip_address,
						tgt.updated_at = SYSTIMESTAMP,
						tgt.updated_by = src.created_by
		WHEN NOT MATCHED THEN
            INSERT (
                    token_auth_name,
                    device_id,
                    device_type,
                    token,
                    token_expired,
                    refresh_token,
                    refresh_token_expired,
                    is_login,
                    user_login,
                    ip_address,
                    created_at,
                    created_by
            ) VALUES (
                    src.token_auth_name,
                    src.device_id,
                    src.device_type,
                    src.token,
                    src.token_expired,
                    src.refresh_token,
                    src.refresh_token_expired,
                    src.is_login,
                    src.user_login,
                    src.ip_address,
                    src.created_at,
                    src.created_by
            );
            
        SELECT 
            '{"token_auth_id":' || token_auth_id || ',"token_auth_name":"' || token_auth_name || '","device_id":"' || device_id || '","device_type":"' || device_type || '","token":"' || token || '","token_expired":"' || token_expired || '","refresh_token":"' || refresh_token || '","refresh_token_expired":"' || refresh_token_expired || '","is_login":' || is_login || ',"user_login":"' || user_login || '","fcm_token": "' || fcm_token || '","ip_address": "' || ip_address || '","created_by":"' || created_by || '","created_at":"' || created_at || '"}'
        INTO v_json
        FROM UBS_TRAINING.TOKEN_AUTH tgt
        WHERE tgt.token_auth_name = p_token_auth_name AND tgt.device_id = p_device_id AND tgt.device_type = p_device_type AND tgt.deleted_at IS NULL;
        -- Return the JSON
        RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.token_user_login (
    p_token_auth_name VARCHAR2,
    p_device_id VARCHAR2,
    p_device_type VARCHAR2,
    p_user_login VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.TOKEN_AUTH 
	  SET
        is_login = 1,
        user_login = p_user_login,
        updated_at = SYSTIMESTAMP,
        updated_by = p_updated_by
    WHERE
        token_auth_name = p_token_auth_name
        AND device_id = p_device_id
        AND device_type = p_device_type;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.clear_user_login (
    p_token_auth_name VARCHAR2,
    p_device_id VARCHAR2,
    p_device_type VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.TOKEN_AUTH 
	  SET
        is_login = 0,
        user_login = NULL,
        updated_at = SYSTIMESTAMP,
        updated_by = p_updated_by
    WHERE
        token_auth_name = p_token_auth_name
        AND device_id = p_device_id
        AND device_type = p_device_type;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_auth_token (
    p_token_auth_name VARCHAR2,
    p_device_id VARCHAR2,
    p_device_type VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN 
    SELECT 
        '{"token_auth_id":' || token_auth_id || ',"token_auth_name":"' || token_auth_name || '","device_id":"' || device_id || '","device_type":"' || device_type || '","token":"' || token || '","token_expired":"' || token_expired || '","refresh_token":"' || refresh_token || '","refresh_token_expired":"' || refresh_token_expired || '","is_login":' || is_login || ',"user_login":"' || user_login || '","fcm_token": "' || fcm_token || '","ip_address": "' || ip_address || '","created_by":"' || created_by || '","created_at":"' || created_at || '"}'
    INTO v_json
    FROM UBS_TRAINING.TOKEN_AUTH tgt
    WHERE tgt.token_auth_name = p_token_auth_name AND tgt.device_id = p_device_id AND tgt.device_type = p_device_type AND tgt.deleted_at IS NULL;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.clear_auth_token (
    p_user_login VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.TOKEN_AUTH 
	SET
        is_login = 0,
        user_login = NULL,
        updated_at = SYSTIMESTAMP,
        updated_by = p_updated_by
    WHERE
        user_login = p_user_login;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_iam_access (
    p_is_notification NUMBER,
    p_role_guid VARCHAR2,
    p_created_by VARCHAR2,
    v_guid OUT VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB :='{}';
   	v_count NUMBER;
BEGIN
	SELECT COUNT(guid) INTO v_count FROM UBS_TRAINING.IAM_ACCESS  ia WHERE ia.role_guid = p_role_guid AND ia.DELETED_AT IS NULL;
	IF v_count=0 THEN
    DECLARE
        l_guid VARCHAR2(32);
        l_is_notification NUMBER;
        l_role_guid VARCHAR2(32);
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.IAM_ACCESS (
            is_notification,
            role_guid,
            created_by
        )
        VALUES (
            p_is_notification,
            p_role_guid,
            p_created_by
        )
        RETURNING 
            guid,
            is_notification,
            role_guid,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO 
            l_guid,
            l_is_notification,
            l_role_guid,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;

        -- Set the OUT parameter with the returned GUID
        v_guid := l_guid;

        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_notification) || ',"role_guid":"' || l_role_guid || '","created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS')|| '"}';
		END;
       END IF;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_iam_access (
    p_guid VARCHAR2,
    p_is_notification NUMBER,
    p_updated_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the updated row
    DECLARE
        l_id NUMBER;
        l_guid VARCHAR2(32);
        l_is_notification NUMBER;
        l_role_guid VARCHAR2(32);
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100);
        l_updated_at TIMESTAMP;
        l_deleted_by VARCHAR2(100);
        l_deleted_at TIMESTAMP;
    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.IAM_ACCESS
        SET
            is_notification = p_is_notification,
            updated_by = p_updated_by,
            updated_at = SYSTIMESTAMP
        WHERE
            guid = p_guid
        RETURNING
            id,
            guid,
            is_notification,
            role_guid,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO
            l_id,
            l_guid,
            l_is_notification,
            l_role_guid,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;
        
        -- Construct JSON object
        v_json := '{"id": ' || l_id || ',"guid":"' || l_guid || '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_notification) || ',"role_guid":"' || l_role_guid || '","created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || l_updated_by || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_iam_access (
    p_guid VARCHAR2,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and set the deleted columns
    UPDATE UBS_TRAINING.IAM_ACCESS
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_IAM_ACCESS_BY_GUID" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"id":' || id || ',"guid":"' || guid ||
        '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_notification) ||
        ',"role":' || UBS_TRAINING.DETAIL_ROLE_KEY(role_guid) || ',"created_by":"' || created_by || 
        '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json
    FROM UBS_TRAINING.IAM_ACCESS
    WHERE guid = p_guid AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_IAM_ACCESS" (
    p_set_is_notification NUMBER,
    p_is_notification NUMBER,
    p_set_role_guid NUMBER,
    p_role_guid VARCHAR2,
    p_set_created_by NUMBER,
    p_value_created_by VARCHAR2,
    p_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := ' ';
BEGIN
    DECLARE
        v_iam_access_data CLOB;
        v_iam_access_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
        -- Initialize CLOB for v_iam_access_data
        DBMS_LOB.CREATETEMPORARY(v_iam_access_data, TRUE);
        -- Make limit variable
        IF p_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := p_limit_data;
        END IF;
        -- Make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * p_limit_data + 1;
        END IF;
        SELECT COUNT(*)
        INTO v_iam_access_count
        FROM UBS_TRAINING.IAM_ACCESS iam
        WHERE
                (p_set_is_notification != 1 OR ((1=1) AND p_is_notification = iam.is_notification))
                AND (p_set_role_guid != 1 OR ((1=1) AND UPPER(iam.ROLE_GUID) LIKE UPPER(p_role_guid)))
                AND (p_set_created_by != 1 OR ((1=1) AND UPPER(iam.CREATED_BY) LIKE UPPER(p_value_created_by)))
                AND iam.DELETED_AT IS NULL;
            IF v_iam_access_count = 0 THEN
       		 v_json := '{"iam_access_data":[' || v_iam_access_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_iam_access_count / limit_value) || ',"total_data":' || v_iam_access_count || '}';
       		RETURN v_json;
      	END IF;
        -- Query for IAM_ACCESS data
        FOR iam_access_rec IN (
        SELECT
        	    ID,
                GUID,
                IS_NOTIFICATION,
                ROLE_GUID,
                CREATED_AT,
                CREATED_BY,
                UPDATED_AT,
                UPDATED_BY,
                rnum
        	FROM(
            SELECT
            	iam.ID,
                iam.GUID,
                iam.IS_NOTIFICATION,
                iam.ROLE_GUID,
                iam.CREATED_AT,
                iam.CREATED_BY,
                iam.UPDATED_AT,
                iam.UPDATED_BY,
                ROWNUM AS rnum
            FROM
                UBS_TRAINING.IAM_ACCESS iam
            WHERE
                (p_set_is_notification != 1 OR ((1=1) AND p_is_notification = iam.is_notification))
                AND (p_set_role_guid != 1 OR ((1=1) AND UPPER(iam.ROLE_GUID) LIKE UPPER(p_role_guid)))
                AND (p_set_created_by != 1 OR ((1=1) AND UPPER(iam.CREATED_BY) LIKE UPPER(p_value_created_by)))
                AND iam.DELETED_AT IS NULL
				ORDER BY
				    CASE WHEN UPPER(p_sort_value) = 'ID ASC' THEN iam.ID END ASC,
				    CASE WHEN UPPER(p_sort_value) = 'ID DESC' THEN iam.ID END DESC,
				    CASE WHEN UPPER(p_sort_value) = 'IS_NOTIFICATION ASC' THEN iam.IS_NOTIFICATION END ASC,
				    CASE WHEN UPPER(p_sort_value) = 'IS_NOTIFICATION DESC' THEN iam.IS_NOTIFICATION END DESC,
				    CASE WHEN UPPER(p_sort_value) = 'ROLE_GUID ASC' THEN iam.ROLE_GUID END ASC,
				    CASE WHEN UPPER(p_sort_value) = 'ROLE_GUID DESC' THEN iam.ROLE_GUID END DESC,
				    CASE WHEN UPPER(p_sort_value) = 'CREATED_AT ASC' THEN iam.CREATED_AT END ASC,
				    CASE WHEN UPPER(p_sort_value) = 'CREATED_AT DESC' THEN iam.CREATED_AT END DESC,
				    CASE WHEN UPPER(p_sort_value) = 'CREATED_BY ASC' THEN iam.CREATED_BY END ASC,
				    CASE WHEN UPPER(p_sort_value) = 'CREATED_BY DESC' THEN iam.CREATED_BY END DESC,
				    iam.CREATED_AT DESC
				    )
				    WHERE rnum BETWEEN offset_value AND (offset_value + limit_value - 1)
        )

        LOOP
            -- Append the JSON representation of the current record to the CLOB
            DBMS_LOB.APPEND(v_iam_access_data, '{"guid":"' || iam_access_rec.GUID ||'","id":' || iam_access_rec.id || ',"is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_access_rec.is_notification) || ',"role":' || UBS_TRAINING.DETAIL_ROLE_KEY(iam_access_rec.role_guid) || ',"created_at":"' || TO_CHAR(iam_access_rec.CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') || '","created_by":"' || iam_access_rec.CREATED_BY || '","updated_at":"' || TO_CHAR(iam_access_rec.UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(iam_access_rec.UPDATED_BY,'') || '"}');
            -- Append a comma to separate JSON objects (except for the last one)
            DBMS_LOB.APPEND(v_iam_access_data, ',');
        END LOOP;
       	
        DBMS_LOB.TRIM(v_iam_access_data, DBMS_LOB.GETLENGTH(v_iam_access_data) - 1);
        v_json := '{"iam_access_data":[' || v_iam_access_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_iam_access_count / limit_value) || ',"total_data":' || v_iam_access_count || '}';
    END;
    -- Return the JSON
    RETURN v_json;
END;
---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_IAM_ACCESS_KEY" (
    p_role_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '[' || CHR(13) || CHR(10); -- Initialize with an opening bracket for JSON ARRAY
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"guid":"' || guid ||
        '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_notification) ||
        ',"iam_has_access":'|| UBS_TRAINING.DETAIL_IAM_HAS_ACCESS_LIST(role_guid)||
        ',"created_by":"' || created_by ||
        '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') ||
        '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}' 
    INTO v_json
    FROM UBS_TRAINING.IAM_ACCESS
    WHERE ROLE_GUID  = p_role_guid;
    
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_IAM_HAS_ACCESS_KEY" (
    p_iam_access_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"guid":"' || guid || 
        '","is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_create) ||
        ',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_read) || 
        ',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_update) || 
        ',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_delete) ||
        ',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom1) || 
        ',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom2) ||
        ',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom3) ||
        ',"sidebar_menu_guid":"' || SIDEBAR_MENU_GUID || '"}' -- End of the outer CASE
    INTO v_json
    FROM UBS_TRAINING.IAM_HAS_ACCESS iha
    WHERE guid = p_iam_access_guid;

    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."INSERT_IAM_ACCESS_FOR_ROLE"
(
	p_is_notification NUMBER,
	p_role_guid VARCHAR2,
	p_created_by VARCHAR2,
	p_data IN UBS_TRAINING.iam_has_req_table
)
RETURN CLOB
IS
    v_json CLOB := '{}';
BEGIN
    DECLARE
        l_id NUMBER;
        l_guid VARCHAR2(32);
        l_is_notification NUMBER;
        l_role_guid VARCHAR2(32);
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
       	v_iam_has_json CLOB;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.IAM_ACCESS (
            is_notification,
            role_guid,
            created_by
        )
        VALUES (
            p_is_notification,
            p_role_guid,
            p_created_by
        )
        RETURNING 
            guid,
            is_notification,
            role_guid,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO 
            l_guid,
            l_is_notification,
            l_role_guid,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;

           v_iam_has_json:=UBS_TRAINING.INSERT_MULTI_IAM_HAS(l_guid,p_data);
        -- Set the OUT parameter with the returned GUID
       

        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_notification) || ',"role_guid":"' || l_role_guid ||'","iam_has_access":[' || v_iam_has_json || '],"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS')|| '"}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE TABLE UBS_TRAINING.AUTHENTICATION (
    authentication_id NUMBER UNIQUE,
    guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
    auth_username VARCHAR2(255),
    auth_password VARCHAR2(255),
    salt VARCHAR2(255),
    forgot_password_token VARCHAR2(255) NULL,
    forgot_password_expiry TIMESTAMP NULL,
    last_login TIMESTAMP NULL,
    is_active NUMBER(1,0) DEFAULT 1,
    employee_guid  VARCHAR2(32) NOT NULL REFERENCES UBS_TRAINING.EMPLOYEE(GUID) ON DELETE CASCADE,
    status VARCHAR2(20) DEFAULT 'active',
    created_by VARCHAR2(100),  
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_by VARCHAR2(100) NULL, 
    updated_at TIMESTAMP NULL,
    deleted_by VARCHAR2(100) NULL,
    deleted_at TIMESTAMP NULL
);

---

CREATE SEQUENCE UBS_TRAINING.authentication_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.authentication_trigger
  BEFORE INSERT ON UBS_TRAINING.AUTHENTICATION
  FOR EACH ROW
BEGIN
  :new.authentication_id := authentication_seq.nextval;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_authentication (
    p_employee_guid VARCHAR2,
    p_auth_username VARCHAR2,
    p_auth_password VARCHAR2,
    p_salt VARCHAR2,
    p_status VARCHAR2,
    p_created_by VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_authentication_id       	NUMBER;
        l_guid              				VARCHAR2(32); -- Adjust the size based on your column definition
        l_auth_username          		VARCHAR2(255); -- Adjust the size based on your column definition
        l_auth_password             VARCHAR2(255);
        l_salt      								VARCHAR2(255);
        l_forgot_password_token     VARCHAR2(255) NULL;
        l_forgot_password_expiry    TIMESTAMP NULL;
        l_last_login   							TIMESTAMP NULL;
        l_is_active            			NUMBER;
        l_employee_guid  						VARCHAR2(32);
        l_status       							VARCHAR2(255);
        l_created_by        				VARCHAR2(100);  
        l_created_at        				TIMESTAMP DEFAULT SYSTIMESTAMP;
        l_updated_by        				VARCHAR2(100) NULL;
        l_updated_at        				TIMESTAMP NULL;
        l_deleted_by        				VARCHAR2(100) NULL;
        l_deleted_at        				TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.AUTHENTICATION (
            employee_guid, auth_username, auth_password,
            salt, status, created_by, created_at
        )
        VALUES (
            p_employee_guid, p_auth_username,
            p_auth_password, p_salt, p_status, p_created_by, SYSTIMESTAMP
        )
        RETURNING authentication_id, guid, auth_username, auth_password, salt, forgot_password_token, forgot_password_expiry, last_login, is_active, employee_guid, status, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at 
        INTO l_authentication_id, l_guid, l_auth_username, l_auth_password, l_salt, l_forgot_password_token, l_forgot_password_expiry, l_last_login, l_is_active, l_employee_guid, l_status, l_created_by, l_created_at, l_updated_by, l_updated_at, l_deleted_by, l_deleted_at;
        
        -- Construct JSON object
        v_json := '{"authentication_id": ' || l_authentication_id || 
									',"guid":"' || l_guid || 
									'","employee_id":"' || l_employee_guid ||
									'","auth_username":"' || l_auth_username || 
									'","auth_password":"' || l_auth_password || 
									'","salt":"' || l_salt || 
									'","forgot_password_token":"' || l_forgot_password_token || 
									'","forgot_password_expiry":"' || l_forgot_password_expiry || 
									'","last_login":"' || l_last_login || 
									'","is_active":' || l_is_active || 
									',"employee_data": '|| UBS_TRAINING.GET_EMPLOYEE(l_employee_guid) ||
									',"status": "' || l_status || 
									'","created_by":"' || l_created_by || 
									'","created_at":"' || l_created_at || 
									'","updated_by":"' || l_updated_by || 
									'","updated_at":"' || l_updated_at || 
									'","deleted_by":"' || l_deleted_by || 
									'","deleted_at":"' || l_deleted_at || '"}';

    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_authentication_username (
    p_auth_username VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"authentication_id": ' || authentication_id || 
				',"guid":"' || guid || 
				'","employee_id":"' || employee_guid ||
				'","auth_username":"' || auth_username || 
				'","auth_password":"' || auth_password || 
				'","salt":"' || salt || 
				'","forgot_password_token":"' || forgot_password_token || 
				'","forgot_password_expiry":"' || forgot_password_expiry || 
				'","last_login":"' || last_login || 
				'","is_active":' || is_active || 
				',"employee_data": '|| UBS_TRAINING.GET_EMPLOYEE(employee_guid) ||
				',"status": "' || status || 
				'","created_by":"' || created_by || 
				'","created_at":"' || created_at || 
				'","updated_by":"' || updated_by || 
				'","updated_at":"' || updated_at || 
				'","deleted_by":"' || deleted_by || 
				'","deleted_at":"' || deleted_at || '"}'
    INTO v_json
    FROM (
    SELECT *
    FROM UBS_TRAINING.AUTHENTICATION
    WHERE auth_username = p_auth_username AND deleted_at IS NULL
      AND ROWNUM <= 1);
    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.update_authentication_password (
    p_guid VARCHAR2,
		p_auth_password VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.AUTHENTICATION
    SET
				auth_password = p_auth_password,
        updated_by = p_updated_by,
        updated_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.update_authentication_username (
    p_guid VARCHAR2,
		p_auth_username VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.AUTHENTICATION
    SET
				auth_username = p_auth_username,
        updated_by = p_updated_by,
        updated_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.update_forgot_password (
    p_guid VARCHAR2,
		p_forgot_password_token VARCHAR2,
		p_forgot_password_expiry TIMESTAMP DEFAULT NULL,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.AUTHENTICATION
    SET
				forgot_password_token = p_forgot_password_token,
        forgot_password_expiry = p_forgot_password_expiry,
				updated_by = p_updated_by,
        updated_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_forgot_token (
    p_forgot_password_token VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"authentication_id": ' || authentication_id || 
				',"guid":"' || guid || 
				'","employee_id":"' || employee_guid ||
				'","auth_username":"' || auth_username || 
				'","auth_password":"' || auth_password || 
				'","salt":"' || salt || 
				'","forgot_password_token":"' || forgot_password_token || 
				'","forgot_password_expiry":"' || forgot_password_expiry || 
				'","last_login":"' || last_login || 
				'","is_active":' || is_active || 
				',"employee_data": '|| UBS_TRAINING.GET_EMPLOYEE(employee_guid) ||
				',"status": "' || status || 
				'","created_by":"' || created_by || 
				'","created_at":"' || created_at || 
				'","updated_by":"' || updated_by || 
				'","updated_at":"' || updated_at || 
				'","deleted_by":"' || deleted_by || 
				'","deleted_at":"' || deleted_at || '"}'
    INTO v_json
    FROM (
    SELECT *
    FROM UBS_TRAINING.AUTHENTICATION
    WHERE forgot_password_token = p_forgot_password_token AND deleted_at IS NULL
      AND ROWNUM <= 1);

    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_authentication_by_id (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"authentication_id": ' || authentication_id || 
				',"guid":"' || guid || 
				'","employee_id":"' || employee_guid ||
				'","auth_username":"' || auth_username || 
				'","auth_password":"' || auth_password || 
				'","salt":"' || salt || 
				'","forgot_password_token":"' || forgot_password_token || 
				'","forgot_password_expiry":"' || forgot_password_expiry || 
				'","last_login":"' || last_login || 
				'","is_active":' || is_active || 
				',"employee_data": '|| UBS_TRAINING.GET_EMPLOYEE(employee_guid) ||
				',"status": "' || status || 
				'","created_by":"' || created_by || 
				'","created_at":"' || created_at || 
				'","updated_by":"' || updated_by || 
				'","updated_at":"' || updated_at || 
				'","deleted_by":"' || deleted_by || 
				'","deleted_at":"' || deleted_at || '"}'
    INTO v_json
    FROM (
    SELECT *
    FROM UBS_TRAINING.AUTHENTICATION
    WHERE guid = p_guid AND deleted_at IS NULL
      AND ROWNUM <= 1);
    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_authentication_by_employee (
    p_employee_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"authentication_id": ' || authentication_id || 
				',"guid":"' || guid || 
				'","employee_id":"' || employee_guid ||
				'","auth_username":"' || auth_username || 
				'","auth_password":"' || auth_password || 
				'","salt":"' || salt || 
				'","forgot_password_token":"' || forgot_password_token || 
				'","forgot_password_expiry":"' || forgot_password_expiry || 
				'","last_login":"' || last_login || 
				'","is_active":' || is_active || 
				',"employee_data": '|| UBS_TRAINING.GET_EMPLOYEE(employee_guid) ||
				',"status": "' || status || 
				'","created_by":"' || created_by || 
				'","created_at":"' || created_at || 
				'","updated_by":"' || updated_by || 
				'","updated_at":"' || updated_at || 
				'","deleted_by":"' || deleted_by || 
				'","deleted_at":"' || deleted_at || '"}'
    INTO v_json
    FROM (
    SELECT *
    FROM UBS_TRAINING.AUTHENTICATION
    WHERE employee_guid = p_employee_guid AND deleted_at IS NULL
      AND ROWNUM <= 1);

    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.record_last_login (
    p_guid VARCHAR2
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.AUTHENTICATION
    SET
        last_login = SYSTIMESTAMP
    WHERE
        guid = p_guid
				AND status = 'active';
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.update_username_by_employee (
    p_employee_guid VARCHAR2,
		p_auth_username VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and return the values into variables
    UPDATE UBS_TRAINING.AUTHENTICATION
    SET
				auth_username = p_auth_username,
        updated_by = p_updated_by,
        updated_at = SYSTIMESTAMP
    WHERE
        employee_guid = p_employee_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_iam_has_access (
    p_is_create NUMBER,
    p_is_read NUMBER,
    p_is_update NUMBER,
    p_is_delete NUMBER,
    p_is_custom1 NUMBER,
    p_is_custom2 NUMBER,
    p_is_custom3 NUMBER,
    p_iam_access_guid VARCHAR2,
    p_sidebar_menu_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_guid VARCHAR2(32);
        l_is_create NUMBER;
        l_is_read NUMBER;
        l_is_update NUMBER;
        l_is_delete NUMBER;
        l_is_custom1 NUMBER;
        l_is_custom2 NUMBER;
        l_is_custom3 NUMBER;
        l_iam_access_guid VARCHAR2(255);
        l_sidebar_menu_guid VARCHAR2(255);
    BEGIN  
        -- Insert new row
        INSERT INTO UBS_TRAINING.IAM_HAS_ACCESS (
            is_create,
            is_read,
            is_update,
            is_delete,
            is_custom1,
            is_custom2,
            is_custom3,
            iam_access_guid,
            sidebar_menu_guid
        )
        VALUES (
            p_is_create,
            p_is_read,
            p_is_update,
            p_is_delete,
            p_is_custom1,
            p_is_custom2,
            p_is_custom3,
            p_iam_access_guid,
            p_sidebar_menu_guid
        )
        RETURNING 
            guid,
            is_create,
            is_read,
            is_update,
            is_delete,
            is_custom1,
            is_custom2,
            is_custom3,
            iam_access_guid,
            sidebar_menu_guid
        INTO 
            l_guid,
            l_is_create,
            l_is_read,
            l_is_update,
            l_is_delete,
            l_is_custom1,
            l_is_custom2,
            l_is_custom3,
            l_iam_access_guid,
            l_sidebar_menu_guid;
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_create) || ',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_read) || ',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_update) || ',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_delete) || ',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom1) || ',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom2) || ',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom3) || ',"iam_access_guid":"' || l_iam_access_guid || '","sidebar_menu_guid":"' || l_sidebar_menu_guid || '"}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_iam_has_access (
    p_guid VARCHAR2,
    p_is_create NUMBER,
    p_is_read NUMBER,
    p_is_update NUMBER,
    p_is_delete NUMBER,
    p_is_custom1 NUMBER,
    p_is_custom2 NUMBER,
    p_is_custom3 NUMBER,
    p_iam_guid VARCHAR2,
    p_sidebar_menu_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the updated row
    DECLARE
        l_guid VARCHAR2(32);
        l_is_create NUMBER;
        l_is_read NUMBER;
        l_is_update NUMBER;
        l_is_delete NUMBER;
        l_is_custom1 NUMBER;
        l_is_custom2 NUMBER;
        l_is_custom3 NUMBER;
        l_iam_access_guid VARCHAR2(255);
        l_sidebar_menu_guid VARCHAR2(255);
    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.IAM_HAS_ACCESS
        SET
            is_create = p_is_create,
            is_read = p_is_read,
            is_update = p_is_update,
            is_delete = p_is_delete,
            is_custom1 = p_is_custom1,
            is_custom2 = p_is_custom2,
            is_custom3 = p_is_custom3,
            iam_access_guid = p_iam_guid,
            sidebar_menu_guid = p_sidebar_menu_guid
        WHERE
            guid = p_guid
        RETURNING
            guid,
            is_create,
            is_read,
            is_update,
            is_delete,
            is_custom1,
            is_custom2,
            is_custom3,
            iam_access_guid,
            sidebar_menu_guid
        INTO
            l_guid,
            l_is_create,
            l_is_read,
            l_is_update,
            l_is_delete,
            l_is_custom1,
            l_is_custom2,
            l_is_custom3,
            l_iam_access_guid,
            l_sidebar_menu_guid;
        -- Construct JSON object
       v_json := '{"guid":"' || l_guid ||
  '","is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_create) ||
  ',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_read) ||
  ',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_update) ||
  ',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_delete) ||
  ',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom1) ||
  ',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom2) ||
  ',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_custom3) ||
  ',"iam_access_guid":"' || l_iam_access_guid ||
  '","sidebar_menu_guid":"' || l_sidebar_menu_guid || '"}';
   END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_iam_has_access (
    p_guid VARCHAR2
)
IS
BEGIN
    -- Update the row and set the deleted columns
    DELETE FROM UBS_TRAINING.IAM_HAS_ACCESS
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_IAM_HAS_ACCESS_BY_GUID" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
'{"id":' || id ||
',"guid":"' || guid ||
'","is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_create) ||
',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_read) ||
',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_update) ||
',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_delete) ||
',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom1) ||
',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom2) ||
',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom3) ||
',"iam_access_guid":"' || iam_access_guid ||
'","sidebar_menu_guid":"' || sidebar_menu_guid ||
'"}'
    INTO v_json
    FROM UBS_TRAINING.IAM_HAS_ACCESS
    WHERE guid = p_guid;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_IAM_HAS_ACCESS" (
    p_set_is_create NUMBER,
    p_value_is_create NUMBER,
    p_set_is_read NUMBER,
    p_value_is_read NUMBER,
    p_set_is_update NUMBER,
    p_value_is_update NUMBER,
    p_set_is_delete NUMBER,
    p_value_is_delete NUMBER,
    p_set_is_custom1 NUMBER,
    p_value_is_custom1 NUMBER,
    p_set_is_custom2 NUMBER,
    p_value_is_custom2 NUMBER,
    p_set_is_custom3 NUMBER,
    p_value_is_custom3 NUMBER,
    p_set_iam_access_guid NUMBER,
    p_value_iam_access_guid VARCHAR2,
    p_set_sidebar_menu_guid NUMBER,
    p_value_sidebar_menu_guid VARCHAR2,
    p_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := ' ';
BEGIN
    DECLARE
        v_iam_has_access_data CLOB;
        v_iam_has_access_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
        -- Initialize CLOB for v_iam_has_access_data
        DBMS_LOB.CREATETEMPORARY(v_iam_has_access_data, TRUE);

        -- Make limit variable
        IF p_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := p_limit_data;
        END IF;

        -- Make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * p_limit_data + 1;
        END IF;
       
               -- Query for IAM_HAS_ACCESS count
        SELECT COUNT(*)
        INTO v_iam_has_access_count
        FROM UBS_TRAINING.IAM_HAS_ACCESS iam_has_access
        WHERE
             (p_set_is_create != 1 OR ((1=1) AND iam_has_access.IS_CREATE = p_value_is_create))
            AND (p_set_is_read != 1 OR ((1=1) AND iam_has_access.IS_READ = p_value_is_read))
            AND (p_set_is_update != 1 OR ((1=1) AND iam_has_access.IS_UPDATE = p_value_is_update))
            AND (p_set_is_delete != 1 OR ((1=1) AND iam_has_access.IS_DELETE = p_value_is_delete))
            AND (p_set_is_custom1 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM1 = p_value_is_custom1))
            AND (p_set_is_custom2 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM2 = p_value_is_custom2))
            AND (p_set_is_custom3 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM3 = p_value_is_custom3))
            AND (p_set_iam_access_guid != 1 OR ((1=1) AND iam_has_access.IAM_ACCESS_GUID = p_value_iam_access_guid))
            AND (p_set_sidebar_menu_guid != 1 OR ((1=1) AND iam_has_access.SIDEBAR_MENU_GUID = p_value_sidebar_menu_guid));
        IF v_iam_has_access_count = 0 THEN
        	 v_json := '{"iam_has_access_data":[' || v_iam_has_access_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_iam_has_access_count / limit_value) || ',"total_data":' || v_iam_has_access_count || '}';
 			RETURN v_json;
        END IF;

        -- Query for IAM_HAS_ACCESS data
        FOR iam_has_access_rec IN (
        SELECT * from
            (SELECT
                iam_has_access.GUID,
                iam_has_access.ID,
                iam_has_access.IS_CREATE,
                iam_has_access.IS_READ,
                iam_has_access.IS_UPDATE,
                iam_has_access.IS_DELETE,
                iam_has_access.IS_CUSTOM1,
                iam_has_access.IS_CUSTOM2,
                iam_has_access.IS_CUSTOM3,
                iam_has_access.IAM_ACCESS_GUID,
                iam_has_access.SIDEBAR_MENU_GUID,
                ROWNUM AS rnum
            FROM
                UBS_TRAINING.IAM_HAS_ACCESS iam_has_access
            WHERE
                 (p_set_is_create != 1 OR ((1=1) AND iam_has_access.IS_CREATE = p_value_is_create))
                AND (p_set_is_read != 1 OR ((1=1) AND iam_has_access.IS_READ = p_value_is_read))
                AND (p_set_is_update != 1 OR ((1=1) AND iam_has_access.IS_UPDATE = p_value_is_update))
                AND (p_set_is_delete != 1 OR ((1=1) AND iam_has_access.IS_DELETE = p_value_is_delete))
                AND (p_set_is_custom1 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM1 = p_value_is_custom1))
                AND (p_set_is_custom2 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM2 = p_value_is_custom2))
                AND (p_set_is_custom3 != 1 OR ((1=1) AND iam_has_access.IS_CUSTOM3 = p_value_is_custom3))
                AND (p_set_iam_access_guid != 1 OR ((1=1) AND iam_has_access.IAM_ACCESS_GUID = p_value_iam_access_guid))
                AND (p_set_sidebar_menu_guid != 1 OR ((1=1) AND iam_has_access.SIDEBAR_MENU_GUID = p_value_sidebar_menu_guid))
			ORDER BY
			    CASE WHEN UPPER(p_sort_value) = 'ID ASC' THEN iam_has_access.ID END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'ID DESC' THEN iam_has_access.ID END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'GUID ASC' THEN iam_has_access.GUID END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'GUID DESC' THEN iam_has_access.GUID END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CREATE ASC' THEN iam_has_access.IS_CREATE END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CREATE DESC' THEN iam_has_access.IS_CREATE END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_READ ASC' THEN iam_has_access.IS_READ END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_READ DESC' THEN iam_has_access.IS_READ END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_UPDATE ASC' THEN iam_has_access.IS_UPDATE END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_UPDATE DESC' THEN iam_has_access.IS_UPDATE END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_DELETE ASC' THEN iam_has_access.IS_DELETE END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_DELETE DESC' THEN iam_has_access.IS_DELETE END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM1 ASC' THEN iam_has_access.IS_CUSTOM1 END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM1 DESC' THEN iam_has_access.IS_CUSTOM1 END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM2 ASC' THEN iam_has_access.IS_CUSTOM2 END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM2 DESC' THEN iam_has_access.IS_CUSTOM2 END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM3 ASC' THEN iam_has_access.IS_CUSTOM3 END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IS_CUSTOM3 DESC' THEN iam_has_access.IS_CUSTOM3 END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'IAM_ACCESS_GUID ASC' THEN iam_has_access.IAM_ACCESS_GUID END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'IAM_ACCESS_GUID DESC' THEN iam_has_access.IAM_ACCESS_GUID END DESC,
			    CASE WHEN UPPER(p_sort_value) = 'SIDEBAR_MENU_GUID ASC' THEN iam_has_access.SIDEBAR_MENU_GUID END ASC,
			    CASE WHEN UPPER(p_sort_value) = 'SIDEBAR_MENU_GUID DESC' THEN iam_has_access.SIDEBAR_MENU_GUID END DESC,
				iam_has_access.GUID ASC
				)
				where RNUM BETWEEN offset_value AND (offset_value + limit_value - 1)
        )
        LOOP
            -- Append the JSON representation of the current record to the CLOB
        DBMS_LOB.APPEND(
  v_iam_has_access_data,
  '{"guid":"' || iam_has_access_rec.GUID ||
  '","id":' || iam_has_access_rec.ID ||
  ',"is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_CREATE) ||
  ',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_READ) ||
  ',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_UPDATE) ||
  ',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_DELETE) ||
  ',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_CUSTOM1) ||
  ',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_CUSTOM2) ||
  ',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(iam_has_access_rec.IS_CUSTOM3) ||
  ',"iam_access_guid":"' || iam_has_access_rec.IAM_ACCESS_GUID ||
  '","sidebar_menu_guid":"' || iam_has_access_rec.SIDEBAR_MENU_GUID || '"}'
);
            DBMS_LOB.APPEND(v_iam_has_access_data, ',');
        END LOOP;

        -- Remove the trailing comma
        DBMS_LOB.TRIM(v_iam_has_access_data, DBMS_LOB.GETLENGTH(v_iam_has_access_data) - 1);



        -- Construct the JSON object
        v_json := '{"iam_has_access_data":[' || v_iam_has_access_data || '],"current_page":' || P_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_iam_has_access_count / limit_value) || ',"total_data":' || v_iam_has_access_count || '}';
    END;

    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."DETAIL_IAM_HAS_ACCESS_LIST" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '[' || CHR(13) || CHR(10); -- Initialize with an opening bracket for JSON ARRAY
BEGIN
    FOR emp IN (
        SELECT guid
        FROM (
            SELECT iha.guid
            FROM UBS_TRAINING.iam_has_access iha 
            JOIN UBS_TRAINING.iam_access ia ON iha.iam_access_guid = ia.guid
            WHERE
            	ia.role_guid = p_guid
                AND deleted_at IS NULL
        )
    ) LOOP
        v_json := v_json || UBS_TRAINING.detail_iam_has_access_key(emp.guid) || ',' || CHR(13) || CHR(10);
    END LOOP;
    
    -- Remove the trailing comma and close the JSON array
    v_json := RTRIM(v_json, ',' || CHR(13) || CHR(10)) || CHR(13) || CHR(10) || ']';
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_role (
    p_code VARCHAR2,
    p_role_name VARCHAR2,
    p_created_by VARCHAR2,
    v_guid OUT VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_guid VARCHAR2(32);
        l_code VARCHAR(255);
        l_role_name VARCHAR(255);
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.ROLE (
            code,
            role_name,
            created_by
        )
        VALUES (
            p_code,
            p_role_name,
            p_created_by
        )
        RETURNING 
            guid,
            code,
            role_name,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO 
            l_guid,
            l_code,
            l_role_name,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;
           
         	v_guid:=l_guid;
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","code":"' || l_code || '","role_name":"' || l_role_name || '","order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"';
    END;
    RETURN v_json;
       EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code": "' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
               	RAISE;
                RETURN v_json;
                -- You can choose to perform additional actions or continue without raising an error
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
           	RAISE;
            RETURN v_json;
    -- Return the JSON
END;

---

CREATE OR REPLACE TYPE UBS_TRAINING.iam_has_req AS OBJECT (
    p_is_create NUMBER,
    p_is_read NUMBER,
    p_is_update NUMBER,
    p_is_delete NUMBER,
    p_is_custom1 NUMBER,
    p_is_custom2 NUMBER,
    p_is_custom3 NUMBER,
    p_sidebar_menu_guid VARCHAR2(255)
);

---

CREATE OR REPLACE TYPE UBS_TRAINING.iam_has_req_table AS TABLE OF UBS_TRAINING.iam_has_req;

---

CREATE OR REPLACE TYPE UBS_TRAINING.iam_has_req_cud AS OBJECT (
p_is_crud NUMBER,	
p_has_req_guid VARCHAR2(32),
    p_is_create NUMBER,
    p_is_read NUMBER,
    p_is_update NUMBER,
    p_is_delete NUMBER,
    p_is_custom1 NUMBER,
    p_is_custom2 NUMBER,
    p_is_custom3 NUMBER,
    p_iam_guid VARCHAR(32),
    p_sidebar_menu_guid VARCHAR2(255)
);

---

CREATE OR REPLACE TYPE UBS_TRAINING.iam_has_req_cud_table AS TABLE OF UBS_TRAINING.iam_has_req_cud;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.INSERT_MULTI_IAM_HAS(
p_iam_guid VARCHAR2,
p_data IN UBS_TRAINING.iam_has_req_table
)RETURN CLOB
IS 
v_json CLOB;
BEGIN
	DBMS_LOB.CREATETEMPORARY(v_json, TRUE);
	FOR i IN 1..p_data.COUNT LOOP 
		DECLARE
			v_res CLOB;
		BEGIN
			v_res:=UBS_TRAINING.insert_iam_has_access(
				p_data(i).p_is_create,
			    p_data(i).p_is_read,
			    p_data(i).p_is_update,
			    p_data(i).p_is_delete,
			    p_data(i).p_is_custom1,
			    p_data(i).p_is_custom2,
			    p_data(i).p_is_custom3,
			    p_iam_guid,
			    p_data(i).p_sidebar_menu_guid
			);
			DBMS_LOB.APPEND(v_json, v_res || ',');
	END;
	END LOOP; 
	 DBMS_LOB.TRIM(v_json, DBMS_LOB.GETLENGTH(v_json) - 1);
RETURN v_json;
	EXCEPTION
	    WHEN OTHERS THEN
	        -- Handle exceptions as needed
	    	IF DBMS_LOB.GETLENGTH(v_json) > 1 THEN
		    	DBMS_LOB.TRIM(v_json, DBMS_LOB.GETLENGTH(v_json) - 1);
		    END IF;
		   RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.INSERT_ROLE_AND_CHILD(
  p_role_code VARCHAR2,
  p_role_name VARCHAR2,
  p_created_by VARCHAR2,
  p_iam_is_notification NUMBER,
	p_iam_has_data IN UBS_TRAINING.iam_has_req_table
) RETURN CLOB
IS
v_json CLOB;
v_role_json CLOB;
v_role_guid VARCHAR2(32);
v_iam_json CLOB;
v_iam_guid VARCHAR2(32);
v_has_json CLOB;
BEGIN
	v_role_json:=UBS_TRAINING.INSERT_ROLE(p_role_code,p_role_name,p_created_by,v_role_guid);
	v_iam_json:=UBS_TRAINING.INSERT_IAM_ACCESS_FOR_ROLE(p_iam_is_notification,v_role_guid,p_created_by,p_iam_has_data);

	v_json:='{"role":' || v_role_json || ',"iam_access":' || v_iam_json ||'}}';
	RETURN v_json;
          EXCEPTION
   	WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code": "' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
                RETURN v_json;
                -- You can choose to perform additional actions or continue without raising an error
    WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
            RETURN v_json;
END INSERT_ROLE_AND_CHILD;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_role (
    p_guid VARCHAR2,
    p_code VARCHAR2,
    p_role_name VARCHAR2,
    p_updated_by VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the updated row
    DECLARE
        l_role_id NUMBER;
        l_guid VARCHAR2(32);
        l_code VARCHAR(255);
        l_role_name VARCHAR(255);
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100);
        l_updated_at TIMESTAMP;
        l_deleted_by VARCHAR2(100);
        l_deleted_at TIMESTAMP;
    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.ROLE
        SET
            code = p_code,
            role_name = p_role_name,
            updated_by = p_updated_by,
            updated_at = SYSTIMESTAMP
        WHERE
            guid = p_guid
        RETURNING
            guid,
            code,
            role_name,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO
            l_guid,
            l_code,
            l_role_name,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;
        
        -- Construct JSON object
        v_json := '"guid":"' || l_guid || '","code":"' || l_code || '","role_name":"' || l_role_name || '","order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || l_updated_by || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"';
    END;
   
    RETURN v_json;
       EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code": "' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
               	RAISE;
                RETURN v_json;
                -- You can choose to perform additional actions or continue without raising an error
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
           	RAISE;
            RETURN v_json;
    -- Return the JSON
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.UPDATE_MULTI_IAM_HAS (
    p_iam_guid VARCHAR2,
    p_data IN UBS_TRAINING.iam_has_req_cud_table
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    DBMS_LOB.CREATETEMPORARY(v_json, TRUE);
    
    FOR i IN 1..p_data.COUNT LOOP
        DECLARE
            v_res CLOB;
        BEGIN
            CASE WHEN p_data(i).p_is_crud = 1 THEN
                v_res := UBS_TRAINING.insert_iam_has_access(
                    p_data(i).p_is_create,
                    p_data(i).p_is_read,
                    p_data(i).p_is_update,
                    p_data(i).p_is_delete,
                    p_data(i).p_is_custom1,
                    p_data(i).p_is_custom2,
                    p_data(i).p_is_custom3,
                    p_iam_guid,
                    p_data(i).p_sidebar_menu_guid
                );
                DBMS_LOB.APPEND(v_json, v_res || ',');
            
            WHEN p_data(i).p_is_crud = 2 THEN
                v_res := UBS_TRAINING.update_iam_has_access(
                    p_data(i).p_has_req_guid,
                    p_data(i).p_is_create, 
                    p_data(i).p_is_read,
                    p_data(i).p_is_update,
                    p_data(i).p_is_delete,
                    p_data(i).p_is_custom1,
                    p_data(i).p_is_custom2,
                    p_data(i).p_is_custom3,
                    p_data(i).p_iam_guid,
                    p_data(i).p_sidebar_menu_guid
                );
                DBMS_LOB.APPEND(v_json, v_res || ',');
            ELSE
                UBS_TRAINING.delete_iam_has_access(p_data(i).p_has_req_guid);
            END CASE;
        END;
    END LOOP;
    
    -- Trim the trailing comma from the JSON string
            IF DBMS_LOB.GETLENGTH(v_json) > 1 THEN
                DBMS_LOB.TRIM(v_json, DBMS_LOB.GETLENGTH(v_json) - 1);
            END IF;
   
    
    -- Return the JSON
    RETURN v_json;
       EXCEPTION
        WHEN OTHERS THEN
            -- Handle exceptions as needed
            IF DBMS_LOB.GETLENGTH(v_json) > 1 THEN
                DBMS_LOB.TRIM(v_json, DBMS_LOB.GETLENGTH(v_json) - 1);
            END IF;
            RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.UPDATE_IAM_ACCESS_FOR_ROLE (
p_guid VARCHAR2,
    p_is_notification NUMBER,
	p_updated_by VARCHAR2 DEFAULT NULL,
	p_data IN UBS_TRAINING.iam_has_req_cud_table
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the updated row
    DECLARE
        l_id NUMBER;
        l_guid VARCHAR2(32);
        l_is_notification NUMBER;
        l_role_guid VARCHAR2(32);
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100);
        l_updated_at TIMESTAMP;
        l_deleted_by VARCHAR2(100);
        l_deleted_at TIMESTAMP;
       	v_iam_has CLOB;
    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.IAM_ACCESS
        SET
            is_notification = p_is_notification,
            updated_by = p_updated_by,
            updated_at = SYSTIMESTAMP
        WHERE
            guid = p_guid
        RETURNING
            id,
            guid,
            is_notification,
            role_guid,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO
            l_id,
            l_guid,
            l_is_notification,
            l_role_guid,
            l_created_by,
            l_created_at,
            l_updated_by, 
            l_updated_at;
          
         v_iam_has:=UBS_TRAINING.UPDATE_MULTI_IAM_HAS(l_guid,p_data); 
        
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(l_is_notification) || ',"role_guid":"' || l_role_guid ||'","iam_has_access":[' || v_iam_has || '],"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || l_updated_by || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.UPDATE_ROLE_AND_CHILD(
	p_role_guid VARCHAR2,
    p_role_code VARCHAR2,
    p_role_name VARCHAR2,
    p_updated_by VARCHAR2,
    p_iam_is_notification NUMBER,
	p_iam_has_data IN UBS_TRAINING.iam_has_req_cud_table
) RETURN CLOB
IS
v_json CLOB; 
v_role_json CLOB;
v_role_guid VARCHAR2(32);
v_iam_json CLOB;
v_iam_guid VARCHAR2(32);
v_has_json CLOB;
BEGIN
	SELECT guid INTO v_iam_guid FROM UBS_TRAINING.iam_access iam WHERE iam.role_guid = p_role_guid;
	v_role_json:=UBS_TRAINING.update_role(p_role_guid,p_role_code,p_role_name,p_updated_by);
	v_iam_json:=UBS_TRAINING.update_iam_access_for_role(v_iam_guid,p_iam_is_notification,p_updated_by,p_iam_has_data);
	v_json:='{"role":{' || v_role_json || ',"iam_access":' || v_iam_json ||'}}';
	RETURN v_json;
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- Unique constraint violation error
                v_json := '{"error": {"code": "' || SQLCODE || '","message":"Duplicate key violation. This record already exists."}}';
                -- Log the error information
                RETURN v_json;
                -- You can choose to perform additional actions or continue without raising an error
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code":"' || SQLCODE || '","message":"' || SQLERRM || '"}}';
            -- Print error information to debug
            RETURN v_json;
END UPDATE_ROLE_AND_CHILD;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_role (
    p_guid VARCHAR2,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
	UPDATE UBS_TRAINING.EMPLOYEE emp
    SET
        ROLE_GUID = NULL,
        UPDATED_BY = p_deleted_by,
        UPDATED_AT = SYSTIMESTAMP
    WHERE
           emp.role_guid = p_guid;
    -- Update the row and set the deleted columns
    UPDATE UBS_TRAINING.ROLE
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING."DELETE_ROLE_AND_CHILD" (
p_guid VARCHAR2,
p_deleted_by VARCHAR2
)
IS
BEGIN
	DELETE FROM UBS_TRAINING.IAM_HAS_ACCESS
	WHERE
		iam_access_guid IN (SELECT guid FROM UBS_TRAINING.IAM_ACCESS iam WHERE iam.ROLE_GUID=p_guid);
	
	UPDATE UBS_TRAINING.IAM_ACCESS
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        role_guid = p_guid;
       
    UPDATE UBS_TRAINING.EMPLOYEE emp
    SET
        ROLE_GUID = NULL,
        UPDATED_BY = p_deleted_by,
        UPDATED_AT = SYSTIMESTAMP
    WHERE
           emp.role_guid = p_guid;
       
        UPDATE UBS_TRAINING.ROLE
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
    
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.detail_iam_access_key (
    p_role_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"guid":"' || guid ||
        '","is_notification":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_notification) ||
        ',"iam_has_access":'|| UBS_TRAINING.DETAIL_IAM_HAS_ACCESS_LIST(role_guid)||
        ',"created_by":"' || created_by ||
        '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') ||
        '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}' 
    INTO v_json
    FROM UBS_TRAINING.IAM_ACCESS
    WHERE ROLE_GUID  = p_role_guid;
    
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.detail_iam_has_access_key (
    p_iam_access_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"guid":"' || guid || 
        '","is_create":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_create) ||
        ',"is_read":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_read) || 
        ',"is_update":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_update) || 
        ',"is_delete":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_delete) ||
        ',"is_custom1":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom1) || 
        ',"is_custom2":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom2) ||
        ',"is_custom3":' || UBS_TRAINING.DETAIL_TO_BOOLEAN(is_custom3) ||
        ',"sidebar_menu_guid":"' || SIDEBAR_MENU_GUID || '"}' -- End of the outer CASE
    INTO v_json
    FROM UBS_TRAINING.IAM_HAS_ACCESS iha
    WHERE guid = p_iam_access_guid;

    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.detail_iam_has_access_list (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '[' || CHR(13) || CHR(10); -- Initialize with an opening bracket for JSON ARRAY
BEGIN
    FOR emp IN (
        SELECT guid
        FROM (
            SELECT iha.guid
            FROM UBS_TRAINING.iam_has_access iha 
            JOIN UBS_TRAINING.iam_access ia ON iha.iam_access_guid = ia.guid
            WHERE
            	ia.role_guid = p_guid
                AND deleted_at IS NULL
        )
    ) LOOP
        v_json := v_json || UBS_TRAINING.detail_iam_has_access_key(emp.guid) || ',' || CHR(13) || CHR(10);
    END LOOP;
    
    -- Remove the trailing comma and close the JSON array
    v_json := RTRIM(v_json, ',' || CHR(13) || CHR(10)) || CHR(13) || CHR(10) || ']';
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_ROLE_BY_GUID" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"guid":"' || guid ||
        '","code":"' || code || 
        '","role_name":"' || role_name || 
        '","iam_access":' || UBS_TRAINING.DETAIL_IAM_ACCESS_KEY(guid)||
        ',"order_number":' || order_number ||
        ',"created_by":"' || created_by ||'","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}'
    INTO v_json
    FROM UBS_TRAINING.ROLE
    WHERE guid = p_guid AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_ROLES" (
    p_set_code NUMBER,
    p_value_code VARCHAR2,
    p_set_role_name NUMBER,
    p_value_role_name VARCHAR2,
    p_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := ' ';
BEGIN
    DECLARE
        v_role_data CLOB;
        v_role_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
        -- Initialize CLOB for v_role_data
        DBMS_LOB.CREATETEMPORARY(v_role_data, TRUE);

        -- Make limit variable
        IF P_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := P_limit_data;
        END IF;
        -- make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * P_limit_data + 1;
        END IF;
       
        SELECT COUNT(*)
        INTO v_role_count
        FROM UBS_TRAINING.ROLE role
        WHERE
            (p_set_code != 1 OR ((1=1) AND UPPER(role.CODE) LIKE UPPER(p_value_code)))
            AND (p_set_role_name != 1 OR ((1=1) AND UPPER(role.ROLE_NAME) LIKE UPPER(p_value_role_name)))
            AND role.DELETED_AT IS NULL;
IF v_role_count = 0 THEN
     v_json := '{"role_data":[' || v_role_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_role_count / limit_value) || ',"total_data":' || v_role_count || '}';
    RETURN v_json;
END IF;

IF CEIL(v_role_count / limit_value)<p_offset_page THEN
     v_json := '{"role_data":[' || v_role_data || '],"current_page":' || offset_value || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_role_count / limit_value) || ',"total_data":' || v_role_count || '}';
    RETURN v_json;
END IF;

        -- Query for role data
        FOR role_rec IN (
        SELECT * FROM (
            SELECT
            	GUID,
            	CODE,
            	ROLE_NAME,
            	ORDER_NUMBER,
            	CREATED_AT,
                CREATED_BY,
                UPDATED_AT,
                UPDATED_BY,
                ROWNUM AS rnum
                FROM(
            	SELECT
                r.GUID,
                r.CODE,
                r.ROLE_NAME,
                r.ORDER_NUMBER,
                r.CREATED_AT,
                r.CREATED_BY,
                r.UPDATED_AT,
                r.UPDATED_BY
            FROM
                UBS_TRAINING.ROLE r
            WHERE
                (p_set_code != 1 OR ((1=1) AND UPPER(r.CODE) LIKE UPPER(p_value_code)))
                AND (p_set_role_name != 1 OR ((1=1) AND UPPER(r.ROLE_NAME) LIKE UPPER(p_value_role_name)))
                AND r.DELETED_AT IS NULL
                ORDER BY
                CASE WHEN UPPER(p_sort_value) = 'CODE ASC' THEN r.CODE END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CODE DESC' THEN r.CODE END DESC,
                CASE WHEN UPPER(p_sort_value) = 'ROLE_NAME ASC' THEN r.ROLE_NAME END ASC,
                CASE WHEN UPPER(p_sort_value) = 'ROLE_NAME DESC' THEN r.ROLE_NAME END DESC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER ASC' THEN r.ORDER_NUMBER END ASC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER DESC' THEN r.ORDER_NUMBER END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT ASC' THEN r.CREATED_AT END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT DESC' THEN r.CREATED_AT END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY ASC' THEN r.CREATED_BY END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY DESC' THEN r.CREATED_BY END DESC,
                r.CREATED_AT DESC
        ))
            WHERE
                rnum BETWEEN offset_value AND (offset_value + limit_value - 1)
        )
        LOOP
            -- Append the JSON representation of the current record to the CLOB
            DBMS_LOB.APPEND(v_role_data, '{"guid":"' || role_rec.GUID || '","code":"' || role_rec.CODE || '","role_name":"' || role_rec.ROLE_NAME || '","order_number":' || role_rec.ORDER_NUMBER ||',"iam_access":' || UBS_TRAINING.DETAIL_IAM_ACCESS_KEY(role_rec.guid)||
           ',"created_at":"' || TO_CHAR(role_rec.CREATED_AT, 'YYYY-MM-DD HH24:MI:SS') || '","created_by":"' || role_rec.CREATED_BY || '","updated_at":"' || TO_CHAR(role_rec.UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(role_rec.UPDATED_BY,'') || '"}');

            -- Append a comma to separate JSON objects (except for the last one)
            DBMS_LOB.APPEND(v_role_data, ',');
        END LOOP;
		DBMS_LOB.TRIM(v_role_data, DBMS_LOB.GETLENGTH(v_role_data) - 1);

        -- Construct the JSON object
        v_json := '{"role_data":[' || v_role_data || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_role_count / limit_value) || ',"total_data":' || v_role_count || '}';
    END;

    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.UPDATE_EMPLOYEE_ROLE(
	p_status_action NUMBER,
    p_role_guid VARCHAR2,
    p_updated_by VARCHAR2 DEFAULT NULL,
    p_user_guid  VARCHAR2 
)
IS
BEGIN
	IF p_status_action = 1 THEN
	UBS_TRAINING.UPDATE_EMPLOYEE_ROLE(2,p_role_guid,p_updated_by,'');
	    UPDATE UBS_TRAINING.EMPLOYEE
    SET
        ROLE_GUID = p_role_guid,
        UPDATED_BY = p_updated_by,
        UPDATED_AT = SYSTIMESTAMP
    WHERE
        GUID IN (
            SELECT (TRIM(VALUE)) AS status_user 
            FROM XMLTABLE(
                XMLNAMESPACES(DEFAULT 'http://www.w3.org/2001/XMLSchema-instance'), 
                ('"' || REPLACE(p_user_guid, ',', '","') || '"') 
                COLUMNS VALUE VARCHAR2(4000) PATH '.'
            )
        );
	ELSE
		    UPDATE UBS_TRAINING.EMPLOYEE emp
    SET
        ROLE_GUID = NULL,
        UPDATED_BY = p_updated_by,
        UPDATED_AT = SYSTIMESTAMP
    WHERE
           emp.role_guid = p_role_guid;
 END IF;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_IAMACCESSMDDW"
(p_employee_guid VARCHAR2)
RETURN CLOB
IS v_result CLOB;
BEGIN
	SELECT
		'{"role_name":"' || r.ROLE_NAME ||
		'","role_code":"'	 ||r.CODE||
		'","iam_access_guid":"' || IA.GUID ||
		'","is_notification":' || ia.IS_NOTIFICATION || '}'
	INTO v_result
	FROM UBS_TRAINING.EMPLOYEE e 
	LEFT JOIN UBS_TRAINING."ROLE" r ON e.ROLE_GUID = r.GUID 
	LEFT JOIN UBS_TRAINING.IAM_ACCESS ia ON R.GUID = IA.ROLE_GUID
	WHERE e.GUID = p_employee_guid AND r.DELETED_AT IS NULL;
	RETURN v_result;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_IAM_HAS_ACCESS_MDDW"
(p_iam_guid VARCHAR2)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    DECLARE 
        v_temp_json CLOB;
    BEGIN
        DBMS_LOB.CREATETEMPORARY(v_temp_json, TRUE);
        FOR rec IN (
            SELECT 
                iha.ID,
                iha.GUID,
                iha.SIDEBAR_MENU_GUID,
                iha.IS_CREATE,
                iha.IS_READ,
                iha.IS_UPDATE,
                iha.IS_DELETE,
                iha.IS_CUSTOM1,
                iha.IS_CUSTOM2,
                iha.IS_CUSTOM3
            FROM UBS_TRAINING.IAM_HAS_ACCESS iha
            WHERE iha.IAM_ACCESS_GUID = p_iam_guid
        )
        LOOP
            DBMS_LOB.APPEND(v_temp_json, '{"id":' || rec.id || ',"guid":"' || rec.guid || '","sidebarmenu_guid":"' || rec.sidebar_menu_guid || '","is_read":' || rec.is_read || ',"is_create":' || rec.is_create || ',"is_update":' || rec.is_update || ',"is_delete":' || rec.is_delete || ',"is_custom_1":' || rec.is_custom1 || ',"is_custom_2":' || rec.is_custom2 || ',"is_custom_3":' || rec.is_custom3 || '}');
            DBMS_LOB.APPEND(v_temp_json, ',');
        END LOOP;
        DBMS_LOB.TRIM(v_temp_json, DBMS_LOB.GETLENGTH(v_temp_json) - 1);
        v_json := '[' || v_temp_json || ']';
    END;
    RETURN v_json;
END;

---

CREATE TABLE UBS_TRAINING.BLACKLISTED_TOKEN (
    token VARCHAR2(255),
    blacklisted_type VARCHAR2(255),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_blacklisted_token (
    p_token VARCHAR2,
    p_blacklisted_type VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_token          		VARCHAR2(255); -- Adjust the size based on your column definition
        l_blacklisted_type  VARCHAR2(255);
        l_created_at        TIMESTAMP DEFAULT SYSTIMESTAMP;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.BLACKLISTED_TOKEN (
            token, blacklisted_type, created_at
        )
        VALUES (
            p_token, p_blacklisted_type, SYSTIMESTAMP
        )
        RETURNING token, blacklisted_type, created_at
        INTO l_token, l_blacklisted_type, l_created_at;
        
        -- Construct JSON object
        v_json := '{"token": ' || l_token || 
									',"blacklisted_type":"' || l_blacklisted_type || 
									'","created_at":"' || l_created_at || '"}';
    END;
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.get_blacklisted_token (
    p_token VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid and status_user
    SELECT 
        '{"token": ' || token || 
				',"blacklisted_type":"' || blacklisted_type || 
				'","created_at":"' || created_at || '"}'
    INTO v_json
    FROM (
    SELECT *
    FROM UBS_TRAINING.BLACKLISTED_TOKEN
    WHERE token = p_token
      AND ROWNUM <= 1);
    RETURN v_json;
EXCEPTION
WHEN NO_DATA_FOUND THEN
    -- Handle case when no data is found
    RETURN v_json;
WHEN OTHERS THEN
    -- Handle other exceptions as needed
    RETURN NULL;
END;

---

CREATE TABLE UBS_TRAINING.MASTERDATA_VALUE (
  masterdata_value_id NUMBER UNIQUE,
  guid VARCHAR2(32) DEFAULT RAWTOHEX(SYS_GUID()) PRIMARY KEY,
  category VARCHAR2(50) NOT NULL,
  value1 VARCHAR2(255) NOT NULL,
  value2 VARCHAR2(255),
  parent_id NUMBER REFERENCES UBS_TRAINING.MASTERDATA_VALUE(MASTERDATA_VALUE_ID) ON DELETE CASCADE,
  order_number NUMBER,
  created_by VARCHAR2(100),
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
  updated_by VARCHAR2(100) NULL,
  updated_at TIMESTAMP NULL,
  deleted_by VARCHAR2(100) NULL,
  deleted_at TIMESTAMP NULL
);

---

CREATE SEQUENCE UBS_TRAINING.masterdata_value_seq
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE;

---

CREATE OR REPLACE TRIGGER UBS_TRAINING.masterdata_value_trigger
  BEFORE INSERT ON UBS_TRAINING.MASTERDATA_VALUE
  FOR EACH ROW
BEGIN
  :new.masterdata_value_id := masterdata_value_seq.nextval;
  :new.order_number := :new.masterdata_value_id;
END;

---

CREATE OR REPLACE TYPE UBS_TRAINING.CLOBTABLE AS TABLE OF CLOB;

---

INSERT ALL
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (1, '0BD05A4A0997F4A3E06014AC02006216', 'User Status', 'Active', NULL, NULL, 1, 'temporary by system', TIMESTAMP'2023-12-06 03:57:41.201277', 'temporary by system', TIMESTAMP'2023-12-07 14:02:14.852125', NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (2, '0BD183B73F0AF9B8E06014AC02006312', 'User Status', 'Non active', NULL, NULL, 2, 'temporary by system', TIMESTAMP'2023-12-06 05:20:51.191536', 'temporary by system', TIMESTAMP'2023-12-07 14:04:08.947533', NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (3, '0BDA72E638332B0FE06014AC020067D6', 'Project Status', 'Active', NULL, NULL, 1, 'temporary by system', TIMESTAMP'2023-12-06 16:43:46.975525', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (4, '0BDA72E638342B0FE06014AC020067D6', 'Project Status', 'Cancel', NULL, NULL, 2, 'temporary by system', TIMESTAMP'2023-12-06 16:43:56.877569', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (5, '0BDA72E638352B0FE06014AC020067D6', 'Project Status', 'Finished', NULL, NULL, 3, 'temporary by system', TIMESTAMP'2023-12-06 16:44:01.785639', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (6, '0BDA72E638362B0FE06014AC020067D6', 'Project Priority', 'Urgent - Important', NULL, NULL, 1, 'temporary by system', TIMESTAMP'2023-12-06 16:44:13.375123', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (7, '0BDA72E638372B0FE06014AC020067D6', 'Project Priority', 'Not Urgent - Important', NULL, NULL, 2, 'temporary by system', TIMESTAMP'2023-12-06 16:44:19.866027', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (8, '0BDA72E638382B0FE06014AC020067D6', 'Project Priority', 'Urgent - Not Important', NULL, NULL, 3, 'temporary by system', TIMESTAMP'2023-12-06 16:44:27.114525', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.MASTERDATA_VALUE (MASTERDATA_VALUE_ID, GUID, CATEGORY, VALUE1, VALUE2, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT) 
    VALUES (9, '0BDA72E638392B0FE06014AC020067D6', 'Project Priority', 'Not Urgent - Not Important', NULL, NULL, 4, 'temporary by system', TIMESTAMP'2023-12-06 16:44:34.688994', NULL, NULL, NULL, NULL)
SELECT 1 FROM DUAL;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.insert_masterdata_value (
    p_category VARCHAR2,
    p_value1 VARCHAR2,
    p_value2 VARCHAR2,
    p_parent_id NUMBER,
    p_created_by VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the inserted row
    DECLARE
        l_guid VARCHAR2(32);
        l_category VARCHAR2(50);
        l_value1 VARCHAR2(255);
        l_value2 VARCHAR2(255);
        l_parent_id NUMBER;
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100) NULL;
        l_updated_at TIMESTAMP NULL;
        l_deleted_by VARCHAR2(100) NULL;
        l_deleted_at TIMESTAMP NULL;
    BEGIN 
        -- Insert new row
        INSERT INTO UBS_TRAINING.masterdata_value (
            category,
            value1,
            value2,
            parent_id,
            created_by
        )
        VALUES (
            p_category,
            p_value1,
            p_value2,
            p_parent_id,
            p_created_by
        )
        RETURNING 
            guid,
            category,
            value1,
            value2,
            parent_id,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO 
            l_guid,
            l_category,
            l_value1,
            l_value2,
            l_parent_id,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","category":"' || l_category || '","value1":"' || l_value1 || '","value2":"' || l_value2 || '","parent_id":' || NVL(l_parent_id, 0) || ',"order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || NVL(l_updated_by, '') || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}';
    END;
    RETURN v_json;
      	EXCEPTION
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code": ' || SQLCODE || ',"message":"' || SQLERRM || '"}}';
    -- Return the JSON
    RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."GET_MASTERDATA_VALUE_BY_GUID" (
    p_guid VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"masterdata_value_id":' || masterdata_value_id || ',"guid":"' || guid ||
        '","category":"' || category || '","value1":"' || value1 ||
        '","value2":"' || NVL(value2, '') || '","parent":' || UBS_TRAINING.detail_parent_masterdata(parent_id) || ',"order_number":' || order_number ||
        ',"created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
        '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}'
    INTO v_json
    FROM UBS_TRAINING.MASTERDATA_VALUE
    WHERE guid = p_guid AND deleted_at IS NULL;
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN v_json;
    WHEN OTHERS THEN
            v_json := '{"error": {"code": ' || SQLCODE || ',"message":"' || SQLERRM || '"}}';
        -- Handle other exceptions as needed
        RETURN v_json;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.update_masterdata_value (
    p_guid VARCHAR2,
    p_category VARCHAR2,
    p_value1 VARCHAR2,
    p_value2 VARCHAR2,
    p_parent_id NUMBER,
    p_order_number NUMBER,
    p_updated_by VARCHAR2 DEFAULT NULL
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    -- Declare variables to store column values of the updated row
    DECLARE
        l_guid VARCHAR2(32);
       	l_category VARCHAR2(255);
        l_value1 VARCHAR2(255);
        l_value2 VARCHAR2(255);
        l_parent_id NUMBER;
        l_order_number NUMBER;
        l_created_by VARCHAR2(100);
        l_created_at TIMESTAMP;
        l_updated_by VARCHAR2(100);
        l_updated_at TIMESTAMP;
    BEGIN
        -- Update the row and return the values into variables
        UPDATE UBS_TRAINING.MASTERDATA_VALUE
        SET
            category=p_category,
            value1 = p_value1,
            value2 = p_value2,
            parent_id = p_parent_id,
            order_number = p_order_number,
            updated_by = p_updated_by,
            updated_at = SYSTIMESTAMP
        WHERE
            guid = p_guid
        RETURNING
            guid,
            category,
            value1,
            value2,
            parent_id,
            order_number,
            created_by,
            created_at,
            updated_by,
            updated_at
        INTO
            l_guid,
            l_category,
            l_value1,
            l_value2,
            l_parent_id,
            l_order_number,
            l_created_by,
            l_created_at,
            l_updated_by,
            l_updated_at;

        
        -- Construct JSON object
        v_json := '{"guid":"' || l_guid || '","category":"' || l_category || '","value1":"' || l_value1 || '","value2":"' || l_value2 || '","parent_id":' || NVL(l_parent_id, 0) || ',"order_number":' || l_order_number || ',"created_by":"' || l_created_by || '","created_at":"' || TO_CHAR(l_created_at, 'YYYY-MM-DD HH24:MI:SS') || '","updated_by":"' || l_updated_by || '","updated_at":"' || TO_CHAR(l_updated_at, 'YYYY-MM-DD HH24:MI:SS') ||'"}';
    END;
    -- Return the JSON
    RETURN v_json;
   
    EXCEPTION
        WHEN OTHERS THEN
            -- Construct JSON object for general error information
            v_json := '{"error": {"code": ' || SQLCODE || ',"message":"' || SQLERRM || '"}}';
       	RETURN v_json;
       
END;

---

CREATE OR REPLACE PROCEDURE UBS_TRAINING.delete_masterdata_value (
    p_guid VARCHAR2,
    p_deleted_by VARCHAR2 DEFAULT NULL
)
IS
BEGIN
    -- Update the row and set the deleted columns
    UPDATE UBS_TRAINING.MASTERDATA_VALUE
    SET
        deleted_by = p_deleted_by,
        deleted_at = SYSTIMESTAMP
    WHERE
        guid = p_guid;
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING.detail_parent_masterdata(
    p_parent_id VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB := '{}'; -- Initialize with an empty JSON object
BEGIN
    -- Retrieve data by guid
    SELECT 
        '{"masterdata_value_id":' || masterdata_value_id || 
        ',"guid":"' || guid ||
        '","category":"' || category || 
        '","value1":"' || value1 ||
        '","value2":"' || NVL(value2, '') ||
        '","parent_id":' || NVL(parent_id, 0) ||
        ',"order_number":' || ORDER_NUMBER || 
        ',"created_by":"' || created_by || '","created_at":"' || TO_CHAR(created_at, 'YYYY-MM-DD HH24:MI:SS') ||
         '","updated_by":"' || NVL(updated_by, '') || '","updated_at":"' || TO_CHAR(updated_at, 'YYYY-MM-DD HH24:MI:SS') || '"}'
    INTO v_json
    FROM UBS_TRAINING.MASTERDATA_VALUE
    WHERE masterdata_value_id = p_parent_id AND deleted_at IS NULL;
    
    RETURN v_json;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle case when no data is found
        RETURN 'null';
    WHEN OTHERS THEN
        -- Handle other exceptions as needed
        RETURN NULL; 
END;

---

CREATE OR REPLACE FUNCTION UBS_TRAINING."LIST_MASTERDATA_VALUES" (
    p_set_category NUMBER,
    p_value_category VARCHAR2,
    p_set_value1 NUMBER,
    p_value_value1 VARCHAR2,
    p_set_value2 NUMBER,
    p_value_value2 VARCHAR2,
    p_set_parent_id NUMBER,
    p_value_parent_id NUMBER,
    p_limit_data NUMBER,
    p_offset_page NUMBER,
    p_sort_value VARCHAR2
)
RETURN CLOB
IS
    v_json CLOB;
BEGIN
    DECLARE
        v_masterdata_values CLOB; -- Adjust the size based on your data
        v_masterdata_count NUMBER;
        offset_value NUMBER;
        limit_value NUMBER;
    BEGIN
	    DBMS_LOB.CREATETEMPORARY(v_masterdata_values, TRUE);
        -- make limit variable
        IF p_limit_data <= 0 THEN
            limit_value := 10;
        ELSE
            limit_value := p_limit_data;
        END IF;
        -- make offset variable
        IF p_offset_page <= 0 THEN
            offset_value := 1;
        ELSE
            offset_value := (p_offset_page - 1) * p_limit_data + 1;
        END IF;
        
       	SELECT COUNT(*)
        INTO v_masterdata_count
        FROM UBS_TRAINING.MASTERDATA_VALUE mdv
            WHERE
                (p_set_category != 1 OR ((1=1) AND UPPER(mdv.CATEGORY) LIKE UPPER(p_value_category)))
                AND (p_set_value1 != 1 OR ((1=1) AND UPPER(mdv.VALUE1) LIKE UPPER(p_value_value1)))
                AND (p_set_value2 != 1 OR ((1=1) AND UPPER(mdv.VALUE2) LIKE UPPER(p_value_value2)))
                AND (p_set_parent_id != 1 OR ((1=1) AND mdv.PARENT_ID = p_value_parent_id))
                AND mdv.DELETED_AT IS NULL;
           
       	IF v_masterdata_count = 0 THEN
       		v_json := '{"masterdata_values":[' || v_masterdata_values || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_masterdata_count / limit_value) || ',"total_data":' || v_masterdata_count || '}';
   		RETURN v_json;
      	END IF;
      
      	IF CEIL(v_masterdata_count / limit_value)<p_offset_page THEN
      	    v_json := '{"masterdata_values":[' || v_masterdata_values || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_masterdata_count / limit_value) || ',"total_data":' || v_masterdata_count || '}';
   		RETURN v_json;
      	END IF;
      	
        -- Query for masterdata values
        FOR rec IN(
        SELECT * FROM(
        	SELECT
        		GUID,
               CATEGORY,
               VALUE1,
               VALUE2,
               PARENT_ID,
               ORDER_NUMBER,
               CREATED_AT,
               CREATED_BY,
               UPDATED_AT,
               UPDATED_BY,
               ROWNUM AS rnum
               FROM (
            SELECT
                mdv.GUID,
                mdv.CATEGORY,
                mdv.VALUE1,
                mdv.VALUE2,
                mdv.PARENT_ID,
                mdv.ORDER_NUMBER,
                mdv.CREATED_AT,
                mdv.CREATED_BY,
                mdv.UPDATED_AT,
                mdv.UPDATED_BY
            FROM
                UBS_TRAINING.MASTERDATA_VALUE mdv
            WHERE
                (p_set_category != 1 OR ((1=1) AND UPPER(mdv.CATEGORY) LIKE UPPER(p_value_category)))
                AND (p_set_value1 != 1 OR ((1=1) AND UPPER(mdv.VALUE1) LIKE UPPER(p_value_value1)))
                AND (p_set_value2 != 1 OR ((1=1) AND UPPER(mdv.VALUE2) LIKE UPPER(p_value_value2)))
                AND (p_set_parent_id != 1 OR ((1=1) AND mdv.PARENT_ID = p_value_parent_id))
                AND mdv.DELETED_AT IS NULL
            ORDER BY
                CASE WHEN UPPER(p_sort_value) = 'MASTERDATA_VALUE_ID ASC' THEN MDV.MASTERDATA_VALUE_ID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'MASTERDATA_VALUE_ID DESC' THEN MDV.MASTERDATA_VALUE_ID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'GUID ASC' THEN MDV.GUID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'GUID DESC' THEN MDV.GUID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CATEGORY ASC' THEN MDV.CATEGORY END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CATEGORY DESC' THEN MDV.CATEGORY END DESC,
                CASE WHEN UPPER(p_sort_value) = 'VALUE1 ASC' THEN MDV.VALUE1 END ASC,
                CASE WHEN UPPER(p_sort_value) = 'VALUE1 DESC' THEN MDV.VALUE1 END DESC,
                CASE WHEN UPPER(p_sort_value) = 'VALUE2 ASC' THEN MDV.VALUE2 END ASC,
                CASE WHEN UPPER(p_sort_value) = 'VALUE2 DESC' THEN MDV.VALUE2 END DESC,
                CASE WHEN UPPER(p_sort_value) = 'PARENT_ID ASC' THEN MDV.PARENT_ID END ASC,
                CASE WHEN UPPER(p_sort_value) = 'PARENT_ID DESC' THEN MDV.PARENT_ID END DESC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER ASC' THEN MDV.ORDER_NUMBER END ASC,
                CASE WHEN UPPER(p_sort_value) = 'ORDER_NUMBER DESC' THEN MDV.ORDER_NUMBER END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT ASC' THEN MDV.CREATED_AT END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_AT DESC' THEN MDV.CREATED_AT END DESC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY ASC' THEN MDV.CREATED_BY END ASC,
                CASE WHEN UPPER(p_sort_value) = 'CREATED_BY DESC' THEN MDV.CREATED_BY END DESC,
                MDV.CREATED_AT DESC
        ))
        WHERE rnum BETWEEN offset_value AND (offset_value + limit_value - 1))
        -- Query for masterdata count
		LOOP
	    	DBMS_LOB.APPEND(v_masterdata_values, '{"guid":"' || rec.GUID || '","category":"' || rec.CATEGORY || '","value1":"' || rec.VALUE1 || '","value2":"' || NVL(rec.VALUE2, '') || '","parent":' || UBS_TRAINING.detail_parent_masterdata(rec.parent_id) || ',"order_number":' || rec.ORDER_NUMBER || ',"created_at":"' || rec.CREATED_AT || '","created_by":"' || rec.CREATED_BY || '","updated_at":"' || NVL(TO_CHAR(rec.UPDATED_AT, 'YYYY-MM-DD HH24:MI:SS'), '') || '","updated_by":"' || NVL(rec.UPDATED_BY, '') || '"}');
	        DBMS_LOB.APPEND(v_masterdata_values, ',');
        END LOOP;
       		DBMS_LOB.TRIM(v_masterdata_values, DBMS_LOB.GETLENGTH(v_masterdata_values) - 1);
       
        -- Construct the JSON object
        v_json := '{"masterdata_values":[' || v_masterdata_values || '],"current_page":' || p_offset_page || ',"limit":' || limit_value || ',"total_page":' || CEIL(v_masterdata_count / limit_value) || ',"total_data":' || v_masterdata_count || '}';
    END;
    RETURN v_json;
END;

---

INSERT ALL
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (3, '0BE9CC0F0FCA4535E06014AC020071CE', 'M001', 'Dashboard', 'Dashboard', 1, '/', 'dashboard', 1, NULL, 1, 'temporary by system', TIMESTAMP '2023-12-07 10:19:04.121274', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (5, '0C2BD326C0339AE0E06014AC02009050', 'M002', 'Team Management', 'SupervisorAccount', 1, '/team-management', 'team-management', 1, NULL, 2, 'temporary by system', TIMESTAMP '2023-12-10 17:05:37.162770', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (6, '0C2BD326C0349AE0E06014AC02009050', 'M003', 'Gantt Chart', 'TableChart', 1, '/gantt-chart', 'gantt-chart', 1, NULL, 3, 'temporary by system', TIMESTAMP '2023-12-10 17:05:41.797044', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (9, '0C4B5038B8CAF54BE06014AC0200A115', 'M004', 'RACI Management', 'SupervisedUserCircle', 0, '/raci-management', 'raci-management', 1, NULL, 4, 'temporary by system', TIMESTAMP '2023-12-12 07:03:22.703281', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (92, '0C67748B17CE2EC8E06014AC0200B1DB', 'M005', 'Project', 'Task', 1, '/project', 'project', 1, NULL, 5, 'temporary by system', TIMESTAMP '2023-12-13 16:14:11.645986', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (93, '0C67748B17CF2EC8E06014AC0200B1DB', 'M006', 'Department', 'Business', 1, '/workspace', 'department', 1, NULL, 6, 'temporary by system', TIMESTAMP '2023-12-13 16:14:15.154364', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (94, '0C67748B17D02EC8E06014AC0200B1DB', 'M007', 'State Management', 'LowPriority', 1, '/priority-management', 'priority-management', 1, NULL, 7, 'temporary by system', TIMESTAMP '2023-12-13 16:14:18.225728', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (95, '0C67748B17D12EC8E06014AC0200B1DB', 'M008', 'Access Management', 'Security', 1, '/access-management', 'access-management', 1, NULL, 8, 'temporary by system', TIMESTAMP '2023-12-13 16:14:21.124784', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (96, '0C67748B17D22EC8E06014AC0200B1DB', 'M009', 'User Management', 'Groups', 1, '/user-management', 'user-management', 1, NULL, 9, 'temporary by system', TIMESTAMP '2023-12-13 16:14:24.320616', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (11, '0C4B5038B8CCF54BE06014AC0200A115', 'SM001', 'Responsible', 'VerifiedUser', 1, '/raci-management/responsible', 'responsible', 2, (SELECT SIDEBAR_MENU_ID FROM UBS_TRAINING.SIDEBAR_MENU WHERE GUID = '0C4B5038B8CAF54BE06014AC0200A115'), 1, 'temporary by system', TIMESTAMP '2023-12-12 07:07:08.697252', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (89, '0C67748B17CB2EC8E06014AC0200B1DB', 'SM002', 'Accountable', 'VerifiedUser', 1, '/raci-management/accountable', 'accountable', 2, (SELECT SIDEBAR_MENU_ID FROM UBS_TRAINING.SIDEBAR_MENU WHERE GUID = '0C4B5038B8CAF54BE06014AC0200A115'), 2, 'temporary by system', TIMESTAMP '2023-12-13 16:14:01.734077', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (90, '0C67748B17CC2EC8E06014AC0200B1DB', 'SM003', 'Consulted', 'VerifiedUser', 1, '/raci-management/consulted', 'consulted', 2, (SELECT SIDEBAR_MENU_ID FROM UBS_TRAINING.SIDEBAR_MENU WHERE GUID = '0C4B5038B8CAF54BE06014AC0200A115'), 3, 'temporary by system', TIMESTAMP '2023-12-13 16:14:05.044468', NULL, NULL, NULL, NULL)
    INTO UBS_TRAINING.SIDEBAR_MENU (SIDEBAR_MENU_ID, GUID, CODE, TEXT_SIDEBAR, ICON, HAS_PAGE, URL_PATH, SLUG, LEVEL_SIDEBAR, PARENT_ID, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (91, '0C67748B17CD2EC8E06014AC0200B1DB', 'SM004', 'Informed', 'VerifiedUser', 1, '/raci-management/informed', 'informed', 2, (SELECT SIDEBAR_MENU_ID FROM UBS_TRAINING.SIDEBAR_MENU WHERE GUID = '0C4B5038B8CAF54BE06014AC0200A115'), 4, 'temporary by system', TIMESTAMP '2023-12-13 16:14:08.374403', NULL, NULL, NULL, NULL)
SELECT 1 FROM DUAL;

---

INSERT ALL
    INTO UBS_TRAINING."ROLE" (ROLE_ID, GUID, CODE, ROLE_NAME, ORDER_NUMBER, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
    VALUES (118, '0CEA188286523464E06014AC0200F06F', 'SYSADMIN', 'Superadmin', 118, 'temporary by system', TIMESTAMP '2023-12-20 04:05:38.384421', '0CEA2A1BC6DE2246E06014AC0200F07B', TIMESTAMP '2024-07-14 14:31:20.833461', NULL, NULL)
SELECT 1 FROM DUAL;

---

INSERT INTO UBS_TRAINING.IAM_ACCESS
(ID, GUID, IS_NOTIFICATION, ROLE_GUID, CREATED_BY, CREATED_AT, UPDATED_BY, UPDATED_AT, DELETED_BY, DELETED_AT)
VALUES(100, '0CEA188286533464E06014AC0200F06F', 1, '0CEA188286523464E06014AC0200F06F', 'temporary by system', TIMESTAMP '2023-12-20 04:05:38.391723', '0CEA2A1BC6DE2246E06014AC0200F07B', TIMESTAMP '2024-07-14 14:31:20.833854', NULL, NULL);

---

INSERT ALL
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (265, '1044F54BFEB0664EE06014AC02007B75', 0, 1, 0, 0, 1, 1, NULL, '0CEA188286533464E06014AC0200F06F', '0BE9CC0F0FCA4535E06014AC020071CE')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (271, '10501E589D946A4BE06014AC020080F1', 0, 1, 0, 0, 1, 1, NULL, '0CEA188286533464E06014AC0200F06F', '0C2BD326C0339AE0E06014AC02009050')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (264, '10450B9E58F597F2E06014AC02007B6B', 0, 1, 0, 0, 1, 1, NULL, '0CEA188286533464E06014AC0200F06F', '0C2BD326C0349AE0E06014AC02009050')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (268, '1045C43C665E74DAE06014AC02007BC9', 0, 1, 0, 0, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C4B5038B8CCF54BE06014AC0200A115')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (200, '0CEA7FE35DB615BCE06014AC0200F0AF', 0, 1, 0, 0, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C67748B17CB2EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (201, '0CEA7FE35DB715BCE06014AC0200F0AF', 0, 1, 0, 0, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C67748B17CC2EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (202, '0CEA7FE35DB815BCE06014AC0200F0AF', 0, 1, 0, 0, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C67748B17CD2EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (194, '0CEA1882865B3464E06014AC0200F06F', 1, 1, 1, 1, 1, 1, 1, '0CEA188286533464E06014AC0200F06F', '0C67748B17CE2EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (270, '104E017C266C84D5E06014AC02007FC1', 0, 1, 0, 0, 1, 1, 1, '0CEA188286533464E06014AC0200F06F', '0C67748B17CF2EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (196, '0CEA1882865D3464E06014AC0200F06F', 0, 1, 1, 0, 1, 1, NULL, '0CEA188286533464E06014AC0200F06F', '0C67748B17D02EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (197, '0CEA1882865E3464E06014AC0200F06F', 1, 1, 1, 1, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C67748B17D12EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (198, '0CEA1882865F3464E06014AC0200F06F', 0, 1, 0, 0, 1, 1, 1, '0CEA188286533464E06014AC0200F06F', '0C67748B17D22EC8E06014AC0200B1DB')
    INTO UBS_TRAINING.IAM_HAS_ACCESS (ID, GUID, IS_CREATE, IS_READ, IS_UPDATE, IS_DELETE, IS_CUSTOM1, IS_CUSTOM2, IS_CUSTOM3, IAM_ACCESS_GUID, SIDEBAR_MENU_GUID)
    VALUES (215, '0D76BE30166A5C23E06014AC02003235', 0, 1, 0, 0, NULL, NULL, NULL, '0CEA188286533464E06014AC0200F06F', '0C4B5038B8CAF54BE06014AC0200A115')
SELECT 1 FROM DUAL;