package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *IamHasAccessService) DeleteIamHasAccess(ctx context.Context, guid string) (err error) {

	q := query.New(s.connectionString)

	err = q.DeleteIamHasAccess(ctx, query.DeleteAndGetIamHasAccessParams{
		GUID: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
