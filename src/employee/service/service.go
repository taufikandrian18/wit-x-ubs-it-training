package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type EmployeeService struct {
	mainDB           *sql.DB
	connectionString string
	cfg              config.KVStore
}

func NewEmployeeService(
	mainDB *sql.DB,
	connectionString string,
	cfg config.KVStore,
) *EmployeeService {
	return &EmployeeService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              cfg,
	}
}
