package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *RoleService) UpdateRoleAndChild(ctx context.Context, req query.UpdateRoleParams) (res json.RawMessage, err error) {

	q := query.New(s.connectionString)

	res, err = q.UpdateRoleAndChild(ctx, req)
	if err != nil {
		return
	}

	return
}

func (s *RoleService) UpdateEmployeesRole(ctx context.Context, req query.UpdateEmployeesRoleParams) (err error) {

	q := query.New(s.connectionString)

	err = q.UpdateEmployeesRole(ctx, req)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update employees role")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
