package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type IamAccessService struct {
	mainDB           *sql.DB
	cfg              config.KVStore
	connectionString string
}

func NewIamAccessService(
	mainDB *sql.DB,
	connectionString string,
	ccfg config.KVStore,
) *IamAccessService {
	return &IamAccessService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              ccfg,
	}
}

func (s *IamAccessService) GetDB() *sql.DB {
	return s.mainDB
}
