package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *IamAccessService) GetIamAccess(ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetIamAccess(ctx, query.GetIamAccessParams{
		Guid: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *IamAccessService) ListIamAccess(
	ctx context.Context, request query.ListIamAccessParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListIamAccess(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *IamAccessService) ListSidebarAccess(ctx context.Context, iamAccessGuid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListSidebarAccess(ctx, iamAccessGuid)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list sidebar access")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *IamAccessService) GetRoleMenuAccess(ctx context.Context, iamAccessGuid string, roleGuid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetRoleSidebarAccessMenu(ctx, iamAccessGuid, roleGuid)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get role sidebar access menu")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
