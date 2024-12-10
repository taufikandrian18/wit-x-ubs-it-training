package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *IamHasAccessService) GetIamHasAccess(ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetIamHasAccess(ctx, query.DeleteAndGetIamHasAccessParams{
		GUID: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *IamHasAccessService) ListIamHasAccess(
	ctx context.Context, request query.ListIamHasAccessParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListIamHasAccess(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
