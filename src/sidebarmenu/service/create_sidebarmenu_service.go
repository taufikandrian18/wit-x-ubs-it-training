package service

import (
	"context"
	"encoding/json"

	query "gitlab.com/wit-id/test/src/repository/query"
)

func (s *SidebarMenuService) InsertSidebarmenu(ctx context.Context, req query.InsertSidebarMenuEntity) (res json.RawMessage, err error) {

	q := query.New(s.connectionString)

	res, err = q.InsertSidebarMenu(ctx, req)
	if err != nil {
		return res, err
	}

	return
}
