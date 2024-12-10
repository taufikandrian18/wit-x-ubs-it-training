package payload

import (
	"context"
	"database/sql"

	"gitlab.com/wit-id/test/common/utility"
)

type tokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

type TokenInfo struct {
	Token           sql.NullString `json:"token"`
	BlacklistedType sql.NullString `json:"blacklisted_type"`
	CreatedAt       string         `json:"created_at"`
}

type LoginPayload struct {
	Username string `json:"username" valid:"required"`
	Password string `json:"password" valid:"required"`
}

func (payload *LoginPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

type LogoutPayload struct {
	AccessToken  string `json:"access_token" valid:"required"`
	RefreshToken string `json:"refresh_token" valid:"required"`
}

func (payload *LogoutPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

type ChangePassword struct {
	Password             string `json:"password" valid:"required"`
	PasswordConfirmation string `json:"password_confirmation" valid:"required"`
	OldPassword          string `json:"old_password" valid:"required"`
}

func (payload *ChangePassword) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

type ReplacePassword struct {
	Password string `json:"password" valid:"required"`
}

func (payload *ReplacePassword) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

type ForgotPasswordRequestPayload struct {
	Username string `json:"username" valid:"required"`
}

type readForgotPasswordRequest struct {
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

type SSOResponseBody struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func ToPayloadForgotPasswordRequest(responseSubject string, responseBody string) (payload readForgotPasswordRequest) {
	payload = readForgotPasswordRequest{
		Subject: responseSubject,
		Body:    responseBody,
	}

	return
}

func (payload *ForgotPasswordRequestPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}

type ForgotPasswordSubmitPayload struct {
	Password             string `json:"password" valid:"required"`
	PasswordConfirmation string `json:"password_confirmation" valid:"required"`
}

func (payload *ForgotPasswordSubmitPayload) Validate(ctx context.Context) (err error) {
	if err = utility.ValidateStruct(ctx, payload); err != nil {
		return
	}
	return
}
