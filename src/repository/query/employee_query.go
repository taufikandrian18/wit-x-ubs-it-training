package query

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertEmployeeParams struct {
	Fullname          string         `json:"fullname"`
	Email             string         `json:"email"`
	PhoneNumber       sql.NullString `json:"phone_number"`
	DateOfBirth       sql.NullString `json:"date_of_birth"`
	HireDate          sql.NullString `json:"hire_date"`
	IDCard            sql.NullString `json:"id_card"`
	Gender            string         `json:"gender"`
	ProfilePictureUrl sql.NullString `json:"profile_picture_url"`
	PICId             sql.NullInt64  `json:"pic_id"`
	RoleId            sql.NullString `json:"role_id"`
	StatusUser        string         `json:"status_user"`
	CreatedBy         string         `json:"created_by"`
}

func (q *Queries) InsertEmployee(ctx context.Context, arg InsertEmployeeParams) (response json.RawMessage, err error) {
	var resultString string
	var DBErr DBError

	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.insert_employee(
				:2, :3, :4, TO_DATE(:5, 'YYYY-MM-DD'), TO_DATE(:6, 'YYYY-MM-DD'), :7, :8, :9, :10, :11, :12, :13
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Fullname,
		arg.Email,
		arg.PhoneNumber,
		arg.DateOfBirth,
		arg.HireDate,
		arg.IDCard,
		arg.Gender,
		arg.ProfilePictureUrl,
		sql.NullInt64{Int64: arg.PICId.Int64, Valid: arg.PICId.Valid},
		sql.NullString{String: arg.RoleId.String, Valid: arg.RoleId.Valid},
		arg.StatusUser,
		arg.CreatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	isError, err := DBErr.Unmarshal([]byte(resultString))
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed unmarshal error")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	if isError {
		log.FromCtx(ctx).Error(fmt.Errorf(DBErr.Error.Message), "failed insert employee")
		if DBErr.Error.Code == "-1" {
			err = errors.WithStack(httpservice.ErrEmployeeUnique)
		} else {
			err = errors.WithStack(httpservice.ErrInternalServerError)
		}
		return
	}

	response = json.RawMessage(resultString)

	return
}

type UpdateEmployeeParams struct {
	Guid              string         `json:"guid"`
	Fullname          string         `json:"fullname"`
	Email             string         `json:"email"`
	PhoneNumber       sql.NullString `json:"phone_number"`
	DateOfBirth       sql.NullString `json:"date_of_birth"`
	HireDate          sql.NullString `json:"hire_date"`
	IDCard            sql.NullString `json:"id_card"`
	Gender            string         `json:"gender"`
	ProfilePictureUrl sql.NullString `json:"profile_picture_url"`
	PICId             sql.NullInt64  `json:"pic_id"`
	StatusUser        string         `json:"status_user"`
	UpdatedBy         string         `json:"updated_by"`
}

func (q *Queries) UpdateEmployee(ctx context.Context, arg UpdateEmployeeParams) (response json.RawMessage, err error) {
	var DBErr DBError
	var resultString string
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.update_employee(
				:2, :3, :4, :5, TO_DATE(:6, 'YYYY-MM-DD'), TO_DATE(:7, 'YYYY-MM-DD'), :8, :9, :10, :11, :12, :13
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Guid,
		arg.Fullname,
		arg.Email,
		arg.PhoneNumber,
		arg.DateOfBirth,
		arg.HireDate,
		arg.IDCard,
		arg.Gender,
		arg.ProfilePictureUrl,
		sql.NullInt64{Int64: arg.PICId.Int64, Valid: arg.PICId.Valid},
		arg.StatusUser,
		arg.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	isError, err := DBErr.Unmarshal([]byte(resultString))
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed unmarshal error")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	if isError {
		log.FromCtx(ctx).Error(fmt.Errorf(DBErr.Error.Message), "failed insert employee")
		if DBErr.Error.Code == "-1" {
			err = errors.WithStack(httpservice.ErrEmployeeUnique)
		} else {
			err = errors.WithStack(httpservice.ErrInternalServerError)
		}
		return
	}

	response = json.RawMessage(resultString)

	return
}

type GetEmployeeUsernameParams struct {
	Username string `json:"username"`
}

func (q *Queries) GetEmployeeByUsername(ctx context.Context, arg GetEmployeeUsernameParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_employee_username(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Username,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee by username")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type GetEmployeeParams struct {
	Guid string `json:"guid"`
}

func (q *Queries) GetEmployee(ctx context.Context, arg GetEmployeeParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_employee(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type DeleteEmployeeParams struct {
	Guid      string `json:"guid"`
	DeletedBy string `json:"deleted_by"`
}

func (q *Queries) DeleteEmployee(ctx context.Context, arg DeleteEmployeeParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.delete_employee(
				:1,
				:2
			);
		END;
	`,
		arg.Guid,
		arg.DeletedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed delete employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type ListEmployeeParams struct {
	SetGuid        int32          `json:"set_guid"`
	Guid           string         `json:"guid"`
	SetFullname    int32          `json:"set_fullname"`
	Fullname       string         `json:"fullname"`
	SetEmail       int32          `json:"set_email"`
	Email          string         `json:"email"`
	SetPhoneNumber int32          `json:"set_phone_number"`
	PhoneNumber    sql.NullString `json:"phone_number"`
	SetDateOfBirth int32          `json:"set_date_of_birth"`
	DateOfBirth    sql.NullString `json:"date_of_birth"`
	SetHireDate    int32          `json:"set_hire_date"`
	HireDate       sql.NullString `json:"hire_date"`
	SetIDCard      int32          `json:"set_id_card"`
	IDCard         sql.NullString `json:"id_card"`
	SetGender      int32          `json:"set_gender"`
	Gender         string         `json:"gender"`
	SetPICId       int32          `json:"set_pic_id"`
	PICId          sql.NullInt64  `json:"pic_id"`
	SetRoleId      int32          `json:"set_role_id"`
	RoleId         sql.NullString `json:"role_id"`
	SetStatusUser  int32          `json:"set_status_user"`
	StatusUser     string         `json:"status_user"`
	SetCreatedBy   int32          `json:"set_created_by"`
	CreatedBy      string         `json:"created_by"`
	LimitData      int32          `json:"limit_data"`
	OffsetPages    int32          `json:"offset_pages"`
	OrderParam     string         `json:"order_param"`
}

func (q *Queries) ListEmployee(ctx context.Context, arg ListEmployeeParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString, tempString string
	// Execute the PL/SQL block
	rows, err := db.Query(`
	SELECT * FROM
    TABLE(UBS_TRAINING.list_employee(
		:1,
		:2,
		:3,
		:4,
		:5,
		:6,
		:7,
		:8,
		:9,
		TO_DATE(:10, 'YYYY-MM-DD'),
		:11,
		TO_DATE(:12, 'YYYY-MM-DD'),
		:13,
		:14,
		:15,
		:16,
		:17,
		:18,
		:19,
		:20,
		:21,
		:22,
		:23,
		:24,
		:25,
		:26,
		:27
			))
	`,
		arg.SetGuid,
		arg.Guid,
		arg.SetFullname,
		arg.Fullname,
		arg.SetEmail,
		arg.Email,
		arg.SetPhoneNumber,
		arg.PhoneNumber,
		arg.SetDateOfBirth,
		arg.DateOfBirth,
		arg.SetHireDate,
		arg.HireDate,
		arg.SetIDCard,
		arg.IDCard,
		arg.SetGender,
		arg.Gender,
		arg.SetPICId,
		sql.NullInt64{Int64: arg.PICId.Int64, Valid: arg.PICId.Valid},
		arg.SetRoleId,
		sql.NullString{String: arg.RoleId.String, Valid: arg.RoleId.Valid},
		arg.SetStatusUser,
		arg.StatusUser,
		arg.SetCreatedBy,
		arg.CreatedBy,
		arg.LimitData,
		arg.OffsetPages,
		arg.OrderParam,
	)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed list employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	for rows.Next() {
		rows.Scan(&tempString)
		if err != nil {
			log.FromCtx(ctx).Error(err, "failed list PROJECT BOARD")
			err = errors.WithStack(httpservice.ErrInternalServerError)
			return
		}
		resultString += tempString
	}

	response = json.RawMessage(resultString)

	return
}

type UpdateEmployeeProfilePhotoParams struct {
	Guid string `json:"guid"`
	Url  string `json:"url"`
}

func (q *Queries) UpdateEmployeeProfilePhoto(ctx context.Context, arg UpdateEmployeeProfilePhotoParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.UPDATE_PROFILE_PHOTO_EMP(
				:1,
				:2
			);
		END;
	`,
		arg.Guid,
		arg.Url,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update profile photo employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_employee(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type GetEmployeeUsernameIsActiveParams struct {
	Username string `json:"username"`
}

func (q *Queries) GetEmployeeIsActiveByUsername(ctx context.Context, arg GetEmployeeUsernameIsActiveParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_employee_is_active(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.Username,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee is active by username")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}
