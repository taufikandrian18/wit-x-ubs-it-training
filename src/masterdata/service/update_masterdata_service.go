package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *MasterDataService) UpdateMasterData(ctx context.Context, req query.UpdateMasterdataParams) (res json.RawMessage, err error) {

	q := query.New(s.connectionString)

	res, err = q.UpdateMasterData(ctx, req)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
