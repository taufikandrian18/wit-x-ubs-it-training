package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	query "gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *EmployeeService) UpdateEmployee(
	ctx context.Context, request query.UpdateEmployeeParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.UpdateEmployee(ctx, request)
	if err != nil {
		return
	}

	return
}

func (s *EmployeeService) UpdateProfilePhotoEmployee(
	ctx context.Context, request query.UpdateEmployeeProfilePhotoParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.UpdateEmployeeProfilePhoto(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
