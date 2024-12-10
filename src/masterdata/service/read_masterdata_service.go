package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *MasterDataService) GetMasterdata(ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetMasterdata(ctx, query.GetMasterdataParams{
		Guid: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *MasterDataService) ListMasterdata(
	ctx context.Context, request query.ListMasterdataParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListMasterdata(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
