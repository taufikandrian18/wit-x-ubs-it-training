package service

import (
	"context"

	"github.com/pkg/errors"
	"gitlab.com/wit-id/test/common/httpservice"
	"gitlab.com/wit-id/test/common/jwt"
	"gitlab.com/wit-id/test/toolkit/log"
)

func (s *AuthTokenService) ValidateAuthToken(ctx context.Context, token string) (claimsJwt jwt.RequestJWTToken, err error) {
	claimsJwt, err = jwt.ClaimsJwtToken(ctx, s.cfg, token)
	if err != nil {
		log.FromCtx(ctx).Error(err, "failed validate claims token")
		err = errors.WithStack(httpservice.ErrInvalidToken)

		return
	}

	return
}
