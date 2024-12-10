package payload

import (
	"context"
	"database/sql"
	"strings"

	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
)

type EmployeeJson struct {
	EmployeeID        int    `json:"employee_id"`
	GUID              string `json:"guid"`
	Fullname          string `json:"fullname"`
	Email             string `json:"email"`
	PhoneNumber       string `json:"phone_number"`
	DateOfBirth       string `json:"date_of_birth"`
	HireDate          string `json:"hire_date"`
	IDCard            string `json:"id_card"`
	Gender            string `json:"gender"`
	ProfilePictureURL string `json:"profile_picture_url"`
	PicID             int    `json:"pic_id"`
	StatusUser        string `json:"status_user"`
	LastSyncUser      string `json:"last_sync_hris"`
	CreatedBy         string `json:"created_by"`
	CreatedAt         string `json:"created_at"`
	UpdatedBy         string `json:"updated_by"`
	UpdatedAt         string `json:"updated_at"`
	DeletedBy         string `json:"deleted_by"`
	DeletedAt         string `json:"deleted_at"`
}

type InsertEmployeePayload struct {
	Fullname          string  `json:"name" valid:"required"`
	Email             string  `json:"email" valid:"required"`
	PhoneNumber       string  `json:"phone_number" valid:"required"`
	DateOfBirth       string  `json:"date_of_birth" valid:"required"`
	HireDate          string  `json:"hire_date" valid:"required"`
	IDCard            string  `json:"id_card" valid:"required"`
	Gender            string  `json:"gender" valid:"required"`
	ProfilePictureUrl string  `json:"profile_picture_url"`
	PICId             *int64  `json:"pic_id"`
	RoleId            *string `json:"role_id"`
}

type UpdateEmployeePayload struct {
	Fullname          string `json:"name" valid:"required"`
	Email             string `json:"email" valid:"required"`
	PhoneNumber       string `json:"phone_number" valid:"required"`
	DateOfBirth       string `json:"date_of_birth" valid:"required"`
	HireDate          string `json:"hire_date" valid:"required"`
	IDCard            string `json:"id_card" valid:"required"`
	Gender            string `json:"gender" valid:"required"`
	ProfilePictureUrl string `json:"path_url"`
	PICId             *int64 `json:"pic_id"`
}

type UpdateProfilePayload struct {
	PathUrl string `json:"path_url"`
}

type ListFilterEmployeePayload struct {
	SetGuid        bool     `json:"set_guid"`
	Guid           string   `json:"guid"`
	SetFullname    bool     `json:"set_fullname"`
	Fullname       string   `json:"fullname"`
	SetEmail       bool     `json:"set_email"`
	Email          string   `json:"email"`
	SetPhoneNumber bool     `json:"set_phone_number"`
	PhoneNumber    string   `json:"phone_number"`
	SetDateOfBirth bool     `json:"set_date_of_birth"`
	DateOfBirth    *string  `json:"date_of_birth"`
	SetHireDate    bool     `json:"set_hire_date"`
	HireDate       *string  `json:"hire_date"`
	SetIDCard      bool     `json:"set_id_card"`
	IDCard         string   `json:"id_card"`
	SetGender      bool     `json:"set_gender"`
	Gender         string   `json:"gender"`
	SetPICId       bool     `json:"set_pic_id"`
	PICId          *int64   `json:"pic_id"`
	SetRoleId      bool     `json:"set_role_id"`
	RoleId         string   `json:"role_id"`
	SetStatusUser  bool     `json:"set_status_user"`
	StatusUser     []string `json:"status_user"`
	SetCreatedBy   bool     `json:"set_created_by"`
	CreatedBy      string   `json:"created_by"`
}

type ListEmployeePayload struct {
	Filter ListFilterEmployeePayload `json:"filter"`
	Limit  int32                     `json:"limit" valid:"required~limit is required field"`
	Page   int32                     `json:"page" valid:"required~page is required field"`
	Order  string                    `json:"order" valid:"required~order is required field"`
	Sort   string                    `json:"sort" valid:"required~sort is required field"` // ASC, DESC
}

func (payload *InsertEmployeePayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *UpdateEmployeePayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *ListEmployeePayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}

	return
}

func (payload *InsertEmployeePayload) ToEntity() (data query.InsertEmployeeParams) {

	// Format dateOfBirth in 'YYYY-MM-DD' format
	formattedDateOfBirth := utility.ParseStringToTime(payload.DateOfBirth, constants.TimeDateFormat).Format("2006-01-02")
	formattedHireDate := utility.ParseStringToTime(payload.HireDate, constants.TimeDateFormat).Format("2006-01-02")

	data = query.InsertEmployeeParams{
		Fullname:   payload.Fullname,
		Email:      payload.Email,
		Gender:     payload.Gender,
		StatusUser: constants.StatusActive,
		CreatedBy:  constants.CreatedByTemporaryBySystem,
	}

	if payload.PhoneNumber != "" {
		data.PhoneNumber = sql.NullString{
			String: payload.PhoneNumber,
			Valid:  true,
		}
	}

	if payload.DateOfBirth != "" {
		data.DateOfBirth = sql.NullString{
			String: formattedDateOfBirth,
			Valid:  true,
		}
	}

	if payload.HireDate != "" {
		data.HireDate = sql.NullString{
			String: formattedHireDate,
			Valid:  true,
		}
	}

	if payload.IDCard != "" {
		data.IDCard = sql.NullString{
			String: payload.IDCard,
			Valid:  true,
		}
	}

	if payload.ProfilePictureUrl != "" {
		data.ProfilePictureUrl = sql.NullString{
			String: payload.ProfilePictureUrl,
			Valid:  true,
		}
	}

	if payload.PICId != nil {
		data.PICId = sql.NullInt64{
			Int64: *payload.PICId,
			Valid: true,
		}
	}

	if payload.RoleId != nil {
		data.RoleId = sql.NullString{
			String: *payload.RoleId,
			Valid:  true,
		}
	}

	return
}

func (payload *UpdateEmployeePayload) ToEntity(key string) (data query.UpdateEmployeeParams) {

	// Format dateOfBirth in 'YYYY-MM-DD' format
	formattedDateOfBirth := utility.ParseStringToTime(payload.DateOfBirth, constants.TimeDateFormat).Format("2006-01-02")
	formattedHireDate := utility.ParseStringToTime(payload.HireDate, constants.TimeDateFormat).Format("2006-01-02")

	data = query.UpdateEmployeeParams{
		Guid:       key,
		Fullname:   payload.Fullname,
		Email:      payload.Email,
		Gender:     payload.Gender,
		StatusUser: constants.StatusActive,
		UpdatedBy:  constants.CreatedByTemporaryBySystem,
	}

	if payload.PhoneNumber != "" {
		data.PhoneNumber = sql.NullString{
			String: payload.PhoneNumber,
			Valid:  true,
		}
	}

	if payload.DateOfBirth != "" {
		data.DateOfBirth = sql.NullString{
			String: formattedDateOfBirth,
			Valid:  true,
		}
	}

	if payload.HireDate != "" {
		data.HireDate = sql.NullString{
			String: formattedHireDate,
			Valid:  true,
		}
	}

	if payload.IDCard != "" {
		data.IDCard = sql.NullString{
			String: payload.IDCard,
			Valid:  true,
		}
	}

	if payload.ProfilePictureUrl != "" {
		data.ProfilePictureUrl = sql.NullString{
			String: payload.ProfilePictureUrl,
			Valid:  true,
		}
	}

	if payload.PICId != nil {
		data.PICId = sql.NullInt64{
			Int64: *payload.PICId,
			Valid: true,
		}
	}

	return
}

func (payload *ListEmployeePayload) ToEntity() (data query.ListEmployeeParams) {

	// Format dateOfBirth in 'YYYY-MM-DD' format
	formattedDateOfBirth := utility.ParseStringToTime(*payload.Filter.DateOfBirth, constants.TimeDateFormat).Format("2006-01-02")
	formattedHireDate := utility.ParseStringToTime(*payload.Filter.HireDate, constants.TimeDateFormat).Format("2006-01-02")
	data = query.ListEmployeeParams{
		SetGuid:        translateBoolIntoNumber(payload.Filter.SetGuid),
		Guid:           payload.Filter.Guid,
		SetFullname:    translateBoolIntoNumber(payload.Filter.SetFullname),
		Fullname:       queryStringLike(payload.Filter.Fullname),
		SetEmail:       translateBoolIntoNumber(payload.Filter.SetEmail),
		Email:          queryStringLike(payload.Filter.Email),
		SetPhoneNumber: translateBoolIntoNumber(payload.Filter.SetPhoneNumber),
		SetDateOfBirth: translateBoolIntoNumber(payload.Filter.SetDateOfBirth),
		SetHireDate:    translateBoolIntoNumber(payload.Filter.SetHireDate),
		SetIDCard:      translateBoolIntoNumber(payload.Filter.SetIDCard),
		SetGender:      translateBoolIntoNumber(payload.Filter.SetGender),
		SetPICId:       translateBoolIntoNumber(payload.Filter.SetPICId),
		SetRoleId:      translateBoolIntoNumber(payload.Filter.SetRoleId),
		Gender:         payload.Filter.Gender,
		SetStatusUser:  translateBoolIntoNumber(payload.Filter.SetStatusUser),
		StatusUser:     strings.Join(payload.Filter.StatusUser, constants.DefaultDelimiterStringOracleValue),
		SetCreatedBy:   translateBoolIntoNumber(payload.Filter.SetCreatedBy),
		CreatedBy:      queryStringLike(payload.Filter.CreatedBy),
		OrderParam:     makeOrderParam(payload.Order, payload.Sort),
		OffsetPages:    payload.Page,
		LimitData:      limitWithDefault(payload.Limit),
	}

	if payload.Filter.PhoneNumber != "" {
		data.PhoneNumber = sql.NullString{
			String: queryStringLike(payload.Filter.PhoneNumber),
			Valid:  true,
		}
	}

	if *payload.Filter.DateOfBirth != "" {
		data.DateOfBirth = sql.NullString{
			String: formattedDateOfBirth,
			Valid:  true,
		}
	}

	if payload.Filter.HireDate != nil {
		data.HireDate = sql.NullString{
			String: formattedHireDate,
			Valid:  true,
		}
	}

	if payload.Filter.IDCard != "" {
		data.IDCard = sql.NullString{
			String: queryStringLike(payload.Filter.IDCard),
			Valid:  true,
		}
	}

	if payload.Filter.PICId != nil {
		data.PICId = sql.NullInt64{
			Int64: *payload.Filter.PICId,
			Valid: true,
		}
	}

	if payload.Filter.RoleId != "" {
		data.RoleId = sql.NullString{
			String: payload.Filter.RoleId,
			Valid:  true,
		}
	}

	return
}
