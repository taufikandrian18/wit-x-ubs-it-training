package payload

import (
	"github.com/asaskevich/govalidator"
	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
)

type HrisPic struct {
	Guid           string `json:"guid"`
	Fullname       string `json:"fullname"`
	Email          string `json:"email"`
	PhoneNumber    string `json:"phone_number"`
	DateOfBirth    string `json:"date_of_birth"`
	HireDate       string `json:"hire_date"`
	IDCard         string `json:"id_card"`
	Gender         string `json:"gender"`
	ProfilePicture string `json:"profile_picture_url"`
	PicID          int    `json:"pic_id"`
	StatusUser     string `json:"status_user"`
	CreatedAt      string `json:"created_at"`
	CreatedBy      string `json:"created_by"`
	UpdatedAt      string `json:"updated_at"`
	UpdatedBy      string `json:"updated_by"`
	LastSyncHris   string `json:"last_sync_hris"`
	DeletedBy      string `json:"deleted_by"`
	DeletedAt      string `json:"deleted_at"`
	// Add other pic fields here
}

type HrisEmployeeData struct {
	EmployeeID     int      `json:"employee_id"`
	Guid           string   `json:"guid"`
	Fullname       string   `json:"fullname"`
	Email          string   `json:"email"`
	PhoneNumber    string   `json:"phone_number"`
	DateOfBirth    string   `json:"date_of_birth"`
	HireDate       string   `json:"hire_date"`
	IDCard         string   `json:"id_card"`
	Gender         string   `json:"gender"`
	ProfilePicture string   `json:"profile_picture_url"`
	Pic            *HrisPic `json:"pic"`
	StatusUser     string   `json:"status_user"`
	CreatedBy      string   `json:"created_by"`
	CreatedAt      string   `json:"created_at"`
	UpdatedBy      string   `json:"updated_by"`
	UpdatedAt      string   `json:"updated_at"`
	DeletedBy      string   `json:"deleted_by"`
	DeletedAt      string   `json:"deleted_at"`
	LastSyncHris   string   `json:"last_sync_hris"`
	// Add other employee_data fields here
}

type Authentication struct {
	AuthenticationID     int              `json:"authentication_id"`
	Guid                 string           `json:"guid"`
	EmployeeID           string           `json:"employee_id"`
	AuthUsername         string           `json:"auth_username"`
	AuthPassword         string           `json:"auth_password"`
	Salt                 string           `json:"salt"`
	ForgotPasswordToken  string           `json:"forgot_password_token"`
	ForgotPasswordExpiry string           `json:"forgot_password_expiry"`
	LastLogin            string           `json:"last_login"`
	IsActive             int              `json:"is_active"`
	EmployeeData         HrisEmployeeData `json:"employee_data"`
	Status               string           `json:"status"`
	CreatedBy            string           `json:"created_by"`
	CreatedAt            string           `json:"created_at"`
	UpdatedBy            string           `json:"updated_by"`
	UpdatedAt            string           `json:"updated_at"`
	DeletedBy            string           `json:"deleted_by"`
	DeletedAt            string           `json:"deleted_at"`
}

// AuthTokenPayload ...
type AuthTokenPayload struct {
	AppName    string `json:"app_name" valid:"required"`
	AppKey     string `json:"app_key" valid:"required"`
	DeviceID   string `json:"device_id" valid:"required"`
	DeviceType string `json:"device_type" valid:"required"`
	IPAddress  string `json:"ip_address" valid:"required"`
}

type ResponseAuthToken struct {
	TokenAuthID         int    `json:"token_auth_id"`
	TokenAuthName       string `json:"token_auth_name"`
	DeviceID            string `json:"device_id"`
	DeviceType          string `json:"device_type"`
	Token               string `json:"token"`
	TokenExpired        string `json:"token_expired"`
	RefreshToken        string `json:"refresh_token"`
	RefreshTokenExpired string `json:"refresh_token_expired"`
	IsLogin             int    `json:"is_login"`
	UserLogin           string `json:"user_login"`
	FCMToken            string `json:"fcm_token"`
	IPAddress           string `json:"ip_address"`
	CreatedBy           string `json:"created_by"`
	CreatedAt           string `json:"created_at"`
}

type Employee struct {
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
	DepartementGUID   string `json:"departement_guid"`
	PositionGUID      string `json:"position_guid"`
	StatusUser        string `json:"status_user"`
	CreatedBy         string `json:"created_by"`
	CreatedAt         string `json:"created_at"`
	UpdatedBy         string `json:"updated_by"`
	UpdatedAt         string `json:"updated_at"`
	DeletedBy         string `json:"deleted_by"`
	DeletedAt         string `json:"deleted_at"`
}

// Authentication represents the top-level structure of the JSON.
type ResponseAuthenticationData struct {
	AuthenticationID     int      `json:"authentication_id"`
	GUID                 string   `json:"guid"`
	EmployeeID           string   `json:"employee_id"`
	AuthUsername         string   `json:"auth_username"`
	AuthPassword         string   `json:"auth_password"`
	Salt                 string   `json:"salt"`
	ForgotPasswordToken  string   `json:"forgot_password_token"`
	ForgotPasswordExpiry string   `json:"forgot_password_expiry"`
	LastLogin            string   `json:"last_login"`
	IsActive             int      `json:"is_active"`
	EmployeeData         Employee `json:"employee_data"`
	Status               string   `json:"status"`
	CreatedBy            string   `json:"created_by"`
	CreatedAt            string   `json:"created_at"`
	UpdatedBy            string   `json:"updated_by"`
	UpdatedAt            string   `json:"updated_at"`
	DeletedBy            string   `json:"deleted_by"`
	DeletedAt            string   `json:"deleted_at"`
}

func (payload *AuthTokenPayload) Validate() (err error) {
	// Validate Payload
	if _, err = govalidator.ValidateStruct(payload); err != nil {
		err = errors.Wrapf(httpservice.ErrBadRequest, "bad request: %s", err.Error())
		return
	}

	return
}
