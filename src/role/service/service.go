package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type RoleService struct {
	mainDB           *sql.DB
	cfg              config.KVStore
	connectionString string
}

func NewRoleService(
	mainDB *sql.DB,
	connectionString string,
	ccfg config.KVStore,
) *RoleService {
	return &RoleService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              ccfg,
	}
}

func (s *RoleService) GetDB() *sql.DB {
	return s.mainDB
}
