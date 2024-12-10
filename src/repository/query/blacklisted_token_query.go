package query

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/toolkit/log"
)

type InsertBlacklistedTokenParams struct {
	Token sql.NullString `json:"token"`
	Type  sql.NullString `json:"type"`
}

func (q *Queries) InsertBlacklistedToken(ctx context.Context, arg InsertBlacklistedTokenParams) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.insert_blacklisted_token(
				:2,:3
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		sql.NullString{String: arg.Token.String, Valid: arg.Token.Valid},
		sql.NullString{String: arg.Type.String, Valid: arg.Type.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed insert blacklisted token")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}

	response = json.RawMessage(resultString)

	return
}

func (q *Queries) GetBlacklistedToken(ctx context.Context, token sql.NullString) (response json.RawMessage, err error) {
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
			:1 := UBS_TRAINING.GET_BLACKLISTED_TOKEN(
				:2
			);
		END;
	`,
		sql.Out{Dest: &resultString},
		sql.NullString{String: token.String, Valid: token.Valid},
	)

	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get blacklisted token")
		err = errors.WithStack(httpservice.ErrInternalServerError)
		return
	}
	response = json.RawMessage(resultString)

	return
}
