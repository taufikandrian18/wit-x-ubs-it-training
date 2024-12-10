package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type AuthenticationService struct {
	mainDB           *sql.DB
	connectionString string
	cfg              config.KVStore
}

// NewPostCategoryService ...
func NewAuthenticationService(mainDb *sql.DB, connectionString string, cfg config.KVStore) *AuthenticationService {
	return &AuthenticationService{
		mainDB:           mainDb,
		connectionString: connectionString,
		cfg:              cfg,
	}
}
