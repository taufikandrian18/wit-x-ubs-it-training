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
);

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
                profile_picture_url, pic_id, status_user, created_by,
                updated_by, deleted_by
            )
            VALUES (
                p_fullname, p_email,
                p_phone_number, p_date_of_birth, p_hire_date, p_id_card, p_gender,
                p_profile_picture_url, p_pic_id, p_status_user, p_created_by,
                p_updated_by, p_deleted_by
            )
            RETURNING employee_id, guid, fullname, email, phone_number, date_of_birth, hire_date, id_card, gender, profile_picture_url, pic_id, status_user, created_by, created_at, updated_by, updated_at, deleted_by, deleted_at 
            INTO l_employee_id, l_guid, l_fullname, l_email, l_phone_number, l_date_of_birth, l_hire_date, l_id_card, l_gender, l_profile_picture, l_pic_id, l_status_user, l_created_by, l_created_at, l_updated_by, l_updated_at, l_deleted_by, l_deleted_at;
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

CREATE OR REPLACE PROCEDURE UBS_TRAINING."DELETE_EMPLOYEE" (
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
        '","pic_id":' || NVL(pic_id, 0) || '","status_user":"' || status_user ||
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