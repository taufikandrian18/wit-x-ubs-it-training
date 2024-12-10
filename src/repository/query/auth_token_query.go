package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type AppKey struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
	Key  string `json:"key"`
}

type GetAuthTokenParams struct {
	TokenAuthName string `json:"token_auth_name"`
	DeviceID      string `json:"device_id"`
	DeviceType    string `json:"device_type"`
}

func (q *Queries) GetAuthToken(ctx context.Context, arg GetAuthTokenParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.get_auth_token(
				:2,:3,:4
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.TokenAuthName,
		arg.DeviceID,
		arg.DeviceType,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get auth token")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}

type InsertAuthTokenParams struct {
	TokenAuthName       string         `json:"token_auth_name"`
	DeviceID            string         `json:"device_id"`
	DeviceType          string         `json:"device_type"`
	Token               string         `json:"token"`
	TokenExpired        string         `json:"token_expired"`
	RefreshToken        string         `json:"refresh_token"`
	RefreshTokenExpired string         `json:"refresh_token_expired"`
	IsLogin             int64          `json:"is_login"`
	UserLogin           sql.NullString `json:"user_login"`
	IPAddress           string         `json:"ip_address"`
	CreatedBy           string         `json:"created_by"`
}

func (q *Queries) InsertAuthToken(ctx context.Context, arg InsertAuthTokenParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.insert_token_auth(
				:2, :3, :4, :5, TO_TIMESTAMP(:6, 'DD-MON-YY HH.MI.SSXFF AM'), :7, TO_TIMESTAMP(:8, 'DD-MON-YY HH.MI.SSXFF AM'), :9, :10, :11, :12
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		arg.TokenAuthName,
		arg.DeviceID,
		arg.DeviceType,
		arg.Token,
		arg.TokenExpired,
		arg.RefreshToken,
		arg.RefreshTokenExpired,
		arg.IsLogin,
		arg.UserLogin.String,
		arg.IPAddress,
		arg.CreatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert auth token")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

type RecordAuthTokenUserLoginParams struct {
	TokenAuthName string `json:"token_auth_name"`
	DeviceID      string `json:"device_id"`
	DeviceType    string `json:"device_type"`
	UserLogin     string `json:"user_login"`
	UpdatedBy     string `json:"updated_by"`
}

func (q *Queries) RecordAuthTokenUserLogin(ctx context.Context, arg RecordAuthTokenUserLoginParams) (err error) {
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
			UBS_TRAINING.token_user_login(
				:1,
				:2,
				:3,
				:4,
				:5
			);
		END;
	`,
		arg.TokenAuthName,
		arg.DeviceID,
		arg.DeviceType,
		arg.UserLogin,
		arg.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed record auth token user login")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type ClearAuthTokenUserLoginParams struct {
	TokenAuthName string `json:"token_auth_name"`
	DeviceID      string `json:"device_id"`
	DeviceType    string `json:"device_type"`
	UpdatedBy     string `json:"updated_by"`
}

func (q *Queries) ClearAuthTokenUserLogin(ctx context.Context, arg ClearAuthTokenUserLoginParams) (err error) {
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
			UBS_TRAINING.token_user_login(
				:1,
				:2,
				:3,
				:4
			);
		END;
	`,
		arg.TokenAuthName,
		arg.DeviceID,
		arg.DeviceType,
		arg.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed clear auth token user login")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}

type ClearAuthTokenUserLoginByUserIDParams struct {
	UserLogin string `json:"user_login"`
	UpdatedBy string `json:"updated_by"`
}

func (q *Queries) ClearAuthTokenUserLoginByUserID(ctx context.Context, arg ClearAuthTokenUserLoginByUserIDParams) (err error) {
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
			UBS_TRAINING.clear_auth_token(
				:1,
				:2
			);
		END;
	`,
		arg.UserLogin,
		arg.UpdatedBy,
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed clear auth token user login by user id")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	return
}
