package service

import (
	"context"
	"encoding/json"

	query "gitlab.com/wit-id/test/src/repository/query"
)

func (s *EmployeeService) CreateEmployee(
	ctx context.Context, request query.InsertEmployeeParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.InsertEmployee(ctx, request)
	if err != nil {
		return
	}

	return
}
