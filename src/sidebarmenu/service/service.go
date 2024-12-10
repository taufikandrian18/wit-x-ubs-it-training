package service

import (
	"database/sql"

	"gitlab.com/wit-id/test/toolkit/config"
)

type SidebarMenuService struct {
	mainDB           *sql.DB
	cfg              config.KVStore
	connectionString string
}

func NewSidebarMenuService(
	mainDB *sql.DB,
	connectionString string,
	ccfg config.KVStore,
) *SidebarMenuService {
	return &SidebarMenuService{
		mainDB:           mainDB,
		connectionString: connectionString,
		cfg:              ccfg,
	}
}

func (s *SidebarMenuService) GetDB() *sql.DB {
	return s.mainDB
}
