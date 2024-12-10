package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) Login(ctx context.Context, request payload.LoginPayload, jwtRequest jwt.RequestJWTToken, email string) (
	u json.RawMessage, err error) {
	q := query.New(s.connectionString)

	u, err = q.GetAuthenticationByUsername(ctx, request.Username)
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
		emp, errEmp := q.GetEmployeeByUsername(ctx, query.GetEmployeeUsernameParams{
			Username: email,
		})
		if errEmp != nil {
			log.FromCtx(ctx).Error(err, "failed get User")
			err = errors.WithStack(httpservice.ErrDataNotFound)
			return
		}

		// Unmarshal JSON data into struct
		var apiResponseEmployee payload.EmployeeJson
		err = json.Unmarshal(emp, &apiResponseEmployee)
		if err != nil {
			log.FromCtx(ctx).Error(err, "error while unmarshall data")
			err = errors.WithStack(httpservice.ErrPasswordNotMatch)
			return
		}

		err = s.RegisterEmployee(ctx, apiResponseEmployee, request.Password)
		if err != nil {
			log.FromCtx(ctx).Error(err, "failed insert authentication")
			err = errors.WithStack(httpservice.ErrDataNotFound)
			return
		}

		uRegister, errRegister := q.GetAuthenticationByUsername(ctx, request.Username)
		if errRegister != nil {
			log.FromCtx(ctx).Error(err, "failed register authentication")
			err = errors.WithStack(httpservice.ErrDataNotFound)
			return
		}

		// Unmarshal JSON data into struct
		var apiResponseAuthenticationRegister payload.ResponseAuthenticationData
		err = json.Unmarshal(uRegister, &apiResponseAuthenticationRegister)
		if err != nil {
			log.FromCtx(ctx).Error(err, "error while unmarshall data")
			err = errors.WithStack(httpservice.ErrPasswordNotMatch)
			return
		}

		hashedPassword := utility.HashPassword(request.Password, apiResponseAuthenticationRegister.Salt)
		if hashedPassword != apiResponseAuthenticationRegister.AuthPassword {
			log.FromCtx(ctx).Error(err, "password do not match")
			err = errors.WithStack(httpservice.ErrPasswordNotMatch)
			return
		}

		// Update Last login user backoffice
		if err = q.RecordAuthenticationLastLogin(ctx, apiResponseAuthenticationRegister.GUID); err != nil {
			log.FromCtx(ctx).Error(err, "failed record last login")
			err = errors.WithStack(httpservice.ErrUnknownSource)

			return
		}

		// Update token auth record
		if err = q.RecordAuthTokenUserLogin(ctx, query.RecordAuthTokenUserLoginParams{
			UserLogin:     apiResponseAuthenticationRegister.GUID,
			TokenAuthName: jwtRequest.AppName,
			DeviceID:      jwtRequest.DeviceID,
			DeviceType:    jwtRequest.DeviceType,
		}); err != nil {
			log.FromCtx(ctx).Error(err, "failed update token auth login user")
			err = errors.WithStack(httpservice.ErrUnknownSource)

			return
		}

		u, err = q.GetAuthenticationByUsername(ctx, request.Username)
		if err != nil {
			log.FromCtx(ctx).Error(err, "failed get User")
			err = errors.WithStack(httpservice.ErrDataNotFound)
			return
		}

	} else {
		hashedPassword := utility.HashPassword(request.Password, apiResponseAuthentication.Salt)
		if hashedPassword != apiResponseAuthentication.AuthPassword {
			log.FromCtx(ctx).Error(err, "password do not match")
			err = errors.WithStack(httpservice.ErrPasswordNotMatch)
			return
		}

		// Update Last login user backoffice
		if err = q.RecordAuthenticationLastLogin(ctx, apiResponseAuthentication.GUID); err != nil {
			log.FromCtx(ctx).Error(err, "failed record last login")
			err = errors.WithStack(httpservice.ErrUnknownSource)

			return
		}

		// Update token auth record
		if err = q.RecordAuthTokenUserLogin(ctx, query.RecordAuthTokenUserLoginParams{
			UserLogin:     apiResponseAuthentication.GUID,
			TokenAuthName: jwtRequest.AppName,
			DeviceID:      jwtRequest.DeviceID,
			DeviceType:    jwtRequest.DeviceType,
		}); err != nil {
			log.FromCtx(ctx).Error(err, "failed update token auth login user")
			err = errors.WithStack(httpservice.ErrUnknownSource)

			return
		}
	}

	return
}
