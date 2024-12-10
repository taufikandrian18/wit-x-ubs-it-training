package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) UpdateAuthenticationUsernameByEmployeeID(ctx context.Context, request query.UpdateAuthenticationUsernameByEmployeeIDParams) (err error) {
	q := query.New(s.connectionString)
	err = q.UpdateAuthenticationUsernameByEmployeeID(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update Employee")
		err = errors.WithStack(utility.ParseError(err))
		return
	}

	return
}
