package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (q *Queries) GetAuthenticationByEmployeeID(ctx context.Context, employeeGuid string) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_authentication_by_employee(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		employeeGuid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get authentication by employee id")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

func (q *Queries) GetAuthenticationByForgotPasswordToken(ctx context.Context, forgotPasswordToken sql.NullString) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_forgot_token(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		sql.NullString{String: forgotPasswordToken.String, Valid: forgotPasswordToken.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get authentication by forgot password token")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

func (q *Queries) GetAuthenticationByID(ctx context.Context, guid string) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.get_authentication_by_id(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get authentication by id")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

func (q *Queries) GetAuthenticationByUsername(ctx context.Context, username string) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.GET_AUTHENTICATION_USERNAME(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		username,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get authentication by username")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

type InsertAuthenticationParams struct {
	Guid         string         `json:"guid"`
	EmployeeGuid sql.NullString `json:"employee_guid"`
	Username     string         `json:"username"`
	Password     string         `json:"password"`
	Salt         sql.NullString `json:"salt"`
	Status       string         `json:"status"`
	CreatedBy    string         `json:"created_by"`
}

func (q *Queries) InsertAuthentication(ctx context.Context, arg InsertAuthenticationParams) (response json.RawMessage, err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	var resultString string
	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			:1 := UBS_TRAINING.insert_authentication(
				:2,:3,:4,:5,:6,:7
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		sql.NullString{String: arg.EmployeeGuid.String, Valid: arg.EmployeeGuid.Valid},
		arg.Username,
		arg.Password,
		sql.NullString{String: arg.Salt.String, Valid: arg.Salt.Valid},
		arg.Status,
		arg.CreatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert authentication")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

func (q *Queries) RecordAuthenticationLastLogin(ctx context.Context, guid string) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.record_last_login(
				:1
			);
		END;
	`,
		guid,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed record authentication last login")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type UpdateAuthenticationForgotPasswordParams struct {
	ForgotPasswordToken  sql.NullString `json:"forgot_password_token"`
	ForgotPasswordExpiry sql.NullTime   `json:"forgot_password_expiry"`
	UpdatedBy            sql.NullString `json:"updated_by"`
	Guid                 string         `json:"guid"`
}

func (q *Queries) UpdateAuthenticationForgotPassword(ctx context.Context, arg UpdateAuthenticationForgotPasswordParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	formattedTokenExpire := arg.ForgotPasswordExpiry.Time.Format("02-Jan-06 03.04.05.999999 PM")

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.update_forgot_password(
				:1,
				:2,
				TO_TIMESTAMP(:3, 'DD-MON-YY HH.MI.SSXFF AM'),
				:4
			);
		END;
	`,
		arg.Guid,
		sql.NullString{String: arg.ForgotPasswordToken.String, Valid: arg.ForgotPasswordToken.Valid},
		formattedTokenExpire,
		sql.NullString{String: arg.UpdatedBy.String, Valid: arg.UpdatedBy.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update authentication forgot password")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type UpdateAuthenticationPasswordParams struct {
	Password  string         `json:"password"`
	UpdatedBy sql.NullString `json:"updated_by"`
	Guid      string         `json:"guid"`
}

func (q *Queries) UpdateAuthenticationPassword(ctx context.Context, arg UpdateAuthenticationPasswordParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.update_authentication_password(
				:1,
				:2,
				:3
			);
		END;
	`,
		arg.Guid,
		arg.Password,
		sql.NullString{String: arg.UpdatedBy.String, Valid: arg.UpdatedBy.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update authentication password")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type UpdateAuthenticationUsernameParams struct {
	Username  string         `json:"username"`
	UpdatedBy sql.NullString `json:"updated_by"`
	Guid      string         `json:"guid"`
}

func (q *Queries) UpdateAuthenticationUsername(ctx context.Context, arg UpdateAuthenticationUsernameParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.update_authentication_username(
				:1,
				:2,
				:3
			);
		END;
	`,
		arg.Guid,
		arg.Username,
		sql.NullString{String: arg.UpdatedBy.String, Valid: arg.UpdatedBy.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update authentication username")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type UpdateAuthenticationUsernameByEmployeeIDParams struct {
	Username     string         `json:"username"`
	UpdatedBy    sql.NullString `json:"updated_by"`
	EmployeeGuid sql.NullString `json:"employee_guid"`
}

func (q *Queries) UpdateAuthenticationUsernameByEmployeeID(ctx context.Context, arg UpdateAuthenticationUsernameByEmployeeIDParams) (err error) {
	db, err := sql.Open("godror", q.db)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed open connection")
		err = errors.WithStack(httpservice.ErrInternalServerError)
	}
	defer db.Close()
	// Open a new connection to the database
	err = db.Ping()
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed ping")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	// Execute the PL/SQL block
	_, err = db.Exec(`
		BEGIN
			UBS_TRAINING.update_username_by_employee(
				:1,
				:2,
				:3
			);
		END;
	`,
		sql.NullString{String: arg.EmployeeGuid.String, Valid: arg.EmployeeGuid.Valid},
		arg.Username,
		sql.NullString{String: arg.UpdatedBy.String, Valid: arg.UpdatedBy.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed update authentication username by employee id")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}
