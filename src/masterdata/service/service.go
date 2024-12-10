package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type MasterDataService struct {
	mainDB           *sql.DB
	cfg              config.KVStore
	connectionString string
}

func NewMasterDataService(
	mainDB *sql.DB,
	connectionString string,
	ccfg config.KVStore,
) *MasterDataService {
	return &MasterDataService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              ccfg,
	}
}

func (s *MasterDataService) GetDB() *sql.DB {
	return s.mainDB
}
