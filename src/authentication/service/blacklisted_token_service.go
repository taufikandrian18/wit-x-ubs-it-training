package service

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/src/repository/payload"
	"gitlab.com/wit-id/test/src/repository/query"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthenticationService) IsTokenBlacklisted(ctx context.Context, token string) (
	valid bool, err error) {
	q := query.New(s.connectionString)

	blacklistedToken, err := q.GetBlacklistedToken(ctx, sql.NullString{
		String: token,
		Valid:  true})
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed get blacklisted token")
		err = errors.WithStack(httpservice.ErrDataNotFound)

		return
	}

	// Unmarshal JSON data into struct
	var apiResponse payload.TokenInfo
	err = json.Unmarshal(blacklistedToken, &apiResponse)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed unmarshall api response")
		err = errors.WithStack(httpservice.ErrInternalServerError)

		return
	}

	if apiResponse.Token.Valid {
		valid = true
	}

	return
}

func (s *AuthenticationService) Logout(ctx context.Context,
	logout payload.LogoutPayload) (
	valid bool, err error) {

	q := query.New(s.connectionString)

	_, err = q.InsertBlacklistedToken(ctx, query.InsertBlacklistedTokenParams{
		Token: sql.NullString{String: logout.AccessToken, Valid: true},
		Type:  sql.NullString{String: "access_token", Valid: true},
	})

	_, err = q.InsertBlacklistedToken(ctx, query.InsertBlacklistedTokenParams{
		Token: sql.NullString{String: logout.RefreshToken, Valid: true},
		Type:  sql.NullString{String: "refresh_token", Valid: true},
	})

	if err == nil {
		valid = true
	}

	return
}
