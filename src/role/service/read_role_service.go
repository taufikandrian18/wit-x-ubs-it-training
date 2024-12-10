package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *RoleService) GetRole(ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetRole(ctx, query.GetRoleParams{
		GUID: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *RoleService) ListRole(
	ctx context.Context, request query.ListRoleParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListRole(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *RoleService) ListEmployeeByRole(ctx context.Context, req query.ListEmployeeByRoleParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListEmployeeByRole(ctx, req)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
