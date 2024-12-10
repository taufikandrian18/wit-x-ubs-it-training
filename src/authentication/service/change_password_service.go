package service

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) ChangeEmployeePassword(ctx context.Context,
	username string, params payload.ChangePassword) (
	err error) {

	q := query.New(s.connectionString)
	u, err := q.GetAuthenticationByUsername(ctx, username)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get User")
		err = errors.WithStack(httpservice.ErrDataNotFound)
		return
	}

	// Unmarshal JSON data into struct
	var apiResponseAuthentication payload.ResponseAuthenticationData
	err = json.Unmarshal(u, &apiResponseAuthentication)
	if err != nil {
		log.FromCtx(ctx).Error(err, "error while unmarshall data")
		err = errors.WithStack(httpservice.ErrPasswordNotMatch)
		return
	}

	oldHashedPassword := utility.HashPassword(params.OldPassword, apiResponseAuthentication.Salt)
	if oldHashedPassword != apiResponseAuthentication.AuthPassword {
		log.FromCtx(ctx).Error(err, "old password do not match")
		err = errors.WithStack(httpservice.ErrPasswordNotMatch)
		return
	}

	if params.Password != params.PasswordConfirmation {
		log.FromCtx(ctx).Error(err, "new password do not match")
		err = errors.WithStack(httpservice.ErrPasswordNotMatch)
		return
	}

	newHashedPassword := utility.HashPassword(params.Password, apiResponseAuthentication.Salt)

	err = q.UpdateAuthenticationPassword(ctx, query.UpdateAuthenticationPasswordParams{
		Password:  newHashedPassword,
		UpdatedBy: sql.NullString{String: apiResponseAuthentication.EmployeeID, Valid: true},
		Guid:      apiResponseAuthentication.GUID,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed to update password")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *AuthenticationService) ForgotPasswordRequest(ctx context.Context, username string) (responseSubject string, responseBody string, err error) {
	q := query.New(s.connectionString)

	u, err := q.GetAuthenticationByUsername(ctx, username)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get User")
		err = errors.WithStack(httpservice.ErrDataNotFound)
		return
	}

	// Unmarshal JSON data into struct
	var apiResponseAuthentication payload.ResponseAuthenticationData
	err = json.Unmarshal(u, &apiResponseAuthentication)
	if err != nil {
		log.FromCtx(ctx).Error(err, "error while unmarshall data")
		err = errors.WithStack(httpservice.ErrPasswordNotMatch)
		return
	}

	if apiResponseAuthentication.GUID == "" {
		log.FromCtx(ctx).Error(err, "user not found")
		err = errors.WithStack(httpservice.ErrUserNotFound)
		return
	}

	tokenBytes := make([]byte, 32)
	_, err = rand.Read(tokenBytes)
	if err != nil {
		log.FromCtx(ctx).Error(err, "user not found")
		err = errors.WithStack(httpservice.ErrUserNotFound)
		return
	}
	token := base64.URLEncoding.EncodeToString(tokenBytes)

	err = q.UpdateAuthenticationForgotPassword(ctx, query.UpdateAuthenticationForgotPasswordParams{
		Guid:                 apiResponseAuthentication.GUID,
		ForgotPasswordToken:  sql.NullString{Valid: true, String: token},
		ForgotPasswordExpiry: sql.NullTime{Valid: true, Time: time.Now().Add(15 * time.Minute)},
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed to update forgot token")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	resetLink := fmt.Sprint("http://staging-ubs-project-management.wit.id/auth-pages/forgot-password/", token)
	subject := "UBS Forgot Password"
	plainTextContent := fmt.Sprintf("Hello,\n\nYou have requested to reset your password. Please click on the link below to reset your password:\n\n%s\n\nIf you didn't initiate this request, you can safely ignore this email.\n\nThanks,\nThe UBS Team", resetLink)

	responseSubject = subject
	responseBody = plainTextContent

	return
}

func (s *AuthenticationService) ForgotPasswordChange(ctx context.Context, token, password string) (err error) {
	q := query.New(s.connectionString)

	u, _ := q.GetAuthenticationByForgotPasswordToken(ctx, sql.NullString{Valid: true, String: token})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get User")
		err = errors.WithStack(httpservice.ErrDataNotFound)
		return
	}

	// Unmarshal JSON data into struct
	var apiResponseAuthentication payload.ResponseAuthenticationData
	err = json.Unmarshal(u, &apiResponseAuthentication)
	if err != nil {
		log.FromCtx(ctx).Error(err, "error while unmarshall data")
		err = errors.WithStack(httpservice.ErrPasswordNotMatch)
		return
	}

	if apiResponseAuthentication.GUID == "" {
		log.FromCtx(ctx).Error(err, "user not found")
		err = errors.WithStack(httpservice.ErrUserNotFound)
		return
	}

	layout := "02-Jan-06 03.04.05.999999999 PM"

	// Parse the date string
	forgotPasswordExpiry, err := time.Parse(layout, apiResponseAuthentication.ForgotPasswordExpiry)
	if err != nil {
		fmt.Println("Error parsing date:", err)
		return
	}

	if time.Now().After(forgotPasswordExpiry) {
		log.FromCtx(ctx).Error(err, "expired token")
		err = errors.WithStack(httpservice.ErrVoucherIsExpired)
		return
	}

	encryptedPassword := utility.HashPassword(password, apiResponseAuthentication.Salt)
	err = q.UpdateAuthenticationPassword(ctx, query.UpdateAuthenticationPasswordParams{
		Password:  encryptedPassword,
		UpdatedBy: sql.NullString{String: apiResponseAuthentication.EmployeeID, Valid: true},
		Guid:      apiResponseAuthentication.GUID,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed to update password")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
