package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *EmployeeService) DeleteEmployee(
	ctx context.Context, guid string) (err error) {
	q := query.New(s.connectionString)

	request := query.DeleteEmployeeParams{
		Guid:      guid,
		DeletedBy: constants.CreatedByTemporaryBySystem,
	}

	err = q.DeleteEmployee(ctx, request)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed delete employee")
		err = errors.WithStack(httpservice.ErrUnknownSource)
		return
	}

	return
}
