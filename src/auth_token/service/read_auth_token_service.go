package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthTokenService) ReadAuthToken(ctx context.Context, request query.GetAuthTokenParams) (authToken json.RawMessage, err error) {
	q := query.New(s.connectionString)

	authToken, err = q.GetAuthToken(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get auth token")
		err = errors.WithStack(httpservice.ErrInvalidToken)

		return
	}

	return
}
