package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *MasterDataService) DeleteMasterdata(ctx context.Context, guid, deletedBy string) (err error) {

	q := query.New(s.connectionString)

	err = q.DeleteMasterdata(ctx, query.DeleteMasterDataParams{
		GUID:      guid,
		DeletedBy: deletedBy,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
