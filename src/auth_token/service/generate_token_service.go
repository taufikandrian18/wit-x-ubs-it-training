package service

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthTokenService) AuthToken(ctx context.Context, request payload.AuthTokenPayload) (authToken json.RawMessage, err error) {
	q := query.New(s.connectionString)

	// validate app key
	if err = s.validateAppKey(ctx, q, payload.ValidateAppKeyPayload{
		AppName: request.AppName,
		AppKey:  request.AppKey,
	}); err != nil {
		return
	}

	// generate jwt token
	jwtResponse, err := jwt.CreateJWTToken(ctx, s.cfg, jwt.RequestJWTToken{
		AppName:    request.AppName,
		DeviceID:   request.DeviceID,
		DeviceType: request.DeviceType,
		IPAddress:  request.IPAddress,
	})
	if err != nil {
		return
	}

	authToken, err = s.recordToken(ctx, q, jwtResponse, false)
	if err != nil {
		return
	}

	return
}

func (s *AuthTokenService) RefreshToken(ctx context.Context, request jwt.RequestJWTToken) (authToken json.RawMessage, err error) {
	q := query.New(s.connectionString)

	jwtResponse, err := jwt.CreateJWTToken(ctx, s.cfg, request)
	if err != nil {
		return
	}

	authToken, err = s.recordToken(ctx, q, jwtResponse, true)
	if err != nil {
		return
	}

	return
}

func (s *AuthTokenService) validateAppKey(ctx context.Context, q *query.Queries, request payload.ValidateAppKeyPayload) (err error) {

	appKeyData := query.AppKey{
		ID:   1,
		Name: "wit-dev",
		Key:  "w1t-d3V",
	}

	if request.AppKey != appKeyData.Key {
		log.FromCtx(ctx).Info("app key is not match")

		err = errors.WithStack(httpservice.ErrInvalidAppKey)

		return
	}

	return
}

func (s *AuthTokenService) recordToken(ctx context.Context, q *query.Queries, token jwt.ResponseJwtToken, isRefreshToken bool) (authToken json.RawMessage, err error) {
	if !isRefreshToken {
		authToken, err = q.InsertAuthToken(ctx, query.InsertAuthTokenParams{
			TokenAuthName:       token.AppName,
			DeviceID:            token.DeviceID,
			DeviceType:          token.DeviceType,
			Token:               token.Token,
			TokenExpired:        token.TokenExpired.Format("02-Jan-06 03.04.05.999999 PM"),
			IPAddress:           token.IPAddress,
			RefreshToken:        token.RefreshToken,
			IsLogin:             0,
			RefreshTokenExpired: token.RefreshTokenExpired.Format("02-Jan-06 03.04.05.999999 PM"),
			CreatedBy:           constants.CreatedByTemporaryBySystem,
		})
	} else {
		// Get record
		authData, errGetRecord := s.ReadAuthToken(ctx, query.GetAuthTokenParams{
			TokenAuthName: token.AppName,
			DeviceID:      token.DeviceID,
			DeviceType:    token.DeviceType,
		})
		if errGetRecord != nil {
			err = errGetRecord
			return
		}

		// Unmarshal JSON data into struct
		var apiResponse payload.ResponseAuthToken
		err = json.Unmarshal(authData, &apiResponse)
		if err != nil {
			log.FromCtx(ctx).Error(err, "failed unmarshall api response")
			err = errors.WithStack(httpservice.ErrInternalServerError)

			return
		}

		// var isLogin int64
		// if authData.IsLogin {
		// 	isLogin = 1
		// } else {
		// 	isLogin = 0
		// }

		authToken, err = q.InsertAuthToken(ctx, query.InsertAuthTokenParams{
			TokenAuthName:       apiResponse.TokenAuthName,
			DeviceID:            apiResponse.DeviceID,
			DeviceType:          apiResponse.DeviceType,
			Token:               token.Token,
			TokenExpired:        token.TokenExpired.Format("02-Jan-06 03.04.05.999999 PM"),
			IPAddress:           token.IPAddress,
			RefreshToken:        token.RefreshToken,
			RefreshTokenExpired: token.RefreshTokenExpired.Format("02-Jan-06 03.04.05.999999 PM"),
			IsLogin:             int64(apiResponse.IsLogin),
			UserLogin: sql.NullString{
				String: apiResponse.UserLogin,
				Valid:  true,
			},
			CreatedBy: constants.CreatedByTemporaryBySystem,
		})
	}

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed record token")
		err = errors.WithStack(httpservice.ErrInternalServerError)

		return
	}

	return
}
