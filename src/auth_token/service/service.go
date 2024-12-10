package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type AuthTokenService struct {
	mainDB           *sql.DB
	connectionString string
	cfg              config.KVStore
}

func NewAuthTokenService(
	mainDB *sql.DB,
	connectionString string,
	cfg config.KVStore,
) *AuthTokenService {
	return &AuthTokenService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              cfg,
	}
}
