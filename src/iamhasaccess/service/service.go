package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type IamHasAccessService struct {
	mainDB           *sql.DB
	cfg              config.KVStore
	connectionString string
}

func NewIamHasAccessService(
	mainDB *sql.DB,
	connectionString string,
	ccfg config.KVStore,
) *IamHasAccessService {
	return &IamHasAccessService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              ccfg,
	}
}

func (s *IamHasAccessService) GetDB() *sql.DB {
	return s.mainDB
}
