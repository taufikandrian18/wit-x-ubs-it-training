package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *SidebarMenuService) GetSidebarMenu(ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.GetSidebarMenu(ctx, query.GetMasterdataParams{
		Guid: guid,
	})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get masterdata")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *SidebarMenuService) ListSidebarMenu(
	ctx context.Context, request query.ListSidebarMenuParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListSidebarMenu(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *SidebarMenuService) ListMenuTree(ctx context.Context) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListMenuTree(ctx)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
