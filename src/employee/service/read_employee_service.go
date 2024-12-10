package service

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *EmployeeService) GetEmployee(
	ctx context.Context, guid string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	request := query.GetEmployeeParams{
		Guid: guid,
	}

	response, err = q.GetEmployee(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *EmployeeService) GetEmployeeByUsername(
	ctx context.Context, username string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	request := query.GetEmployeeUsernameParams{
		Username: username,
	}

	response, err = q.GetEmployeeByUsername(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *EmployeeService) GetEmployeeIsActiveByUsername(
	ctx context.Context, username string) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	request := query.GetEmployeeUsernameIsActiveParams{
		Username: username,
	}

	response, err = q.GetEmployeeIsActiveByUsername(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get employee is active")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}

func (s *EmployeeService) GetListEmployee(
	ctx context.Context, request query.ListEmployeeParams) (response json.RawMessage, err error) {
	q := query.New(s.connectionString)

	response, err = q.ListEmployee(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get list employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
