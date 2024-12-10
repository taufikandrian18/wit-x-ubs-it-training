package service

import (
	"context"
	"encoding/json"

	query "gitlab.com/wit-id/test/src/repository/query"
)

func (s *RoleService) InsertRoleAndChild(ctx context.Context, req query.InsertRoleParams) (res json.RawMessage, err error) {

	q := query.New(s.connectionString)

	res, err = q.InsertRoleAndChild(ctx, req)
	if err != nil {
		return
	}

	return
}
