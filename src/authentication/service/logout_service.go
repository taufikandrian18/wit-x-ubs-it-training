package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) LogoutToken(ctx context.Context, request jwt.RequestJWTToken) (err error) {

	q := query.New(s.connectionString)

	if err = q.ClearAuthTokenUserLogin(ctx, query.ClearAuthTokenUserLoginParams{
		TokenAuthName: request.AppName,
		DeviceID:      request.DeviceID,
		DeviceType:    request.DeviceType,
	}); err != nil {
		log.FromCtx(ctx).Error(err, "failed clear auth user login")
		err = errors.WithStack(err)

		return
	}

	return
}
