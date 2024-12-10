package service

import (
	"context"
	"encoding/json"

	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *SidebarMenuService) UpdateSidebarMenu(ctx context.Context, req query.UpdateSidebarMenuEntity) (res json.RawMessage, err error) {

	q := query.New(s.connectionString)

	res, err = q.UpdateSidebarMenu(ctx, req)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert sidebar menu")
		return
	}

	return
}
