package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) GetProfileFromToken(ctx context.Context, guid string) (
	emp json.RawMessage, err error) {
	q := query.New(s.connectionString)

	emp, err = q.GetEmployee(ctx, query.GetEmployeeParams{
		Guid: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get Employee")
		err = errors.WithStack(httpservice.ErrDataNotFound)
		return
	}

	return
}

func (s *AuthenticationService) GetAuthenticationByUsername(ctx context.Context, username string) (
	emp json.RawMessage, err error) {
	q := query.New(s.connectionString)

	emp, err = q.GetAuthenticationByUsername(ctx, username)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get Employee")
		err = errors.WithStack(httpservice.ErrDataNotFound)
		return
	}

	return
}
