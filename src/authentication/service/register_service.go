package service

import (
	"context"
	"database/sql"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/constants"
	"gitlab.com/wit-id/test/common/utility"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) RegisterEmployee(ctx context.Context,
	emp payload.EmployeeJson, password string) (
	err error) {

	salt := utility.GenerateSalt()
	encryptedPassword := utility.HashPassword(password, salt)

	params := query.InsertAuthenticationParams{
		Guid: utility.GenerateGoogleUUID(),
		EmployeeGuid: sql.NullString{
			String: emp.GUID,
			Valid:  true},
		Username:  emp.IDCard,
		Password:  encryptedPassword,
		Status:    constants.StatusActive,
		CreatedBy: constants.CreatedByTemporaryBySystem,
		Salt:      sql.NullString{String: salt, Valid: true},
	}

	q := query.New(s.connectionString)

	_, err = q.InsertAuthentication(ctx, params)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert authentication")
		err = errors.WithStack(err)
		return
	}

	return
}
