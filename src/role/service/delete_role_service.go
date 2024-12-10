package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *RoleService) DeleteRoleAndChild(ctx context.Context, guid, deletedBy string) (err error) {

	q := query.New(s.connectionString)

	err = q.DeleteRole(ctx, query.DeleteRoleParams{
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
